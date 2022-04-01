#!/bin/bash

setup_color() {
    # Only use colors if connected to a terminal
    # Thank your Oh My ZSH
    if [ -t 1 ]; then
        # https://gist.github.com/vratiu/9780109
        # https://misc.flogisoft.com/bash/tip_colors_and_formatting
        #RESET
        RESET=$(printf '\033[m')

        # Regular Colors
        BLACK=$(printf '\033[30m')
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        MAGENTA=$(printf '\033[35m')
        CYAN=$(printf '\033[36m')
        WHITE=$(printf '\033[37m')

        #BACKGROUND
        BG_BLACK=$(printf '\033[40m')
        BG_RED=$(printf '\033[41m')
        BG_GREEN=$(printf '\033[42m')
        BG_YELLOW=$(printf '\033[43m')
        BG_BLUE=$(printf '\033[44m')
        BG_MAGENTA=$(printf '\033[45m')
        BG_CYAN=$(printf '\033[46m')
        BG_WHITE=$(printf '\033[47m')

        # Formatting
        BOLD=$(printf '\033[1m')
        DIM=$(printf '\033[2m')
        ITALIC=$(printf '\033[3m')
        UNDERLINE=$(printf '\033[4m')
        BLINK=$(printf '\033[5m')
        REVERSE=$(printf '\033[7m')

    else
        RESET=""

        # Regular Colors
        BLACK=""
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        MAGENTA=""
        CYAN=""
        WHITE=""

        #BACKGROUND
        BG_BLACK=""
        BG_RED=""
        BG_GREEN=""
        BG_YELLOW=""
        BG_BLUE=""
        BG_MAGENTA=""
        BG_CYAN=""
        BG_WHITE=""

        # Formatting
        BOLD=""
        DIM=""
        ITALIC=""
        UNDERLINE=""
        BLINK=""
        REVERSE=""
    fi
}

press_any_key_to_continue() {
    read -n 1 -s -r -p "${GREEN}${BOLD}Press any key to continue${RESET}"
    printf "\n"
}

ask() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
    [yY][eE][sS] | [yY])
        $1
        ;;
    *)
        continue
        ;;
    esac
}

header() {
    clear
    echo ""
    echo "${YELLOW}#######################################################${RESET}"
    echo ""
    echo "${GREEN}  $1 ${RESET}"
    echo ""
    echo "${YELLOW}#######################################################${RESET}"
    echo ""
    echo ""
}

footer() {
    echo ""
    echo "${GREEN}${BOLD}#######################################################${RESET}"
    echo ""
    echo "${GREEN}  $1 ${RESET}"
    echo ""
    echo "${GREEN}${BOLD}#######################################################${RESET}"
    echo ""
}

launching_command() {
    echo "${YELLOW}${ITALIC}$ $1 ${RESET}"
}

red_text() {
    echo -e "${RED}${BOLD}$1${RESET}"
}

green_text() {
    echo "${GREEN}${BOLD}  $1 ${RESET}"
}

information() {
    echo "${RED}${BOLD}#######################################################${RESET}"
    echo "${RED}${BOLD}${BG_BLACK}                                                       ${RESET}"
    echo "${RED}${BOLD}  $1 ${RESET}"
    echo "${RED}${BOLD}  $2 ${RESET}"
    echo "${RED}${BOLD}${BG_BLACK}                                                       ${RESET}"
    echo "${RED}${BOLD}#######################################################${RESET}"
    press_any_key_to_continue
}

message_exit() {
    echo ""
    echo ""
    echo "${YELLOW}#######################################################${RESET}"
    echo ""
    echo "${RED}${BOLD}Thank you for using this script ${RESET}"
    echo "${YELLOW}${BOLD}you can send me one including BTC to this address : ${RESET}"
    echo "${YELLOW}${BOLD}NOT YET${RESET}"
    echo ""
    echo "${YELLOW}#######################################################${RESET}"
}

end_of_script() {
    clear
    message_exit
    sleep 7
    clear
    exit
}

