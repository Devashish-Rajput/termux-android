#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  🖥️  TERMUX DESKTOP LAB - Installer v3.0
#
#  Device: Lenovo IdeaTab Pro (Dimensity 8300-Ultra)
#  GPU:    ARM Mali-G615 MC6 → Mesa Panfrost/Zink
#
#  Installs:
#  - XFCE4 desktop via Termux-X11
#  - VS Code, Firefox, Chromium
#  - Audio (PulseAudio)
#  - GPU acceleration (Zink over Panfrost/swrast)
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=9
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
    echo -e "${CYAN}  📊 OVERALL PROGRESS: ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r  ${YELLOW}⏳${NC} %s ${CYAN}${spin:$i:1}${NC}  " "$message"
        sleep 0.1
    done

    wait "$pid"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} %-50s\n" "$message"
    else
        printf "\r  ${RED}✗${NC} %s ${RED}(failed)${NC}\n" "$message"
    fi

    return $exit_code
}

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}
    (yes | pkg install "$pkg" -y > /dev/null 2>&1) &
    spinner $! "Installing ${name}..."
}

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════════╗
    ║                                          ║
    ║   🖥️   TERMUX DESKTOP LAB  v3.0  🖥️     ║
    ║                                          ║
    ║   Lenovo IdeaTab Pro · Mali-G615 MC6     ║
    ║                                          ║
    ╚══════════════════════════════════════════╝
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
    GPU_RENDERER=$(getprop ro.hardware.egl 2>/dev/null || echo "")

    echo -e "  ${GREEN}📱${NC} Device:  ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL}${NC}"
    echo -e "  ${GREEN}🤖${NC} Android: ${WHITE}${ANDROID_VERSION}${NC}"
    echo -e "  ${GREEN}⚙️ ${NC} CPU:     ${WHITE}${CPU_ABI}${NC}"

    # --- GPU driver selection ---
    # Adreno (Qualcomm) → Turnip/freedreno
    # Mali (MediaTek/Samsung Exynos) → Panfrost (or zink+swrast fallback)
    # Anything else → swrast
    if [[ "$GPU_RENDERER" == *"adreno"* ]]; then
        GPU_DRIVER="freedreno"
        GPU_LABEL="Adreno → Turnip driver"
    elif [[ "$GPU_RENDERER" == *"mali"* ]] || \
         [[ "$GPU_RENDERER" == *"panfrost"* ]] || \
         [[ "$(getprop ro.hardware 2>/dev/null)" == *"mt"* ]] || \
         [[ "$DEVICE_MODEL" == *"Tab"* && "$DEVICE_BRAND" == *"enovo"* ]]; then
        GPU_DRIVER="panfrost"
        GPU_LABEL="Mali-G615 MC6 → Panfrost/Zink"
    else
        GPU_DRIVER="swrast"
        GPU_LABEL="Unknown → Software rendering"
    fi

    echo -e "  ${GREEN}🎮${NC} GPU:     ${WHITE}${GPU_LABEL}${NC}"
    echo ""
    sleep 1
}

# ============== STEP 1: UPDATE SYSTEM ==============
step_update() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating system packages...${NC}"
    echo ""

    (yes | pkg update -y > /dev/null 2>&1) &
    spinner $! "Updating package lists..."

    (yes | pkg upgrade -y > /dev/null 2>&1) &
    spinner $! "Upgrading installed packages..."
}

# ============== STEP 2: INSTALL REPOSITORIES ==============
step_repos() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding package repositories...${NC}"
    echo ""

    install_pkg "x11-repo"  "X11 Repository"
    install_pkg "tur-repo"  "TUR Repository (Firefox, VS Code, Chromium)"
}

# ============== STEP 3: INSTALL TERMUX-X11 ==============
step_x11() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Termux-X11...${NC}"
    echo ""

    install_pkg "termux-x11-nightly" "Termux-X11 Display Server"
    install_pkg "xorg-xrandr"        "XRandR (Display Settings)"
}

# ============== STEP 4: INSTALL DESKTOP ==============
step_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing XFCE4 Desktop...${NC}"
    echo ""

    install_pkg "xfce4"          "XFCE4 Desktop Environment"
    install_pkg "xfce4-terminal" "XFCE4 Terminal"
    install_pkg "thunar"         "Thunar File Manager"
    install_pkg "mousepad"       "Mousepad Text Editor"
}

