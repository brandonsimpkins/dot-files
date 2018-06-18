

" ================  General Settings  ====================================

setlocal nocompatible               " vim > vi, don't use vi settings
setlocal number                     " show line numbers
setlocal cursorline                 " underline the current line
setlocal viminfo='20,\"50,<2000     " increase session info storage
setlocal wildmode=list:full         " enable completion matching for commands
setlocal wildignore=*.o,*.obj,*~    " ignore garbage
setlocal shell=/bin/bash            " set shell, required for system() calls

if version >= 700                   " if vim version > 7.0
  setlocal spelllang=en_us          " use English for spell check
  setlocal nospell                  " don't spell check by default
endif

syntax on                           " enable syntax highlighting

filetype plugin indent on           " enable filetype plugins and indentation


" ================  Remapped Key Bindings  ===============================

" Note: inline comments break key mappings, use '|' chars to end mappings

nnoremap Q <Nop>|                   " disable Ex mode mapping


" ================  Indentation Settings  ================================

setlocal autoindent         " enable autoindent based on current line
setlocal smartindent        " enable smartindent based on file type syntax
setlocal expandtab          " auto convert tabs to spaces
setlocal smarttab           " use shiftwidth vice tabstop size for tab inserts
setlocal tabstop=4          " set tab view size (in spaces)
setlocal shiftwidth=4       " set tab insert replacement size (in spaces)

" configure tab settings per file type
augroup ConfigureTabs
  autocmd!
  autocmd Filetype sh setlocal tabstop=2 shiftwidth=2
  autocmd Filetype vim setlocal tabstop=2 shiftwidth=2
augroup END


" ================  Search Settings  =====================================

setlocal incsearch          " enable incremental search
setlocal hlsearch           " highlight search matches
setlocal ignorecase         " dont match case on search ...
setlocal smartcase          " until you use caps


" ================  Highlighting And Matching  ===========================

" define highlight colors for the "OverLength" match
highlight OverLength ctermbg=red ctermfg=white

" define highlight colors for the "ExtraWhitespace" match
highlight ExtraWhitespace ctermbg=blue ctermfg=white

" Note: This resets the color of search matches
" highlight Search ctermfg=Black ctermbg=Red

" Note: This resets the color of the current line
" Note2: 'setlocal cursorline' must be enabled
" highlight CursorLine term=underline cterm=underline ctermfg=blue

" Note: This resets the color of the current column
" Note2: 'setlocal cursorcolumn' must be enabled
" setlocal cursorcolumn
" highlight CursorColumn term=underline cterm=underline ctermfg=blue

" match the end of each line that exceeds 80 characters
match OverLength /\%80v.\+/

" match tabs and trailing white space
2match ExtraWhitespace /\s\+$\|\t/

" Note: matching anything else will require the use of 3match


" ================  Status Bar  ==========================================

setlocal laststatus=2       " always show the status line
setlocal ruler              " show cursor coordinates
setlocal noshowmode         " don't show mode in status line
setlocal showcmd            " show key press commands in status line

" Note: in order to inset the '^V' character used in the 'Visual Block' key
" mapping below type <ctrl-v> + <ctrl-v> in INSERT mode

" map long labels and colors to vim modes
let g:ModeSettings={
      \ 'n'  : ['Normal',             'Green'],
      \ 'no' : ['N·Operator Pending', 'Green'],
      \ 'v'  : ['Visual',             'Magenta'],
      \ 'V'  : ['Visual Line',        'Magenta'],
      \ '' : ['Visual Block',       'Magenta'],
      \ 's'  : ['Select',             'Magenta'],
      \ 'S'  : ['S·Line',             'Magenta'],
      \ '^S' : ['S·Block',            'Magenta'],
      \ 'i'  : ['Insert',             'Blue'],
      \ 'R'  : ['Replace',            'Red'],
      \ 'Rv' : ['Virtual Replace',    'Red'],
      \ 'c'  : ['Command',            'Yellow'],
      \ 'cv' : ['Vim Ex',             'Yellow'],
      \ 'ce' : ['Ex',                 'Yellow'],
      \ 'r'  : ['Prompt',             'Yellow'],
      \ 'rm' : ['More',               'Yellow'],
      \ 'r?' : ['Confirm',            'Yellow'],
      \ '!'  : ['Shell',              'Yellow'],
      \ 't'  : ['Terminal',           'Yellow']
      \}

highlight RedModeBlock      ctermfg=0   ctermbg=1
highlight RedModeBlockNC    ctermfg=0   ctermbg=1 term=reverse      cterm=reverse
highlight GreenModeBlock    ctermfg=0   ctermbg=2  term=bold cterm=bold
highlight GreenModeBlockNC  ctermfg=0   ctermbg=2  term=reverse,bold      cterm=reverse,bold
highlight YellowModeBlock    ctermfg=0   ctermbg=3
highlight YellowModeBlockNC  ctermfg=0   ctermbg=3  term=reverse      cterm=reverse
highlight BlueModeBlock      ctermfg=0   ctermbg=4
highlight BlueModeBlockNC    ctermfg=0   ctermbg=4 term=reverse      cterm=reverse
highlight MagentaModeBlock      ctermfg=0   ctermbg=5
highlight MagentaModeBlockNC    ctermfg=0   ctermbg=5 term=reverse      cterm=reverse
highlight WhiteModeBlock      ctermfg=0   ctermbg=7
highlight WhiteModeBlockNC    ctermfg=0   ctermbg=7 term=reverse      cterm=reverse

