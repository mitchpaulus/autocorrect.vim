function! s:LoadAutoCorrect() 
    let previousWorkingDirectory=getcwd()

    " Move to directory of this current file. 
    cd %:p:h
    source autocorrect-list.vim
    " [a]dd [a]bbreviation. Yanks inner word, runs the AddToAbbrev function.
    nnoremap <leader>aa yiw:<C-u>call <SID>AddToAbbrev("<c-r>"")<cr>

    execute 'cd ' . previousWorkingDirectory

endfunction

command -nargs=0 LoadAutocorrect :<c-u>call <SID>LoadAutoCorrect()
"[l]oad [a]uto[c]orrect
nnoremap <leader>lac :<c-u>LoadAutocorrect

"This function is here to quickly be able to add word corrections.
function! s:AddToAbbrev(wrongSpelledWord)
    split $MYVIMRC
    set spell
    "G - to end of file, o - make new line and enter insert mode, iabbrev
    "[variable word]
    execute "normal! Goiabbrev " . a:wrongSpelledWord
    "store misspelled word in s register, replace with first spell suggestion,
    "repaste misspelled word, append and insert space.
    execute "normal! \"syiw1z=\"sPa\<space>"
    "leave user in visual mode, in case the first selection wasn't good.
    execute "normal! lviw"
endfunction
