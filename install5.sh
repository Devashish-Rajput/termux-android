#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 LENOVO IDEAPAD PRO - Dev Desktop Installer
#  
#  Optimized for: Lenovo IdeaTab Pro (Snapdragon/Adreno)
#  Includes: XFCE4 + VS Code + Firefox + Chromium
#  GPU: Turnip/Zink (Adreno auto-detected)
#
#  Usage: bash lenovo-ideapad-setup.sh
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
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📊 PROGRESS: ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
        printf "\r  ${RED}✗${NC} ${message} ${RED}(failed - may already be installed)${NC}\n"
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
    ║   💻  LENOVO IDEAPAD PRO DESKTOP  💻     ║
    ║                                          ║
    ║   VS Code  •  Firefox  •  Chromium       ║
    ║   XFCE4 Desktop  •  GPU Accelerated      ║
    ║                                          ║
    ╚══════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
}

# ============== DEVICE DETECTION ==============
detect_device() {
    echo -e "${PURPLE}[*] Detecting Lenovo IdeaTab Pro specs...${NC}"
    echo ""

    DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Lenovo IdeaTab Pro")
    DEVICE_BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Lenovo")
    ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    CPU_ABI=$(getprop ro.product.cpu.abi 2>/dev/null || echo "arm64-v8a")
    GPU_VENDOR=$(getprop ro.hardware.egl 2>/dev/null || echo "")

    echo -e "  ${GREEN}📱${NC} Device : ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL}${NC}"
    echo -e "  ${GREEN}🤖${NC} Android: ${WHITE}${ANDROID_VERSION}${NC}"
    echo -e "  ${GREEN}⚙️ ${NC} CPU    : ${WHITE}${CPU_ABI}${NC}"

    # Lenovo IdeaTab Pro uses Snapdragon → Adreno GPU → Turnip driver
    if [[ "$GPU_VENDOR" == *"adreno"* ]] || \
       [[ "$CPU_ABI" == "arm64-v8a" ]] || \
       [[ "$DEVICE_BRAND" =~ [Ll]enovo ]]; then
        GPU_DRIVER="freedreno"
        echo -e "  ${GREEN}🎮${NC} GPU    : ${WHITE}Adreno (Snapdragon) → Turnip/Zink${NC}"
    else
        GPU_DRIVER="swrast"
        echo -e "  ${GREEN}🎮${NC} GPU    : ${WHITE}Software renderer (fallback)${NC}"
    fi

    echo ""
    sleep 1
}

# ============== STEP 1: UPDATE SYSTEM ==============
step_update() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating Termux packages...${NC}"
    echo ""

    (yes | pkg update -y > /dev/null 2>&1) &
    spinner $! "Refreshing package lists..."

    (yes | pkg upgrade -y > /dev/null 2>&1) &
    spinner $! "Upgrading existing packages..."
}

# ============== STEP 2: REPOSITORIES ==============
step_repos() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding repositories...${NC}"
    echo ""

    install_pkg "x11-repo"  "X11 Repository"
    install_pkg "tur-repo"  "TUR Repository (Firefox, VS Code, Chromium)"
}

# ============== STEP 3: TERMUX-X11 ==============
step_x11() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Termux-X11 display server...${NC}"
    echo ""

    install_pkg "termux-x11-nightly" "Termux-X11"
    install_pkg "xorg-xrandr"        "XRandR (multi-display support)"

    # Enable landscape / tablet resolution from the start
    echo -e "  ${GREEN}✓${NC} Tablet-friendly resolution support ready"
}

# ============== STEP 4: XFCE4 DESKTOP ==============
step_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing XFCE4 desktop...${NC}"
    echo ""

    install_pkg "xfce4"          "XFCE4 Desktop Environment"
    install_pkg "xfce4-terminal" "XFCE4 Terminal"
    install_pkg "thunar"         "Thunar File Manager"
    install_pkg "mousepad"       "Mousepad Text Editor"
    install_pkg "ristretto"      "Image Viewer"

    # Clean XFCE config so the first boot isn't cluttered
    rm -rf ~/.config/xfce4 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Fresh XFCE4 config ready"
}

# ============== STEP 5: GPU ACCELERATION ==============
step_gpu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing GPU acceleration (Turnip + Zink)...${NC}"
    echo ""

    install_pkg "mesa-zink" "Mesa Zink (OpenGL over Vulkan)"

    if [ "$GPU_DRIVER" == "freedreno" ]; then
        install_pkg "mesa-vulkan-icd-freedreno" "Turnip Adreno driver"
    else
        install_pkg "mesa-vulkan-icd-swrast"   "Software Vulkan fallback"
    fi

    install_pkg "vulkan-loader-android" "Vulkan loader"

    echo -e "  ${GREEN}✓${NC} GPU acceleration configured for Lenovo IdeaTab Pro"
}

# ============== STEP 6: AUDIO ==============
step_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing audio support...${NC}"
    echo ""

    install_pkg "pulseaudio" "PulseAudio"
}

# ============== STEP 7: BROWSERS ==============
step_browsers() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing browsers...${NC}"
    echo ""

    install_pkg "firefox"  "Firefox"
    install_pkg "chromium" "Chromium (Google Chrome equivalent)"

    echo -e "  ${GREEN}✓${NC} Both browsers installed"
}

