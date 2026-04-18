#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  🚀  MOBILE HACKLAB v2.1 – (Modified for Lenovo Idea Tab Pro)
#  Author: Tech Jarves (modified by ChatGPT)
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=11   # reduced: removed some steps (Metasploit, security tools)
CURRENT_STEP=0

# ============== COLORS ==============
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; PURPLE='\033[0;35m'; WHITE='\033[1;37m'; NC='\033[0m'
GRAY='\033[0;90m'; BOLD='\033[1m'

# ============== PROGRESS FUNCTIONS ==============
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    FILLED=$((PERCENT / 5)); EMPTY=$((20 - FILLED))
    BAR="${GREEN}"; for ((i=0;i<FILLED;i++)); do BAR+="█"; done
    BAR+="${GRAY}"; for ((i=0;i<EMPTY;i++)); do BAR+="░"; done; BAR+="${NC}"
    echo ""; echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📊 OVERALL PROGRESS: ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo ""
}
spinner() {
    local pid=$1; local message=$2; local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'; local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 )); printf "\r  ${YELLOW}⏳${NC} ${message} ${CYAN}${spin:$i:1}${NC}  "; sleep 0.1
    done
    wait $pid; local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} ${message}                    \n"
    else
        printf "\r  ${RED}✗${NC} ${message} ${RED}(failed)${NC}     \n"
    fi
    return $exit_code
}
install_pkg() {
    pkg install -y "$1" >/dev/null 2>&1 &
    spinner $! "Installing ${2:-$1}..."
}

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
╔══════════════════════════════════════╗
║                                      ║
║   🚀  MOBILE HACKLAB v2.1  🚀        ║
║                                      ║
║       Tech Jarves (modified)         ║
║                                      ║
╚══════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo -e "${WHITE}         Tech Jarves (modified)${NC}"
    echo ""
}

# ============== DEVICE DETECTION ==============
detect_device() {
    echo -e "${PURPLE}[*] Detecting your device...${NC}"; echo ""
    DEVICE_MODEL=$(getprop ro.product.model || echo "Unknown")
    DEVICE_BRAND=$(getprop ro.product.brand || echo "Unknown")
    ANDROID_VERSION=$(getprop ro.build.version.release || echo "Unknown")
    CPU_ABI=$(getprop ro.product.cpu.abi || echo "arm64-v8a")
    # GPU type detection (simple): check for Mali vs Adreno
    GPU_INFO=$(getprop ro.hardware.egl || echo "")
    if [[ "$GPU_INFO" == *"adreno"* ]] || [[ "${DEVICE_BRAND,,}" =~ samsung|oneplus|xiaomi ]]; then
        GPU_VENDOR="Adreno (Qualcomm)"; GPU_DRIVER="freedreno"
    else
        GPU_VENDOR="Mali (MediaTek)"; GPU_DRIVER="virglrenderer"
    fi
    echo -e "  ${GREEN}📱${NC} Device: ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL}${NC}"
    echo -e "  ${GREEN}🤖${NC} Android: ${WHITE}${ANDROID_VERSION}${NC}"
    echo -e "  ${GREEN}⚙️${NC}  CPU: ${WHITE}${CPU_ABI}${NC}"
    echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}${GPU_VENDOR}${NC}"
    echo ""
    sleep 1
}

# ============== STEP 1: UPDATE SYSTEM ==============
step_update() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating system packages...${NC}"; echo ""
    (yes | pkg update -y) & spinner $! "Updating package lists..."
    (yes | pkg upgrade -y) & spinner $! "Upgrading installed packages..."
}

# ============== STEP 2: INSTALL REPOSITORIES ==============
step_repos() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding package repositories...${NC}"; echo ""
    install_pkg "x11-repo" "X11 Repository"
    install_pkg "tur-repo" "TUR Repository (for Chromium, etc.)"
}

# ============== STEP 3: INSTALL TERMUX X11 ==============
step_x11() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Termux-X11 display server...${NC}"; echo ""
    install_pkg "termux-x11-nightly" "Termux-X11 Server"
    install_pkg "xorg-xrandr" "XRandR (screen resizing)"
}

