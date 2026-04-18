#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 LENOVO TAB PRO - Ultimate Dev Lab v2.5
#  Optimized for MediaTek Dimensity 8300-Ultra (Mali-G615)
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=10
CURRENT_STEP=0

# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ============== PROGRESS FUNCTIONS ==============
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    FILLED=$((PERCENT / 5))
    EMPTY=$((20 - FILLED))
    BAR="${GREEN}"
    for ((i=0; i<FILLED; i++)); do BAR+="█"; done
    BAR+="${NC}${WHITE}"
    for ((i=0; i<EMPTY; i++)); do BAR+="░"; done
    echo -e "\n${CYAN}📊 PROGRESS: ${WHITE}${PERCENT}% [${BAR}${WHITE}] Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC}\n"
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
    printf "\r  ${GREEN}✓${NC} ${message}               \n"
}

install_pkg() {
    local pkg=$1
    (pkg install $pkg -y > /dev/null 2>&1) &
    spinner $! "Installing $pkg"
}

# ============== START INSTALLATION ==============

clear
echo -e "${PURPLE}🚀 Optimizing Lenovo Tab Pro for Dev Work...${NC}"
echo -e "${GRAY}Hardware: Dimensity 8300-Ultra | 12GB RAM${NC}"

# STEP 1: SYSTEM UPDATE
update_progress
(pkg update -y && pkg upgrade -y > /dev/null 2>&1) &
spinner $! "Updating System"

# STEP 2: REPOS
update_progress
install_pkg "x11-repo"
install_pkg "tur-repo"

# STEP 3: X11 & DESKTOP
update_progress
install_pkg "termux-x11-nightly"
install_pkg "xfce4"
install_pkg "xfce4-terminal"

# STEP 4: MALI GPU ACCELERATION (ZINK)
update_progress
echo -e "${BLUE}[*] Configuring Zink for Mali-G615...${NC}"
install_pkg "mesa-zink"
install_pkg "vulkan-loader-android"
install_pkg "mesa-vulkan-icd-swrast"

# STEP 5: AUDIO
update_progress
install_pkg "pulseaudio"

# STEP 6: VS CODE & DEV TOOLS
update_progress
install_pkg "code-oss"
install_pkg "git"
install_pkg "nodejs"

# STEP 7: BROWSERS (Chrome/Firefox)
update_progress
install_pkg "firefox"
install_pkg "chromium" # Termux version of Chrome

# STEP 8: GPU CONFIGURATION
update_progress
mkdir -p ~/.config
cat > ~/.config/devlab-gpu.sh << 'GPUEOF'
# Optimization for MediaTek/Mali GPUs
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export ZINK_DESCRIPTORS=lazy
export vblank_mode=0
GPUEOF

# STEP 9: LAUNCHER SCRIPT
update_progress
cat > ~/start-desktop.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
source ~/.config/devlab-gpu.sh

# Cleanup
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null

# Audio
pulseaudio --start --exit-idle-time=-1 2>/dev/null
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null

# Start X11
termux-x11 :0 -ac &
sleep 2
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1

echo "🚀 Desktop Launching... Switch to Termux-X11 App!"
exec startxfce4
LAUNCHEREOF
chmod +x ~/start-desktop.sh

# STEP 10: SHORTCUTS
update_progress
mkdir -p ~/Desktop
cat > ~/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Exec=code-oss --no-sandbox
Icon=code-oss
Type=Application
EOF
chmod +x ~/Desktop/*.desktop

clear
echo -e "${GREEN}✅ SETUP COMPLETE!${NC}"
echo -e "${WHITE}1. Open Termux-X11 App${NC}"
echo -e "${WHITE}2. Run: ${CYAN}./start-desktop.sh${NC}"
