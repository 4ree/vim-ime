" Automatic Input Method Handler for both fcitx5 and ibus
" This will detect which input method is available and configure accordingly

" Detect which input method system is running
function! DetectInputMethod()
    " Check if fcitx5 is running
    let fcitx5_running = system('pgrep -x fcitx5')
    if v:shell_error == 0
        return 'fcitx5'
    endif
    
    " Check if fcitx is running (fcitx4)
    let fcitx_running = system('pgrep -x fcitx')
    if v:shell_error == 0
        return 'fcitx'
    endif
    
    " Check if ibus is running
    let ibus_running = system('pgrep -x ibus-daemon')
    if v:shell_error == 0
        return 'ibus'
    endif
    
    return 'none'
endfunction

" Global variable to store the detected input method
let g:input_method = DetectInputMethod()

" fcitx5/fcitx4 functions
function! FcitxOff()
    if g:input_method == 'fcitx5'
        let l:input_status = system('fcitx5-remote')
        let g:input_lang = l:input_status
        if l:input_status == 2
            silent! execute '!fcitx5-remote -c'
        endif
    elseif g:input_method == 'fcitx'
        let l:input_status = system('fcitx-remote')
        let g:input_lang = l:input_status
        if l:input_status == 2
            silent! execute '!fcitx-remote -c'
        endif
    endif
endfunction

function! FcitxOn()
    if g:input_method == 'fcitx5'
        let l:input_status = system('fcitx5-remote')
        if l:input_status == 1 && exists('g:input_lang') && g:input_lang == 2
            silent! execute '!fcitx5-remote -o'
        endif
    elseif g:input_method == 'fcitx'
        let l:input_status = system('fcitx-remote')
        if l:input_status == 1 && exists('g:input_lang') && g:input_lang == 2
            silent! execute '!fcitx-remote -o'
        endif
    endif
endfunction

function! IBusOff()
    if g:input_method == 'ibus'
        " Store current engine
        let g:ibus_prev_engine = substitute(system('ibus engine'), '\n', '', 'g')
        " Switch to English engine (clean version without emoji)
        silent! execute '!ibus engine xkb:us::eng'
    endif
endfunction

function! IBusOn()
    if g:input_method == 'ibus'
        let l:current_engine = substitute(system('ibus engine'), '\n', '', 'g')
        " If not already on English engine, restore previous engine
        if l:current_engine !~? 'xkb:us::eng' && exists('g:ibus_prev_engine')
            silent! execute '!ibus engine ' . g:ibus_prev_engine
        elseif exists('g:ibus_prev_engine') && g:ibus_prev_engine !~? 'xkb:us::eng'
            silent! execute '!ibus engine ' . g:ibus_prev_engine
        endif
    endif
endfunction

" Unified functions that work with any detected input method
function! InputMethodOff()
    if g:input_method == 'fcitx5' || g:input_method == 'fcitx'
        call FcitxOff()
    elseif g:input_method == 'ibus'
        call IBusOff()
    endif
endfunction

function! InputMethodOn()
    if g:input_method == 'fcitx5' || g:input_method == 'fcitx'
        call FcitxOn()
    elseif g:input_method == 'ibus'
        call IBusOn()
    endif
endfunction

" Set up autocommands based on detected input method
if g:input_method != 'none'
    augroup InputMethodHandler
        autocmd!
        " Handle search mode
        autocmd CmdLineEnter [/?] silent call InputMethodOn()
        autocmd CmdLineLeave [/?] silent call InputMethodOff()
        autocmd CmdLineEnter \? silent call InputMethodOn()
        autocmd CmdLineLeave \? silent call InputMethodOff()
        " Handle insert mode
        autocmd InsertEnter * silent call InputMethodOn()
        autocmd InsertLeave * silent call InputMethodOff()
        " Handle when vim starts
        autocmd VimEnter * silent call InputMethodOff()
        " Handle when vim loses/gains focus (if supported)
        autocmd FocusLost * silent call InputMethodOff()
        autocmd FocusGained * silent call InputMethodOff()
    augroup END
    
    " Initialize - turn off input method when vim starts
    silent call InputMethodOff()
    
    " Display which input method was detected
    echo "Detected input method: " . g:input_method
else
    echo "No input method detected (fcitx5, fcitx, or ibus)"
endif

" Optional: Manual toggle function
function! ToggleInputMethod()
    if g:input_method != 'none'
        " This is a simple toggle - you might want to implement more sophisticated logic
        call InputMethodOn()
        echo "Input method enabled"
    else
        echo "No input method system detected"
    endif
endfunction

" Optional: Key mapping to manually toggle input method
nnoremap <leader>im :call ToggleInputMethod()<CR>
