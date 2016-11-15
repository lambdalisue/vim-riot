" Vim ftdetect file
" Language: Riot.js (JavaScript)
" Maintainer: ryym

if exists('*GetRiotIndent')
  finish
endif

" --- dependencies ---

" Use XML indentation becase it is
" more small and simple than the HTML one.
unlet! b:did_indent
runtime! indent/xml.vim

unlet! b:did_indent
runtime! indent/css.vim

unlet! b:did_indent
runtime! indent/javascript.vim

" --- dependencies ---

setlocal indentexpr=GetRiotIndent()

" JS indentkeys
setlocal indentkeys=0{,0},0),0],0\,,!^F,o,O,e
" HTML indentkeys
setlocal indentkeys+=*<Return>,<>>,<<>

" Multiline end tag regex (line beginning with '>' or '/>')
let s:endtag = '^\s*\/\?>\s*'

function! s:GetSynNamesAtSOL(lnum) abort
  return map(synstack(a:lnum, 1), 'synIDattr(v:val, "name")')
endfunction

function! s:GetSynNamesAtEOL(lnum) abort
  let lnum = prevnonblank(a:lnum)
  let col = strlen(getline(lnum))
  return map(synstack(lnum, col), 'synIDattr(v:val, "name")')
endfunction

function! s:SeemsHtmlSyntax(synattr) abort
  return a:synattr =~ '^html' || a:synattr =~ 'Tag' || a:synattr == 'jsBlockInHtml'
endfunction

function! s:SeemsCssSyntax(synattr) abort
  return a:synattr =~ '^css'
endfunction

" Get indents inferred from the current context.
function! GetRiotIndent() abort
  let prevSyntaxes = s:GetSynNamesAtEOL(v:lnum - 1)
  let lastPrevSyn = get(prevSyntaxes, -1)

  if s:SeemsHtmlSyntax(lastPrevSyn)
    let ind = XmlIndentGet(v:lnum, 0)

    if getline(v:lnum) =~? s:endtag
      " Align '/>' and '>' with '<' for multiline tags.
      let ind = ind - &shiftwidth
    elseif getline(v:lnum - 1) =~? s:endtag
      " Correct the indentation of any tags following '/>' or '>'.
      let ind = ind + &shiftwidth
    endif

    return ind
  endif

  if s:SeemsCssSyntax(lastPrevSyn)
    return GetCSSIndent()
  endif

  return GetJavascriptIndent()
endfunction
