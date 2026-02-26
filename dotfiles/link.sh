#!/bin/bash
#===============================================================================
# dotfiles 심볼릭 링크 스크립트
# install.sh에서 자동 호출되며, dotfile 추가 시 수동으로도 실행 가능
#===============================================================================

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

link_file() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        ln -sf "$src" "$dest"
        echo -e "${GREEN}[UPDATED]${NC} $dest → $src"
    elif [ -f "$dest" ]; then
        mv "$dest" "${dest}.backup.$(date +%Y%m%d%H%M%S)"
        ln -sf "$src" "$dest"
        echo -e "${YELLOW}[BACKUP+LINK]${NC} $dest (기존 파일 백업됨)"
    else
        ln -sf "$src" "$dest"
        echo -e "${GREEN}[LINKED]${NC} $dest → $src"
    fi
}

echo "Dotfiles 링크 시작..."
echo ""

# Zsh
link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Tmux (gpakosz/.tmux 개인화)
link_file "$DOTFILES_DIR/.tmux.conf.local" "$HOME/.tmux.conf.local"

# Vim (amix/vimrc 개인화)
if [ -d "$HOME/.vim_runtime" ]; then
    link_file "$DOTFILES_DIR/vim_my_configs.vim" "$HOME/.vim_runtime/my_configs.vim"
else
    echo -e "${YELLOW}[SKIP]${NC} vim_my_configs.vim — ~/.vim_runtime 없음 (amix/vimrc 미설치)"
fi

echo ""
echo "완료!"
