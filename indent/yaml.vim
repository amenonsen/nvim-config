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
        if lnum <= 1 then
            return 0
        end
        return vim.fn.indent(lnum-1)
    end
EOF
