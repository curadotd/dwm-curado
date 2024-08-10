#!/bin/bash

# Function to install dependencies for Debian-based distributions
install_debian() {
    sudo apt update
    sudo apt install -y libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev cmake libxft-dev libimlib2-dev libxinerama-dev libxcb-res0-dev alsa-utils
}

# Function to install dependencies for Red Hat-based distributions
install_redhat() {
    sudo yum groupinstall -y "Development Tools"
    sudo yum install -y dbus-devel gcc git libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb libXext-devel libxcb-devel libGL-devel libEGL-devel libepoxy-devel meson ninja-build pcre2-devel pixman-devel uthash-devel xcb-util-image-devel xcb-util-renderutil-devel xorg-x11-proto-devel xcb-util-devel cmake libxft-devel libimlib2-devel libxinerama-devel libxcb-res0-devel alsa-utils
}

# Function to install dependencies for Arch-based distributions
install_arch() {
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm base-devel libconfig dbus libev libx11 libxcb libxext libgl libegl libepoxy meson pcre2 pixman uthash xcb-util-image xcb-util-renderutil xorgproto cmake libxft libimlib2 libxinerama libxcb-res xorg-xev xorg-xbacklight alsa-utils
}

# Detect the distribution and install the appropriate packages
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        debian|ubuntu)
            echo "Detected Debian-based distribution"
            install_debian
            ;;
        rhel|centos|fedora)
            echo "Detected Red Hat-based distribution"
            install_redhat
            ;;
        arch)
            echo "Detected Arch-based distribution"
            install_arch
            ;;
        *)
            echo "Unsupported distribution"
            exit 1
            ;;
    esac
else
    echo "/etc/os-release not found. Unsupported distribution"
    exit 1
fi

picom_animations() {
    # Clone the repository in the home/build directory
    mkdir -p ~/build
    if [ ! -d ~/build/picom ]; then
        if ! git clone https://github.com/FT-Labs/picom.git ~/build/picom; then
            echo "Failed to clone the repository"
            return 1
        fi
    else
        echo "Repository already exists, skipping clone"
    fi

    cd ~/build/picom || { echo "Failed to change directory to picom"; return 1; }

    # Build the project
    if ! meson setup --buildtype=release build; then
        echo "Meson setup failed"
        return 1
    fi

    if ! ninja -C build; then
        echo "Ninja build failed"
        return 1
    fi

    # Install the built binary
    if ! sudo ninja -C build install; then
        echo "Failed to install the built binary"
        return 1
    fi

    echo "Picom animations installed successfully"
}

clone_config_folders() {
    # Ask user if they want to use dotconfig files
    read -p "Do you want to use the dotconfig files? (y/n) " use_dotconfig

    if [[ $use_dotconfig =~ ^[Yy]$ ]]; then
        echo "Setting up dotconfig files..."
    
        # Check if .config folder exists
        if [ ! -d "$HOME/.config" ]; then
            echo "Creating .config folder..."
            mkdir "$HOME/.config"
        fi

        # Clone dotconfig repository
        echo "Cloning dotconfig repository..."
        git clone https://github.com/curadotd/dotconfig.git $git_path/dotconfig

        cd $git_path/dotconfig
        cp -R dunst $HOME/.config/
        cp -R kitty $HOME/.config/
        cp -R MangoHud $HOME/.config/
        cp -R rofi $HOME/.config/
        cp -R gamemode.ini $HOME/.config/
        cp -R starship.toml $HOME/.config/
        cp -R user-dirs.dirs $HOME/.config/
        cp -R user-dirs.locale $HOME/.config/

        # You may want to add additional steps here, such as:
        # - Moving files from .config/dotconfig to .config
        # - Removing the temporary dotconfig folder
        # - Setting up symlinks if necessary
    else
        echo "Skipping dotconfig setup."
    fi
}

# Call the function
clone_config_folders

# Call the function
picom_animations

echo "All dependencies installed successfully."