# ============== STEP 5: INSTALL GPU DRIVERS ==============
step_gpu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing GPU Acceleration...${NC}"
    echo ""

    # Zink translates OpenGL calls to Vulkan — needed regardless of GPU
    install_pkg "mesa-zink"            "Mesa Zink (OpenGL over Vulkan)"
    install_pkg "vulkan-loader-android" "Vulkan Loader"

    case "$GPU_DRIVER" in
        freedreno)
            install_pkg "mesa-vulkan-icd-freedreno" "Turnip Adreno Driver"
            ;;
        panfrost)
            # Panfrost is the open-source Mali driver in Mesa.
            # In Termux it is bundled inside the mesa package; the Vulkan
            # fallback (swrast ICD) is used when a Panfrost Vulkan ICD is
            # not yet available upstream.
            install_pkg "mesa"                      "Mesa (Panfrost OpenGL)"
            install_pkg "mesa-vulkan-icd-swrast"   "Software Vulkan ICD (Zink fallback)"
            echo -e "  ${YELLOW}ℹ️ ${NC} Panfrost rasterises OpenGL; Zink bridges to Vulkan for GLES 3.2"
            ;;
        *)
            install_pkg "mesa-vulkan-icd-swrast" "Software Vulkan Renderer"
            ;;
    esac

    echo -e "  ${GREEN}✓${NC} GPU acceleration configured (driver: ${GPU_DRIVER})"
}

# ============== STEP 6: INSTALL AUDIO ==============
step_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Audio Support...${NC}"
    echo ""

    install_pkg "pulseaudio" "PulseAudio Sound Server"
}

# ============== STEP 7: INSTALL APPS ==============
step_apps() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Applications...${NC}"
    echo ""

    install_pkg "firefox"   "Firefox Browser"
    install_pkg "chromium"  "Chromium Browser"
    install_pkg "code-oss"  "VS Code (code-oss)"
    install_pkg "git"       "Git Version Control"
    install_pkg "wget"      "Wget"
    install_pkg "curl"      "cURL"
}

# ============== STEP 8: CREATE LAUNCHER SCRIPTS ==============
step_launchers() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Launcher Scripts...${NC}"
    echo ""

    mkdir -p ~/.config

    # ----- GPU environment config -----
    # Mali-G615: use Zink (GALLIUM_DRIVER=zink) with the swrast Vulkan ICD
    # as Panfrost Vulkan isn't yet in Termux's Mesa build.
    cat > ~/.config/desktoplab-gpu.sh << 'GPUEOF'
# Termux Desktop Lab — GPU / Mesa environment
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.3
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
# Panfrost/Mali hint — ignored on other GPUs
export PAN_MESA_DEBUG=nocheck
GPUEOF
    echo -e "  ${GREEN}✓${NC} GPU config saved to ~/.config/desktoplab-gpu.sh"

    # Source from bashrc (idempotent)
    if ! grep -q "desktoplab-gpu.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/desktoplab-gpu.sh 2>/dev/null' >> ~/.bashrc
    fi

    # ----- Desktop launcher -----
    cat > ~/start-desktop.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🚀 Starting Termux Desktop Lab..."
echo ""

# Load GPU config
source ~/.config/desktoplab-gpu.sh 2>/dev/null

# Kill stale sessions
echo "🔄 Cleaning up old sessions..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce"       2>/dev/null
pkill -9 -f "dbus"       2>/dev/null
sleep 0.5

# Audio
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "🔊 Starting PulseAudio..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp \
    auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1

# X11 server
echo "📺 Starting Termux-X11..."
termux-x11 :0 -ac &
sleep 3
export DISPLAY=:0

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱 Open the Termux-X11 app to see the desktop"
echo "  🔊 Audio is enabled"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exec startxfce4
LAUNCHEREOF
    chmod +x ~/start-desktop.sh
    echo -e "  ${GREEN}✓${NC} Created ~/start-desktop.sh"

    # ----- Stop script -----
    cat > ~/stop-desktop.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Stopping Termux Desktop Lab..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio"  2>/dev/null
pkill -9 -f "xfce"        2>/dev/null
pkill -9 -f "dbus"        2>/dev/null
echo "Done."
STOPEOF
    chmod +x ~/stop-desktop.sh
    echo -e "  ${GREEN}✓${NC} Created ~/stop-desktop.sh"

    # ----- App launcher menu -----
    cat > ~/launcher.sh << 'MENUEOF'
#!/data/data/com.termux/files/usr/bin/bash
source ~/.config/desktoplab-gpu.sh 2>/dev/null

