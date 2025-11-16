#!/bin/bash
mkdir -p ~/.config
rm -rf ~/.vimrc ~/.vim ~/.antigen ~/.emacs.d ~/.oh-my-zsh ~/.zshrc ~/.config/nvim
curr_dir=$(cd "$(dirname "${0}")" && pwd)
ln -sf "${curr_dir}/ctags" ~/.ctags
ln -sf "${curr_dir}/zshrc" ~/.zshrc
ln -sf "${curr_dir}/.tmux".conf ~/.tmux.conf
ln -sf "${curr_dir}/gitconfig" ~/.gitconfig


if [ "$(uname)" = 'Darwin' ]; then
  brew install cmake nodejs hub git-delta curlie tmux ripgrep exa prettyping bat fzf gdu duf
fi

if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  if [ "${ID_LIKE-$ID}" = "debian" ]; then
    echo "Installing for debian"
    sudo apt-get install -y curl pv direnv jq git-hub iputils-ping unzip eza
    if [ -z "$(which go)" ]; then
      curl -sL "https://dl.google.com/go/$(curl -s "https://go.dev/dl/?mode=json" | jq -r '.[0].files[].filename | select(test("go.*.linux-amd64.tar.gz"))')" | sudo tar -C /usr/local -xz
      # shellcheck disable=SC2016
      echo 'export PATH="/usr/local/go/bin:$PATH"' | sudo tee /etc/profile.d/golang.sh
      # shellcheck disable=SC1091
      source /etc/profile.d/golang.sh
    fi
    sudo curl -o /usr/bin/prettyping -L --progress https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
    sudo chmod +x /usr/bin/prettyping
    curl -o /tmp/bat.deb -L --progress "$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r '.assets[] | select(.name | contains("amd64.deb") and contains("bat_")) | .browser_download_url')"
    sudo dpkg -i /tmp/bat.deb
    
    # shellcheck disable=SC2164
    popd
    
    sudo apt-get install -y build-essential    
  fi
  if [ "${ID}" = "arch" ]; then
    echo "Installing for arch"
    sudo pacman -S cmake python clang go tmux ctags ncurses nodejs git-delta eza ripgrep bat prettyping
  fi
fi

# shellcheck disable=SC2164
cd "${curr_dir}"
echo "Environment has been configured."