# ============== STEP 4: INSTALL DESKTOP ENVIRONMENT ==============
step_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing XFCE4 Desktop...${NC}"; echo ""
    install_pkg "xfce4" "XFCE4 Desktop Environment"
    install_pkg "xfce4-terminal" "XFCE4 Terminal"
    install_pkg "thunar" "Thunar File Manager"
    install_pkg "mousepad" "Mousepad Editor"
}

# ============== STEP 5: GPU ACCELERATION SETUP ==============
step_gpu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Configuring GPU acceleration...${NC}"; echo ""
    # Install Zink (OpenGL over Vulkan) and Vulkan loader
    install_pkg "mesa-zink" "Mesa Zink (GL-over-Vulkan)"
    install_pkg "vulkan-loader-android" "Vulkan Loader"
    # Install VirGL for broader device support (uses Android GL/ES)
    install_pkg "virglrenderer-android" "VirGL renderer (Android GL/Vulkan)"
    echo -e "  ${GREEN}✓${NC} GPU acceleration packages installed."
}

# ============== STEP 6: AUDIO SUPPORT ==============
step_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing audio support...${NC}"; echo ""
    install_pkg "pulseaudio" "PulseAudio Server"
    echo -e "  ${GREEN}✓${NC} PulseAudio installed (for sound)."
    echo -e "${YELLOW}⚠️  Note: On Android 16+, PulseAudio is known to fail (see termux issue #27978)${NC}"
}

# ============== STEP 7: BROWSERS & APPS ==============
step_apps() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing applications...${NC}"; echo ""
    install_pkg "firefox" "Firefox Browser"
    install_pkg "code-oss" "VS Code Editor"
    install_pkg "chromium" "Chromium Browser"  # Added Chromium per user request
    install_pkg "git" "Git Version Control"
    install_pkg "wget" "Wget Downloader"
    install_pkg "curl" "cURL"
}

# ============== STEP 8: NETWORK TOOLS ==============
step_network_tools() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing network utilities...${NC}"; echo ""
    install_pkg "nmap" "Nmap Network Scanner"
    install_pkg "netcat-openbsd" "Netcat"
    install_pkg "whois" "Whois Lookup"
    install_pkg "dnsutils" "DNS Tools"
    install_pkg "tracepath" "Tracepath"
    # Note: Use network tools responsibly (unauthorized scanning can be illegal【17†L21-L29】).
}

# ============== STEP 9: WINDOWS COMPATIBILITY (WINE) ==============
step_wine() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Wine (via Hangover)...${NC}"; echo ""
    # Remove any conflicting Wine
    (pkg remove wine-stable -y) & spinner $! "Removing old Wine versions..."
    # Install Hangover Wine (32-bit support on ARM64)
    install_pkg "hangover-wine" "Wine Compatibility Layer"
    install_pkg "hangover-wowbox64" "Box64 (for 32-bit apps)"
    # Symlinks
    ln -sf $PREFIX/opt/hangover-wine/bin/wine $PREFIX/bin/wine
    ln -sf $PREFIX/opt/hangover-wine/bin/winecfg $PREFIX/bin/winecfg
    echo -e "  ${GREEN}✓${NC} Wine (Hangover) installed."
}

# ============== STEP 10: LAUNCHER SCRIPTS ==============
step_launchers() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating launcher scripts...${NC}"; echo ""
    mkdir -p ~/.config
    # GPU config for Zink/VirGL
    cat > ~/.config/hacklab-gpu.sh << 'GPUEOF'
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
GPUEOF
    # Add to bashrc if not present
    grep -q "hacklab-gpu.sh" ~/.bashrc || echo 'source ~/.config/hacklab-gpu.sh' >> ~/.bashrc
    echo -e "  ${GREEN}✓${NC} GPU config script created."

    # Main launcher
    cat > ~/start-hacklab.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""; echo "🚀 Starting Mobile HackLab Desktop..."; echo ""
source ~/.config/hacklab-gpu.sh 2>/dev/null
echo "🔄 Cleaning up old sessions..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null

echo "🔊 Starting audio server..."
pulseaudio --kill 2>/dev/null; sleep 0.5
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 >/dev/null
export PULSE_SERVER=127.0.0.1

echo "📺 Starting X11 display server..."
termux-x11 :0 -ac &
sleep 3
export DISPLAY=:0