warning() {
    if (whiptail --title "WARNING" --yesno "This script was created with an Alienware M15 R6, some of the options are specific to this machine but you can use this script to prepare your Kali Linux.
    
 Even if the script was done with love, the author LinkPhoenix of this one is in no way responsible for what you will do in it and is released from all responsibility on the results of this one.
 
 By selecting YES you accept it is conditions otherwise please select NO!" 15 100); then
        echo "User selected Yes, exit status was $?."
    else
        echo "User selected No, exit status was $?."
        exit
    fi
}

CheckNvidiaFirmware() {
    header "Check Nvidia Bios Version for Nvidia GForce RTX 3060 Mobile"
    press_any_key_to_continue

    if hash nvidia-smi 2>/dev/null; then
        green_text "Command 'nvidia-smi' found, I can check your Nvidia Bios Version"
        press_any_key_to_continue
    else
        red_text "Command 'nvidia-smi' not found, I need it for check your Nvidia Bios Version"
        while true; do
            echo "sudo $package_manager install nvidia-smi"
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                launching_command "sudo $package_manager install nvidia-smi" && sudo $package_manager install nvidia-smi
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    NvidiaFirmwareVersion=$(nvidia-smi -i 0 -q | grep "VBIOS" | awk '{print $NF}')
    IFS='.' read -ra ADDR <<<"$NvidiaFirmwareVersion"

    information "Nvidia Bios Version : $NvidiaFirmwareVersion" "I will check if your version is up to date"

    if [[ "${ADDR[4]}" > "46" ]]; then
        green_text "Your firmware version : $NvidiaFirmwareVersion"
        green_text "it seems to be up to date and you should have no problem with the HDMI and USB-C port"
        press_any_key_to_continue
    else
        red_text "Your firmware version : $NvidiaFirmwareVersion"
        red_text "It looks like your firmware version of your Nvidia graphics card is not up to date"
        red_text "and you may be experiencing issues with the HDMI and USB-C port."
        red_text "https://www.dell.com/support/home/fr-fr/drivers/driversdetails?driverid=xhk39&oscode=naa&productcode=alienware-m15-r6-laptop"
        press_any_key_to_continue
    fi
}

install_nala() {
    header "Nala Installation"

    press_any_key_to_continue

    if hash nala 2>/dev/null; then
        green_text "Nala is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'nala' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    launching_command "echo 'deb [arch=amd64,arm64,armhf] http://deb.volian.org/volian/ scar main' | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list"
    echo "deb [arch=amd64,arm64,armhf] http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
    launching_command "wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg >/dev/null"
    wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg >/dev/null
    launching_command "sudo $package_manager update && sudo $package_manager install nala -y"
    sudo $package_manager update && sudo $package_manager install nala -y

    footer "NALA INSTALLATION END"

    press_any_key_to_continue

}

install_nvidia_driver() {
    header "Install Nvidia Driver for Nvidia GForce RTX 3060 Mobile"
    press_any_key_to_continue

    red_text "You must first update your entire system before installing the driver."
    red_text "If it's not done, don't start this step and come back when it's done"
    red_text "Also check if you have the correct version of the Bios for your Nvidia GPU"

    while true; do
        read -p "Do you want continue? (y/N)" yn
        case $yn in
        [Yy]*)
            break
            ;;
        [Nn]* | '')
            menu_whiptail
            ;;
        *) echo "Please answer yes or no." ;;
        esac
    done

    information "Install tools detect Nvidia Bios Version" "More informations : https://www.kali.org/docs/general-use/install-nvidia-drivers-on-kali-linux/"
    launching_command "sudo $package_manager install nvidia-detect clinfo hashcat"
    sudo $package_manager install nvidia-detect clinfo hashcat
    launching_command "sudo $package_manager install nvidia-driver nvidia-cuda-toolkit"
    sudo $package_manager install nvidia-driver nvidia-cuda-toolkit

    footer "NVIDIA DRIVER INSTALLATION END"

    press_any_key_to_continue

}

install_visualcode() {
    header "Install Visual Code"
    press_any_key_to_continue

    if hash code 2>/dev/null; then
        green_text "Visual Code is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'code' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    launching_command "sudo $package_manager install wget gpg"
    sudo $package_manager install wget gpg
    launching_command "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    launching_command "sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/"
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    launching_command "sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'"
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    launching_command "rm -f packages.microsoft.gpg"
    rm -f packages.microsoft.gpg
    launching_command "sudo $package_manager update && sudo $package_manager install code -y"
    sudo $package_manager update && sudo $package_manager install code -y

    footer "VISUAL CODE INSTALLATION END"

    press_any_key_to_continue

}

setup_package_manager() {
    if hash nala 2>/dev/null; then
        while true; do
            green_text "Nala is detected"
            read -p "Do you want to use it as package manager in this script ? (y/N)" yn
            case $yn in
            [Yy]*)
                package_manager=nala
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    else
        package_manager=apt
    fi
}

fix_libwacom_common() {
    header "Fix libwacom9 : Depends: libwacom-common (= 2.1.0-2) but 1.12-1 is to be installed"
    press_any_key_to_continue

    launching_command "sudo $package_manager install firmware-linux"
    sudo $package_manager install firmware-linux

    footer "FIX FOR LIBWACOM9 END"

    press_any_key_to_continue

}

fix_missing_bin() {
    header "Fix adlp_dmc_ver2_12.bin missing"
    press_any_key_to_continue

    launching_command "cd ~"
    cd ~
    launching_command "mkdir linux-firmware-missing"
    mkdir linux-firmware-missing
    launching_command "cd linux-firmware-missing"
    cd linux-firmware-missing
    launching_command "wget https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/adlp_dmc_ver2_12.bin"
    wget https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/i915/adlp_dmc_ver2_12.bin
    launching_command "sudo cp ./adlp_* /lib/firmware/i915"
    sudo cp ./adlp_* /lib/firmware/i915
    launching_command "sudo update-initramfs -k all -c"
    sudo update-initramfs -k all -c
    launching_command "cd ~ && rm -rf linux-firmware-missing"
    cd ~ && rm -rf linux-firmware-missing

    footer "FIX adlp_dmc_ver2_12.bin MISSING END"

    press_any_key_to_continue

}

