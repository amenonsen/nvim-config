" Vim color file
" black
" Created by  with ThemeCreator (https://github.com/mswift42/themecreator)

hi clear
syntax clear

if exists("syntax on")
syntax reset
endif

set t_Co=256
let g:colors_name = "black"

" Define reusable colorvariables.
let s:bg="#000000"
let s:fg="#ffffee"
let s:fg2="#ebebdb"
let s:fg3="#d6d6c8"
let s:fg4="#c2c2b5"
let s:bg2="#141414"
let s:bg3="#292929"
let s:bg4="#3d3d3d"
let s:keyword="#ffffee"
let s:builtin="#ffffee"
let s:const= "#ffffee"
let s:comment="#888888"
let s:func="#ffffee"
let s:str="#ffffee"
let s:type="#ffffee"
let s:var="#ffffee"
let s:warning="#ff0000"
let s:warning2="#ff8800"

hi Normal term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:fg guibg=s:bg
hi Cursor term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:bg guibg=s:fg
hi CursorLine term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guibg=s:bg2
hi CursorLineNr term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:str guibg=s:bg
hi CursorColumn term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guibg=s:bg2
hi ColorColumn term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guibg=s:bg2
hi LineNr term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:fg2 guibg=s:bg2
hi VertSplit term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:fg3 guibg=s:bg3
hi MatchParen term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:warning2 gui=underline
hi StatusLine term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:fg2 guibg=s:bg3
hi Pmenu term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:fg guibg=s:bg2
hi PmenuSel term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guibg=s:bg3
hi IncSearch term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:bg guibg=s:keyword
hi Search term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE gui=underline
hi Directory term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:const
hi Folded term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:fg4 guibg=s:bg
hi WildMenu term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:str guibg=s:bg

hi Boolean term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:const
hi Character term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:const
hi Comment term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:comment
hi Conditional term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi Constant term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:const
hi Todo term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guibg=s:bg
hi Define term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi DiffAdd term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=#fafafa guibg=#123d0f
hi DiffDelete term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guibg=s:bg2
hi DiffChange term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guibg=#151b3c guifg=#fafafa
hi DiffText term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=#ffffff guibg=#ff0000
hi ErrorMsg term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:warning guibg=s:bg2
hi WarningMsg term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:fg guibg=s:warning2
hi Float term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:const
hi Function term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:func
hi Identifier term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:type
hi Keyword term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi Label term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:var
hi NonText term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:bg4 guibg=s:bg2
hi Number term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:const
hi Operator term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi PreProc term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi Special term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:fg
hi SpecialKey term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:fg2 guibg=s:bg2
hi Statement term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi StorageClass term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:type
hi String term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:str
hi Tag term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi Title term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:fg
hi Todo term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:fg2 gui=inverse,bold
hi Type term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:type
hi Underlined term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE gui=underline

" Neovim Terminal Mode
let g:terminal_color_0 = s:bg
let g:terminal_color_1 = s:warning
let g:terminal_color_2 = s:keyword
let g:terminal_color_3 = s:bg4
let g:terminal_color_4 = s:func
let g:terminal_color_5 = s:builtin
let g:terminal_color_6 = s:fg3
let g:terminal_color_7 = s:str
let g:terminal_color_8 = s:bg2
let g:terminal_color_9 = s:warning2
let g:terminal_color_10 = s:fg2
let g:terminal_color_11 = s:var
let g:terminal_color_12 = s:type
let g:terminal_color_13 = s:const
let g:terminal_color_14 = s:fg4
let g:terminal_color_15 = s:comment

" Ruby Highlighting
hi rubyAttribute term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:builtin
hi rubyLocalVariableOrMethod term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:var
hi rubyGlobalVariable term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:var
hi rubyInstanceVariable term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:var
hi rubyKeyword term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi rubyKeywordAsMethod term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi rubyClassDeclaration term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi rubyClass term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi rubyNumber term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:const

" Python Highlighting
hi pythonBuiltinFunc term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:builtin

" Go Highlighting
hi goBuiltins term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:builtin
let g:go_highlight_array_whitespace_error = 1
let g:go_highlight_build_constraints      = 1
let g:go_highlight_chan_whitespace_error  = 1
let g:go_highlight_extra_types            = 1
let g:go_highlight_fields                 = 1
let g:go_highlight_format_strings         = 1
let g:go_highlight_function_calls         = 1
let g:go_highlight_function_parameters    = 1
let g:go_highlight_functions              = 1
let g:go_highlight_generate_tags          = 1
let g:go_highlight_operators              = 1
let g:go_highlight_space_tab_error        = 1
let g:go_highlight_string_spellcheck      = 1
let g:go_highlight_types                  = 1
let g:go_highlight_variable_assignments   = 1
let g:go_highlight_variable_declarations  = 1

" Javascript Highlighting
hi jsBuiltins term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:builtin
hi jsFunction term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi jsGlobalObjects term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:type
hi jsAssignmentExps term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:var

" Html Highlighting
hi htmlLink term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:var gui=underline
hi htmlStatement term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword
hi htmlSpecialTagName term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:keyword

" Markdown Highlighting
hi mkdCode term=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE guifg=s:builtin
