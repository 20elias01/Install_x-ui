#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to display logo
show_logo() {
    clear
    local COLORS=("\033[31m" "\033[91m" "\033[33m" "\033[93m" "\033[32m" "\033[36m" "\033[34m" "\033[35m")
    local NC="\033[0m"  # No Color

    local num_colors=${#COLORS[@]}
    local line_num=0

    while IFS= read -r line; do
        local color_index=$((line_num % num_colors))
        echo -e "${COLORS[color_index]}$line${NC}"
        ((line_num++))
    done << "EOF"
            ██████████    █████           ███                                    
           ░░███░░░░░█   ░░███           ░░░                                     
            ░███  █ ░     ░███           ████      ██████       █████            
            ░██████       ░███          ░░███     ░░░░░███     ███░░             
            ░███░░█       ░███           ░███      ███████    ░░█████            
            ░███ ░   █    ░███      █    ░███     ███░░███     ░░░░███           
            ██████████    ███████████    █████   ░░████████    ██████            
           ░░░░░░░░░░    ░░░░░░░░░░░    ░░░░░     ░░░░░░░░    ░░░░░░           
    
  -----------   █████   █████    ███████████     ██████   █████                
  |  Local  |  ░░███   ░░███    ░░███░░░░░███   ░░██████ ░░███                 
  |         |   ░███    ░███     ░███    ░███    ░███░███ ░███                 
  |  Ipv4   |   ░███    ░███     ░██████████     ░███░░███░███                 
  |         |   ░░███   ███      ░███░░░░░░      ░███ ░░██████                 
  |  Tunnel |    ░░░█████░       ░███            ░███  ░░█████                 
  -----------      ░░███         █████           █████  ░░█████                
                    ░░░         ░░░░░           ░░░░░    ░░░░░                 

EOF
}


# Function to display the menu
show_menu() {
    show_logo
    echo -e "${GREEN}1. ${YELLOW}>>> ${BLUE}Install x-ui Panel${NC}"
    echo -e "${GREEN}0. ${YELLOW}>>> ${RED}Exit${NC}"
    echo -e ""
    echo -e "${YELLOW}==============================================${NC}"
}

# Function to detect system architecture
detect_arch() {
    ARCH=$(uname -m)
    case "${ARCH}" in
        x86_64 | x64 | amd64) XUI_ARCH="amd64" ;;
        i*86 | x86) XUI_ARCH="386" ;;
        armv8* | armv8 | arm64 | aarch64) XUI_ARCH="arm64" ;;
        armv7* | armv7) XUI_ARCH="armv7" ;;
        armv6* | armv6) XUI_ARCH="armv6" ;;
        armv5* | armv5) XUI_ARCH="armv5" ;;
        s390x) XUI_ARCH="s390x" ;;
        *) XUI_ARCH="amd64" ;;
    esac
}

# Function to install x-ui
install_xui() {
    read -p "$(echo -e "${YELLOW}Enter your desired version (e.g., 2.5.2) or press Enter for latest version: ${NC}")" VERSION
    
    if [ -z "$VERSION" ]; then
        VERSION="v2.5.2"
    else
        VERSION="v$VERSION"
    fi
    
    detect_arch
    
    echo -e "${YELLOW}\n▸ Downloading x-ui package for ${CYAN}${XUI_ARCH}${YELLOW} architecture...${NC}"
    wget https://github.com/MHSanaEi/3x-ui/releases/download/${VERSION}/x-ui-linux-${XUI_ARCH}.tar.gz -O x-ui-linux-${XUI_ARCH}.tar.gz
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Failed to download x-ui package!${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}\n▸ Preparing for installation...${NC}"
    cd /root/
    rm -rf x-ui/ /usr/local/x-ui/ /usr/bin/x-ui
    tar zxvf x-ui-linux-${XUI_ARCH}.tar.gz
    chmod +x x-ui/x-ui x-ui/bin/xray-linux-* x-ui/x-ui.sh
    cp x-ui/x-ui.sh /usr/bin/x-ui
    cp -f x-ui/x-ui.service /etc/systemd/system/
    mv x-ui/ /usr/local/
    rm x-ui-linux-${XUI_ARCH}.tar.gz
    
    echo -e "${YELLOW}\n▸ Starting and enabling x-ui service...${NC}"
    systemctl daemon-reload
    systemctl enable x-ui
    systemctl restart x-ui
    
    echo -e "${GREEN}\n✓ x-ui has been installed successfully!${NC}"
    echo -e "${CYAN}╔════════════════════════════════════════╗"
    echo -e "║   ${MAGENTA}Panel URL: ${BLUE}http://your-server-ip:54321   ${CYAN}║"
    echo -e "║   ${MAGENTA}Username: ${BLUE}admin                          ${CYAN}║"
    echo -e "║   ${MAGENTA}Password: ${BLUE}admin                          ${CYAN}║"
    echo -e "╚════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}\nTo access the menu later, run: ${GREEN}x-ui${NC}"
    echo -e "${YELLOW}==============================================${NC}"
}

# Main menu loop
while true; do
    show_menu
    read -p "$(echo -e "${GREEN}▸ Select an option [${CYAN}0${GREEN}-${CYAN}1${GREEN}]: ${NC}")" choice
    
    case $choice in
        1)
            install_xui
            read -p "$(echo -e "${YELLOW}Press ${GREEN}Enter${YELLOW} to return to menu...${NC}")"
            ;;
        0)
            echo -e "${RED}\nExiting... Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}\nInvalid option! Please try again.${NC}"
            sleep 1
            ;;
    esac
done