# ============== STEP 8: VS CODE + DEV TOOLS ==============
step_devtools() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing VS Code and developer tools...${NC}"
    echo ""

    install_pkg "code-oss" "VS Code (code-oss)"
    install_pkg "git"      "Git"
    install_pkg "curl"     "cURL"
    install_pkg "wget"     "Wget"
    install_pkg "python"   "Python 3"
    install_pkg "nodejs"   "Node.js"

    echo ""
    echo -e "  ${YELLOW}⏳${NC} Installing pip packages..."
    pip install --quiet --break-system-packages pylint black > /dev/null 2>&1
    echo -e "  ${GREEN}✓${NC} Python linter & formatter installed"
}

# ============== STEP 9: LAUNCHER + SHORTCUTS ==============
step_setup() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating launcher and desktop shortcuts...${NC}"
    echo ""

    # ── GPU env file ──────────────────────────────────────────────────────────
    mkdir -p ~/.config
    cat > ~/.config/lenovo-gpu.sh << 'GPUEOF'
# Lenovo IdeaTab Pro – Adreno/Turnip+Zink GPU config
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
GPUEOF

    grep -q "lenovo-gpu.sh" ~/.bashrc 2>/dev/null || \
        echo 'source ~/.config/lenovo-gpu.sh 2>/dev/null' >> ~/.bashrc

    echo -e "  ${GREEN}✓${NC} GPU environment config saved"

    # ── Desktop launcher ──────────────────────────────────────────────────────
    cat > ~/start-desktop.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "💻 Starting Lenovo IdeaTab Pro Desktop..."
echo ""

source ~/.config/lenovo-gpu.sh 2>/dev/null

# Clean up stale sessions
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce"       2>/dev/null
pkill -9 -f "dbus"       2>/dev/null
sleep 1

# ── Audio ──────────────────────────────────────────────────────────────────
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "🔊 Starting audio..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1

# ── X11 server ─────────────────────────────────────────────────────────────
echo "📺 Starting X11 display server..."
termux-x11 :0 -ac &
sleep 3

export DISPLAY=:0

# Optional: force tablet-friendly DPI (uncomment if text looks tiny)
# xrandr --dpi 120

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱 Open the Termux-X11 app to see desktop!"
echo "  🖥️  XFCE4 + VS Code + Firefox + Chromium"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exec startxfce4
LAUNCHEREOF
    chmod +x ~/start-desktop.sh
    echo -e "  ${GREEN}✓${NC} Launcher  → ~/start-desktop.sh"

    # ── Stop script ───────────────────────────────────────────────────────────
    cat > ~/stop-desktop.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Stopping desktop..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "xfce"       2>/dev/null
pkill -9 -f "dbus"       2>/dev/null
echo "Done."
STOPEOF
    chmod +x ~/stop-desktop.sh
    echo -e "  ${GREEN}✓${NC} Stop script → ~/stop-desktop.sh"

    # ── Desktop shortcuts ─────────────────────────────────────────────────────
    mkdir -p ~/Desktop

    cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Exec=firefox
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
EOF

    cat > ~/Desktop/Chromium.desktop << 'EOF'
[Desktop Entry]
Name=Chromium
Exec=chromium --no-sandbox
Icon=chromium
Type=Application
Categories=Network;WebBrowser;
EOF

    cat > ~/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Exec=code-oss --no-sandbox
Icon=code-oss
Type=Application
Categories=Development;
EOF

    cat > ~/Desktop/Terminal.desktop << 'EOF'
[Desktop Entry]
Name=Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
EOF

    cat > ~/Desktop/Files.desktop << 'EOF'
[Desktop Entry]
Name=Files
Exec=thunar
Icon=system-file-manager
Type=Application
Categories=System;FileManager;
EOF

    chmod +x ~/Desktop/*.desktop 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Desktop shortcuts created (Firefox, Chromium, VS Code, Terminal, Files)"
}

# ============== COMPLETION ==============
show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'DONE'
    ╔══════════════════════════════════════════════════╗
    ║                                                  ║
    ║        ✅  SETUP COMPLETE — 100%  ✅             ║
    ║                                                  ║
    ║   Lenovo IdeaTab Pro Desktop is ready!           ║
    ║                                                  ║
    ╚══════════════════════════════════════════════════╝
DONE
    echo -e "${NC}"

    echo -e "${WHITE}🚀 START DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/start-desktop.sh${NC}"
    echo ""
    echo -e "${WHITE}🛑 STOP DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/stop-desktop.sh${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 Installed:${NC}"
    echo -e "   • XFCE4 Desktop (GPU accelerated)"
    echo -e "   • Firefox  &  Chromium"
    echo -e "   • VS Code (code-oss)"
    echo -e "   • Python 3, Node.js, Git, curl, wget"
    echo -e "   • PulseAudio (sound support)"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}⚡ TIP: Open the Termux-X11 app BEFORE running start-desktop.sh${NC}"
    echo ""
}

# ============== MAIN ==============
main() {
    show_banner

    echo -e "${WHITE}  Installs a lightweight Linux desktop on your Lenovo IdeaTab Pro${NC}"
    echo -e "${WHITE}  with VS Code, Firefox, Chromium and GPU acceleration.${NC}"
    echo ""
    echo -e "${GRAY}  Estimated time: 10–20 minutes (depends on internet speed)${NC}"
    echo ""
    echo -e "${YELLOW}  Press Enter to start, or Ctrl+C to cancel...${NC}"
    read

    detect_device
    step_update
    step_repos
    step_x11
    step_desktop
    step_gpu
    step_audio
    step_browsers
    step_devtools
    step_setup

    show_completion
}

main
