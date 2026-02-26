# Server Setup (Ubuntu 24.04)

서버 초기 세팅 자동화 스크립트 및 dotfiles 관리

## 사용법

### 최초 설치 (새 서버)

```bash
# 방법 1: 리포 클론 후 실행
git clone https://github.com/YOUR_ID/server-setup.git ~/server-setup
cd ~/server-setup && bash install.sh

# 방법 2: 원라이너 (리포 자동 클론)
curl -fsSL https://raw.githubusercontent.com/YOUR_ID/server-setup/main/install.sh | bash
```

### dotfiles 수정 후 다른 서버에 반영

```bash
# 수정한 서버에서
cd ~/server-setup && git add -A && git commit -m "메시지" && git push

# 다른 서버에서 (심볼릭 링크 덕분에 pull만 하면 즉시 반영)
cd ~/server-setup && git pull

# 새 dotfile을 추가한 경우에만
bash dotfiles/link.sh
```

---

## 구조

```
server-setup/
├── install.sh              # 패키지 설치 + 도구 세팅 + dotfiles 링크 (최초 1회)
├── dotfiles/
│   ├── .zshrc              # Zsh 설정 (Oh My Zsh + 플러그인)
│   ├── .tmux.conf.local    # Tmux 설정 (gpakosz/.tmux 개인화)
│   ├── vim_my_configs.vim  # Vim 설정 (amix/vimrc 개인화)
│   └── link.sh             # 심볼릭 링크 스크립트
├── .gitignore
└── README.md
```

### 디렉토리 전략

OS별 폴더 분리 없이 단일 구조로 관리한다.
현재 Ubuntu 24.04 전용이며, 다른 OS가 필요해지면 그때 분리를 고려한다.
서버 대부분이 같은 OS라면 분리는 과잉 설계다.

---

## 설치 패키지 상세

### 기본 도구

| 패키지 | 설명 | 사용 예시 |
|--------|------|-----------|
| `net-tools` | ifconfig, netstat 등 네트워크 진단 | `ifconfig`, `netstat -tulnp` |
| `curl` | URL 요청/다운로드 | `curl -fsSL https://example.com/script.sh \| bash` |
| `wget` | 파일 다운로드 (이어받기 지원) | `wget -c https://example.com/file.tar.gz` |
| `git` | 버전 관리 | `git clone`, `git pull` |
| `unzip` | zip 압축 해제 | `unzip archive.zip -d /target/` |
| `tree` | 디렉토리 트리 시각화 | `tree -L 2 /var/www/` |
| `jq` | JSON 파싱/필터링 (API 응답 처리 필수) | `curl api.example.com \| jq '.data[0].name'` |

### 모니터링

| 패키지 | 설명 | 사용 예시 |
|--------|------|-----------|
| `htop` | 프로세스 모니터 (top 대체, 컬러/마우스 지원) | `htop` → F6으로 정렬, F5로 트리뷰 |
| `iotop` | 디스크 I/O 모니터 (어떤 프로세스가 디스크를 쓰는지) | `sudo iotop -o` (활동중인 것만) |
| `ncdu` | 디스크 사용량 분석 (du 대체, 대화형 UI) | `ncdu /var/log/` → 큰 파일/폴더 탐색 |

### 모던 CLI (기존 명령어 대체)

| 패키지 | 대체 대상 | 장점 | 사용 예시 |
|--------|----------|------|-----------|
| `fzf` | Ctrl+R | 퍼지 검색으로 히스토리/파일 탐색 | `Ctrl+R` → 부분 타이핑으로 명령어 검색 |
| `bat` | cat | 구문 강조 + 줄 번호 자동 표시 | `bat config.yaml` |
| `ripgrep` | grep | 10배 이상 빠른 검색, .gitignore 자동 무시 | `rg "TODO" --type py` |
| `fd-find` | find | 직관적 문법, 빠름 | `fd "\.log$" /var/` (find보다 간결) |
| `glow` | cat (마크다운) | 터미널에서 마크다운 렌더링 | `glow README.md` |
| `catimg` | - | 터미널에서 이미지 표시 | `img photo.jpg` (alias 설정됨) |

### 보안

| 패키지 | 설명 | 사용 예시 |
|--------|------|-----------|
| `fail2ban` | SSH 브루트포스 자동 차단 (기본 5회 실패 → IP 밴) | `sudo fail2ban-client status sshd` |
| `ufw` | 방화벽 (iptables 간편 래퍼) | `sudo ufw allow 80`, `sudo ufw status` |

