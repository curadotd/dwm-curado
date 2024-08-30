#!/bin/bash

wget https://raw.githubusercontent.com/curadotd/linux_workstation_build/main/install_dwm

chmod +x install_dwm

# Function to install brightnessctl
install_brightnessctl() {
    if command -v pacman &> /dev/null; then
        # Arch Linux
        sudo pacman -S --needed brightnessctl
    elif command -v apt-get &> /dev/null; then
        # Debian/Ubuntu-based systems
        sudo apt-get update
        sudo apt-get install brightnessctl
    elif command -v dnf &> /dev/null; then
        # Rocky Linux
        sudo dnf install brightnessctl
    else
        echo "Unsupported package manager. Please install brightnessctl manually."
        return 1
    fi
}

# Check if the system is a laptop
if [ -d "/sys/class/power_supply" ]; then
    # System is likely a laptop
    echo "Laptop detected. Installing brightnessctl and adding brightness controls to DWM config."
    
    # Install brightnessctl
    install_brightnessctl

    # Append new key bindings to config.def.h
    sed -i '/{ MODKEY,                       XK_e,          spawn,                  SHCMD ("thunar")}, \/\/ open thunar file manager/a \
    { 0,                            0x1008ff03,    spawn,                  SHCMD ("brightnessctl s 10%-")}, // decrease backlight brightness\
    { 0,                            0x1008ff02,    spawn,                  SHCMD ("brightnessctl s +10%")}, // increase backlight brightness\
    { 0,                            0x1008ff8e,    spawn,                  SHCMD ("brightnessctl s 10%-")}, // decrease backlight brightness' /path/to/dwm/config.def.h
    
    echo "Brightness controls added to DWM config."
else
    echo "This doesn't appear to be a laptop. Skipping brightness control configuration."
fi

# Recompile and reinstall DWM
./install_dwm
