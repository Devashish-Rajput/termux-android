#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 DEVELOPMENT WORKSTATION - Optimization v3.1
#  Target Hardware: MediaTek Dimensity 8300-Ultra
#  Payload: XFCE4, Code-OSS, Chromium, Firefox ONLY.
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=10
CURRENT_STEP=0

# ============== COLORS ==============
RED='\033; then
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
    ╔══════════════════════════════════════════════════════╗
    ║                                                      ║
    ║   🚀 ARM NATIVE DEV WORKSTATION 🚀                   ║
    ║   Optimized for Dimensity 8300 / Mali-G615           ║
    ║                                                      ║
    ╚══════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
}

# ============== STEP 1: SYSTEM UPDATE ==============
step_update() {
    update_progress
    echo -e "${PURPLE} Core System Synchronization...${NC}"
    (yes | pkg update -y > /dev/null 2>&1) &
    spinner $! "Updating package manifests..."
    (yes | pkg upgrade -y > /dev/null 2>&1) &
    spinner $! "Upgrading core binaries..."
}

# ============== STEP 2: REPOSITORIES ==============
step_repos() {
    update_progress
    echo -e "${PURPLE} Integrating Third-Party Repositories...${NC}"
    install_pkg "x11-repo" "X11 Display Architecture Repo"
    install_pkg "tur-repo" "Termux User Repository (IDE/Browsers)"
}

# ============== STEP 3: DISPLAY SERVER ==============
step_x11() {
    update_progress
    echo -e "${PURPLE} Compiling Display Server Components...${NC}"
    install_pkg "termux-x11-nightly" "Termux-X11 Protocol Server"
    install_pkg "xorg-xrandr" "Display Geometry Utilities"
}

# ============== STEP 4: DESKTOP ENVIRONMENT ==============
step_desktop() {
    update_progress
    echo -e "${PURPLE} Provisioning XFCE4 Workspace...${NC}"
    install_pkg "xfce4" "XFCE4 Core Environment"
    install_pkg "xfce4-terminal" "XFCE4 Native Terminal"
}

# ============== STEP 5: MALI GPU ACCELERATION ==============
step_gpu() {
    update_progress
    echo -e "${PURPLE} Linking Mali-G615 Translation Layers...${NC}"
    
    install_pkg "mesa-zink" "Mesa Zink (Vulkan API Translator)"
    install_pkg "virglrenderer-mesa-zink" "VirGL Renderer (Zink backend)"
    install_pkg "virglrenderer-android" "VirGL Android Integration"
    install_pkg "vulkan-loader-android" "Native Android Vulkan Loader"
    
    echo -e "  ${GREEN}✓${NC} Mali GPU translation bridge verified."
}

# ============== STEP 6: AUDIO SUBSYSTEM ==============
step_audio() {
    update_progress
    echo -e "${PURPLE} Initializing Audio Daemons...${NC}"
    install_pkg "pulseaudio" "PulseAudio TCP Server"
}

# ============== STEP 7: DEVELOPER TOOLCHAIN ==============
step_toolchain() {
    update_progress
    echo -e "${PURPLE} Fetching Developer Toolchain...${NC}"
    
    install_pkg "code-oss" "Visual Studio Code (Code-OSS)"
    install_pkg "chromium" "Google Chromium"
    install_pkg "firefox" "Mozilla Firefox"
    install_pkg "git" "Git Version Control"
}

# ============== STEP 8: DISPLAY SCALING (3K @ 144HZ) ======
step_scaling() {
    update_progress
    echo -e "${PURPLE} Injecting High-DPI Display Overrides...${NC}"
    
    # Establish XFCE settings directory
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    
    # Force XFCE GDK scaling factor to 2 for 3K display mapping
    cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'XSET'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Gdk" type="empty">
    <property name="WindowScalingFactor" type="int" value="2"/>
  </property>
</channel>
XSET
    echo -e "  ${GREEN}✓${NC} XFCE High-DPI scaling matrix applied."
}

