-- Depends on https://github.com/wbthomason/packer.nvim being cloned into
-- ~/.local/share/nvim/site/pack/packer/start

local packer_startup = function(use)
    -- Packer can manage itself.
    use 'wbthomason/packer.nvim'

    -- We must run :PackerCompile every time this configuration is modified.
    vim.cmd([[autocmd BufWritePost plugins.lua source <afile> | PackerCompile]])

    -- If a file is already open in vim somewhere, just switch to that editor
    -- instead of bothering me with a warning about the swapfile. (Depends on
    -- support from the window manager.)
    use 'gioele/vim-autoswap'

    -- Allows "." to repeat complex plugin-defined actions; required by
    -- vim-surround and vim-unimpaired (at least).
    use 'tpope/vim-repeat'

    -- Allows manipulations of "surrounding" text objects like pairs of
    -- quotes, open/close <tags>, etc. (e.g., cs"', ysiw")
    use 'tpope/vim-surround'

    -- Key mapping manager (supersedes junegunn/vim-peekaboo and has a lot more
    -- functionality, like displaying applicable mappings after partial input).
    use {
        'folke/which-key.nvim',
        config = function()
            require('which-key').setup({
                plugins = {
                    spelling = {
                        enabled = true,
                        suggestions = 20,
                    },
                },
            })
        end
    }

    -- Configure Neovim's builtin LSP client to speak to various external
    -- language servers. (Supersedes LSP clients like coc.nvim or ale that
    -- provide similar functionality.)
    use {
        'neovim/nvim-lspconfig',
        config = function()
            local nvim_lsp = require('lspconfig')

            -- Define buffer-local mappings and options to access LSP
            -- functionality after the language server and buffer are
            -- attached.
            local on_attach = function(client, bufnr)
                local function buf_setopt(...) vim.api.nvim_buf_set_option(bufnr, ...) end

                buf_setopt('omnifunc', 'v:lua.vim.lsp.omnifunc')

                require('which-key').register({
                    ["K"] = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover text" },
                    ["gd"] = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Goto definition" },
                    ["gr"] = { "<cmd>lua vim.lsp.buf.references()<CR>", "List references" },
                    ["gD"] = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "Goto declaration" },
                    ["gi"] = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Goto implementation" },
                    ["<C-k>"] = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature help" },
                    ["[e"] = { "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", "Prev diagnostic" },
                    ["]e"] = { "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", "Next diagnostic" },
                    ["<leader>q"] = {
                        "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>",
                        "List all diagnostics"
                    },
                    ["<leader>e"] = {
                        "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>",
                        "Show line diagnostics"
                    },
                    ["FF"] = { "<cmd>lua vim.lsp.buf.formatting()<CR>", "Format code" },
                    ["<leader>D"] = { "<cmd>lua vim.lsp.buf.type_definition()<CR>", "Type definition" },
                    ["<leader>rn"] = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
                    ["<leader>ca"] = { '<cmd>lua vim.lsp.buf.code_action()<CR>', "Code action" },
                    ["\\W"] = {
                        name = "+Workspaces",
                        l = {
                            "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
                            "List workspace directories"
                        },
                        a = {
                            "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>",
                            "Add workspace directory"
                        },
                        r = {
                            "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>",
                            "Remove workspace directory"
                        },
                    },
                }, { buffer = bufnr })

                require('which-key').register({
                    ["FF"] = { "<cmd>lua vim.lsp.buf.formatting()<CR>", "Format code" },
                }, { mode = "v", buffer = bufnr })
            end

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            capabilities.textDocument.completion.completionItem.preselectSupport = true
            capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
            capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
            capabilities.textDocument.completion.completionItem.deprecatedSupport = true
            capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
            capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
            capabilities.textDocument.completion.completionItem.resolveSupport = {
                properties = {
                    'documentation',
                    'detail',
                    'additionalTextEdits',
                }
            }

            local servers = {
                "clangd", "pyright", "jedi_language_server", "bashls",
                "jsonls", "cssls", "html"
            }

            for _, ls in ipairs(servers) do
                nvim_lsp[ls].setup({
                    capabilities = capabilities,
                    on_attach = on_attach,
                    flags = {
                        debounce_text_changes = 500,
                    }
                })
            end

            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
                vim.lsp.diagnostic.on_publish_diagnostics, {
                    virtual_text = false,
                    signs = true,
                    update_in_insert = false,
                }
            )

            vim.cmd [[
                autocmd CursorHold,CursorHoldI * lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false})
            ]]
        end
    }

    -- A language server that integrates with external tools like black
    -- and shellcheck, as well as allowing LSP actions to be implemented
    -- in Lua using buffers inside Neovim (without separate processes).
    -- Can provide diagnostics, formatting, and code actions (with many
    -- builtin configurations for existing tools).
    use {
        'jose-elias-alvarez/null-ls.nvim',
        config = function()
            local nls = require "null-ls"

            nls.config({
                debounce = 250,
                sources = {
                    nls.builtins.formatting.black,
                    nls.builtins.diagnostics.shellcheck.with({
                        diagnostics_format = "[#{c}] #{m} (#{s})"
                    })
                }
            })
            require("lspconfig")["null-ls"].setup({})
        end,
    }

    -- A Neovim interface to the tree-sitter incremental parser library, to
    -- enable syntax-aware highlighting, text object definitions, and other
    -- features (instead of using the traditional regex-based hacks).
    use {
        'nvim-treesitter/nvim-treesitter', run = ':TSUpdate',
        -- These modules are not actually dependencies, but the reverse: they
        -- need nvim-treesitter to work. I'm putting them all in here to make
        -- sure they're all loaded before running the setup function below
        -- (though I'm not sure if it's really needed).
        requires = {
            'nvim-treesitter/nvim-treesitter-textobjects',
            'JoosepAlviste/nvim-ts-context-commentstring',
            'nvim-treesitter/playground',
        },
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = "maintained",
                context_commentstring = {
                    enable = true,
                    enable_autocmd = false,
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                    custom_captures = {},
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = "<CR>",
                        node_decremental = "<BS>",
                        scope_incremental = "grc",
                    }
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["aP"] = "@parameter.outer",
                            ["iP"] = "@parameter.inner",
                            ["a#"] = "@comment.outer",
                        }
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]m"] = "@function.outer",
                            ["]]"] = "@class.outer",
                        },
                        goto_next_end = {
                            ["]M"] = "@function.outer",
                            ["]["] = "@class.outer"
                        },
                        goto_previous_start = {
                            ["[m"] = "@function.outer",
                            ["[["] = "@class.outer"
                        },
                        goto_previous_end = {
                            ["[M"] = "@function.outer",
                            ["[]"] = "@class.outer"
                        }
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ["<leader>a"] = "@parameter.inner",
                        },
                        swap_previous = {
                            ["<leader>A"] = "@parameter.inner",
                        },
                    },
                    lsp_interop = {
                        enable = true,
                        border = 'none',
                        peek_definition_code = {
                            ["df"] = "@function.outer",
                            ["dF"] = "@class.outer",
                        },
                    },
                },
                playground = {
                    enable = true,
                }
            })
        end
    }

    -- Defines gcc/gc{motion}/gC{motion} mappings to toggle comments on the
    -- current line or selected lines based on the 'commentstring' setting.
    use {
        'b3nj5m1n/kommentary',
        config = function()
            require('kommentary.config').configure_language("default", {
                ignore_whitespace = false,
                use_consistent_indentation = true,
                single_line_comment_string = 'auto',
                multi_line_comment_strings = 'auto',
                hook_function = function()
                    require('ts_context_commentstring.internal').update_commentstring()
                end
            })
            require('kommentary.config').configure_language("html", {
                ignore_whitespace = false,
                use_consistent_indentation = true,
                single_line_comment_string = 'auto',
                multi_line_comment_strings = 'auto',
                hook_function = function()
                    require('ts_context_commentstring.internal').update_commentstring()
                end
            })
        end
    }

    -- Displays class/function/block context at the top of the screen while
    -- scrolling through source code. Like context.vim.
    use {
        'romgrk/nvim-treesitter-context',
        config = function()
            require('treesitter-context').setup({
                enable = true,
                throttle = true,
            })
        end
    }

    -- Configurable fuzzy-finder over lists (like fzf, but without the
    -- dependency on an external binary), with various plugins.
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
        },
        config = function ()
            local telescope = require('telescope')
            telescope.setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<esc>"] = "close",
                            ["<C-q>"] = "close",
                        },
                        n = {
                            ["q"] = "close",
                        },
                    },
                },
                pickers = {
                    buffers = {
                        sort_lastused = true,
                        theme = 'dropdown',
                        previewer = false,
                        mappings = {
                            i = { ['<C-d>'] = "delete_buffer" },
                        }
                    },
                }
            })
            require('which-key').register({
                ["<C-f>"] = {
                    "<cmd>lua require('telescope-files').project_files()<CR>",
                    "Find files",
                },
                ["<C-b>"] = { "<cmd>lua require('telescope.builtin').buffers()<CR>", "Buffers" },
                ["<C-g>"] = {
                    "<cmd>lua require('telescope.builtin').live_grep({sorter=require('telescope.sorters').empty()})<CR>",
                    "Live grep"
                },
                ["T"] = {
                    name = "+Telescope",
                    ["T"] = { "<cmd>lua require('telescope.builtin').builtin()<CR>", "Builtins" },
                    h = { "<cmd>lua require('telescope.builtin').help_tags()<CR>", "Help tags" },
                },
            })
        end
    }

    -- Adds support to Telescope for https://github.com/jhawthorn/fzy (an
    -- alternative to fzf), which needs to be installed separately.
    use {
        'nvim-telescope/telescope-fzy-native.nvim',
        config = function()
            require('telescope').load_extension('fzy_native')
        end
    }

    -- A snippet manager (required for some LSP actions) written in Lua.
    -- More complex than UltiSnips, but supports the new VS Code snippet
    -- format, integrates better with compe, and has more features.
    -- See https://github.com/neovim/nvim-lspconfig/wiki/Snippets
    use {
        'L3MON4D3/LuaSnip',
        config = function()
            require('luasnip').config.setup({
                store_selection_keys = "<Tab>"
            })
        end
    }

    -- A completion manager that obtains completion data from multiple
    -- sources (LSP, LuaSnip, buffers, etc.) based on plugins included
    -- below. This is the pure-Lua successor of nvim-compe.
    use {
        'hrsh7th/nvim-cmp',
        config = function()
            local cmp = require "cmp"
            local luasnip = require('luasnip')

            cmp.setup({
                completion = {
                    autocomplete = {},
                    completeopt = 'menu,menuone,noselect',
                    keyword_length = 1,
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                },
                mapping = {
                    ['<C-p>'] = cmp.mapping.prev_item(),
                    ['<C-n>'] = cmp.mapping.next_item(),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<BS>'] = cmp.mapping.close(),
                    ['<Esc>'] = cmp.mapping.close(),
                    ['<Space>'] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ['<CR>'] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ['<Tab>'] = cmp.mapping.mode({ 'i', 's' }, function(_, fallback)
                        if vim.fn.pumvisible() == 1 then
                            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
                        elseif luasnip.jumpable(1) then
                            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-next', true, true, true), '')
                        else
                            fallback()
                        end
                    end),
                    ['<S-Tab>'] = cmp.mapping.mode({ 'i', 's' }, function(_, fallback)
                        if vim.fn.pumvisible() == 1 then
                            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n')
                        elseif luasnip.jumpable(-1) then
                            vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
                        else
                            fallback()
                        end
                    end)
                },
            })

            vim.api.nvim_set_keymap("i", "<C-E>", "<Plug>luasnip-next-choice", {})
            vim.api.nvim_set_keymap("s", "<C-E>", "<Plug>luasnip-next-choice", {})
        end
    }

    -- Completion sources for nvim-cmp.
    use {
        { 'saadparwaiz1/cmp_luasnip' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'hrsh7th/cmp-buffer' },
    }

    -- Makes it easier to input and identify Unicode characters and
    -- digraphs. <C-x><C-z> in insert mode completes based on the name
    -- of the unicode character, :Digraphs xxx searches digraphs for
    -- matches.
    use {
        'chrisbra/unicode.vim',
        config = function()
            require('which-key').register({
                ga = { "<Plug>(UnicodeGA)", "Identify character" }
            })
        end
    }

    -- Displays a "minimap"-style split display of classes/functions,
    -- but unlike Tagbar (which is unmaintained), these plugins are
    -- based on LSP symbols.
    use {
        'simrat39/symbols-outline.nvim'
    }

    -- Unlike NERDTree and NvimTree, Rnvimr uses RPC to communicate with
    -- Ranger, thus inheriting all of its file management functionality.
    use {
        'kevinhwang91/rnvimr'
    }

    -- Add mappings to toggle all of the above plugins.
    require('which-key').register({
        ["\\T"] = {
            name = "+Toggles",
            A = { "<cmd>AerialToggle<CR>", "Aerial outline" },
            S = { "<cmd>SymbolsOutline<CR>", "Symbols outline" },
            R = { "<cmd>RnvimrToggle<CR>", "Ranger" },
        }
    })

    -- Provides a Telescope-based interface to the github cli. More complete
    -- than nvim-telescope/telescope-github.nvim (e.g., access to comments).
    use {
        'pwntester/octo.nvim',
        config = function()
            require('octo').setup({})
        end
    }

    -- Ask Sourcetrail to open the current symbol in the IDE or, conversely,
    -- accept requests from Sourcetrail to open a particular symbol in vim.
    use {
        'CoatiSoftware/vim-sourcetrail',
        config = function()
            require('which-key').register({
                ["\\S"] = {
                    name = "+Sourcetrail",
                    r = { "<cmd>SourcetrailRefresh<CR>", "Start/refresh connection" },
                    a = { "<cmd>SourcetrailActivateToken<CR>", "Activate current token" },
                },
            })
        end
    }

    -- Fugitive provides a lightweight alternative to running git commands with
    -- `:!git …`, with better output handling and nice buffer integration where
    -- appropriate.
    --
    -- Splice is the only interface I've ever found that makes three-way merges
    -- comprehensible. Unfortunately, it cannot coexist with Fugitive. We need
    -- to use Splice (and therefore exclude Fugitive) only when invoked via
    -- `git mergetool`. We can make that decision in .vimrc.
    --
    -- To do so, we must make both modules optional here.
    --
    use {
        { 'tpope/vim-fugitive', opt = true },
        { 'sjl/splice.vim', opt = true },
    }

    -- Displays git change annotations and provides inline previews of
    -- diff hunks.
    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup({
                numhl = false,
                linehl = false,
                keymaps = {
                    noremap = true,

                    ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'"},
                    ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'"},

                    ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
                    ['v <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
                    ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
                    ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
                    ['v <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
                    ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
                    ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
                    ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',

                    ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>'
                },
                watch_index = {
                    interval = 1000,
                    follow_files = true
                },
                current_line_blame = false,
                update_debounce = 250,
                word_diff = false,
                use_internal_diff = true,
            })

            require('which-key').register({
                ["[c"] = { "Prev hunk" },
                ["]c"] = { "Next hunk" },
                ["<leader>h"] = {
                    name = "+Hunk",
                    s = { "Stage hunk" },
                    u = { "Unstage hunk" },
                    r = { "Reset hunk" },
                    R = { "Reset buffer" },
                    p = { "Preview hunk" },
                    b = { "Blame line" },
                },
            }, { mode = "n" })
            require('which-key').register({
                ["<leader>h"] = {
                    name = "+Hunk",
                    s = { "Stage hunk" },
                    r = { "Reset hunk" },
                },
            }, { mode = "v" })
        end
    }

    -- Supports Python debugging using debugpy and nvim-dap, which adds
    -- support for the Debug Adapter Protocol (and requires an adapter
    -- per language to be debugged).
    use {
        'mfussenegger/nvim-dap',
        config = function()
            local dap = require('dap')
            local repl = require('dap.repl')

            repl.commands = vim.tbl_extend('force', repl.commands, {
                custom_commands = {
                    ['.br'] = function(text)
                        if text == "" or not text:match(':') then
                            repl.append("ERR: Please specify `.br filename:lineno`")
                            return
                        end
                        local fname, lnum = unpack(vim.split(text, ':'))
                        local bufnr = vim.fn.bufnr(fname)
                        if bufnr == -1 then
                            bufnr = vim.fn.bufload(fname)
                        end
                        require('dap.breakpoints').toggle({}, bufnr, tonumber(lnum))
                        dap.session():set_breakpoints(bufnr)
                    end
                },
            })

            require('which-key').register({
                ["\\B"] = {
                    "<cmd>lua require('dap').toggle_breakpoint()<CR>",
                    "DAP: Toggle breakpoint",
                },
                ["\\C"] = {
                    "<cmd>setlocal number<CR><cmd>lua require('dap').continue()<CR>",
                    "DAP: Continue",
                },
            })

            -- These dap-repl-specific mappings make using the debugger
            -- a bit more like the usual gdb experience, but note that
            -- you can't _start_ the program using 'c' in the REPL, you
            -- must first do so using the \C mapping above in the source
            -- buffer, and only then switch to the REPL.
            vim.cmd[[
                augroup dap-repl
                    autocmd!
                    autocmd FileType dap-repl nnoremap<buffer> n <cmd>lua require('dap').step_over()<CR>
                    autocmd FileType dap-repl nnoremap<buffer> s <cmd>lua require('dap').step_into()<CR>
                    autocmd FileType dap-repl nnoremap<buffer> c <cmd>lua require('dap').continue()<CR>
                    autocmd FileType dap-*,dapui* nnoremap<buffer> -w <cmd>1wincmd w<CR>
                    autocmd FileType dap-*,dapui* nnoremap<buffer> -s <cmd>2wincmd w<CR>
                    autocmd FileType dap-*,dapui* nnoremap<buffer> -b <cmd>3wincmd w<CR>
                    autocmd FileType dap-*,dapui* nnoremap<buffer> -S <cmd>4wincmd w<CR>
                    autocmd FileType dap-*,dapui* nnoremap<buffer> -c <cmd>5wincmd w<CR>
                    autocmd FileType dap-*,dapui* nnoremap<buffer> -o <cmd>6wincmd w<CR>
                    autocmd FileType dap-*,dapui* nnoremap<buffer> -r <cmd>7wincmd w<CR>
                augroup end
            ]]
        end
    }
    use {
        'mfussenegger/nvim-dap-python',
        config = function()
            local dappy = require('dap-python')
            dappy.setup('~/.virtualenvs/debugpy/bin/python')
            dappy.test_runner = 'pytest'
        end
    }

    -- Uses virtual text to display context information with nvim-dap.
    use {
        'theHamsta/nvim-dap-virtual-text',
        config = function()
            vim.g.dap_virtual_text = true
        end
    }

    -- Provides a basic debugger UI for nvim-dap
    use {
        "rcarriga/nvim-dap-ui",
        config = function()
            require('dapui').setup({
            })
            require('which-key').register({
                ["\\D"] = {
                    "<cmd>setlocal number<CR><cmd>lua require('dapui').toggle()<CR>",
                    "DAP: Debugger UI",
                }
            })
        end
    }

    -- Provides a Telescope interface to nvim-dap functionality.
    use {
        'nvim-telescope/telescope-dap.nvim',
        config = function()
            require('telescope').load_extension('dap')
        end
    }

    -- Integrates with vim-test and nvim-dap to run tests.
    use {
        "rcarriga/vim-ultest", run = ":UpdateRemotePlugins",
        requires = { 'vim-test/vim-test' },
        config = function()
            require("ultest").setup({
                builders = {
                    ['python#pytest'] = function (cmd)
                        local non_modules = {'python', 'pipenv', 'poetry'}
                        local module_index = 1
                        if vim.tbl_contains(non_modules, cmd[1]) then
                            module_index = 3
                        end
                        local module = cmd[module_index]
                        local args = vim.list_slice(cmd, module_index + 1)
                        return {
                            dap = {
                                type = 'python',
                                request = 'launch',
                                module = module,
                                args = args
                            }
                        }
                    end
                }
            })
            require('which-key').register({
                ["[t"] = { "<Plug>(ultest-prev-fail)", "Prev test failure" },
                ["]t"] = { "<Plug>(ultest-next-fail)", "Next test failure" },
            })
        end
    }

    -- Lightweight statusbar configuration plugin and (optional) icons to use
    -- in the statusbar.
    use {
        'shadmansaleh/lualine.nvim',
        requires = {
            'kyazdani42/nvim-web-devicons',
        },
        extensions = { 'quickfix', 'fugitive' },
        config = function ()
            -- Get rid of distracting colour changes in the statusline
            -- altogether, by starting with gruvbox and setting all the
            -- backgrounds to the same colour in every mode.
            local colors = {
                black = '#282828',
                beige = '#a89984',
                white = '#ffffff',
            }
            local custom_theme = {
                normal = {
                    a = {bg = colors.beige, fg = colors.black, gui = 'bold'},
                    b = {bg = colors.beige, fg = colors.white},
                    c = {bg = colors.beige, fg = colors.black}
                },
                insert = {
                    a = {bg = colors.beige, fg = colors.black, gui = 'bold'},
                    b = {bg = colors.beige, fg = colors.white},
                    c = {bg = colors.beige, fg = colors.black}
                },
                visual = {
                    a = {bg = colors.beige, fg = colors.black, gui = 'bold'},
                    b = {bg = colors.beige, fg = colors.white},
                    c = {bg = colors.beige, fg = colors.black}
                },
                replace = {
                    a = {bg = colors.beige, fg = colors.black, gui = 'bold'},
                    b = {bg = colors.beige, fg = colors.white},
                    c = {bg = colors.beige, fg = colors.black}
                },
                command = {
                    a = {bg = colors.beige, fg = colors.black, gui = 'bold'},
                    b = {bg = colors.beige, fg = colors.white},
                    c = {bg = colors.beige, fg = colors.black}
                },
                inactive = {
                    a = {bg = colors.beige, fg = "#555555", gui = 'bold'},
                    b = {bg = colors.beige, fg = colors.white},
                    c = {bg = colors.beige, fg = colors.black}
                }
            }

            local ts_stat_transforms = {
                python = function(s)
                    -- "class Xyzzy(object):" → "Xyzzy"
                    if s:find("class ") then
                        s = s:gsub("class ", ""):gsub("%([^%)]*%):", "")
                    -- "def fn(a,r,g,s) -> r:" → "fn()"
                    elseif s:find("def ") then
                        s = s:gsub("def ", ""):gsub("%([^%)]*%)", "()"):gsub("%).*:", ")")
                    end
                    return s
                end,
                lua = function(s)
                    return s:gsub(" *{$", ""):gsub("%($", "")
                end
            }
            setmetatable(ts_stat_transforms, {
                __index = function(_, _)
                    return function(s) return s end
                end
            })

            require('lualine').setup({
                options = {
                    theme = custom_theme,
                    icons_enabled = false,
                    component_separators = {'', ''},
                    section_separators = {'', ''},
                    disabled_filetypes = {}
                },
                sections = {
                    lualine_a = {
                        { 'filename', path = 1 }
                    },
                    lualine_b = {
                        function()
                            return require('nvim-treesitter').statusline({
                                indicator_size = 100,
                                type_patterns = {'class', 'function', 'method'},
                                transform_fn = ts_stat_transforms[vim.o.filetype],
                                separator = ' → ',
                            })
                        end
                    },
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {'branch'},
                    lualine_z = {'location'}
                },
                inactive_sections = {
                    lualine_a = { 'filename' },
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                tabline = {},
                extensions = {}
            })
        end
    }

    use 'rktjmp/lush.nvim'
    use '~/src/colorscheme-antipathy'
end

local packer_config = {
    compile_path = vim.fn.stdpath('data') .. '/site/pack/loader/start/packer.nvim/plugin/packer_compiled.lua',
    display = {
        open_fn = function()
            return require('packer.util').float({ border = 'single' })
        end
    },
    git = {
        clone_timeout = 1200,
    }
}

return require('packer').startup({ packer_startup, config = packer_config })