function! GetGitStatusInfo()

  " ensure directory exists so we don't fail to cd
  if isdirectory(expand('%:p:h'))
    echom 'Determining Git Status for ' . expand('%:p')

    " change to the file's parent directory to ensure we're in the git repo if
    " one exists, query for the branch, trim the endline
    let l:branch = system('cd "' . expand('%:p:h') . '"; ' .
          \ 'git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d "\n"')

    " if we're in a branch, then we can get file status
    if (l:branch != '')
      echom 'Detected Git branch: ' . l:branch

      " change to the file's parent directory, get the short status of the
      " file, get the first 2 characters, trim the endline, replace spaces
      " with underscores?
      let l:status = system('cd "' . expand('%:p:h') . '"; ' .
            \ 'git status --short "' . expand('%:p') . '" 2>/dev/null | ' .
            \ 'cut -c1-2 | sed "s/ /./g" | tr -d "\n"' )

      "
      if l:status == ''
        let l:status='..'
      endif

      return [l:branch, l:status]
    endif
  endif

  " return unsuccessfully
  " TODO: return type seems hokey, is there an cleaner way to do this?
  echom 'File is not part of a Git repo.'
  return ['']
endfunction




function! VersionControlStatus()
  if exists('w:VersionInfo')
    return w:VersionInfo
  else
    let l:GitStatus = GetGitStatusInfo()
    if (l:GitStatus[0] != '')
      let w:VersionInfo = "Git B[" . l:GitStatus[0] . "] S[" .
            \ l:GitStatus[1] . "]"
    else
      let w:VersionInfo = ''
    endif
  endif
  return w:VersionInfo
endfunction

function! LeftItem(item)
  if a:item != ''
    return '〉' . a:item . ' '
  endif
  return ''
endfunction

function! RightItem(item)
  if a:item != ''
    return ' ' . a:item . '〈'
  endif
  return ''
endfunction



"let localbranchname = VersionControlStatus()

function! IsActiveWindow()
  if winnr() == g:active_window
    return 'This is the active window | '
  endif

  return ''
endfunction

function! ActiveFileType()
  if &filetype != ''
    return '[' . &filetype . ']'
  endif
  return ''
endfunction




" freaky black magic i still don't quite understand that reduces the delay
" after hitting the <esc> key in insert / replace mode from 1000 milliseconds
" to 10 milliseconds
set ttimeoutlen=10

function! ChangeTheme()

  " special chars   ►◤⎖⎖⎝⎝⎠⎠⎩⎩⎍⎍⌹⌹〉〉〈〉〉〉

  let mode=mode()
  let name=g:ModeSettings[mode][0]
  let color=g:ModeSettings[mode][1]

  " echom 'color: ' . color
  let status='%#' . color . 'ModeBlock#'
  let status .= ' '. name . ' '

  " more freaky black magic voodoo - call the function in the %{}
  " context to have the function evaluate in teh actual window's
  " context, not the current window context provided by %!
  let status.="%{LeftItem(VersionControlStatus())}"




  let status .='〉%f '

  " let status.='%#' . color . 'ModeBlockNC#' . '〉'


  let status.="%h"      "help file flag
  let status.="%m"      "modified flag
  let status.="%r"      "read only flag


  let status.="\ %="                        " align left
  let g:active_window=winnr()
  " let status.="%{IsActiveWindow()}"


  "let status .= 'bufnr() [' . bufnr('%') . '] actual [' . g:actual_curbuf ']  '
  " let status .= 'bufnr() [%{bufnr("%")}] actual [%{g:actual_curbuf}]  '

  let status.="Enc[%{strlen(&fenc)?&fenc:'none'}]" .  '〈'

  let status.="%{RightItem('FF['. &ff . ']')}"              "file format

  "let status.=' active window [' . g:active_window . ']   | '

  " let status .= '〈'
  " let status.='%#' . color . 'ModeBlock#'

  let status.=' Buf[%n/%{bufnr("$")}] Win[%{winnr()}]'
  let status.= '〈 [%p%%] '            " line X of Y [percent of file]

  "  let status.="\ Win:%{winnr()}"                    " Buffer number

  " let status .= '\33[2K\r'

  "let status.='%#' . color . 'ModeBlockNC#'
  " let status .= '%{AddEndline()}'

  return status
endfunction

highlight User1      ctermfg=0   ctermbg=1


function! AddEndline()
  echom 'called AddEndline()'
  if exists("g:actual_curbuf")
    echom 'var g_actual_curbuf exists'
    if g:actual_curbuf != bufnr('%')
      return '%1* < ------------------------------ not current window ----------------------------'
    endif
  endif
  return ""
endfunction


set statusline=%!ChangeTheme()               " Changing the statusline color

" saved special chars for formatting
" set statusline=%f►◤⎖⎖⎝⎝⎠⎠⎩⎩⎍⎍⌹⌹〉〉〈〈〉〉〉


" ================  Auto Commands  =======================================

" automatically remove trailing whitespace on read/write for text files
augroup StripWhitespace
  autocmd!
  autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif
augroup END


" TODO: cleanup since this was copied off the internet
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
        \| exe "normal! g'\"" | endif
endif



augroup TrackActiveWindow
  autocmd!
  autocmd WinEnter * let w:active_window = 1
  autocmd WinLeave * let w:active_window = 0
augroup END