# ============== STEP 9: ENVIRONMENT BOOTSTRAPPING ======
step_launchers() {
    update_progress
    echo -e "${PURPLE} Generating Execution Daemons...${NC}"
    
    mkdir -p ~/.config
    # Explicit Mali-G615 Hardware Acceleration Overrides
    cat > ~/.config/mali-gpu.sh << 'GPUEOF'
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.3COMPAT
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export ZINK_DESCRIPTORS=lazy
GPUEOF

    if! grep -q "mali-gpu.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/mali-gpu.sh 2>/dev/null' >> ~/.bashrc
    fi

    # Core execution daemon for Developer Workspace
    cat > ~/start-workspace.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
clear
echo "🚀 Bootstrapping Developer Workspace..."

# Inject Mali Zink translation logic
source ~/.config/mali-gpu.sh 2>/dev/null

# Subsystem sanitization
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "virgl_test_server" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null

# Audio subsystem initialization
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1

# Hardware translation initialization
echo "⚙️  Initializing VirGL OpenGL translation layer..."
virgl_test_server --use-egl-surfaceless --use-gles &
sleep 2

# Display server initialization targeting 160 DPI
echo "📺 Spawning Termux-X11 Display Server..."
termux-x11 :0 -ac -dpi 160 &
sleep 3
export DISPLAY=:0

echo "🖥️  Handing off to XFCE4 Window Manager..."
echo "============================================="
echo "   Switch to the Termux-X11 Application"
echo "============================================="
exec startxfce4
LAUNCHEREOF
    chmod +x ~/start-workspace.sh

    # Workspace teardown script
    cat > ~/stop-workspace.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Initiating system teardown..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "virgl_test_server" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
echo "Workspace successfully halted."
STOPEOF
    chmod +x ~/stop-workspace.sh
    echo -e "  ${GREEN}✓${NC} Daemon configuration generated."
}

# ============== STEP 10: IDE & BROWSER SHORTCUTS ======
step_shortcuts() {
    update_progress
    echo -e "${PURPLE} Constructing Graphical Application Shortcuts...${NC}"
    
    mkdir -p ~/Desktop
    
    # Visual Studio Code (Mandates --no-sandbox)
    cat > ~/Desktop/VSCode.desktop << 'EOF'

Name=VS Code
Comment=Code Editor
Exec=code-oss --no-sandbox
Icon=code-oss
Type=Application
Categories=Development;
EOF
    
    # Google Chromium (Mandates --no-sandbox)
    cat > ~/Desktop/Chromium.desktop << 'EOF'

Name=Chromium
Comment=Web Browser
Exec=chromium --no-sandbox
Icon=chromium
Type=Application
Categories=Network;WebBrowser;
EOF

    # Mozilla Firefox
    cat > ~/Desktop/Firefox.desktop << 'EOF'

Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
EOF

    # Terminal
    cat > ~/Desktop/Terminal.desktop << 'EOF'

Name=Terminal
Comment=XFCE Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
EOF

    chmod +x ~/Desktop/*.desktop 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Desktop shortcuts bound."
}

# ============== MAIN EXECUTION THREAD ==============
main() {
    show_banner
    
    echo -e "${WHITE}  Executing payload sequence for MediaTek Developer Workspace.${NC}"
    echo -e "${GRAY}  Target: Code-OSS, Chromium, Firefox, XFCE4, GPU Translation.${NC}"
    echo ""
    echo -e "${YELLOW}  Acknowledge execution by pressing Enter...${NC}"
    read
    
    step_update
    step_repos
    step_x11
    step_desktop
    step_gpu
    step_audio
    step_toolchain
    step_scaling
    step_launchers
    step_shortcuts
    
    echo ""
    echo -e "${GREEN}  ✅ DEPLOYMENT COMPLETED SUCCESSFULLY ✅${NC}"
    echo ""
    echo -e "${WHITE}  To launch the workspace: ${GREEN}bash ~/start-workspace.sh${NC}"
    echo -e "${WHITE}  To halt the workspace:   ${GREEN}bash ~/stop-workspace.sh${NC}"
    echo ""
}

main
