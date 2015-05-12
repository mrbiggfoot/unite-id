" unite source: id
" Version: 0.1.0
" Author : Milan Svoboda<milan.svoboda@centrum.cz>,
"          Andrew Pyatkov <mrbiggfoot@gmail.com>
" License: The MIT License

let s:save_cpo = &cpo
set cpo&vim

" Variables "{{{
call unite#util#set_default('g:unite_source_id_required_pattern_length', 3)
call unite#util#set_default('g:unite_source_id_max_candidates', 1000)
"}}}

let s:source = {
\   'action_table': {},
\	'syntax': 'uniteSource__id',
\	'hooks': {
	\ 'on_syntax': function("unite#sources#id#on_syntax"),
	\ },
\ }

function! s:source.hooks.on_init(args, context)
  let a:context.source__input = get(a:args, 0, '')
  if a:context.source__input == ''
    let a:context.source__input = expand("<cword>")
  endif
endfunction

function! s:format_item(item)
	return a:item[0] . ":" . a:item[1] . "\t" .
	\ substitute(join(a:item[2:], ":"), '^\s\+', '', '')
endfunction

function! s:source.gather_candidates(args, context)
	let l:set_db_path_opt = ''
	if exists("g:unite_ids_db_path")
		let l:set_db_path_opt = ' --file="' . g:unite_ids_db_path . '"'
	endif
	let l:custom_opts = get(a:args, 1, '')
    let l:result = unite#util#system(self.type . l:set_db_path_opt . ' ' . l:custom_opts . ' -R grep "' . a:context.source__input . '"')
    let l:matches = split(l:result, '\r\n\|\r\|\n')
    let l:entries = map(l:matches, 'split(v:val, ":")')
    return map(l:entries,
                \ '{
                \ "kind": "jump_list",
                \ "word": s:format_item(v:val),
                \ "action__path": v:val[0],
                \ "action__line": v:val[1],
                \ "action__text": join(v:val[2:], ":"),
                \ }')
endfunction"}}}


function! unite#sources#id#define()
  return map([{'name': 'lid', 'type': 'lid'},
  \           {'name': 'aid', 'type': 'aid'}],
  \      'extend(copy(s:source),
  \       extend(v:val, {"name": "id/" . v:val.name,
  \      "description": "candidates from " . v:val.name}))')
endfunction

function! unite#sources#id#on_syntax(args, context)
	syntax match uniteSource__id_Path /[^:]*:/he=e-1 contained containedin=uniteSource__id
	syntax match uniteSource__id_LineNr /\d\+/ contained containedin=uniteSource__id
	syntax match uniteSource__id_Item /\s\+.*/ contained containedin=uniteSource__id
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