install_packages() {
    if hash resize 2>/dev/null; then
        eval $(resize)
        PACKAGES=$(whiptail --title "By LinkPhoenix" --checklist \
            "Choose the packages you want to install" $(($LINES - 10)) $(($COLUMNS - 50)) $(($LINES - 20)) \
            "vlc" "Multimedia player and streamer" OFF \
            "neofetch" "Shows Linux System Information with Distribution Logo" OFF \
            "thunderbird" "mail/news client with RSS, chat and integrated spam filter support" OFF \
            "bleachbit" "delete unnecessary files from the system" OFF \
            "i8kutils" "Fan control for Dell laptops" OFF \
            "calibre" "powerful and easy to use e-book manager" OFF \
            "piper" "GTK application to configure gaming devices" OFF \
            "qbittorrent" "bittorrent client based on libtorrent-rasterbar with a Qt5 GUI" OFF \
            "libreoffice" "office productivity suite " OFF \
            "htop" "interactive processes viewer" OFF \
            "btop" "Modern and colorful command line resource monitor that shows usage and stats" OFF \
            "iftop" "displays bandwidth usage information on an network interface" OFF \
            "atop" "Monitor for system resources and process activity" OFF \
            "filezilla" "Full-featured graphical FTP/FTPS/SFTP client" OFF \
            "telegram-desktop" "fast and secure messaging application" OFF \
            "network-manager-openvpn" "network management framework (OpenVPN plugin core)" OFF \
            "network-manager-l2tp" "network management framework (L2TP plugin core)" OFF \
            "network-manager-pptp" "network management framework (PPTP plugin core)" OFF 3>&2 2>&1 1>&3)
    else
        PACKAGES=$(whiptail --title "By LinkPhoenix" --checklist --menu "By LinkPhoenix" \
            "Choose the packages you want to install" 25 78 16 \
            "vlc" "Multimedia player and streamer" OFF \
            "neofetch" "Shows Linux System Information with Distribution Logo" OFF \
            "thunderbird" "mail/news client with RSS, chat and integrated spam filter support" OFF \
            "bleachbit" "delete unnecessary files from the system" OFF \
            "i8kutils" "Fan control for Dell laptops" OFF \
            "calibre" "powerful and easy to use e-book manager" OFF \
            "piper" "GTK application to configure gaming devices" OFF \
            "qbittorrent" "bittorrent client based on libtorrent-rasterbar with a Qt5 GUI" OFF \
            "libreoffice" "office productivity suite " OFF \
            "htop" "interactive processes viewer" OFF \
            "btop" "Modern and colorful command line resource monitor that shows usage and stats" OFF \
            "iftop" "displays bandwidth usage information on an network interface" OFF \
            "atop" "Monitor for system resources and process activity" OFF \
            "filezilla" "Full-featured graphical FTP/FTPS/SFTP client" OFF \
            "telegram-desktop" "fast and secure messaging application" OFF \
            "network-manager-openvpn" "network management framework (OpenVPN plugin core)" OFF \
            "network-manager-l2tp" "network management framework (L2TP plugin core)" OFF \
            "network-manager-pptp" "network management framework (PPTP plugin core)" OFF 3>&2 2>&1 1>&3)
    fi

    for element in ${PACKAGES[@]}; do
        element="${element:1:-1}"
        launching_command "sudo $package_manager install $element"
        sudo $package_manager install $element
    done

    footer "PACKAGES INSTALLATION END"

    press_any_key_to_continue

}

install_spotify() {
    header "Install Spotify"
    press_any_key_to_continue

    if hash spotify 2>/dev/null; then
        green_text "Spotify is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'spotify' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    #https://community.spotify.com/t5/Desktop-Linux/New-install-instructions-for-Debian-Ubuntu/td-p/5228160
    launching_command "curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo gpg --dearmor -o /usr/share/keyrings/spotify-archive-keyring.gpg"
    curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo gpg --dearmor -o /usr/share/keyrings/spotify-archive-keyring.gpg
    launching_command "echo deb [signed-by=/usr/share/keyrings/spotify-archive-keyring.gpg] http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list"
    echo "deb [signed-by=/usr/share/keyrings/spotify-archive-keyring.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    launching_command "sudo $package_manager update && sudo $package_manager install spotify-client -y"
    sudo $package_manager update && sudo $package_manager install spotify-client -y

    footer "SPOTIFY CLIENT INSTALLATION END"

    press_any_key_to_continue
}