### 네트워크

| 패키지 | 설명 | 사용 예시 |
|--------|------|-----------|
| `vnstat` | 누적 트래픽 통계 (일/월/년). 데몬이 기록, CPU 부하 거의 0 | `vnstat` (요약), `vnstat -m` (월별), `vnstat -d` (일별) |
| `nload` | 실시간 대역폭 그래프 (송수신) | `nload` |
| `iftop` | 실시간 연결별 대역폭 (어떤 IP가 트래픽 쓰는지) | `sudo iftop` |
| `mtr` | traceroute + ping 합친 네트워크 경로 진단 | `mtr google.com` |
| `dnsutils` | dig, nslookup 등 DNS 조회 | `dig example.com` |
| `iperf3` | 두 서버 간 대역폭 측정 (필요할 때만 서버 띄워서 사용) | `iperf3 -s` (서버), `iperf3 -c IP` (클라이언트) |

### 개발

| 패키지 | 설명 | 사용 예시 |
|--------|------|-----------|
| `build-essential` | gcc, g++, make 등 C/C++ 빌드 도구 모음 | 소스 빌드 시 필요 |
| `python3-pip` | Python 패키지 관리자 | `pip install requests` |
| `Docker` + `Compose` | 컨테이너 런타임 | `docker compose up -d` |

### 기타 유틸

| 패키지 | 설명 | 사용 예시 |
|--------|------|-----------|
| `rsync` | 파일/디렉토리 동기화 (scp보다 빠르고 이어받기 지원) | `rsync -avz ./data/ user@server:/backup/` |
| `lsof` | 열린 파일/포트/프로세스 조회 | `lsof -i :8080` (8080 포트 누가 쓰는지) |

---

## Zsh + Oh My Zsh

### Oh My Zsh란?

Zsh 설정 프레임워크. 테마, 플러그인, alias를 한번에 관리한다.
bash 대비 자동완성, 히스토리 공유, 경로 교정 등이 기본 탑재되어 있다.

### 테마: agnoster

Git 브랜치, 경로, 사용자 정보를 컬러 세그먼트로 보여주는 프롬프트.
Powerline 폰트가 필요하다 (로컬 터미널 앱에 설치해야 함).
폰트 없이 쓸 거면 `robbyrussell` (기본 테마)로 변경.

### 적용된 플러그인

| 플러그인 | 설명 |
|---------|------|
| `git` | git alias 모음. `gst`=status, `ga`=add, `gc`=commit, `gp`=push, `gl`=log 등 |
| `z` | 자주 가는 디렉토리 빠른 이동. `z project` → 최근 방문한 project 경로로 점프 |
| `docker` | docker 명령어 자동완성 + alias |
| `docker-compose` | docker compose 자동완성 |
| `fzf` | `Ctrl+R` 히스토리 퍼지 검색. 부분 타이핑만으로 과거 명령어를 찾는다 |
| `zsh-autosuggestions` | 히스토리 기반 자동완성. 회색 글씨로 제안 → `→` 화살표로 적용 |
| `zsh-syntax-highlighting` | 명령어 실시간 구문 강조. 유효한 명령=초록, 오류=빨강 |

### 추가된 alias

```bash
ll          # ls -alFh (상세 목록)
cat         # bat으로 대체 (구문 강조)
grep        # ripgrep으로 대체 (빠른 검색)
dc          # docker compose
dps         # docker ps (이름/상태/포트만 깔끔하게)
dlog        # docker logs -f (실시간 로그)
gs/gd/gl    # git status / diff / log --oneline --graph
ports       # 열린 포트 확인 (ss -tulnp)
myip        # 서버 외부 IP 확인
img         # catimg (터미널 이미지 뷰어, 창 크기 자동 맞춤)
claude      # claude --dangerously-skip-permissions
traffic     # vnstat (누적 트래픽 통계)
bandwidth   # nload (실시간 대역폭)
```

### 서버별 개별 설정

서버마다 다른 PATH, alias 등은 `~/.zshrc.local`에 넣는다 (자동 로드됨, gitignore 대상).

---

## Tmux + Oh My Tmux (gpakosz/.tmux)

### Oh My Tmux란?

