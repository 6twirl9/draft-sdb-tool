set foldmethod=marker
highlight Folded     ctermfg=darkcyan ctermbg=NONE
highlight FoldColumn ctermfg=black    ctermbg=NONE
set foldclose=all
set foldtext=getline(v:foldstart)
set foldmarker====,///
set fillchars=fold:-
set foldcolumn=3
syn sync fromstart