install_insync() {
    header "Install Insync"
    press_any_key_to_continue

    if hash insync 2>/dev/null; then
        green_text "Insync is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'insync' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    #https://community.spotify.com/t5/Desktop-Linux/New-install-instructions-for-Debian-Ubuntu/td-p/5228160
    launching_command "gpg --keyserver keyserver.ubuntu.com --recv-keys ACCAF35C"
    gpg --keyserver keyserver.ubuntu.com --recv-keys ACCAF35C
    launching_command "gpg --export ACCAF35C | sudo tee /usr/share/keyrings/insync.gpg"
    gpg --export ACCAF35C | sudo tee /usr/share/keyrings/insync.gpg
    launching_command "echo 'deb [signed-by=/usr/share/keyrings/insync.gpg] http://apt.insync.io/debian bullseye non-free contrib' | sudo tee /etc/apt/sources.list.d/insync.list"
    echo "deb [signed-by=/usr/share/keyrings/insync.gpg] http://apt.insync.io/debian bullseye non-free contrib" | sudo tee /etc/apt/sources.list.d/insync.list
    launching_command "sudo $package_manager update && sudo $package_manager install insync -y"
    sudo $package_manager update && sudo $package_manager install insync -y

    footer "INSYNC INSTALLATION END"

    press_any_key_to_continue
}

install_cups() {
    header "Install cups"
    press_any_key_to_continue

    if hash cups 2>/dev/null; then
        green_text "cups is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'cups' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    #https://community.spotify.com/t5/Desktop-Linux/New-install-instructions-for-Debian-Ubuntu/td-p/5228160
    launching_command "sudo $package_manager install cups"
    sudo $package_manager install cups
    launching_command "sudo systemctl start cups"
    sudo systemctl start cups
    launching_command "sudo systemctl enable cups"
    sudo systemctl enable cups
    launching_command "sudo $package_manager install cups-backend-bjnp"
    sudo $package_manager install cups-backend-bjnp

    footer "CUPS INSTALLATION END"

    press_any_key_to_continue
}

install_driver_rtl88xxau() {
    header "realtek-rtl88xxau-dkms for ALFA AWUS036ACH"
    press_any_key_to_continue

    launching_command "sudo $package_manager install realtek-rtl88xxau-dkms -y"
    sudo $package_manager install realtek-rtl88xxau-dkms

    footer "DRIVER FOR ALF WIFI INSTALLATION END"

    press_any_key_to_continue
}

install_flux() {
    header "Install Flux GUI"
    press_any_key_to_continue

    if hash fluxgui 2>/dev/null; then
        green_text "fluxgui is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'fluxgui' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    launching_command "sudo $package_manager install git python-appindicator python-xdg python-pexpect python-gconf python-gtk2 python-glade2 libxxf86vm1 libcanberra-gtk-module"
    sudo $package_manager install git python-appindicator python-xdg python-pexpect python-gconf python-gtk2 python-glade2 libxxf86vm1 libcanberra-gtk-module
    launching_command "cd /tmp"
    cd /tmp
    launching_command "git clone 'ttps://github.com/xflux-gui/fluxgui.git)'"
    git clone "https://github.com/xflux-gui/fluxgui.git"
    launching_command "cd fluxgui"
    cd fluxgui
    launching_command "sudo ./setup.py install --record installed.txt"
    sudo ./setup.py install --record installed.txt
    launching_command "cd ~"
    cd ~

    footer "FLUX INSTALLATION END"

    press_any_key_to_continue
}

check_rvm_as_function() {
    #https://stackoverflow.com/a/19954212/12317483
    # Load RVM into a shell session *as a function*
    # Loading RVM *as a function* is mandatory
    # so that we can use 'rvm use <specific version>'
    echo "${YELLOW}I will try to add RVM as Source${RESET}"
    if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
        # First try to load from a user install
        source "$HOME/.rvm/scripts/rvm"
        echo "${GREEN}using user install $HOME/.rvm/scripts/rvm${RESET}"
    elif [[ -s "/usr/local/rvm/scripts/rvm" ]]; then
        # Then try to load from a root install
        source "/usr/local/rvm/scripts/rvm"
        echo "${GREEN}using root install /usr/local/rvm/scripts/rvm${RESET}"
    else
        echo "${RED}ERROR: An RVM installation was not found.${RESET}"
    fi
}

install_rvm_and_ruby() {
    header "Install RVM and stable RUBY"
    press_any_key_to_continue

    if hash rvm 2>/dev/null; then
        green_text "rvm is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'rvm' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    launching_command "sudo $package_manager install apt-transport-https ca-certificates gnupg2 curl"
    sudo $package_manager install apt-transport-https ca-certificates gnupg2 curl
    launching_command "curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -"
    curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
    launching_command "curl -sSL https://get.rvm.io | bash -s stable --ruby"
    curl -sSL https://get.rvm.io | bash -s stable --ruby
    check_rvm_as_function
    while true; do
        red_text "Rvm install Ruby stable Release"
        read -p "Do you want to install Ruby 3.1.1? (y/N)" yn
        case $yn in
        [Yy]*)
            break
            ;;
        [Nn]* | '')
            menu_whiptail
            ;;
        *) echo "Please answer yes or no." ;;
        esac
    done

    launching_command "rvm install 3.1.1"
    rvm install 3.1.1
    while true; do
        red_text "RVM don't use yet the last Ruby version"
        read -p "Config RVM for use Ruby 3.1.1 as default? (y/N)" yn
        case $yn in
        [Yy]*)
            break
            ;;
        [Nn]* | '')
            menu_whiptail
            ;;
        *) echo "Please answer yes or no." ;;
        esac
    done

    launching_command "rvm use --default 3.1.1"
    rvm use --default 3.1.1

    footer "RVM AND RUBY INSTALLATION END"

    press_any_key_to_continue
}

