#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 LENOVO TAB PRO DEV DESKTOP - Optimized v2.0
#  
#  Focus: Chrome (Chromium), Firefox, VS Code only
#  WM: Openbox + panel (lightweight)
#  Optimized for 12GB RAM / High-Res Tablet Screens
#  GPU acceleration auto-setup (Turnip/Zink)
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
    ║   💻 LENOVO TAB PRO DEV DESKTOP 💻   ║
    ║        (Optimized for 12GB RAM DeepSeek)      ║
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
    echo -e "  ${GREEN}📱${NC} Device: ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL} (12GB RAM)${NC}"
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
    echo -e "  ${GRAY}⏭️  Skipping full upgrade to prevent Android process limits${NC}"
}

step_repos() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding repositories...${NC}"
    install_pkg "x11-repo" "X11 Repository"
    install_pkg "tur-repo" "TUR Repository (Firefox, VS Code)"
    echo -e "  ${YELLOW}⏳${NC} Refreshing new package sources..."
    (pkg update -y >> "$INSTALL_LOG" 2>&1) &
    spinner $! "Syncing repositories..."
}

step_x11() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Display Server...${NC}"
    install_pkg "termux-x11-nightly" "Termux-X11"
    install_pkg "xorg-xrandr" "XRandR"
    install_pkg "xorg-xrdb" "X Resource Database"
}

step_wm() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Lightweight Window Manager...${NC}"
    install_pkg "openbox" "Openbox WM"
    install_pkg "xfce4-panel" "Simple Panel"
    install_pkg "xfce4-terminal" "Terminal Emulator"
    # No file manager, no full desktop environment
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
    install_pkg "chromium" "Chromium Browser (Chrome)"
    install_pkg "code-oss" "VS Code Editor"
    # Git and curl are small, kept for convenience
    install_pkg "git" "Git"
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

    # High-DPI scaling for tablet (144 DPI)
    echo "Xft.dpi: 144" > ~/.Xresources

    # Openbox configuration – right-click menu with our apps
    mkdir -p ~/.config/openbox
    cat > ~/.config/openbox/menu.xml << 'MENUEOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu>
<menu id="root-menu" label="Menu">
  <item label="Firefox"><action name="Execute"><command>firefox</command></action></item>
  <item label="Chromium"><action name="Execute"><command>chromium --no-sandbox</command></action></item>
  <item label="VS Code"><action name="Execute"><command>code-oss --no-sandbox</command></action></item>
  <item label="Terminal"><action name="Execute"><command>xfce4-terminal</command></action></item>
  <separator/>
  <item label="Exit"><action name="Exit"/></item>
</menu>
</openbox_menu>
MENUEOF

    cat > ~/start-desktop.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🚀 Starting Lenovo Tab Dev Desktop (Openbox + Apps)..."
echo ""

source ~/.config/desktop-gpu.sh 2>/dev/null

pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "openbox" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null

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
xrdb -merge ~/.Xresources 2>/dev/null

# Start panel and window manager
xfce4-panel &
openbox --startup &

# Optional: launch a terminal on startup
xfce4-terminal &

echo "🖥️ Desktop ready. Right-click for menu."
echo "To stop: bash ~/stop-desktop.sh"
wait
LAUNCHEREOF
    chmod +x ~/start-desktop.sh

    cat > ~/stop-desktop.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Stopping Desktop..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "openbox" 2>/dev/null
pkill -9 -f "xfce4-panel" 2>/dev/null
echo "Desktop stopped."
STOPEOF
    chmod +x ~/stop-desktop.sh
}

step_shortcuts() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating App Shortcuts (Desktop & Menu)...${NC}"
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
    echo -e "${WHITE}  This will install a minimal Linux workspace${NC}"
    echo -e "${WHITE}  with Openbox + Chrome, Firefox, VS Code.${NC}"
    echo ""
    echo -e "${YELLOW}  Press Enter to start installation...${NC}"
    read
    detect_device
    step_update
    step_repos
    step_x11
    step_wm
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
    echo -e "${CYAN}💡 Tip: Right-click on the desktop for an app menu.${NC}"
    echo -e "${CYAN}💡 If Android kills Termux, run ADB:${NC}"
    echo -e "   ${WHITE}adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent; /system/bin/device_config put activity_manager max_phantom_processes 100000"${NC}"
}

main
