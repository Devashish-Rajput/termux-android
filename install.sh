#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 LENOVO TAB PRO DEV DESKTOP - Installer v1.0
#  
#  Features:
#  - Optimized for 12GB RAM / High-Res Tablet Screens
#  - GPU acceleration auto-setup (Turnip/Zink)
#  - Clean XFCE4 Desktop Environment with DPI Scaling
#  - VS Code, Firefox, Chromium pre-installed
#  
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=9
CURRENT_STEP=0
INSTALL_LOG="$HOME/desktop_install.log"
export DEBIAN_FRONTEND=noninteractive

# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

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
    echo -e "${CYAN}  📊 PROGRESS: ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
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
        printf "\r  ${RED}✗${NC} ${message} ${RED}(failed - check $INSTALL_LOG)${NC}     \n"
    fi
    return $exit_code
}

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}
    (pkg install -y -o Dpkg::Options::="--force-confnew" $pkg >> "$INSTALL_LOG" 2>&1) &
    spinner $! "Installing ${name}..."
}

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════╗
    ║                                      ║
    ║   💻 LENOVO TAB PRO DEV DESKTOP 💻   ║
    ║                                      ║
    ╚══════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo "=== Mobile Desktop Install Log ===" > "$INSTALL_LOG"
}

# ============== DEVICE DETECTION ==============
detect_device() {
    echo -e "${CYAN}[*] Optimizing for your device...${NC}"
    echo ""
    
    DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
    DEVICE_BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Unknown")
    GPU_VENDOR=$(getprop ro.hardware.egl 2>/dev/null || echo "")
    
    echo -e "  ${GREEN}📱${NC} Device: ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL} (12GB RAM Edition)${NC}"
    
    # Lenovo uses both Snapdragon (Adreno) and MediaTek in their Pro line. This catches both.
    if [[ "${GPU_VENDOR,,}" == *"adreno"* ]] || [[ "${DEVICE_BRAND,,}" == *"lenovo"* ]]; then
        GPU_DRIVER="freedreno"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Hardware Acceleration Enabled (Turnip/Zink)${NC}"
    else
        GPU_DRIVER="swrast"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Software rendering${NC}"
    fi
    echo ""
    sleep 1
}

# ============== INSTALLATION STEPS ==============

step_update() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating system packages...${NC}"
    (pkg update -y >> "$INSTALL_LOG" 2>&1) &
    spinner $! "Updating package lists..."
    (pkg upgrade -y -o Dpkg::Options::="--force-confnew" >> "$INSTALL_LOG" 2>&1) &
    spinner $! "Upgrading installed packages..."
}

step_repos() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding repositories...${NC}"
    install_pkg "x11-repo" "X11 Repository"
    install_pkg "tur-repo" "TUR Repository (Firefox, VS Code)"
}

step_x11() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Display Server...${NC}"
    install_pkg "termux-x11-nightly" "Termux-X11"
    install_pkg "xorg-xrandr" "XRandR"
    install_pkg "xorg-xrdb" "X Resource Database (For Tablet Scaling)"
}

step_desktop() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Desktop Environment...${NC}"
    install_pkg "xfce4" "XFCE4 Desktop"
    install_pkg "xfce4-terminal" "Terminal"
    install_pkg "thunar" "File Manager"
}

step_gpu() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing GPU Drivers...${NC}"
    install_pkg "mesa-zink" "Mesa Zink"
    if [ "$GPU_DRIVER" == "freedreno" ]; then
        install_pkg "mesa-vulkan-icd-freedreno" "Turnip Adreno Driver"
    else
        install_pkg "mesa-vulkan-icd-swrast" "Software Renderer"
    fi
    install_pkg "vulkan-loader-android" "Vulkan Loader"
}

step_audio() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Audio...${NC}"
    install_pkg "pulseaudio" "PulseAudio Sound Server"
}

step_apps() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Developer Tools...${NC}"
    install_pkg "firefox" "Firefox Browser"
    install_pkg "chromium" "Chromium Browser"
    install_pkg "code-oss" "VS Code Editor"
    install_pkg "git" "Git Version Control"
    install_pkg "curl" "cURL"
}

step_launchers() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Tablet-Optimized Scripts...${NC}"
    
    mkdir -p ~/.config
    cat > ~/.config/desktop-gpu.sh << 'GPUEOF'
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
GPUEOF

    # Create UI Scaling config for High-Res Tablet Screens
    echo "Xft.dpi: 144" > ~/.Xresources
    
    cat > ~/start-desktop.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🚀 Starting Lenovo Tab Dev Desktop..."
echo ""

source ~/.config/desktop-gpu.sh 2>/dev/null

pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null

unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "🔊 Starting audio..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1

echo "📺 Starting Display..."
termux-x11 :0 -ac &
sleep 3

export DISPLAY=:0

# Apply High-Res Tablet Scaling
xrdb -merge ~/.Xresources 2>/dev/null

echo "🖥️ Launching Workspace..."
exec startxfce4
LAUNCHEREOF
    chmod +x ~/start-desktop.sh
    
    cat > ~/stop-desktop.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Stopping Desktop..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null
echo "Desktop stopped."
STOPEOF
    chmod +x ~/stop-desktop.sh
}

step_shortcuts() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating App Shortcuts...${NC}"
    
    mkdir -p ~/Desktop
    
    cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Type=Application
EOF

    cat > ~/Desktop/Chromium.desktop << 'EOF'
[Desktop Entry]
Name=Chromium
Comment=Web Browser
Exec=chromium --no-sandbox
Icon=chromium
Type=Application
EOF
    
    cat > ~/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Comment=Code Editor
Exec=code-oss --no-sandbox
Icon=code-oss
Type=Application
EOF
    
    cat > ~/Desktop/Terminal.desktop << 'EOF'
[Desktop Entry]
Name=Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Type=Application
EOF

    chmod +x ~/Desktop/*.desktop 2>/dev/null
}

# ============== MAIN EXECUTION ==============
main() {
    show_banner
    echo -e "${WHITE}  This will install a clean Linux developer workspace${NC}"
    echo -e "${WHITE}  specifically optimized for your Lenovo Tab Pro.${NC}"
    echo ""
    echo -e "${YELLOW}  Press Enter to start installation...${NC}"
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
    
    echo ""
    echo -e "${GREEN}✅ INSTALLATION COMPLETE! ✅${NC}"
    echo ""
    echo -e "${WHITE}🚀 TO START:${NC} ${GREEN}bash ~/start-desktop.sh${NC}"
    echo -e "${WHITE}🛑 TO STOP:${NC}  ${GREEN}bash ~/stop-desktop.sh${NC}"
    echo ""
    echo -e "${CYAN}💡 Note: If Android 12+ forcefully closes the app (Phantom Process Killer),${NC}"
    echo -e "${CYAN}   you may still need to run the ADB command to disable the process limit.${NC}"
    echo ""
}

main