install_gems() {
    if hash resize 2>/dev/null; then
        #gem_array=(rspec rubocop pry dotenv twitter nokogiri launchy watir selenium-webdriver json colorize sinatra shotgun csv rack sqlite3 faker)
        eval $(resize)
        GEMS=$(whiptail --title "By LinkPhoenix" --checklist \
            "Choose the gem(s) you want to install" $(($LINES - 10)) $(($COLUMNS - 50)) $(($LINES - 20)) \
            "rails" "Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity." OFF \
            "bundler" "Bundler manages an application's dependencies through its entire life, across many machines, systematically and repeatably" OFF \
            "jekyll" "Jekyll is a simple, blog aware, static site generator." OFF \
            "rspec" "BDD for Ruby" OFF \
            "rubocop" "RuboCop is a Ruby code style checking and code formatting tool." OFF \
            "pry" "Pry is a runtime developer console and IRB alternative with powerful introspection capabilities." OFF \
            "dotenv" "Loads environment variables from $(.env)." OFF \
            "nokogiri" "Nokogiri makes it easy and painless to work with XML and HTML from Ruby." OFF \
            "launchy" "Launchy is helper class for launching cross-platform applications in a fire and forget manner. " OFF \
            "watir" "Watir stands for Web Application Testing In Ruby It facilitates the writing of automated tests by mimicing the behavior of a user interacting with a website." OFF \
            "selenium-webdriver" "Selenium implements the W3C WebDriver protocol to automate popular browsers. It aims to mimic the behaviour of a real user as it interacts with the application's HTML." OFF \
            "json" "This is a JSON implementation as a Ruby extension in C." OFF \
            "bundler" "Bundler manages an application's dependencies through its entire life, across many machines, systematically and repeatably" OFF \
            "sinatra" "Sinatra is a DSL for quickly creating web applications in Ruby with minimal effort." OFF \
            "shotgun" "Reloading Rack development server" OFF \
            "csv" "The CSV library provides a complete interface to CSV files and data." OFF \
            "rack" "Rack provides a minimal, modular and adaptable interface for developing web applications in Ruby." OFF \
            "sqlite3" "This module allows Ruby programs to interface with the SQLite3 database engine (http://www.sqlite.org)." OFF \
            "faker" "Faker, a port of Data::Faker from Perl, is used to easily generate fake data: names, addresses, phone numbers, etc." OFF 3>&2 2>&1 1>&3)

    else
        GEMS=$(whiptail --title "By LinkPhoenix" --checklist --menu "By LinkPhoenix" \
            "Choose the gem(s) you want to install" 25 78 16 \
            "rails" "Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity." OFF \
            "bundler" "Bundler manages an application's dependencies through its entire life, across many machines, systematically and repeatably" OFF \
            "jekyll" "Jekyll is a simple, blog aware, static site generator." OFF \
            "rspec" "BDD for Ruby" OFF \
            "rubocop" "RuboCop is a Ruby code style checking and code formatting tool." OFF \
            "pry" "Pry is a runtime developer console and IRB alternative with powerful introspection capabilities." OFF \
            "dotenv" "Loads environment variables from $(.env)." OFF \
            "nokogiri" "Nokogiri makes it easy and painless to work with XML and HTML from Ruby." OFF \
            "launchy" "Launchy is helper class for launching cross-platform applications in a fire and forget manner. " OFF \
            "watir" "Watir stands for Web Application Testing In Ruby It facilitates the writing of automated tests by mimicing the behavior of a user interacting with a website." OFF \
            "selenium-webdriver" "Selenium implements the W3C WebDriver protocol to automate popular browsers. It aims to mimic the behaviour of a real user as it interacts with the application's HTML." OFF \
            "json" "This is a JSON implementation as a Ruby extension in C." OFF \
            "bundler" "Bundler manages an application's dependencies through its entire life, across many machines, systematically and repeatably" OFF \
            "sinatra" "Sinatra is a DSL for quickly creating web applications in Ruby with minimal effort." OFF \
            "shotgun" "Reloading Rack development server" OFF \
            "csv" "The CSV library provides a complete interface to CSV files and data." OFF \
            "rack" "Rack provides a minimal, modular and adaptable interface for developing web applications in Ruby." OFF \
            "sqlite3" "This module allows Ruby programs to interface with the SQLite3 database engine (http://www.sqlite.org)." OFF \
            "faker" "Faker, a port of Data::Faker from Perl, is used to easily generate fake data: names, addresses, phone numbers, etc." OFF 3>&2 2>&1 1>&3)
    fi

    for element in ${GEMS[@]}; do
        element="${element:1:-1}"
        launching_command "gem install $element"
        gem install $element
    done

}

