#!/bin/bash
#===============================================================================
# Ubuntu 24.04 서버 초기 설정 스크립트 (대화형)
# 사용법: bash install.sh
#===============================================================================

set -e

#---------------------------------------
# 색상 출력
#---------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
title() { echo -e "\n${CYAN}${BOLD}═══ $1 ═══${NC}\n"; }

#---------------------------------------
# 변수
#---------------------------------------
REPO_URL="https://github.com/bokjjang/server-setup.git"
SETUP_DIR="$HOME/server-setup"

#---------------------------------------
# whiptail 존재 확인
#---------------------------------------
if ! command -v whiptail &>/dev/null; then
    error "whiptail이 없습니다. 설치 중..."
    sudo apt update && sudo apt install -y whiptail
fi

#---------------------------------------
# curl로 실행 시 리포 클론
#---------------------------------------
if [ ! -d "$SETUP_DIR/.git" ]; then
    info "리포 클론 중..."
    git clone "$REPO_URL" "$SETUP_DIR" 2>/dev/null || {
        warn "리포 클론 실패 — 이미 존재하거나 URL을 확인하세요."
    }
fi

#===============================================================================
# 설치 모드 선택
#===============================================================================
INSTALL_MODE=$(whiptail --title "Server Setup (Ubuntu 24.04)" \
    --menu "설치 모드를 선택하세요:" 15 60 3 \
    "1" "전체 설치 (새 서버 초기 세팅)" \
    "2" "선택 설치 (원하는 항목만 선택)" \
    "3" "dotfiles만 링크 (프로그램 설치 없이)" \
    3>&1 1>&2 2>&3) || exit 0

#===============================================================================
# 선택 설치: 카테고리 선택
#===============================================================================
INSTALL_SYSTEM=false
INSTALL_MODERN_CLI=false
INSTALL_NETWORK=false
INSTALL_SECURITY=false
INSTALL_DOCKER=false
INSTALL_ZSH=false
INSTALL_TMUX=false
INSTALL_VIM=false
INSTALL_DOTFILES=false

if [ "$INSTALL_MODE" = "1" ]; then
    # 전체 설치
    INSTALL_SYSTEM=true
    INSTALL_MODERN_CLI=true
    INSTALL_NETWORK=true
    INSTALL_SECURITY=true
    INSTALL_DOCKER=true
    INSTALL_ZSH=true
    INSTALL_TMUX=true
    INSTALL_VIM=true
    INSTALL_DOTFILES=true

elif [ "$INSTALL_MODE" = "2" ]; then
    # 선택 설치
    SELECTIONS=$(whiptail --title "설치 항목 선택" \
        --checklist "스페이스바로 선택/해제, 엔터로 확인:" 20 70 9 \
        "SYSTEM"     "기본 패키지 (curl, git, htop, jq 등)" ON \
        "MODERN_CLI" "모던 CLI (fzf, bat, ripgrep, catimg 등)" ON \
        "NETWORK"    "네트워크 (vnstat, nload, iftop, mtr 등)" ON \
        "SECURITY"   "보안 (fail2ban, ufw)" ON \
        "DOCKER"     "Docker + Docker Compose" ON \
        "ZSH"        "Zsh + Oh My Zsh + 플러그인" ON \
        "TMUX"       "Tmux + Oh My Tmux (gpakosz)" ON \
        "VIM"        "Vim + amix/vimrc + vim-tmux-navigator" ON \
        "DOTFILES"   "Dotfiles 심볼릭 링크" ON \
        3>&1 1>&2 2>&3) || exit 0

    [[ "$SELECTIONS" == *"SYSTEM"*     ]] && INSTALL_SYSTEM=true
    [[ "$SELECTIONS" == *"MODERN_CLI"* ]] && INSTALL_MODERN_CLI=true
    [[ "$SELECTIONS" == *"NETWORK"*    ]] && INSTALL_NETWORK=true
    [[ "$SELECTIONS" == *"SECURITY"*   ]] && INSTALL_SECURITY=true
    [[ "$SELECTIONS" == *"DOCKER"*     ]] && INSTALL_DOCKER=true
    [[ "$SELECTIONS" == *"ZSH"*        ]] && INSTALL_ZSH=true
    [[ "$SELECTIONS" == *"TMUX"*       ]] && INSTALL_TMUX=true
    [[ "$SELECTIONS" == *"VIM"*        ]] && INSTALL_VIM=true
    [[ "$SELECTIONS" == *"DOTFILES"*   ]] && INSTALL_DOTFILES=true