gpakosz/.tmux 프로젝트. 설치하면 예쁜 상태바, 유용한 기본 설정이 한번에 적용된다.
`.tmux.conf`는 gpakosz가 관리하고, `.tmux.conf.local`에서 개인화한다.

### 적용된 설정

**상태바**
- 하단 → 상단으로 이동 (`set -g status-position top`)
- gpakosz 테마 기반 (배터리, 날짜, 호스트명 등 표시)
- 색상 커스터마이징 가능 (설정 파일 내 주석 참고)

**마우스**
- `set -g mouse on` → 패널 클릭 이동, 스크롤, 드래그 리사이즈 모두 지원

**패널 이동**
- `Ctrl + h/j/k/l` → vim-tmux-navigator 연동
- vim 분할창 안에서는 vim 분할창 이동
- vim 바깥 tmux 패널에서는 tmux 패널 이동
- **vim 분할창 ↔ tmux 패널 경계도 자유롭게 넘나든다** (vim-tmux-navigator)

**키 바인딩**

| 키 | 기능 |
|----|------|
| `prefix + \|` | 수직 분할 (현재 경로 유지) |
| `prefix + -` | 수평 분할 (현재 경로 유지) |
| `prefix + c` | 새 윈도우 (현재 경로 유지) |
| `Ctrl + h/j/k/l` | 패널 이동 (prefix 없이 바로) |
| `prefix + H/J/K/L` | 패널 크기 조절 |
| `prefix + r` | 설정 리로드 |

**기타**
- 윈도우/패널 인덱스 1부터 시작
- ESC 딜레이 제거 (vim 사용 시 필수)
- 256 컬러 + True Color 지원
- 히스토리 버퍼 10,000줄

---

## Vim + amix/vimrc

### amix/vimrc란?

"The Ultimate vimrc". 합리적인 기본 설정 + 유용한 매핑을 제공한다.
basic 버전 사용 (플러그인 없이 설정만, 서버에서 가볍게 쓰기 적합).
`.vimrc`는 amix가 관리하고, `~/.vim_runtime/my_configs.vim`에서 개인화한다.

### 적용된 설정

**표시**
- 줄 번호 + 상대 줄 번호 (이동할 줄 수 한눈에 파악)
- 현재 줄 하이라이트
- 스크롤 시 위아래 8줄 여백 유지

**들여쓰기**
- 기본 4칸 스페이스 (탭 → 스페이스 변환)
- yaml, json, js, html, css는 자동으로 2칸

**검색**
- 대소문자 스마트 검색 (소문자만 입력 → 무시, 대문자 포함 → 구분)
- 실시간 검색 + 결과 하이라이트

**클립보드**
- `set clipboard=unnamedplus` 적용
- vim에서 `v`로 블록 지정 → `y`로 복사하면 시스템 클립보드에 저장
- **단, SSH 원격 서버에서는 로컬 PC 클립보드로 직접 전달이 안 된다**
- 로컬에서 직접 vim을 쓸 때는 잘 동작함
- SSH에서 클립보드 연동이 필요하면: 터미널 앱의 OSC 52 지원을 켜거나, tmux의 마우스 선택 후 터미널 앱의 복사 기능을 사용

**키 매핑**

| 키 | 모드 | 기능 |
|----|------|------|
| `jk` | Insert | ESC 대신 INSERT 모드 탈출 |
| `Ctrl + h/j/k/l` | Normal | 분할창/패널 이동 (vim-tmux-navigator가 자동 처리) |
| `Ctrl + s` | Normal/Insert | 저장 |
| `Ctrl + a` | Normal | 전체 선택 |
| `J / K` | Visual | 선택한 블록 위/아래로 이동 |
| `leader + nh` | Normal | 검색 하이라이트 끄기 |

**Ctrl+hjkl과 tmux 패널 이동의 관계 (vim-tmux-navigator)**
- `Ctrl+hjkl` 하나로 vim 분할창과 tmux 패널을 모두 이동한다
- vim 분할창 → vim 분할창: vim이 처리
- tmux 패널 → tmux 패널: tmux가 처리
- **vim 분할창 → tmux 패널 (경계 넘기)**: vim-tmux-navigator가 자동 감지하여 전환
- vim 플러그인(~/.vim/pack)과 tmux 설정(.tmux.conf.local) 양쪽에 설치되어 있다
