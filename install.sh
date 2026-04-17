#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 LENOVO TAB PRO DEV DESKTOP - Installer v1.1
#  
#  Features:
#  - Optimized for 12GB RAM / High-Res Tablet Screens
#  - GPU acceleration auto-setup (Turnip/Zink)
#  - Clean XFCE4 Desktop Environment with DPI Scaling
#  - VS Code, Firefox, Chromium pre-installed
#  - Phantom Process Killer Bypass included
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
    
    # Skipped pkg upgrade to prevent Android Phantom Process Killer from crashing Termux
    echo -e "  ${GRAY}⏭️  Skipping full upgrade to prevent Android process limits${NC}"
}

step_repos() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding repositories...${NC}"
    install_pkg "x11-repo" "X11 Repository"
    install_pkg "tur-repo" "TUR Repository (Firefox, VS Code)"
    
    # CRITICAL FIX: Refresh package lists so Termux can actually see the new apps we just added
    echo -e "  ${YELLOW}⏳${NC} Refreshing new package sources..."
    (pkg update -y >> "$INSTALL_LOG" 2>&1) &
    spinner $! "Syncing repositories..."
}

step_x11() {
    update_progress
    echo -e "${CYAN}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Display Server...${NC}"
    install_pkg "termux-x11-nightly" "Termux-X11"
    install_pkg "xorg-xrand
