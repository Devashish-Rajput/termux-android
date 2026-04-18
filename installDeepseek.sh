#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  💻 DEV LAB - VS Code + Browsers (Mali GPU Ready)
#  
#  For: Lenovo Idea Tab Pro (Dimensity 8300, Mali-G615)
#  Features:
#  - GPU acceleration via Panfrost + Zink
#  - XFCE4 desktop + audio
#  - VS Code, Firefox, Chromium
#  - No bloat / security tools
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=12
CURRENT_STEP=0

# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

# ============== PROGRESS FUNCTIONS ==============
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    FILLED=$((PERCENT / 5))
    EMPTY=$((20 - FILLED))
    BAR="${GREEN}"
    for ((i=0; i<FILLED; i++)); do BAR+="█"; done
    BAR+="${GRAY}"
    for ((i=0; i<EMPTY; i++)); do BAR+="░"; done
    BAR+="${NC}"
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📊 PROGRESS: Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r  ${YELLOW}⏳${NC} ${message} ${CYAN}${spin:$i:1}${NC}  "
        sleep 0.1
    done
    wait $pid
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} ${message}                    \n"
    else
        printf "\r  ${RED}✗${NC} ${message} ${RED}(failed)${NC}     \n"
    fi
    return $exit_code
}

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}
    (yes | pkg install $pkg -y > /dev/null 2>&1) &
    spinner $! "Installing ${name}..."
}

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════╗
    ║                                      ║
    ║   💻  DEV LAB (Mali GPU Ready)  💻   ║
    ║                                      ║
    ║     VS Code • Firefox • Chromium     ║
    ║                                      ║
    ╚══════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo ""
}

# ============== DEVICE DETECTION (Mali) ==============
detect_device() {
    echo -e "${PURPLE}[*] Detecting your device...${NC}"
    echo ""
    DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
    DEVICE_BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Unknown")
    ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    CPU_ABI=$(getprop ro.product.cpu.abi 2>/dev/null || echo "arm64-v8a")
    HARDWARE=$(getprop ro.hardware 2>/dev/null | tr '[:upper:]' '[:lower:]')
    
    echo -e "  ${GREEN}📱${NC} Device: ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL}${NC}"
    echo -e "  ${GREEN}🤖${NC} Android: ${WHITE}${ANDROID_VERSION}${NC}"
    echo -e "  ${GREEN}⚙️${NC}  CPU: ${WHITE}${CPU_ABI}${NC}"
    
    # Detect Mali GPU (MediaTek Dimensity)
    if [[ "$HARDWARE" == *"mt"* ]] || [[ "$DEVICE_MODEL" == *"Tab Pro"* ]]; then
        GPU_TYPE="mali"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Mali (MediaTek) - Panfrost + PanVK${NC}"
    else
        GPU_TYPE="unknown"
        echo -e "  ${YELLOW}🎮${NC} GPU: ${WHITE}Unknown, using software rendering${NC}"
    fi
    echo ""
    sleep 1
}

# ============== STEP 1: UPDATE SYSTEM ==============
step_update() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating system...${NC}\n"
    (yes | pkg update -y > /dev/null 2>&1) &
    spinner $! "Updating package lists"
    (yes | pkg upgrade -y > /dev/null 2>&1) &
    spinner $! "Upgrading packages"
}

# ============== STEP 2: REPOSITORIES ==============
step_repos() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding repos...${NC}\n"
    install_pkg "x11-repo" "X11 Repository"
    install_pkg "tur-repo" "TUR Repository (VS Code, Chromium)"
}

# ============== STEP 3: TERMUX-X11 ==============
step_x11() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Termux-X11...${NC}\n"
    install_pkg "termux-x11-nightly" "Termux-X11 Server"
    install_pkg "xorg-xrandr" "XRandR"
}

# ============== STEP 4: XFCE4 DESKTOP ==============
step_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing XFCE4 desktop...${NC}\n"
    install_pkg "xfce4" "XFCE4 Desktop"
    install_pkg "xfce4-terminal" "Terminal"
    install_pkg "thunar" "File Manager"
    install_pkg "mousepad" "Text Editor"
}

# ============== STEP 5: GPU ACCELERATION (Mali) ==============
step_gpu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Configuring GPU (Panfrost + Zink)...${NC}\n"
    
    # Base Mesa and Zink
    install_pkg "mesa-zink" "Mesa Zink (OpenGL over Vulkan)"
    install_pkg "vulkan-loader-android" "Vulkan Loader"
    
    if [ "$GPU_TYPE" == "mali" ]; then
        # Try PanVK Vulkan driver for Mali (if available)
        if pkg list-all | grep -q mesa-vulkan-icd-panfrost; then
            install_pkg "mesa-vulkan-icd-panfrost" "PanVK (Mali Vulkan)"
        else
            echo -e "  ${YELLOW}⚠ PanVK not found, using software Vulkan${NC}"
            install_pkg "mesa-vulkan-icd-swrast" "Software Vulkan"
        fi
    else
        install_pkg "mesa-vulkan-icd-swrast" "Software Vulkan"
    fi
    
    # Create GPU config for Mali/Zink
    mkdir -p ~/.config
    cat > ~/.config/devlab-gpu.sh << 'GPUEOF'
