"===============================================================================
" amix/vimrc 개인화 설정
" 이 파일은 ~/.vim_runtime/my_configs.vim 으로 링크됩니다.
" amix/vimrc가 기본 설정을 제공하고, 여기서 추가/덮어쓰기합니다.
"===============================================================================

"---------------------------------------
" 표시
"---------------------------------------
set number                  " 줄 번호 표시
set relativenumber          " 상대 줄 번호 (이동할 줄 수 파악에 유용)
set cursorline              " 현재 줄 하이라이트
set scrolloff=8             " 스크롤 시 위아래 8줄 여백 유지
set signcolumn=yes          " 왼쪽 사인 컬럼 항상 표시 (화면 흔들림 방지)

"---------------------------------------
" 들여쓰기
"---------------------------------------
set tabstop=4               " 탭 = 4칸
set shiftwidth=4            " 자동 들여쓰기 4칸
set softtabstop=4
set expandtab               " 탭 → 스페이스
set smartindent             " 스마트 들여쓰기

"---------------------------------------
" 검색
"---------------------------------------
set ignorecase              " 검색 시 대소문자 무시
set smartcase               " 대문자 입력 시 대소문자 구분
set hlsearch                " 검색 결과 하이라이트
set incsearch               " 입력 중 실시간 검색

"---------------------------------------
" 편의
"---------------------------------------
set mouse=a                 " 마우스 지원
set updatetime=250          " 스왑 파일 갱신 주기 (ms)
set undofile                " undo 히스토리 파일로 저장 (종료 후에도 undo 가능)
set splitbelow              " 수평 분할 시 아래로
set splitright              " 수직 분할 시 오른쪽으로

"---------------------------------------
" 클립보드
"---------------------------------------
" v로 블록 지정 → y로 복사 → 시스템 클립보드에 저장
" * 로컬 환경(GUI): 바로 동작
" * SSH 원격 서버: 서버에는 클립보드 개념이 없으므로 로컬 PC로 직접 전달 안 됨
"   → 대안 1: 터미널 앱(iTerm2, Windows Terminal)에서 OSC 52 지원 켜기
"   → 대안 2: tmux 마우스 드래그 선택 후 터미널 앱의 복사 기능 사용
"   → 대안 3: 마우스로 드래그 후 Ctrl+Shift+C (터미널 복사)
set clipboard=unnamedplus

"---------------------------------------
" 키 매핑
"---------------------------------------
" 리더 키 (amix/vimrc 기본: ,)
" let mapleader = " "       " 스페이스를 리더로 쓰고 싶으면 주석 해제

" jk로 INSERT 모드 탈출 (ESC 대신)
inoremap jk <ESC>

" vim 분할창 ↔ tmux 패널 이동 (Ctrl + hjkl)
" vim-tmux-navigator 플러그인이 자동으로 처리한다.
" vim 분할창 안에서도, tmux 패널 경계를 넘을 때도 Ctrl+hjkl로 통일.
" 별도 매핑 불필요 — 플러그인이 알아서 감지하고 전환한다.

" 검색 하이라이트 끄기
nnoremap <leader>nh :nohlsearch<CR>

" 줄 이동 (Visual 모드에서 J/K로 블록 이동)
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" 전체 선택
nnoremap <C-a> ggVG

" 저장 단축키
nnoremap <C-s> :w<CR>
inoremap <C-s> <ESC>:w<CR>

"---------------------------------------
" 파일 타입별 설정
"---------------------------------------
autocmd FileType yaml setlocal ts=2 sw=2 sts=2
autocmd FileType json setlocal ts=2 sw=2 sts=2
autocmd FileType javascript setlocal ts=2 sw=2 sts=2
autocmd FileType html setlocal ts=2 sw=2 sts=2
autocmd FileType css setlocal ts=2 sw=2 sts=2
autocmd FileType python setlocal ts=4 sw=4 sts=4

"---------------------------------------
" 불필요한 파일 정리
"---------------------------------------
set nobackup                " 백업 파일 생성 안 함
set nowritebackup
set noswapfile              " 스왑 파일 생성 안 함
