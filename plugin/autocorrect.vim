" autocorrect.vim -- Autocorrect built from scratch
" Maintainer: Mitchell Paulus
if exists('g:AutocorrectScriptLoaded') || &compatible || v:version < 703
    finish
endif

let s:FilePath=expand('<sfile>:h')
let g:AutocorrectScriptLoaded=1

if !exists('g:AutocorrectPersonalFile')
    let g:AutocorrectPersonalFile='~/.autocorrect'
endif

let g:AutocorrectLoaded=0

" We asynchronously load the main correction file to not block user input.
" This is done in chucks defined by this variable.
let s:ChunkSize=500

let s:Debug = 0

function! s:SourceLines(lines)
    for line in a:lines
        execute line
    endfor

    if s:Debug
        echom 'Loaded ' . len(a:lines) . ' lines'
    endif
endfunction

" See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures#creating_closures_in_loops_a_common_mistake
" for why we dedicate a function to this.
function! s:CreateCallback(lines)
    return {-> s:SourceLines(a:lines) }
endfunction

function! s:AutocorrectForceLoad()
    let previousDirectory = getcwd()

    if !exists("g:AutocorrectDisableBuiltIn")
        " Load built in abbreviations
        execute "cd " . s:FilePath
        cd ..

        let AbbreviationLines = readfile('corrections.vim')

        " See Issue #3: Recommendation to load abbreviations asynchronously
        let StartLineIndex = 0
        while StartLineIndex <= len(AbbreviationLines)
            " Vim protects us from index out of bounds errors
            let EndLineIndex = StartLineIndex + s:ChunkSize - 1
            let Lines        = AbbreviationLines[StartLineIndex : EndLineIndex]
            let Callback     = s:CreateCallback(Lines)
            call timer_start(1, Callback)
            let StartLineIndex = EndLineIndex + 1
        endwhile
    endif

    let s:personalFile = expand(g:AutocorrectPersonalFile)

    " Load custom words.
    if filereadable(s:personalFile)
        execute 'source ' . s:personalFile
    else
        echom "Could not read in personal autocorrect file: " . s:personalFile
    endif

    " Change working directory back to previous
    execute "cd " . fnameescape(previousDirectory)

    nnoremap <Plug>(AutocorrectAddToAbbrev) yiw:<C-u>call <SID>AddToAbbrev("<c-r>"")<cr>
    if !hasmapto("\<Plug>(AutocorrectAddToAbbrev)") && (empty(maparg("\<leader>a")) > 0)
        " add [a]bbreviation. Yanks inner word, runs the AddToAbbrev function.
        nmap <leader>a <Plug>(AutocorrectAddToAbbrev)
    endif

    let g:AutocorrectLoaded=1
endfunction

function! s:AutocorrectTryLoad()
    if g:AutocorrectLoaded == 0
        call s:AutocorrectForceLoad()
    else
        echom "Autocorrect already loaded."
    endif
endfunction

command! -nargs=0 AutocorrectForceLoad :call <SID>AutocorrectForceLoad()
command! -nargs=0 AutocorrectTryLoad :call <SID>AutocorrectTryLoad()

"This function is here to quickly be able to add word corrections.
function! s:AddToAbbrev(wrongSpelledWord)
    execute 'split ' . g:AutocorrectPersonalFile
    setlocal spell
    "G - to end of file, o - make new line and enter insert mode, iabbrev
    "[variable word]
    if line('$') == 1 && strchars(getline(1)) == 0
        execute "normal! iia " . a:wrongSpelledWord
    else
        execute "normal! Goia " . a:wrongSpelledWord
    endif
    "store misspelled word in s register, replace with first spell suggestion,
    "repaste misspelled word, append and insert space.
    execute "normal! \"syiw1z=\"sPa\<space>\<esc>l"
    setlocal filetype=vim
endfunction

nnoremap <Plug>(AutocorrectForceLoad) :<c-u>AutocorrectForceLoad<cr>
if !hasmapto("\<Plug>(AutocorrectForceLoad)") && (empty(maparg("\<leader>af")) > 0)
    nmap <leader>fa <Plug>(AutocorrectForceLoad)
endif

nnoremap <Plug>(AutocorrectTryLoad) :<c-u>AutocorrectTryLoad<cr>
if !hasmapto("\<Plug>(AutocorrectTryLoad)") && (empty(maparg("\<leader>at")) > 0)
    nmap <leader>ta <Plug>(AutocorrectTryLoad)
endif

function! s:RemoveWhitespace(text)
    return substitute(a:text," ","","g")
endfunction

if exists("g:AutocorrectFiletypes")
    augroup AutocorrectAutocommand
    " Clear out existing commands
    autocmd!

    let s:FileTypesToAdd = []
    for item in g:AutocorrectFiletypes
        call add(s:FileTypesToAdd,s:RemoveWhitespace(item))
    endfor
    execute "autocmd FileType " . join(s:FileTypesToAdd,",") . " AutocorrectTryLoad"
    augroup END
endif