# Mali GPU optimizations
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export ZINK_DESCRIPTORS=lazy
# For PanVK
export VK_ICD_FILENAMES=/data/data/com.termux/files/usr/share/vulkan/icd.d/panfrost_icd.armv7l.json 2>/dev/null
GPUEOF
    echo -e "  ${GREEN}✓${NC} GPU config created"
    
    # Source in .bashrc
    if ! grep -q "devlab-gpu.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/devlab-gpu.sh 2>/dev/null' >> ~/.bashrc
    fi
}

# ============== STEP 6: AUDIO ==============
step_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing audio...${NC}\n"
    install_pkg "pulseaudio" "PulseAudio"
}

# ============== STEP 7: BROWSERS & VS CODE ==============
step_apps() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing apps...${NC}\n"
    install_pkg "firefox" "Firefox Browser"
    install_pkg "chromium" "Chromium Browser"
    install_pkg "code-oss" "VS Code"
    install_pkg "git" "Git"
    install_pkg "wget" "Wget"
    install_pkg "curl" "cURL"
}

# ============== STEP 8: LAUNCHER SCRIPTS ==============
step_launchers() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating launchers...${NC}\n"
    
    # Main Desktop Launcher (with audio fix)
    cat > ~/start-desktop.sh << 'LAUNCHER'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🚀 Starting Dev Lab Desktop..."
echo ""
source ~/.config/devlab-gpu.sh 2>/dev/null
# Kill old sessions
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null
# Audio setup
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1
# Start X11
termux-x11 :0 -ac &
sleep 3
export DISPLAY=:0
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱 Open Termux-X11 app to see desktop"
echo "  🖥️  Running XFCE4 with GPU acceleration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exec startxfce4
LAUNCHER
    chmod +x ~/start-desktop.sh
    echo -e "  ${GREEN}✓${NC} Created ~/start-desktop.sh"
    
    # Stop script
    cat > ~/stop-desktop.sh << 'STOP'
#!/data/data/com.termux/files/usr/bin/bash
echo "Stopping desktop..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
echo "Done."
STOP
    chmod +x ~/stop-desktop.sh
    echo -e "  ${GREEN}✓${NC} Created ~/stop-desktop.sh"
}

# ============== STEP 9: DESKTOP SHORTCUTS ==============
step_shortcuts() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating desktop shortcuts...${NC}\n"
    mkdir -p ~/Desktop
    
    # VS Code
    cat > ~/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Comment=Code Editor
Exec=code-oss --no-sandbox
Icon=code-oss
Type=Application
Categories=Development;
EOF
    
    # Firefox
    cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Type=Application
Categories=Network;
EOF
    
    # Chromium
    cat > ~/Desktop/Chromium.desktop << 'EOF'
[Desktop Entry]
Name=Chromium
Comment=Web Browser
Exec=chromium --no-sandbox
Icon=chromium
Type=Application
Categories=Network;
EOF
    
    # Terminal
    cat > ~/Desktop/Terminal.desktop << 'EOF'
[Desktop Entry]
Name=Terminal
Comment=XFCE Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Type=Application
Categories=System;
EOF
    
    # File Manager
    cat > ~/Desktop/FileManager.desktop << 'EOF'
[Desktop Entry]
Name=File Manager
Comment=Thunar
Exec=thunar
Icon=system-file-manager
Type=Application
Categories=System;
EOF
    
    chmod +x ~/Desktop/*.desktop
    echo -e "  ${GREEN}✓${NC} Shortcuts created"
}

# ============== STEP 10: CLEANUP & FINAL ==============
step_final() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Finalizing...${NC}\n"
    # Fix any broken deps
    (pkg clean > /dev/null 2>&1) &
    spinner $! "Cleaning package cache"
}

# ============== COMPLETION ==============
show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'
    ╔════════════════════════════════════════════════════╗
    ║                                                    ║
    ║           ✅  INSTALLATION COMPLETE!  ✅           ║
    ║                                                    ║
    ║      VS Code + Firefox + Chromium are ready       ║
    ║                                                    ║
    ╚════════════════════════════════════════════════════╝
COMPLETE
    echo -e "${NC}"
    echo -e "${WHITE}📱 Your Dev Lab is ready!${NC}\n"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}🚀 START DESKTOP:${NC}   ${GREEN}bash ~/start-desktop.sh${NC}"
    echo -e "${WHITE}🛑 STOP DESKTOP:${NC}    ${GREEN}bash ~/stop-desktop.sh${NC}"
    echo -e "${WHITE}📂 DESKTOP FILES:${NC}   ${GREEN}~/.local/share/applications/${NC} (or ~/Desktop)"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}💡 TIP: Open Termux-X11 app first, then run start-desktop.sh${NC}"
    echo -e "${CYAN}🎮 GPU: Panfrost + Zink enabled for Mali${NC}"
    echo ""
}

# ============== MAIN ==============
main() {
    show_banner
    echo -e "${WHITE}This will install a lightweight Linux desktop with:${NC}"
    echo -e "  • XFCE4 + GPU acceleration (Mali Panfrost)"
    echo -e "  • VS Code, Firefox, Chromium"
    echo -e "  • Audio support"
    echo -e "\n${GRAY}Time: ~10-20 min (internet speed dependent)${NC}\n"
    echo -e "${YELLOW}Press Enter to start, or Ctrl+C to cancel...${NC}"
    read
    
    detect_device
    step_update
    step_repos
    step_x11
    step_desktop
    step_gpu
    step_audio
    step_apps
    step_launchers
    step_shortcuts
    step_final
    
    show_completion
}

main