elif [ "$INSTALL_MODE" = "3" ]; then
    # dotfiles만
    INSTALL_DOTFILES=true
fi

#---------------------------------------
# 선택 확인
#---------------------------------------
SUMMARY="설치 항목:\n"
$INSTALL_SYSTEM     && SUMMARY+="  ✓ 기본 패키지\n"
$INSTALL_MODERN_CLI && SUMMARY+="  ✓ 모던 CLI\n"
$INSTALL_NETWORK    && SUMMARY+="  ✓ 네트워크 유틸\n"
$INSTALL_SECURITY   && SUMMARY+="  ✓ 보안 (fail2ban, ufw)\n"
$INSTALL_DOCKER     && SUMMARY+="  ✓ Docker\n"
$INSTALL_ZSH        && SUMMARY+="  ✓ Zsh + Oh My Zsh\n"
$INSTALL_TMUX       && SUMMARY+="  ✓ Tmux + Oh My Tmux\n"
$INSTALL_VIM        && SUMMARY+="  ✓ Vim + amix/vimrc\n"
$INSTALL_DOTFILES   && SUMMARY+="  ✓ Dotfiles 링크\n"

whiptail --title "설치 확인" --yesno "$SUMMARY\n진행하시겠습니까?" 20 60 || exit 0

#===============================================================================
# 시스템 업데이트 (패키지 설치가 하나라도 있으면)
#===============================================================================
if $INSTALL_SYSTEM || $INSTALL_MODERN_CLI || $INSTALL_NETWORK || $INSTALL_SECURITY || $INSTALL_ZSH || $INSTALL_TMUX || $INSTALL_VIM; then
    title "시스템 업데이트"
    sudo apt update && sudo apt upgrade -y
fi

#===============================================================================
# 1. 기본 패키지
#===============================================================================
if $INSTALL_SYSTEM; then
    title "기본 패키지 설치"
    sudo apt install -y \
        net-tools curl wget git unzip tree jq \
        htop iotop ncdu \
        build-essential python3-pip \
        zsh tmux vim \
        rsync lsof
fi

#===============================================================================
# 2. 모던 CLI
#===============================================================================
if $INSTALL_MODERN_CLI; then
    title "모던 CLI 도구 설치"
    sudo apt install -y fzf bat ripgrep fd-find catimg

    # bat → batcat 심볼릭 (Ubuntu에서는 batcat으로 설치됨)
    if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
        mkdir -p ~/.local/bin
        ln -sf "$(which batcat)" ~/.local/bin/bat
    fi

    # fd → fdfind 심볼릭 (Ubuntu에서는 fdfind로 설치됨)
    if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        mkdir -p ~/.local/bin
        ln -sf "$(which fdfind)" ~/.local/bin/fd
    fi

    # glow (마크다운 터미널 렌더러)
    if ! command -v glow &>/dev/null; then
        info "glow 설치 중..."
        if command -v snap &>/dev/null; then
            sudo snap install glow
        else
            GLOW_VERSION="2.0.0"
            wget -q "https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/glow_${GLOW_VERSION}_amd64.deb" -O /tmp/glow.deb
            sudo dpkg -i /tmp/glow.deb
            rm -f /tmp/glow.deb
        fi
    else
        info "glow 이미 설치됨 — 스킵"
    fi
fi

#===============================================================================
# 3. 네트워크 유틸리티
#===============================================================================
if $INSTALL_NETWORK; then
    title "네트워크 유틸리티 설치"
    sudo apt install -y \
        vnstat \
        iftop \
        nload \
        mtr \
        dnsutils \
        iperf3
fi

#===============================================================================
# 4. 보안
#===============================================================================
if $INSTALL_SECURITY; then
    title "보안 패키지 설치"
    sudo apt install -y fail2ban ufw

    info "UFW 설정 중..."
    sudo ufw allow OpenSSH
    sudo ufw --force enable
fi

#===============================================================================
# 5. Docker
#===============================================================================
if $INSTALL_DOCKER; then
    title "Docker 설치"
    if ! command -v docker &>/dev/null; then
        curl -fsSL https://get.docker.com | sudo sh
        sudo usermod -aG docker "$USER"
        info "Docker 설치 완료 (재로그인 후 sudo 없이 사용 가능)"
    else
        info "Docker 이미 설치됨 — 스킵"
    fi
fi

#===============================================================================
# 6. Oh My Zsh + 플러그인
#===============================================================================
if $INSTALL_ZSH; then
    title "Oh My Zsh 설치"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        info "Oh My Zsh 이미 설치됨 — 스킵"
    fi

    # 플러그인 (Oh My Zsh 설치 여부와 별도로 체크)
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        info "zsh-autosuggestions 설치 중..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    else
        info "zsh-autosuggestions 이미 설치됨 — 스킵"
    fi

    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        info "zsh-syntax-highlighting 설치 중..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    else
        info "zsh-syntax-highlighting 이미 설치됨 — 스킵"
    fi

    # 기본 쉘 변경
    if [ "$SHELL" != "$(which zsh)" ]; then
        info "기본 쉘을 zsh로 변경 중..."
        sudo chsh -s "$(which zsh)" "$USER"
    fi
fi

#===============================================================================
# 7. Oh My Tmux (gpakosz/.tmux)
#===============================================================================
if $INSTALL_TMUX; then
    title "Oh My Tmux 설치"
    if [ ! -d "$HOME/.tmux" ]; then
        git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
        ln -sf "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
    else
        info "Oh My Tmux 이미 설치됨 — 스킵"
    fi
fi

#===============================================================================
# 8. Vim + amix/vimrc + vim-tmux-navigator
#===============================================================================
if $INSTALL_VIM; then
    title "Vim 설정 (amix/vimrc + vim-tmux-navigator)"
    if [ ! -d "$HOME/.vim_runtime" ]; then
        info "amix/vimrc 설치 중..."
        git clone --depth=1 https://github.com/amix/vimrc.git "$HOME/.vim_runtime"
        sh "$HOME/.vim_runtime/install_basic_vimrc.sh"
    else
        info "amix/vimrc 이미 설치됨 — 스킵"
    fi

    VIM_NAV_DIR="$HOME/.vim/pack/plugins/start/vim-tmux-navigator"
    if [ ! -d "$VIM_NAV_DIR" ]; then
        info "vim-tmux-navigator 설치 중..."
        mkdir -p "$HOME/.vim/pack/plugins/start"
        git clone https://github.com/christoomey/vim-tmux-navigator.git "$VIM_NAV_DIR"
    else
        info "vim-tmux-navigator 이미 설치됨 — 스킵"
    fi
fi

#===============================================================================
# 9. Dotfiles 심볼릭 링크
#===============================================================================
if $INSTALL_DOTFILES; then
    title "Dotfiles 링크"
    if [ -d "$SETUP_DIR/dotfiles" ]; then
        bash "$SETUP_DIR/dotfiles/link.sh"
    else
        warn "dotfiles 디렉토리를 찾을 수 없습니다 — 링크 스킵"
    fi
fi

#===============================================================================
# 완료
#===============================================================================
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║            설치 완료!                    ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "다음 사항을 확인하세요:"
$INSTALL_ZSH     && echo -e "  ${CYAN}•${NC} 재로그인하면 zsh가 기본 쉘로 적용됩니다."
$INSTALL_DOCKER  && echo -e "  ${CYAN}•${NC} Docker는 재로그인 후 sudo 없이 사용 가능합니다."
$INSTALL_ZSH     && echo -e "  ${CYAN}•${NC} 서버별 개별 설정은 ~/.zshrc.local 에서 관리하세요."
$INSTALL_NETWORK && echo -e "  ${CYAN}•${NC} vnstat 데몬이 트래픽 기록을 시작합니다. vnstat -m 으로 월별 확인."
echo ""