install_brave_browser() {
    header "Install Brave Browser"
    press_any_key_to_continue

    if hash brave-browser 2>/dev/null; then
        green_text "brave-browser is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'brave-browser' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    launching_command "sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    launching_command "echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list"
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    launching_command "sudo $package_manager update && sudo $package_manager install brave-browser"
    sudo $package_manager update && sudo $package_manager install brave-browser

    footer "BRAVE BROWSER INSTALLATION END"

    press_any_key_to_continue
}

install_discord() {
    header "Install Discord"
    press_any_key_to_continue

    if hash discord 2>/dev/null; then
        green_text "discord is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'discord' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    launching_command "wget https://dl.discordapp.net/apps/linux/0.0.17/discord-0.0.17.deb"
    wget https://dl.discordapp.net/apps/linux/0.0.17/discord-0.0.17.deb
    launching_command "sudo $package_manager install discord-0.0.17.deb"
    sudo $package_manager install discord-0.0.17.deb
    launching_command "sudo rm discord-0.0.17.deb"
    sudo rm discord-0.0.17.deb

    footer "DISCORD INSTALLATION END"

    press_any_key_to_continue
}

install_whatsapp_for_linux() {
    header "Install whatsapp-for-linux"

    if hash whatsapp-for-linux 2>/dev/null; then
        green_text "whatsapp-for-linux is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        press_any_key_to_continue
        while true; do
            red_text "Command 'whatsapp-for-linux' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    launching_command "cd ~"
    cd ~
    launching_command "git clone https://github.com/eneshecan/whatsapp-for-linux.git"
    git clone https://github.com/eneshecan/whatsapp-for-linux.git
    launching_command "cd whatsapp-for-linux.git"
    cd whatsapp-for-linux.git
    launching_command "sudo $package_manager install cmake libayatana-appindicator3-dev libgtkmm-3.0-dev libwebkit2gtk-4.0-dev"
    sudo $package_manager install cmake libayatana-appindicator3-dev libgtkmm-3.0-dev libwebkit2gtk-4.0-dev
    launching_command "dpkg-buildpackage -uc -us -ui"
    sudo dpkg-buildpackage -uc -us -ui
    launching_command "cd ~"
    cd ~
    red_text "if 'dpkg-buildpackage -uc -us -ui' fail your need launch it manualy in the folder"
    red_text "cd $HOME/whatsapp-for-linux"
    red_text "dpkg-buildpackage -uc -us -ui"
    red_text "cd $HOMME"
    red_text "sudo $package_manager install whatsapp-for-linux_[Version_Number]_amd64.deb"

    footer "WHATSSAPP-FOR-LINUX INSTALLATION END"

    press_any_key_to_continue
}

install_signal() {
    header "Install Signal"
    press_any_key_to_continue

    if hash signal-desktop 2>/dev/null; then
        green_text "Singnal is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'signal-desktop' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    launching_command "wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor >signal-desktop-keyring.gpg"
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor >signal-desktop-keyring.gpg
    launching_command "cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg >/dev/null"
    cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg >/dev/null
    launching_command "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list"
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
    launching_command "sudo $package_manager update && sudo nala install signal-desktop"
    sudo $package_manager update && sudo nala install signal-desktop

    footer "SIGNAL INSTALLATION END"

    press_any_key_to_continue
}

install_gnome_shell_extension_installer() {
    header "Install Gnome Extension Installer"
    press_any_key_to_continue

    if [[ -s "/usr/bin/gnome-shell-extension-installer" ]]; then
        green_text "gnome-shell-extension-installer is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'gnome-shell-extension-installer' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    launching_command "wget -O gnome-shell-extension-installer 'https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer'"
    wget -O gnome-shell-extension-installer "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
    launching_command "chmod +x gnome-shell-extension-installer"
    chmod +x gnome-shell-extension-installer
    launching_command "sudo mv gnome-shell-extension-installer /usr/bin/"
    sudo mv gnome-shell-extension-installer /usr/bin/

    footer "GNOME SHELL EXTENSION INSTALLER INSTALLATION END"

    press_any_key_to_continue
}

install_skype() {
    header "Install Skype"
    press_any_key_to_continue

    if hash skypeforlinux 2>/dev/null; then
        green_text "Skype is already installed"
        press_any_key_to_continue
        menu_whiptail
    else
        while true; do
            red_text "Command 'skypeforlinux' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                break
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    launching_command "cd /tmp"
    cd /tmp
    launching_command "wget -O https://go.skype.com/skypeforlinux-64.deb"
    wget -O https://go.skype.com/skypeforlinux-64.deb
    launching_command "sudo $package_manager install skypeforlinux-64.deb"
    sudo $package_manager install skypeforlinux-64.deb
    launching_command "cd ~"
    cd ~

    footer "SKYPE INSTALLATION END"

    press_any_key_to_continue
}

