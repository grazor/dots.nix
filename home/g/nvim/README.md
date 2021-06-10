## After installation

Requirements

```
pacman -S neovim python-neovim ctags fzf ripgrep nodejs
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo tags >> ~/.gitignore
echo .env >> ~/.gitignore

echo alias :e=nvim >> ~/.zshrc
echo alias vim=nvim >> ~/.zshrc
echo alias :q=exit >> ~/.zshrc
```


```
:PlugInstall
```

## Per project requirements

To make coc find both project modules and env modules place a `.env` file to the root of projects:

```
PYTHONPATH="src/project:src/another"
```

## Features

### Python 

- [X] Python general settings
- [X] Python completion
- [X] Python virtualenv
- [X] Python isort and black
- [X] Python auto import
- [X] Python flake8
- [X] Python goto definition
- [-] Python find usage
- [-] Python snippets

### Files

- [X] Fuzzy emacs-like find file
- [X] Fuzzy search
- [X] Open file relative to current
- [-] File browser
- [X] FS actions

### Visual

- [X] Theme
- [ ] Borders
- [ ] Side icons
- [X] Syntax highlight
- [X] Modeline status / git / blame // acpi / time
- [X] Git diffs

### Editing

- [X] AceJump
- [X] Surround
- [X] JK esc
- [X] CoC integrations (red, gitlab, ...)

### Windows and buffers

- [X] Buffer list
- [X] Switching windows
