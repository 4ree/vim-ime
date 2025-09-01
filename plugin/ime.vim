if exists('g:loaded_input_method_auto') || &compatible
  finish
endif
let g:loaded_input_method_auto = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

" Configuration variables
if !exists('g:input_method_auto_enable')
  let g:input_method_auto_enable = 1
endif

if !exists('g:input_method_auto_debug')
  let g:input_method_auto_debug = 0
endif

" Plugin state
let s:input_method = 'none'
let s:initialized = 0

" Debug function
function! s:debug(msg) abort
  if g:input_method_auto_debug
    echom '[input-method-auto] ' . a:msg
  endif
endfunction

" Detect input method
function! s:detect_input_method() abort
  " Check fcitx5
  if executable('fcitx5-remote')
    let fcitx5_running = system('pgrep -x fcitx5 >/dev/null 2>&1; echo $?')
    if str2nr(fcitx5_running) == 0
      call s:debug('Detected fcitx5')
      return 'fcitx5'
    endif
  endif
  
  " Check fcitx4
  if executable('fcitx-remote')
    let fcitx_running = system('pgrep -x fcitx >/dev/null 2>&1; echo $?')
    if str2nr(fcitx_running) == 0
      call s:debug('Detected fcitx4')
      return 'fcitx'
    endif
  endif
  
  " Check ibus
  if executable('ibus')
    let ibus_running = system('pgrep -x ibus-daemon >/dev/null 2>&1; echo $?')
    if str2nr(ibus_running) == 0
      call s:debug('Detected ibus')
      return 'ibus'
    endif
  endif
  
  call s:debug('No input method detected')
  return 'none'
endfunction

" fcitx functions
function! s:fcitx_off() abort
  try
    if s:input_method == 'fcitx5'
      let l:status = str2nr(substitute(system('fcitx5-remote'), '\n', '', 'g'))
      let g:input_method_auto_prev_state = l:status
      if l:status == 2
        silent! call system('fcitx5-remote -c')
        call s:debug('fcitx5 turned off')
      endif
    elseif s:input_method == 'fcitx'
      let l:status = str2nr(substitute(system('fcitx-remote'), '\n', '', 'g'))
      let g:input_method_auto_prev_state = l:status
      if l:status == 2
        silent! call system('fcitx-remote -c')
        call s:debug('fcitx turned off')
      endif
    endif
  catch
    call s:debug('Error in fcitx_off: ' . v:exception)
  endtry
endfunction

function! s:fcitx_on() abort
  try
    if s:input_method == 'fcitx5'
      let l:status = str2nr(substitute(system('fcitx5-remote'), '\n', '', 'g'))
      if l:status == 1 && exists('g:input_method_auto_prev_state') && g:input_method_auto_prev_state == 2
        silent! call system('fcitx5-remote -o')
        call s:debug('fcitx5 restored')
      endif
    elseif s:input_method == 'fcitx'
      let l:status = str2nr(substitute(system('fcitx-remote'), '\n', '', 'g'))
      if l:status == 1 && exists('g:input_method_auto_prev_state') && g:input_method_auto_prev_state == 2
        silent! call system('fcitx-remote -o')
        call s:debug('fcitx restored')
      endif
    endif
  catch
    call s:debug('Error in fcitx_on: ' . v:exception)
  endtry
endfunction

" ibus functions
function! s:ibus_off() abort
  " Lưu engine hiện tại
  let g:ibus_prev_engine = substitute(system('ibus engine'), '\n', '', 'g')
  call s:debug('ibus_off: saved engine = ' . g:ibus_prev_engine)
  " Chuyển sang engine tiếng Anh
  silent! call system('ibus engine xkb:us::eng')
  let result = substitute(system('ibus engine'), '\n', '', 'g')
  call s:debug('ibus_off: switched to = ' . result)
endfunction

function! s:ibus_on() abort
  let l:current_engine = substitute(system('ibus engine'), '\n', '', 'g')
  call s:debug('ibus_on: current = ' . l:current_engine)
  " nếu engine được set trong normal mode thì
  " lúc vào insert mode dùng luôn engine đó
  if l:current_engine !~? 'xkb:us::eng'
    let g:ibus_prev_engine = l:current_engine
    call s:debug('ibus_on: updated saved engine = ' . l:current_engine)
  endif
  " Khôi phục lại engine
  if exists('g:ibus_prev_engine') && !empty(g:ibus_prev_engine)
    silent! call system('ibus engine ' . shellescape(g:ibus_prev_engine))
    let result = substitute(system('ibus engine'), '\n', '', 'g')
    call s:debug('ibus_on: restored to = ' . result)
  endif
endfunction

" Unified interface
function! s:input_method_off() abort
  if s:input_method == 'fcitx5' || s:input_method == 'fcitx'
    call s:fcitx_off()
  elseif s:input_method == 'ibus'
    call s:ibus_off()
  endif
endfunction

function! s:input_method_on() abort
  if s:input_method == 'fcitx5' || s:input_method == 'fcitx'
    call s:fcitx_on()
  elseif s:input_method == 'ibus'
    call s:ibus_on()
  endif
endfunction

" Initialize function
function! s:init() abort
  if s:initialized
    return
  endif
  
  let s:input_method = s:detect_input_method()
  
  if s:input_method != 'none'
    augroup InputMethodAuto
      autocmd!
      autocmd CmdLineEnter [/?] silent call s:input_method_on()
      autocmd CmdLineLeave [/?] silent call s:input_method_off()
      autocmd CmdLineEnter \? silent call s:input_method_on()
      autocmd CmdLineLeave \? silent call s:input_method_off()
      autocmd InsertEnter * silent call s:input_method_on()
      autocmd InsertLeave * silent call s:input_method_off()
      autocmd VimEnter * silent call s:input_method_off()
      " Remove the problematic FocusLost and FocusGained autocmds
      " autocmd FocusLost * silent call s:input_method_off()
      " autocmd FocusGained * silent call s:input_method_off()
    augroup END
    
    call s:input_method_off()
    let s:initialized = 1
    
    if g:input_method_auto_debug
      echo 'Input method auto initialized: ' . s:input_method
    endif
  else
    if g:input_method_auto_debug
      echo 'No supported input method found'
    endif
  endif
endfunction

" Public functions
function! InputMethodAutoToggle() abort
  if s:input_method != 'none'
    call s:input_method_on()
    echo 'Input method temporarily enabled'
  else
    echo 'No input method detected'
  endif
endfunction

function! InputMethodAutoStatus() abort
  echo 'Input method: ' . s:input_method . ' | Initialized: ' . (s:initialized ? 'yes' : 'no')
endfunction

function! InputMethodAutoReset() abort
  let s:initialized = 0
  autocmd! InputMethodAuto
  call s:init()
  echo 'Input method auto reset'
endfunction

" Commands
command! InputMethodAutoToggle call InputMethodAutoToggle()
command! InputMethodAutoStatus call InputMethodAutoStatus()
command! InputMethodAutoReset call InputMethodAutoReset()

" Key mapping
if !exists('g:input_method_auto_no_mappings') || !g:input_method_auto_no_mappings
  nnoremap <silent> <leader>im :call InputMethodAutoToggle()<CR>
endif

" Initialize if enabled
if g:input_method_auto_enable
  call s:init()
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo
