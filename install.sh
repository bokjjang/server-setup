#!/bin/bash
#===============================================================================
# Ubuntu 24.04 서버 초기 설정 스크립트
# 사용법: bash install.sh
#===============================================================================

set -e

# 색상 출력
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

#---------------------------------------
# 변수
#---------------------------------------
REPO_URL="https://github.com/bokjjang/server-setup.git"  # ← 본인 리포 URL로 변경
SETUP_DIR="$HOME/server-setup"

#---------------------------------------
# curl로 실행 시 리포 클론
#---------------------------------------
if [ ! -d "$SETUP_DIR/.git" ]; then
    info "리포 클론 중..."
    git clone "$REPO_URL" "$SETUP_DIR" 2>/dev/null || {
        warn "리포 클론 실패 — 이미 존재하거나 URL을 확인하세요."
        warn "수동으로 진행합니다."
    }
fi

#===============================================================================
# 1. 시스템 업데이트 + 패키지 설치
#===============================================================================
info "시스템 업데이트 중..."
sudo apt update && sudo apt upgrade -y

info "기본 패키지 설치 중..."
sudo apt install -y \
    net-tools curl wget git unzip tree jq \
    htop iotop ncdu \
    build-essential python3-pip \
    fail2ban ufw \
    zsh tmux vim

# 모던 CLI 도구
info "모던 CLI 도구 설치 중..."
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

# 네트워크 유틸리티
info "네트워크 유틸리티 설치 중..."
sudo apt install -y \
    vnstat \
    iftop \
    nload \
    mtr \
    dnsutils \
    iperf3 \
    rsync \
    lsof

# glow (마크다운 터미널 렌더러)
info "glow 설치 중..."
if ! command -v glow &>/dev/null; then
    # Ubuntu 24.04에서 snap 또는 go install로 설치
    if command -v snap &>/dev/null; then
        sudo snap install glow
    else
        # snap이 없으면 deb 패키지 직접 설치
        GLOW_VERSION="2.0.0"
        wget -q "https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/glow_${GLOW_VERSION}_amd64.deb" -O /tmp/glow.deb
        sudo dpkg -i /tmp/glow.deb
        rm -f /tmp/glow.deb
    fi
else
    info "glow 이미 설치됨 — 스킵"
fi

#===============================================================================
# 2. Docker
#===============================================================================
if ! command -v docker &>/dev/null; then
    info "Docker 설치 중..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$USER"
    info "Docker 설치 완료 (재로그인 후 sudo 없이 사용 가능)"
else
    info "Docker 이미 설치됨 — 스킵"
fi

#===============================================================================
# 3. Oh My Zsh + 플러그인
#===============================================================================
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Oh My Zsh 설치 중..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # 플러그인 설치
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    info "Zsh 플러그인 설치 중..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    info "Oh My Zsh 이미 설치됨 — 스킵"
fi

# 기본 쉘을 zsh로 변경
if [ "$SHELL" != "$(which zsh)" ]; then
    info "기본 쉘을 zsh로 변경 중..."
    sudo chsh -s "$(which zsh)" "$USER"
fi

#===============================================================================
# 4. Oh My Tmux (gpakosz/.tmux)
#===============================================================================
if [ ! -d "$HOME/.tmux" ]; then
    info "Oh My Tmux 설치 중..."
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
    ln -sf "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
else
    info "Oh My Tmux 이미 설치됨 — 스킵"
fi

#===============================================================================
# 5. Vim (amix/vimrc - basic)
#===============================================================================
if [ ! -d "$HOME/.vim_runtime" ]; then
    info "amix/vimrc 설치 중..."
    git clone --depth=1 https://github.com/amix/vimrc.git "$HOME/.vim_runtime"
    sh "$HOME/.vim_runtime/install_basic_vimrc.sh"
else
    info "amix/vimrc 이미 설치됨 — 스킵"
fi

#===============================================================================
# 6. vim-tmux-navigator (vim ↔ tmux 패널 경계 넘나들기)
#===============================================================================
VIM_NAV_DIR="$HOME/.vim/pack/plugins/start/vim-tmux-navigator"
if [ ! -d "$VIM_NAV_DIR" ]; then
    info "vim-tmux-navigator 설치 중..."
    mkdir -p "$HOME/.vim/pack/plugins/start"
    git clone https://github.com/christoomey/vim-tmux-navigator.git "$VIM_NAV_DIR"
else
    info "vim-tmux-navigator 이미 설치됨 — 스킵"
fi

#===============================================================================
# 7. UFW 방화벽
#===============================================================================
info "UFW 설정 중..."
sudo ufw allow OpenSSH
sudo ufw --force enable

#===============================================================================
# 8. Dotfiles 심볼릭 링크
#===============================================================================
info "Dotfiles 링크 중..."
if [ -d "$SETUP_DIR/dotfiles" ]; then
    bash "$SETUP_DIR/dotfiles/link.sh"
else
    warn "dotfiles 디렉토리를 찾을 수 없습니다 — 링크 스킵"
fi

#===============================================================================
# 완료
#===============================================================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN} 설치 완료!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "다음 사항을 확인하세요:"
echo "  1. 재로그인하면 zsh가 기본 쉘로 적용됩니다."
echo "  2. Docker는 재로그인 후 sudo 없이 사용 가능합니다."
echo "  3. 서버별 개별 설정은 ~/.zshrc.local 에서 관리하세요."
echo ""
echo "install.sh 상단의 REPO_URL을 본인 리포로 변경했는지 확인하세요."
echo ""
