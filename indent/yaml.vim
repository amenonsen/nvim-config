if exists("b:did_indent")
  finish
endif

let b:did_indent = 1

setlocal nosmartindent
setlocal sw=2 ts=2 sts=2 et
setlocal indentkeys=o,O,*<Return>,!^F
setlocal indentexpr=GetYamlIndent(v:lnum)

function! GetYamlIndent(lnum)
    return luaeval(printf('get_yaml_indent(%d)', a:lnum))
endfunction

lua <<EOF
    function get_yaml_indent(lnum)
        if lnum == 1 then
            return 0
        end

        local prev_lnum = vim.fn.prevnonblank(lnum-1)
        if prev_lnum == 0 then
            return 0
        end

        local cur_line = vim.trim(vim.fn.getline(lnum))
        local prev_line = vim.trim(vim.fn.getline(prev_lnum))
        local prev_indent = vim.fn.indent(prev_lnum)
        local indent = prev_indent

        -- In selected cases, we're willing to change the indentation of
        -- an existing non-blank line, because our setting of indentkeys
        -- above means we'll be invoked that way only for explicit ^F.

        if cur_line:match('^}}"?$') then
            indent = indent - vim.o.sw
        elseif cur_line ~= "" then
            indent = vim.fn.indent(lnum)
        elseif prev_line == "{{" or prev_line:match(': "{{$') or prev_line:match(': [>|]%-*$') then
            indent = indent + vim.o.sw
        end

        return indent
    end
EOF