install_gnome_extension() {
    header "Install Gnome Extension"
    press_any_key_to_continue

    if [[ -s "/usr/bin/gnome-shell-extension-installer" ]]; then
        continue
    else
        while true; do
            red_text "Command 'gnome-shell-extension-installer' not found."
            read -p "Do you want to install it? (y/N)" yn
            case $yn in
            [Yy]*)
                install_gnome_shell_extension_installer
                ;;
            [Nn]* | '')
                menu_whiptail
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi

    GEXTENSIONVERSION=$(gnome-extensions version)
    if hash resize 2>/dev/null; then
        eval $(resize)
        whiptail --title "Gnome Extension Version" --msgbox "Your Gnome Extension is : $GEXTENSIONVERSION" $(($LINES - 10)) $(($COLUMNS - 50)) $(($LINES - 20))
    else
        whiptail --title "Gnome Extension Version" --msgbox "Your Gnome Extension is : $GEXTENSIONVERSION" 8 78
    fi

    if hash resize 2>/dev/null; then
        eval $(resize)
        GEXTENSION=$(whiptail --title "By LinkPhoenix" --checklist \
            "Choose gnome extension(s) you want to install" $(($LINES - 10)) $(($COLUMNS - 50)) $(($LINES - 20)) \
            "120" "System-monitor : Display system information in GNOME Shell status bar, such as memory, CPU, disk and battery usages, network rates…" OFF \
            "3994" "All IP Addresses : Show IP addresses for LAN, WAN IPv6 and VPN in the GNOME panel. Click on the address to cycle trough different interfaces." OFF \
            "3737" "Hue Lights : This extension controls Philips Hue compatible lights using Philips Hue Bridge on your local network, it also allows controlling Philips Hue Sync Box." OFF \
            "2983" "IP Finder : Displays useful information about your public IP Address" OFF \
            "4506" "Simple System Monitor : Show current CPU usage, memory usage and net speed on panel.
For best experience, please use monospaced font." OFF \
            "4919" "Weather : Animation Weather. " OFF 3>&2 2>&1 1>&3)

    else
        GEXTENSION=$(whiptail --title "By LinkPhoenix" --checklist --menu "By LinkPhoenix" \
            "Choose gnome extension(s) you want to install" 25 78 16 \
            "120" "System-monitor : Display system information in GNOME Shell status bar, such as memory, CPU, disk and battery usages, network rates…" OFF \
            "3994" "All IP Addresses : Show IP addresses for LAN, WAN IPv6 and VPN in the GNOME panel. Click on the address to cycle trough different interfaces." OFF \
            "3737" "Hue Lights : This extension controls Philips Hue compatible lights using Philips Hue Bridge on your local network, it also allows controlling Philips Hue Sync Box." OFF \
            "2983" "IP Finder : Displays useful information about your public IP Address" OFF \
            "4506" "Simple System Monitor : Show current CPU usage, memory usage and net speed on panel.
For best experience, please use monospaced font." OFF \
            "4919" "Weather : Animation Weather. " OFF 3>&2 2>&1 1>&3)
    fi

    while true; do
        read -p "Do you want I try enable extensions? (y/N)" yn
        case $yn in
        [Yy]*)
            gnome-extensions enable system-monitor@paradoxxx.zero.gmail.com
            gnome-extensions enable gnome-extension-all-ip-addresses@havekes.eu
            gnome-extensions enable hue-lights@chlumskyvaclav.gmail.com
            gnome-extensions enable IP-Finder@linxgem33.com
            gnome-extensions enable weather@eexpss.gmail.com
            gnome-extensions enable ssm-gnome@lgiki.net
            red_text "You need restart Gnome Shell"
            red_text "Press Alt+F2, r, Enter to restart GNOME Shell. Your extensions should appear at the top bar in a second."
            footer "GNOME EXTENSION INSTALLER INSTALLATION END"

            press_any_key_to_continue
            ;;
        [Nn]* | '')
            menu_whiptail
            ;;
        *) echo "Please answer yes or no." ;;
        esac
    done

    footer "GNOME EXTENSION INSTALLER INSTALLATION END"

    press_any_key_to_continue
}

