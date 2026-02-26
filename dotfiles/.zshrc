#===============================================================================
# Oh My Zsh 설정
#===============================================================================
export ZSH="$HOME/.oh-my-zsh"

# 테마 (agnoster: git 브랜치 표시, 경로 축약, 깔끔한 프롬프트)
# 다른 추천: robbyrussell(기본, 가벼움), powerlevel10k(고급, 별도설치 필요)
ZSH_THEME="agnoster"

# 플러그인
plugins=(
    git                       # git alias 모음 (gst=status, ga=add, gc=commit 등)
    z                         # 자주 가는 디렉토리 빠른 이동 (z project → 최근 project 경로)
    docker                    # docker 자동완성 + alias
    docker-compose            # docker-compose 자동완성
    fzf                       # Ctrl+R 퍼지 히스토리 검색
    zsh-autosuggestions       # 히스토리 기반 자동 완성 (→ 로 적용)
    zsh-syntax-highlighting   # 명령어 실시간 구문 강조 (유효=초록, 오류=빨강)
)

source $ZSH/oh-my-zsh.sh

#===============================================================================
# 환경변수
#===============================================================================
export LANG=en_US.UTF-8
export EDITOR='vim'

# ~/.local/bin (bat, fd 심볼릭 등)
export PATH="$HOME/.local/bin:$PATH"

#===============================================================================
# Alias
#===============================================================================
# 시스템
alias ll='ls -alFh'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'

# 모던 CLI (설치되어 있을 때만)
command -v bat &>/dev/null && alias cat='bat --paging=never'
command -v rg &>/dev/null && alias grep='rg'

# 디스크/프로세스
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Docker
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlog='docker logs -f'

# Git (oh-my-zsh git 플러그인과 별도로 자주 쓰는 것)
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph -20'

# 서버 관리
alias ports='sudo ss -tulnp'
alias myip='curl -s ifconfig.me && echo'
alias traffic='vnstat'
alias bandwidth='nload'

# 마크다운
alias md='glow'
alias img='catimg -w $(tput cols)'

# Claude Code
alias claude='claude --dangerously-skip-permissions'

#===============================================================================
# 서버별 개별 설정 로드
#===============================================================================
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
