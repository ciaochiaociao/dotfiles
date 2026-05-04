-- Window Layout Manager
-- Save and restore window positions relative to their screen.
-- Positions stored as fractions (0-1) so they adapt to any display.
-- Screens matched by orientation (vertical/standard/wide/ultrawide),
-- falling back to left-to-right index when multiple screens share orientation.
-- AppleScript used ONLY for Chrome tab URLs (Hammerspoon can't access those).

require("hs.ipc")

-- Auto-reload config on changes
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- Defeating paste blocking
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "V", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

local layoutFile = os.getenv("HOME") .. "/.hammerspoon/window_layouts.json"

-- Read all saved layouts from disk. Returns a table { name -> layoutObj }
local function readLayouts()
    local f = io.open(layoutFile, "r")
    if not f then return {} end
    local data = hs.json.decode(f:read("*a"))
    f:close()
    return data or {}
end

-- Write all layouts to disk
local function writeLayouts(layouts)
    local f = io.open(layoutFile, "w")
    f:write(hs.json.encode(layouts, true))
    f:close()
end

-----------------------------------------------------------------------
-- Screen helpers
-----------------------------------------------------------------------
local function orderedScreens()
    local screens = hs.screen.allScreens()
    table.sort(screens, function(a, b) return a:frame().x < b:frame().x end)
    return screens
end

local function screenIndex(screen)
    for i, s in ipairs(orderedScreens()) do
        if s:id() == screen:id() then return i end
    end
    return 1
end

local function screenByIndex(idx)
    local screens = orderedScreens()
    return screens[math.max(1, math.min(idx, #screens))]
end

-- Get the screen the user is currently looking at (where the focused window is)
local function focusedScreen()
    local win = hs.window.focusedWindow()
    if win then return win:screen() end
    return hs.screen.mainScreen()
end

-- Classify a screen's aspect ratio
local function screenOrientation(screen)
    local mode = screen:currentMode()
    local w = mode.w
    local h = mode.h
    local ratio = w / h

    if ratio < 1 then
        return "vertical"
    elseif ratio >= 2.3 then
        return "ultrawide"
    elseif ratio >= 1.7 then
        return "wide"
    else
        return "standard"
    end
end

-- Find the best current screen for a saved window entry.
-- Match by orientation first, then by index among screens of that orientation.
local function resolveScreen(entry)
    local screens = orderedScreens()

    -- Collect screens matching this orientation
    local matches = {}
    for _, s in ipairs(screens) do
        if screenOrientation(s) == entry.screenOrientation then
            table.insert(matches, s)
        end
    end

    if #matches > 0 then
        -- Use orientationIdx to pick the right one among same-orientation screens
        local idx = entry.orientationIdx or 1
        idx = math.max(1, math.min(idx, #matches))
        return matches[idx]
    end

    -- No orientation match — fall back to screenIdx
    return screenByIndex(entry.screenIdx)
end

-----------------------------------------------------------------------
-- Chrome URL helpers (the only part that needs AppleScript)
-----------------------------------------------------------------------

-- Fetch all Chrome tab URLs in one call. Returns { [tabTitle] = url }
local function getChromeTabURLs()
    local chrome = hs.application.get("Google Chrome")
    if not chrome then return {} end

    local ok, result = hs.osascript.applescript([[
        tell application "Google Chrome"
            set output to {}
            repeat with w in windows
                repeat with t in tabs of w
                    set end of output to title of t & "|||" & URL of t
                end repeat
            end repeat
            set AppleScript's text item delimiters to linefeed
            return output as text
        end tell
    ]])
    local urls = {}
    if ok and result and result ~= "" then
        for line in result:gmatch("[^\n]+") do
            local title, url = line:match("^(.+)|||(.+)$")
            if title and url then urls[title] = url end
        end
    end
    return urls
end

-- Match a Hammerspoon window title (e.g. "Page - Google Chrome - Profile")
-- to a Chrome tab title (e.g. "Page") and return the URL.
local function findChromeURL(hsTitle, chromeURLs)
    for tabTitle, url in pairs(chromeURLs) do
        if hsTitle:find(tabTitle, 1, true) then
            return url
        end
    end
    return nil
end

-----------------------------------------------------------------------
-- Capture current window positions
-----------------------------------------------------------------------
local function captureWindows(targetScreen)
    local chromeURLs = getChromeTabURLs()
    local windows = {}

    -- Track how many windows we've seen per orientation, so we can assign
    -- orientationIdx per screen (not per window)
    local screenOrientationIdx = {}  -- screenId -> orientationIdx

    -- Pre-compute orientationIdx for each screen
    local orientationCount = {}  -- orientation -> count so far
    for _, s in ipairs(orderedScreens()) do
        local orient = screenOrientation(s)
        orientationCount[orient] = (orientationCount[orient] or 0) + 1
        screenOrientationIdx[s:id()] = orientationCount[orient]
    end

    for _, win in ipairs(hs.window.allWindows()) do
        local app = win:application()
        if not app then goto continue end

        local title = win:title() or ""
        local bundleID = app:bundleID() or ""
        local appName = app:name() or ""

        -- Skip windows with no title or from Hammerspoon itself
        if title == "" or bundleID == "org.hammerspoon.Hammerspoon" then
            goto continue
        end

        local screen = win:screen()

        -- If saving single monitor, skip windows not on that screen
        if targetScreen and screen:id() ~= targetScreen:id() then
            goto continue
        end

        local sf = screen:frame()
        local wf = win:frame()

        local entry = {
            appName           = appName,
            bundleID          = bundleID,
            title             = title,
            screenIdx         = screenIndex(screen),
            screenOrientation = screenOrientation(screen),
            orientationIdx    = screenOrientationIdx[screen:id()],
            relX = (wf.x - sf.x) / sf.w,
            relY = (wf.y - sf.y) / sf.h,
            relW = wf.w / sf.w,
            relH = wf.h / sf.h,
        }

        -- For Chrome windows, also save the tab URL so we can reopen if needed
        if bundleID == "com.google.Chrome" then
            entry.chromeURL = findChromeURL(title, chromeURLs)
        end

        table.insert(windows, entry)
        ::continue::
    end

    return windows
end

-- Build metadata about the screens used in a layout
local function buildScreenInfo(targetScreen)
    local info = {}

    if targetScreen then
        -- Single monitor save
        local mode = targetScreen:currentMode()
        info.mode = "single"
        info.screens = {{
            index = screenIndex(targetScreen),
            orientation = screenOrientation(targetScreen),
            width = mode.w,
            height = mode.h,
        }}
    else
        -- All monitors save
        local screens = orderedScreens()
        info.mode = #screens == 1 and "single" or "multi"
        info.screens = {}
        for i, s in ipairs(screens) do
            local mode = s:currentMode()
            table.insert(info.screens, {
                index = i,
                orientation = screenOrientation(s),
                width = mode.w,
                height = mode.h,
            })
        end
    end

    return info
end

-----------------------------------------------------------------------
-- Save (with scope and name prompts)
-----------------------------------------------------------------------
local function save()
    -- Ask: current monitor or all monitors?
    local button = hs.dialog.blockAlert(
        "Save Layout",
        "Which windows do you want to save?",
        "Current Monitor",
        "All Monitors",
        "NSWarningAlertStyle"
    )

    local targetScreen = nil
    if button == "Current Monitor" then
        targetScreen = focusedScreen()
    end

    local windows = captureWindows(targetScreen)
    if #windows == 0 then
        hs.alert.show("No windows found")
        return
    end

    local btn, name = hs.dialog.textPrompt(
        "Save Layout",
        "Enter a name for this layout:",
        "", "Save", "Cancel"
    )
    if btn == "Cancel" or not name or name == "" then
        hs.alert.show("Save cancelled")
        return
    end

    local layouts = readLayouts()
    layouts[name] = {
        screenInfo = buildScreenInfo(targetScreen),
        windows = windows,
    }
    writeLayouts(layouts)

    local scope = targetScreen and "current monitor" or "all monitors"
    hs.alert.show("Saved \"" .. name .. "\" (" .. #windows .. " windows, " .. scope .. ")")
end

-----------------------------------------------------------------------
-- Apply a layout
-----------------------------------------------------------------------
local function targetFrameOnScreen(entry, screen)
    local max = screen:frame()
    local f = {}
    f.x = max.x + entry.relX * max.w
    f.y = max.y + entry.relY * max.h
    f.w = entry.relW * max.w
    f.h = entry.relH * max.h
    return f
end

-- Resolve target frame: dispatch to a specific screen, or match by orientation
local function resolveTargetFrame(entry, dispatchScreen)
    if dispatchScreen then
        return targetFrameOnScreen(entry, dispatchScreen)
    else
        return targetFrameOnScreen(entry, resolveScreen(entry))
    end
end

-- Find an existing non-Chrome window matching a layout entry
local function findMatchingWindow(entry, currentWindows, usedWindows)
    -- Match by bundleID + exact title
    local candidates = currentWindows[entry.bundleID] or {}
    for _, c in ipairs(candidates) do
        if not usedWindows[c.win:id()] and c.title == entry.title then
            return c.win
        end
    end

    -- Partial title match fallback
    for _, c in ipairs(candidates) do
        if not usedWindows[c.win:id()] and c.title:find(entry.title:sub(1, 30), 1, true) then
            return c.win
        end
    end

    return nil
end

-- Build lookup tables for current non-Chrome windows
local function buildWindowIndex()
    local currentWindows = {}
    for _, win in ipairs(hs.window.allWindows()) do
        local app = win:application()
        if app then
            local bid = app:bundleID() or ""
            if bid ~= "com.google.Chrome" then
                if not currentWindows[bid] then currentWindows[bid] = {} end
                table.insert(currentWindows[bid], { win = win, title = win:title() or "" })
            end
        end
    end
    return currentWindows
end

-- dispatchScreen: if provided, all windows are placed on this screen
--                 if nil, windows are matched to screens by orientation
local function applyLayout(windows, dispatchScreen)
    local currentWindows = buildWindowIndex()
    local usedWindows = {}
    local restored = 0
    local opened = 0

    for _, entry in ipairs(windows) do
        local tf = resolveTargetFrame(entry, dispatchScreen)

        if entry.bundleID == "com.google.Chrome" and entry.chromeURL then
            -- Chrome: always open a new window
            local x2 = math.floor(tf.x + tf.w)
            local y2 = math.floor(tf.y + tf.h)
            hs.osascript.applescript(string.format([[
                tell application "Google Chrome"
                    make new window
                    set URL of active tab of front window to "%s"
                    set bounds of front window to {%d, %d, %d, %d}
                end tell
            ]], entry.chromeURL:gsub('"', '\\"'),
                math.floor(tf.x), math.floor(tf.y), x2, y2))
            opened = opened + 1
        else
            -- Non-Chrome: find and reposition existing window
            local win = findMatchingWindow(entry, currentWindows, usedWindows)
            if win then
                usedWindows[win:id()] = true
                win:setFrame(tf, 0)
                restored = restored + 1
            end
        end
    end

    return restored, opened
end

-----------------------------------------------------------------------
-- Load (with chooser picker, then monitor selection)
-----------------------------------------------------------------------
local function load()
    local layouts = readLayouts()
    if not next(layouts) then
        hs.alert.show("No saved layouts")
        return
    end

    -- Build choices for the picker
    local choices = {}
    for name, layoutObj in pairs(layouts) do
        local windows = layoutObj.windows
        local screenInfo = layoutObj.screenInfo

        -- Summarize apps in this layout
        local apps = {}
        for _, entry in ipairs(windows) do
            apps[entry.appName] = (apps[entry.appName] or 0) + 1
        end
        local parts = {}
        for app, count in pairs(apps) do
            table.insert(parts, app .. " (" .. count .. ")")
        end
        table.sort(parts)

        -- Build subtitle with screen info
        local subtitle = #windows .. " windows: " .. table.concat(parts, ", ")
        if screenInfo then
            local orientations = {}
            for _, s in ipairs(screenInfo.screens) do
                table.insert(orientations, s.orientation .. " " .. s.width .. "x" .. s.height)
            end
            subtitle = "[" .. screenInfo.mode .. ": " .. table.concat(orientations, ", ") .. "] " .. subtitle
        end

        table.insert(choices, {
            text = name,
            subText = subtitle,
            layoutName = name,
        })
    end

    table.sort(choices, function(a, b) return a.text < b.text end)

    local chooser = hs.chooser.new(function(choice)
        if not choice then return end

        local layoutObj = layouts[choice.layoutName]
        local windows = layoutObj.windows

        -- Ask where to dispatch the layout
        local screens = orderedScreens()
        local screenLabels = {}
        for i, s in ipairs(screens) do
            local mode = s:currentMode()
            table.insert(screenLabels, i .. ": " .. s:name() .. " (" .. mode.w .. "x" .. mode.h .. ", " .. screenOrientation(s) .. ")")
        end

        local button = hs.dialog.blockAlert(
            "Load Layout: " .. choice.layoutName,
            "Where to place the windows?\n\nAvailable monitors:\n" .. table.concat(screenLabels, "\n"),
            "Current Monitor",
            "Auto (match by orientation)",
            "NSWarningAlertStyle"
        )

        local dispatchScreen = nil
        if button == "Current Monitor" then
            dispatchScreen = focusedScreen()
        end
        -- "Auto" leaves dispatchScreen nil → resolveScreen matches by orientation

        local restored, opened = applyLayout(windows, dispatchScreen)
        hs.alert.show("\"" .. choice.layoutName .. "\": restored " .. restored .. ", opened " .. opened)
    end)

    chooser:choices(choices)
    chooser:placeholderText("Choose a layout to restore...")
    chooser:show()
end

-- Keybindings
hs.hotkey.bind({"ctrl", "cmd"}, "S", save)
hs.hotkey.bind({"ctrl", "cmd"}, "L", load)

hs.alert.show("Hammerspoon loaded")
