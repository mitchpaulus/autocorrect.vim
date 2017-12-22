" autocorrect.vim -- Autocorrect built from scratch
" Maintainer: Mitchell Paulus
if exists('g:AutocorrectScriptLoaded') || &compatible || v:version < 703
    finish
endif

if !exists('g:Autocorrect_PersonalFile')
    let g:Autocorrect_PersonalFile='~/.autocorrect'
endif

let g:AutocorrectScriptLoaded=1

function! LoadAutocorrect() 
    if !filereadable(expand(g:Autocorrect_PersonalFile))
        let success = writefile([],expand(g:Autocorrect_PersonalFile),"a") 
    endif

    if exists('g:AutocorrectLoaded')
        execute 'source ' . g:Autocorrect_PersonalFile
        return
    endif

    let previousDirectory = expand("%:p:h")

    " Load built in abbreviations
    cd %:p:h
    cd ..
    source corrections.vim
    let g:AutocorrectLoaded=1
    " Load custom words.
    execute 'source ' . expand(g:Autocorrect_PersonalFile)

    execute "cd " . previousDirectory

    " [a]dd [a]bbreviation. Yanks inner word, runs the AddToAbbrev function.
    nnoremap <leader>aa yiw:<C-u>call <SID>AddToAbbrev("<c-r>"")<cr>
endfunction

command! -nargs=0 LoadAutocorrect :call LoadAutocorrect()
"[l]oad [a]uto[c]orrect
nnoremap <leader>lac :<c-u>LoadAutocorrect<cr>

"This function is here to quickly be able to add word corrections.
function! s:AddToAbbrev(wrongSpelledWord)
    execute 'split ' . g:Autocorrect_PersonalFile
    setlocal spell
    "G - to end of file, o - make new line and enter insert mode, iabbrev
    "[variable word]
    if line('$') == 1 && strchars(getline(1)) == 0
        execute "normal! iiabbrev " . a:wrongSpelledWord
    else
        execute "normal! Goiabbrev " . a:wrongSpelledWord
    endif
    "store misspelled word in s register, replace with first spell suggestion,
    "repaste misspelled word, append and insert space.
    execute "normal! \"syiw1z=\"sPa\<space>"
    "leave user in visual mode, in case the first selection wasn't good.
    execute "normal! lviw"
    setlocal filetype=vim
endfunction

" typical sort command sort /\v.{-1,}\s.{-1,}\s/ u
function! s:AddIAbbrevs() 
endfunction
