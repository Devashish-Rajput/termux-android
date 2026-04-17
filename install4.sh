#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  Lenovo Idea Tab Pro - Dev Desktop Installer
#  Focus: VS Code + Chromium + Firefox
#######################################################

TOTAL_STEPS=7
CURRENT_STEP=0

# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ============== PROGRESS ==============
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

    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 10 ))
        printf "\r  ${YELLOW}⏳${NC} %s ${CYAN}%s${NC}  " "$message" "${spin:$i:1}"
        sleep 0.1
    done

    wait "$pid"
    local exit_code=$?

    if [ "$exit_code" -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} %s                    \n" "$message"
    else
        printf "\r  ${RED}✗${NC} %s ${RED}(failed)${NC}\n" "$message"
    fi

    return "$exit_code"
}

install_pkg() {
    local pkg="$1"
    local name="${2:-$pkg}"

    (pkg install -y "$pkg" > /dev/null 2>&1) &
    spinner $! "Installing ${name}..."
}

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════════════╗
    ║                                              ║
    ║   🚀  LENOVO IDEA TAB PRO DEV DESKTOP  🚀    ║
    ║                                              ║
    ║        VS Code • Chromium • Firefox          ║
    ║                                              ║
    ╚══════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo ""
}

# ============== DEVICE DETECTION ==============
detect_device() {
    echo -e "${PURPLE}[*] Detecting device...${NC}"
    echo ""

    DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
    DEVICE_BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Unknown")
    ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    CPU_ABI=$(getprop ro.product.cpu.abi 2>/dev/null || echo "arm64-v8a")
    GPU_HINT="$(getprop ro.hardware.egl 2>/dev/null || echo "")"
    GPU_HINT_LC=$(echo "$GPU_HINT" | tr '[:upper:]' '[:lower:]')

    echo -e "  ${GREEN}📱${NC} Device: ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL}${NC}"
    echo -e "  ${GREEN}🤖${NC} Android: ${WHITE}${ANDROID_VERSION}${NC}"
    echo -e "  ${GREEN}⚙️${NC}  CPU: ${WHITE}${CPU_ABI}${NC}"

    if [[ "$GPU_HINT_LC" == *"adreno"* ]] || [[ "$GPU_HINT_LC" == *"qualcomm"* ]] || [[ "$GPU_HINT_LC" == *"freedreno"* ]]; then
        GPU_MODE="freedreno"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Adreno/Qualcomm path${NC}"
    else
        GPU_MODE="swrast"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Software fallback${NC}"
    fi

    echo ""
    sleep 1
}

# ============== STEP 1: UPDATE ==============
step_update() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating packages...${NC}"
    echo ""

    (pkg update -y > /dev/null 2>&1) &
    spinner $! "Updating package lists..."

    #(pkg upgrade -y > /dev/null 2>&1) &
    #spinner $! "Upgrading installed packages..."
}

# ============== STEP 2: REPOSITORY ==============
step_repo() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Enabling X11 repository...${NC}"
    echo ""

    install_pkg "x11-repo" "X11 repository"
}

# ============== STEP 3: DESKTOP BASE ==============
step_desktop_base() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing desktop base...${NC}"
    echo ""

    install_pkg "termux-x11-nightly" "Termux-X11"
    install_pkg "xfce4" "XFCE4 desktop"
    install_pkg "xfce4-terminal" "XFCE terminal"
    install_pkg "thunar" "File manager"
    install_pkg "dbus" "DBus"
}

# ============== STEP 4: GPU + AUDIO ==============
step_gpu_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Configuring GPU and audio...${NC}"
    echo ""

    install_pkg "pulseaudio" "PulseAudio"
    install_pkg "mesa-zink" "Mesa Zink"
    install_pkg "vulkan-loader-android" "Vulkan loader"

    if [ "$GPU_MODE" = "freedreno" ]; then
        install_pkg "mesa-vulkan-icd-freedreno" "Turnip driver"
    else
        install_pkg "mesa-vulkan-icd-swrast" "Software Vulkan"
    fi

    echo -e "  ${GREEN}✓${NC} GPU and audio packages installed"
}

# ============== STEP 5: APPS ==============
step_apps() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing apps...${NC}"
    echo ""

    install_pkg "code-oss" "VS Code"
    install_pkg "firefox" "Firefox"
    install_pkg "chromium" "Chromium"
}