menu_whiptail() {
    while [ 1 ]; do

        if hash resize 2>/dev/null; then
            eval $(resize)
            CHOICE=$(whiptail --title "Installfest - The Hacking Project" --menu "By LinkPhoenix" --nocancel --notags --clear $(($LINES - 10)) $(($COLUMNS - 50)) $(($LINES - 20)) \
                "1)" "Exit" \
                "2)" "fix libwacom common error" \
                "3)" "Fix Missing Bin" \
                "4)" "install Nala" \
                "5)" "Check Nvidia Firmware" \
                "6)" "Install Nvidia Driver" \
                "7)" "Install Packages" \
                "8)" "Install Visual Code" \
                "9)" "Install Discord" \
                "10)" "Install Flux" \
                "11)" "Install Whatssapp For Linux" \
                "12)" "Install Signal" \
                "13)" "Install Insync" \
                "14)" "Install Cups" \
                "15)" "Install Spotify" \
                "16)" "Install RVM and Ruby" \
                "17)" "Install Gems" \
                "18)" "Install Alfa's Driver" \
                "19)" "Install Brave Browser" \
                "20)" "Install Gnome Shell Extension" \
                "21)" "Install Gnome Extension" \
                "22)" "Install Skype" 3>&2 2>&1 1>&3)
        else
            CHOICE=$(whiptail --title "Installfest - The Hacking Project" --menu "By LinkPhoenix" --nocancel --notags --clear 25 78 16 \
                "1)" "Exit" \
                "2)" "fix libwacom common error" \
                "3)" "Fix Missing Bin" \
                "4)" "install Nala" \
                "5)" "Check Nvidia Firmware" \
                "6)" "Install Nvidia Driver" \
                "7)" "Install Packages" \
                "8)" "Install Visual Code" \
                "9)" "Install Discord" \
                "10)" "Install Flux" \
                "11)" "Install Whatssapp For Linux" \
                "12)" "Install Signal" \
                "13)" "Install Insync" \
                "14)" "Install Cups" \
                "15)" "Install Spotify" \
                "16)" "Install RVM and Ruby" \
                "17)" "Install Gems" \
                "18)" "Install Alfa's Driver" \
                "19)" "Install Brave Browser" \
                "20)" "Install Gnome Shell Extension" \
                "21)" "Install Gnome Extension" \
                "22)" "Install Skype" 3>&2 2>&1 1>&3)
        fi
        case $CHOICE in
        "1)") end_of_script ;;
        "2)") fix_libwacom_common ;;
        "3)") fix_missing_bin ;;
        "4)") install_nala ;;
        "5)") CheckNvidiaFirmware ;;
        "6)") install_nvidia_driver ;;
        "7)") install_packages ;;
        "8)") install_visualcode ;;
        "9)") install_discord ;;
        "10)") install_flux ;;
        "11)") install_whatsapp_for_linux ;;
        "12)") install_signal ;;
        "13)") install_insync ;;
        "14)") install_cups ;;
        "15)") install_spotify ;;
        "16)") install_rvm_and_ruby ;;
        "17)") install_gems ;;
        "18)") install_driver_rtl88xxau ;;
        "19)") install_brave_browser ;;
        "20)") install_gnome_shell_extension_installer ;;
        "21)") install_gnome_extension ;;
        "22)") install_skype ;;
        esac
    done
    exit
}

main() {
    setup_color

    header="
###################################################################
#                                                                 #
#      This script has been tested with this configuration        #
#                                                                 #
###################################################################
"

    i=0
    while [ $i -lt ${#header} ]; do
        sleep 0.0000001
        echo -ne "${RED}${BOLD}${header:$i:1}${RESET}" | tr -d '%'
        ((i++))
    done

    config="


..............                                     
            ..,;:ccc,.                             
          ......''';lxO.                           OS: Kali GNU/Linux Rolling x86_64 
.....''''..........,:ld;                           Host: Alienware m15 R6
           .';;;:::;,,.x,                          Kernel: 5.16.0-kali6-amd64 
      ..'''.            0Xxoc:,.  ...              DE: GNOME 41.4
  ....                ,ONkc;,;cokOdc',.            CPU: 11th Gen Intel i7-11800H (16) @ 4.600GHz 
 .                   OMo           ':ddo.          GPU: NVIDIA GeForce RTX 3060 Mobile / Max-Q 
                    dMc               :OO;         GPU: Intel TigerLake-H GT1 [UHD Graphics] 
                    0M.                 .:o.       
                    ;Wd                            
                     ;XO,                          
                       ,d0Odlc;,..                 
                           ..',;:cdOOd::,.         
                                    .:d;.':;.      
                                       'd,  .'     
                                         ;l   ..   
                                          .o       
                                            c      
                                            .'
                                             .                                           
                                                                                              
"
    i=0
    while [ $i -lt ${#config} ]; do
        sleep 0.0000001
        echo -ne "${GREEN}${BOLD}${config:$i:1}${RESET}" | tr -d '%'
        ((i++))
    done

    info_script="
Script information

Author              LinkPhoenix
Github              https://github.com/LinkPhoenix
URL Repository      https://github.com/LinkPhoenix/AlienWareM15R6-Kali-Linux-initial-setup

"

    i=0
    while [ $i -lt ${#info_script} ]; do
        sleep 0.001
        echo -ne "${YELLOW}${BOLD}${info_script:$i:1}${RESET}" | tr -d "%"
        ((i++))
    done

    press_any_key_to_continue
    warning

    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        clear
        setup_package_manager
        menu_whiptail
    else
        whiptail --title "Not a linux operating system" --msgbox "This script is only compatible with a linux distribution (linux-gnu)
    
                The script will not execute" 12 78
    fi
}

main
