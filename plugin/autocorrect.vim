" autocorrect.vim -- Autocorrect built from scratch
" Maintainer: Mitchell Paulus
if exists('g:AutocorrectScriptLoaded') || &compatible || v:version < 703
    finish
endif

let s:FilePath=expand('<sfile>:h')
let g:AutocorrectScriptLoaded=1

if !exists('g:Autocorrect_PersonalFile')
    let g:Autocorrect_PersonalFile='~/.autocorrect'
endif

function! LoadAutocorrect() 
    let previousDirectory = expand("%:p:h")

    " Load built in abbreviations
    execute "cd " . s:FilePath
    cd ..
    source corrections.vim

    let personalFile = expand(g:Autocorrect_PersonalFile)

    " Load custom words.
    if filereadable(personalFile)
        execute 'source ' . personalFile
        echom "Read in personal file: " . personalFile
    endif

    " Change working directory back to previous
    execute "cd " . fnameescape(previousDirectory)

    " add [a]bbreviation. Yanks inner word, runs the AddToAbbrev function.
    nnoremap <leader>a yiw:<C-u>call <SID>AddToAbbrev("<c-r>"")<cr>
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
    execute "normal! \"syiw1z=\"sPa\<space>\<esc>l"
    setlocal filetype=vim
endfunction