while true; do
    clear
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║     🖥️  Termux Desktop Lab — Apps        ║"
    echo "╠══════════════════════════════════════════╣"
    echo "║  1) 🌐 Firefox                           ║"
    echo "║  2) 🌐 Chromium                          ║"
    echo "║  3) 💻 VS Code                           ║"
    echo "║  4) 🚀 Start Desktop (XFCE4)             ║"
    echo "║  5) 🎮 Check GPU / GL Info               ║"
    echo "║  0) ❌ Exit                              ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
    read -rp "  Select option: " choice

    case $choice in
        1) DISPLAY=:0 firefox & ;;
        2) DISPLAY=:0 chromium --no-sandbox & ;;
        3) DISPLAY=:0 code-oss --no-sandbox & ;;
        4) bash ~/start-desktop.sh ;;
        5)
            echo ""
            echo "=== glxinfo renderer ==="
            DISPLAY=:0 glxinfo 2>/dev/null | grep -E "renderer|version" || \
                echo "(Start the desktop first, or install mesa-demos)"
            echo ""
            read -rp "Press Enter to continue..."
            ;;
        0) exit 0 ;;
        *) echo "Invalid option" ; sleep 1 ;;
    esac
done
MENUEOF
    chmod +x ~/launcher.sh
    echo -e "  ${GREEN}✓${NC} Created ~/launcher.sh"
}

# ============== STEP 9: DESKTOP SHORTCUTS ==============
step_shortcuts() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Desktop Shortcuts...${NC}"
    echo ""

    mkdir -p ~/Desktop

    cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox %u
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
EOF

    cat > ~/Desktop/Chromium.desktop << 'EOF'
[Desktop Entry]
Name=Chromium
Comment=Web Browser
Exec=chromium --no-sandbox %u
Icon=chromium
Type=Application
Categories=Network;WebBrowser;
EOF

    cat > ~/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Comment=Code Editor
Exec=code-oss --no-sandbox %F
Icon=code-oss
Type=Application
Categories=Development;TextEditor;
MimeType=text/plain;inode/directory;
EOF

    cat > ~/Desktop/Terminal.desktop << 'EOF'
[Desktop Entry]
Name=Terminal
Comment=XFCE4 Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
EOF

    cat > ~/Desktop/AppLauncher.desktop << 'EOF'
[Desktop Entry]
Name=App Launcher
Comment=Open apps menu
Exec=xfce4-terminal -e "bash ~/launcher.sh"
Icon=applications-other
Type=Application
Categories=System;
EOF

    chmod +x ~/Desktop/*.desktop 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Desktop shortcuts created"
}

# ============== COMPLETION ==============
show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║         ✅  INSTALLATION COMPLETE — 100%  ✅              ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
COMPLETE
    echo -e "${NC}"

    echo -e "${WHITE}📱 Your Termux Desktop Lab is ready!${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}🚀 START DESKTOP:${NC}   ${GREEN}bash ~/start-desktop.sh${NC}"
    echo -e "${WHITE}🔧 APP LAUNCHER:${NC}    ${GREEN}bash ~/launcher.sh${NC}"
    echo -e "${WHITE}🛑 STOP DESKTOP:${NC}    ${GREEN}bash ~/stop-desktop.sh${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📦 INSTALLED:${NC}"
    echo -e "   • Firefox & Chromium browsers"
    echo -e "   • VS Code (code-oss)"
    echo -e "   • XFCE4 Desktop + Termux-X11"
    echo -e "   • PulseAudio"
    echo -e "   • Mesa Zink / Panfrost GPU acceleration"
    echo ""
    echo -e "${WHITE}⚡ TIP: Open the Termux-X11 app BEFORE running start-desktop.sh${NC}"
    echo -e "${WHITE}⚡ TIP: For 144 Hz, set refresh rate in Termux-X11 settings → Custom resolution${NC}"
    echo ""
}

# ============== MAIN ==============
main() {
    show_banner
    detect_device

    echo -e "${WHITE}  Installs XFCE4 desktop + VS Code, Firefox, Chromium${NC}"
    echo -e "${WHITE}  on your Lenovo IdeaTab Pro (Mali-G615 / Dimensity 8300-Ultra).${NC}"
    echo ""
    echo -e "${GRAY}  Estimated time: 10–20 minutes (depends on connection speed)${NC}"
    echo ""
    echo -e "${YELLOW}  Press Enter to start, or Ctrl+C to cancel...${NC}"
    read -r

    step_update
    step_repos
    step_x11
    step_desktop
    step_gpu
    step_audio
    step_apps
    step_launchers
    step_shortcuts

    show_completion
}

main