echo "🖥️ Launching XFCE4 Desktop..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱 Open the Termux-X11 app to see desktop!"
echo "  🔊 Audio is enabled!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
exec startxfce4
LAUNCHEREOF
    chmod +x ~/start-hacklab.sh
    echo -e "  ${GREEN}✓${NC} Created ~/start-hacklab.sh"

    # Shutdown script
    cat > ~/stop-hacklab.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Stopping Mobile HackLab..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null
echo "Desktop stopped."
STOPEOF
    chmod +x ~/stop-hacklab.sh
    echo -e "  ${GREEN}✓${NC} Created ~/stop-hacklab.sh"
}

# ============== STEP 11: DESKTOP SHORTCUTS ==============
step_shortcuts() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Desktop shortcuts...${NC}"; echo ""
    mkdir -p ~/Desktop

    # Firefox shortcut
    cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
EOF

    # VS Code
    cat > ~/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Comment=Code Editor
Exec=code-oss
Icon=code-oss
Type=Application
Categories=Development;
EOF

    # Chromium (added)
    cat > ~/Desktop/Chromium.desktop << 'EOF'
[Desktop Entry]
Name=Chromium
Comment=Web Browser
Exec=chromium
Icon=chromium
Type=Application
Categories=Network;WebBrowser;
EOF

    # XFCE Terminal
    cat > ~/Desktop/Terminal.desktop << 'EOF'
[Desktop Entry]
Name=Terminal
Comment=XFCE4 Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
EOF

    # Windows File Manager (Winefile)
    cat > ~/Desktop/Windows_Explorer.desktop << 'EOF'
[Desktop Entry]
Name=Windows Explorer
Comment=Wine File Manager
Exec=winefile
Icon=folder-windows
Type=Application
Categories=System;
EOF

    # Wine Config
    cat > ~/Desktop/Wine_Config.desktop << 'EOF'
[Desktop Entry]
Name=Wine Config
Comment=Wine Settings
Exec=winecfg
Icon=wine
Type=Application
Categories=Settings;
EOF

    chmod +x ~/Desktop/*.desktop 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Desktop shortcuts created"
}

# ============== COMPLETION MESSAGE ==============
show_completion() {
    echo ""; echo -e "${GREEN}"
    cat << 'COMPLETE'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║         ✅  INSTALLATION COMPLETE!  ✅                        ║
║                                                               ║
║              🎉 100% - All Done! 🎉                           ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
COMPLETE
    echo -e "${NC}"
    echo -e "${WHITE}📱 Your Mobile HackLab is ready!${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}🚀 TO START THE DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/start-hacklab.sh${NC}"
    echo ""
    echo -e "${WHITE}🛑 TO STOP THE DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/stop-hacklab.sh${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 INSTALLED TOOLS:${NC}"
    echo -e "   • Browsers: Firefox, Chromium"
    echo -e "   • Editor: VS Code"
    echo -e "   • Network: nmap, netcat, whois, dnsutils, tracepath"
    echo -e "   • Utilities: Git, wget, curl"
    echo -e "   • Windows Compatibility: Wine (Hangover)"
    echo -e "   • Desktop: XFCE4, GPU Acceleration via Zink/VirGL"
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📺 Subscribe: https://youtube.com/@TechJarves${NC}"
    echo -e "${CYAN}  🎬 Tutorial:  [YOUR VIDEO URL]${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}⚡ TIP: Open the Termux-X11 app first, then run start-hacklab.sh${NC}"
    echo ""
}

# ============== MAIN INSTALLATION ==============
main() {
    show_banner
    echo -e "${WHITE}  This script will install a Linux desktop (XFCE) with GPU acceleration and tools on your Android tablet.${NC}"
    echo -e "${WHITE}  Compatible with Lenovo Idea Tab Pro (MediaTek Dimensity) and Termux.${NC}"
    echo ""
    echo -e "${GRAY}  Estimated time: 15-30 minutes (depends on internet speed)${NC}"
    echo ""
    echo -e "${YELLOW}  Press Enter to start installation, or Ctrl+C to cancel...${NC}"
    read

    detect_device
    step_update
    step_repos
    step_x11
    step_desktop
    step_gpu
    step_audio
    step_apps
    step_network_tools
    step_wine
    step_launchers
    step_shortcuts
    show_completion
}

# ============== RUN ==============
main
