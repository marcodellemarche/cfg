#!/bin/bash
set -e

echo "1. Checking out cfg repository"

if [ -d "$HOME"/.cfg ]; then
    echo "1.1 Directory "$HOME"/.cfg exists"
    cd "$HOME"/.cfg
    remote=$(git remote -v | head -n 1 | awk -F ' ' '{print $2}')

    if [ "$remote" = "https://github.com/marcodellemarche/cfg.git" ]; then
        echo "1.2 Directory already contains the repo"
    else
        echo "Directory "$HOME"/.cfg is either not a repo or the wrong one"
	exit 1
    fi
else
    echo "1.1 Directory "$HOME"/.cfg is empty, cloning repo"
    git clone --bare https://github.com/marcodellemarche/cfg.git "$HOME"/.cfg
fi

function config {
    /usr/bin/git --git-dir="$HOME"/.cfg/ --work-tree="$HOME" $@
}

# Checking out repo files
config checkout

# Avoid showing the entire home as untracked
config config status.showUntrackedFiles no


echo "2. Initialising submodules"

# Submodules
config submodule update --init


echo "3. Cloning custom ZSH things into .oh-my-zsh folder"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}/themes/powerlevel10k || true
git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z || true
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true
git clone https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin || true

echo "4. Installing ZSH via APT"

sudo apt install -y zsh


echo "5. Make ZSH the default shell"

sudo chsh -s $(which zsh)


echo "6. Installing tools"

echo "6.1. LSD"
# https://github.com/Peltoche/lsd

if ! [ -x "$(command -v lsd)" ]; then
    lsd_version=0.23.1

    wget https://github.com/Peltoche/lsd/releases/download/$(echo $lsd_version)/lsd_$(echo $lsd_version)_amd64.deb
    
    sudo dpkg -i lsd_$(echo $lsd_version)_amd64.deb

    rm lsd_$(echo $lsd_version)_amd64.deb

    echo -e "\tLSD successfully installed"
else
    echo -e "\tLSD already installed"
fi


echo "6.2. xclip"
# https://avilpage.com/2014/04/access-clipboard-from-terminal-in.html

if ! [ -x "$(command -v xclip)" ]; then
    sudo apt install -y xclip

    echo -e "\txclip successfully installed"
else
    echo -e "\txclip already installed"
fi


echo "6.3. pyenv"
# https://github.com/pyenv/pyenv#automatic-installer


if ! [ -x "$(command -v pyenv)" ]; then
    curl https://pyenv.run | bash

    echo -e "\tpyenv successfully installed"
else
    echo -e "\tpyenv already installed"
fi

echo "6.4. Go"
# https://go.dev/doc/install


if ! [ -x "$(command -v go)" ]; then
    go_version=1.19.4

    wget https://go.dev/dl/go$(echo $go_version).linux-amd64.tar.gz

    rm -rf /usr/local/go && tar -C /usr/local -xzf go$(echo $go_version).linux-amd64.tar.gz

    echo -e "\tGo successfully installed"
else
    echo -e "\tGo already installed"
fi

echo "6.5. tmux"
# https://github.com/tmux/tmux/wiki/Installing


if ! [ -x "$(command -v tmux)" ]; then
    sudo apt install -y tmux

    echo -e "\ttmux successfully installed"
else
    echo -e "\ttmux already installed"
fi

echo "6.6. Rust and Cargo"
# https://www.rust-lang.org/tools/install


if ! [ -x "$(command -v cargo)" ] && ! [ -x "$(command -v rustc)" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    echo -e "\tRust and Cargo successfully installed"
else
    echo -e "\tRust (or Cargo) already installed"
fi

echo "6.6. Node and N"
# https://www.rust-lang.org/tools/install


if ! [ -x "$(command -v node)" ]; then
    curl -L https://bit.ly/n-install | bash

    n install 16

    echo -e "\Node and N successfully installed"
else
    echo -e "\tNode already installed"
fi

echo "6.7. fzf"
# https://github.com/junegunn/fzf#using-git


if ! [ -x "$(command -v fzf)" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

    ~/.fzf/install --bin

    echo -e "\Node and N successfully installed"
else
    echo -e "\tfzf already installed"
fi
