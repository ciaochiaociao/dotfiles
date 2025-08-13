## Prerequisites:
```
# (Ubuntu)

sudo apt-get build-dep vim
```

## Clone from VCS
```
git clone https://github.com/vim/vim.git  # clone from git


## clone from Mercurial (`hg`)
hg clone https://bitbucket.org/vim-mirror/vim  # Suggested by http://vim.org
hg clone https://vim.googlecode.com/hg/ vim  # Suggested by https://www.youtube.com/watch?v=YhqsjUUHj6g

cd vim/src
```

### Installation Suggested by http://vim.org
```
make
```
```
make WITH_PYTHON=1 WITH_RUBY=YES install clean  # Installation with python interpreter  # https://forums.freebsd.org/threads/how-to-enable-python-interpreter-of-vim.30103/
```

### Installation Suggested by https://www.youtube.com/watch?v=YhqsjUUHj6g
```
./configure --enable-pythoninterp --with-features=huge --prefix="$HOME/opt/vim"
make && make install
mkdir -p "$HOME/bin"
cd "$HOME/bin"
ln -s "$HOME/opt/vim/bin/vim"
which vim
vim --version
```

### Install pixbuf-based theme for GTK+ 2 in Ubuntu for GUI user

```
sudo apt-get install gtk2-engines-pixbuf  # pixbuf-based theme for GTK+ 2. GTK+ is a multi-platform toolkit for creating graphical user interfaces.
```
