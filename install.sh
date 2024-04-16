#!/bin/sh

# Nonfree Repos & Backports
echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list.d/bookworm.list
echo "deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list.d/bookworm.list

echo "deb http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list.d/security.list
echo "deb-src http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list.d/security.list

echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list.d/updates.list
echo "deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list.d/updates.list

echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free-firmware" | sudo tee /etc/apt/sources.list.d/backports.list
echo "deb-src http://deb.debian.org/debian bookworm-backports main contrib non-free-firmware" | sudo tee -a /etc/apt/sources.list.d/backports.list

# PreReqs
sudo apt update
sudo apt install -y \
    meson wget build-essential ninja-build cmake-extras cmake gettext gettext-base fontconfig libfontconfig-dev libffi-dev libxml2-dev libdrm-dev libxkbcommon-x11-dev libxkbregistry-dev libxkbcommon-dev \
    libudev-dev libseat-dev seatd libxcb-dri3-dev libegl-dev libgles2-mesa-dev libegl1-mesa-dev glslang-tools libinput-bin libinput-dev libxcb-composite0-dev libavutil-dev libavcodec-dev libavformat-dev \
    libxcb-ewmh2 libxcb-present-dev libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev libxcb-xinput-dev xdg-desktop-portal-wlr libtomlplusplus3 libxcb-ewmh-dev libpixman-1-dev libgtk2.0-dev \
    libgtk-3-dev libgtkmm-3.0-dev libxcb-util-dev libxcb-util0-dev libxcb-util1 libxcb-xinerama0 libxcb-keysyms1-dev libxcb-cursor-dev libxcb-shape0-dev cmake-format pkg-config libxcb-doc libfreetype6-dev \
    libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 python3-pip libyaml-dev openssl zlib1g-dev libffi-dev libgmp-dev software-properties-common apt-transport-https intltool lsb-release ca-certificates

# Install nala and additional package
sudo apt install -y nala
sudo usermod -aG sudo $USER

# Add PHP Surya repo
echo "deb https://packages.sury.org/php/ bookworm main" | sudo tee /etc/apt/sources.list.d/sury-php.list
wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add -

# Upgrade 
sudo nala upgrade -y

# Install Sway and other packages
sudo nala install -y \
    sway pavucontrol waybar swaylock sway-backgrounds swayidle grim wl-clipboard rofi xwayland dunst xdg-desktop-portal-wlr qtwayland5 libnm-dev network-manager-gnome slurp \
    thunar btop thunar-archive-plugin thunar-volman neofetch notepadqq terminator kitty viewnior vlc ranger file-roller lxappearance mpd mpc ncmpcpp python3-pip i3ipc \
    xdg-user-dirs-gtk qt5ct network-manager-openvpn-gnome geany geany-plugins jq
	
	# Update Dirs
	xdg-user-dirs-gtk-update
	
	sudo nala install --no-install-recommends sddm -y

# Non ESR-Firefox
sudo mkdir -p /etc/apt/keyrings
# Import repository signing key
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
# Verify fingerprint
gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
# Add repository
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
# Configure package pinning
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

# Update package lists and install Firefox
sudo apt update && sudo apt install -y firefox

# Install Package for web dev
sudo nala install -y \
    code composer nginx network-manager libnss3-tools jq xsel \
    php8.1-cli php8.1-curl php8.1-mbstring php8.1-mcrypt php8.1-xml php8.1-zip php8.1-sqlite3 php8.1-mysql php8.1-pgsql php8.1-fpm \
    lxpolkit policykit-1-gnome policykit-1

# Install Theme, Icon and Font
sudo nala install -y papirus-icon-theme fonts-noto-color-emoji
sudo git clone https://github.com/EliverLara/Nordic.git /usr/share/themes/Nordic

# Remove unused package
sudo nala purge -y foot zutty

# Copy config files
mkdir -p ~/.config/autostart
mkdir -p ~/Wallpapers
mkdir -p ~/Git
cp -aR dotfiles/config/* ~/.config
cp dotfiles/config/.gtkrc-2.0 ~/
cp -aR dotfiles/backgrounds ~/Pictures
touch ~/.config/mpd/database
mkdir -p ~/.local/share/fonts
cp -aR dotfiles/fonts ~/.local/share
sudo cp -aR dotfiles/extra /usr/share
sudo cp -aR main.py /usr/bin
sudo ln -s /usr/bin/main.py /usr/bin/autotiling
sudo chmod +x /usr/bin/main.py /usr/bin/autotiling
fc-cache -vf

# Enable systemd unit
systemctl enable --user mpd

# Final upgrade
sudo nala upgrade -y && sudo nala install -y jq