# ============== STEP 6: LAUNCHERS ==============
step_launchers() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating launch scripts...${NC}"
    echo ""

    mkdir -p ~/.config

    cat > ~/.config/lenovo-devdesk-gpu.sh << EOF
# Lenovo Idea Tab Pro Dev Desktop GPU mode
export DEVGPU_MODE="$GPU_MODE"
export MESA_NO_ERROR=1
export MESA_VK_WSI_PRESENT_MODE=immediate
EOF

    cat > ~/start-devdesk.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🚀 Starting Lenovo Dev Desktop..."
echo ""

source ~/.config/lenovo-devdesk-gpu.sh 2>/dev/null || true

# Clean old sessions
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce4-session" 2>/dev/null
pkill -9 -f "dbus-daemon" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null

# Audio
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 >/dev/null 2>&1 || true
export PULSE_SERVER=127.0.0.1

# DBus
mkdir -p $PREFIX/var/run/dbus
dbus-daemon --session --fork --address=unix:path=$PREFIX/var/run/dbus/session_bus_socket
export DBUS_SESSION_BUS_ADDRESS=unix:path=$PREFIX/var/run/dbus/session_bus_socket

# GPU fallback / acceleration
if [ "$DEVGPU_MODE" = "freedreno" ]; then
    export GALLIUM_DRIVER=zink
    export MESA_LOADER_DRIVER_OVERRIDE=zink
    export TU_DEBUG=noconform
else
    export LIBGL_ALWAYS_SOFTWARE=1
    export MESA_LOADER_DRIVER_OVERRIDE=swrast
fi

# Start X server
echo "📺 Starting Termux-X11..."
termux-x11 :0 -ac &
sleep 3
export DISPLAY=:0

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Open the Termux-X11 app to see the desktop"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exec startxfce4
EOF
    chmod +x ~/start-devdesk.sh

    cat > ~/stop-devdesk.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Stopping desktop..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce4-session" 2>/dev/null
pkill -9 -f "dbus-daemon" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
echo "Done."
EOF
    chmod +x ~/stop-devdesk.sh

    echo -e "  ${GREEN}✓${NC} Created ~/start-devdesk.sh"
    echo -e "  ${GREEN}✓${NC} Created ~/stop-devdesk.sh"
}

# ============== STEP 7: SHORTCUTS ==============
step_shortcuts() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating desktop shortcuts...${NC}"
    echo ""

    mkdir -p ~/Desktop

    cat > ~/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Comment=Code Editor
Exec=code-oss --no-sandbox
Icon=code-oss
Type=Application
Categories=Development;
EOF

    cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
EOF

    cat > ~/Desktop/Chromium.desktop << 'EOF'
[Desktop Entry]
Name=Chromium
Comment=Web Browser
Exec=chromium-browser
Icon=chromium
Type=Application
Categories=Network;WebBrowser;
EOF

    chmod +x ~/Desktop/*.desktop 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Desktop shortcuts created"
}

show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'

    ╔═══════════════════════════════════════════════╗
    ║                                               ║
    ║        ✅  INSTALLATION COMPLETE  ✅          ║
    ║                                               ║
    ╚═══════════════════════════════════════════════╝

COMPLETE
    echo -e "${NC}"
    echo -e "${WHITE}Start desktop: ${GREEN}bash ~/start-devdesk.sh${NC}"
    echo -e "${WHITE}Stop desktop : ${GREEN}bash ~/stop-devdesk.sh${NC}"
    echo -e "${WHITE}Apps on desktop: VS Code, Chromium, Firefox${NC}"
    echo ""
    echo -e "${YELLOW}Tip: Open Termux-X11 first, then run the start script.${NC}"
    echo ""
}

main() {
    show_banner
    echo -e "${WHITE}This installer sets up a lightweight desktop for the Lenovo Idea Tab Pro.${NC}"
    echo -e "${WHITE}It installs only the desktop shell plus VS Code, Chromium, and Firefox.${NC}"
    echo ""
    echo -e "${GRAY}Estimated time: 10-20 minutes${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to start, or Ctrl+C to cancel...${NC}"
    read

    detect_device
    step_update
    step_repo
    step_desktop_base
    step_gpu_audio
    step_apps
    step_launchers
    step_shortcuts

    show_completion
}

main
