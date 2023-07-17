#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update system first
apt update -y
apt upgrade -y

# Install xgetres
git clone https://github.com/tamirzb/xgetres.git
cd xgetres
make
make install

# Clone suckless tools
git clone https://github.com/javiergarcferrer/suckless ~/.suckless

cd ~/.suckless
# symlink /etc/sudoers and /etc/apt/sources.list file
# assuming these files are present in the current directory
ln -s $(pwd)/sudoers /etc/sudoers
ln -s $(pwd)/sources.list /etc/apt/sources.list
ln -s $(pwd)/.Xresources ~/.Xresources
ln -s $(pwd)/.xinitrc ~/.xinitrc
ln -s $(pwd)/.xbindkeysrc ~/.xbindkeysrc

# Update system again after replacing sources
apt update -y

# Install packages in apt.run (assuming you have a file with a list of packages)
while read package; do apt install -y $package; done < apt.list

# Install Discord
wget -O discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
dpkg -i discord.deb
apt-get install -f

# Remove Mozilla Firefox
apt remove -y firefox-esr

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
apt-get install -f

git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.sh
./vcpkg integrate install
./vcpkg install jsoncpp

# Build dwmipcpp, dwm, st, dmenu and polybar-dwm-module
cd ~/.suckless/dwmipcpp
make clean install

cd ~/.suckless/dwm
make clean install

cd ~/.suckless/st
make clean install

# Register st terminal
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/st 50

# Select your terminal
sudo update-alternatives --config x-terminal-emulator

cd ~/.suckless/dmenu
make clean install

cd ~/.suckless/polybar-dwm-module
./build.sh

# Install ZSH and make it the default shell
apt install -y zsh
chsh -s $(which zsh)

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k for Oh-My-Zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Define your new theme
new_theme='ZSH_THEME="powerlevel10k/powerlevel10k"'

# Find and replace the theme in .zshrc
sed -i.bak 's/^ZSH_THEME=.*$/'"$new_theme"'/' ~/.zshrc

# Reload the ZSH configuration
source ~/.zshrc

# Install Nerd Fonts
git clone --depth=1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
./install.sh

# Download and install Neovim from the GitHub release page
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod a+x nvim.appimage
mv nvim.appimage /usr/bin/vim

# Install NvChad
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1

# Remove GNOME
apt remove -y gnome-shell

# The end of the script
echo "The script has finished. Your system is now riced!. Please reboot"
