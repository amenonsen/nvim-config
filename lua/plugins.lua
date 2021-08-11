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
                    marks = true,
                    registers = true,
                    spelling = {
                        enabled = true,
                        suggestions = 20,
                    },
                    presets = {
                        operators = true,
                        motions = true,
                        text_objects = true,
                        windows = true,
                        nav = true,
                        z = true,
                        g = true,
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

            local border = {
                {'╭', "FloatBorder"},
                {'─', "FloatBorder"},
                {'╮', "FloatBorder"},
                {'│', "FloatBorder"},
                {'╯', "FloatBorder"},
                {'─', "FloatBorder"},
                {'╰', "FloatBorder"},
                {'│', "FloatBorder"},
            }

            -- Define buffer-local mappings and options to access LSP
            -- functionality after the language server and buffer are
            -- attached.
            local on_attach = function(client, bufnr)
                local function buf_nmap(...) vim.api.nvim_buf_set_keymap(bufnr, 'n', ...) end
                local function buf_setopt(...) vim.api.nvim_buf_set_option(bufnr, ...) end

                vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                    vim.lsp.handlers.hover, {border = border}
                )
                vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
                    vim.lsp.handlers.signature_help, {border = border}
                )

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
                    ["<leader>LF"] = { "<cmd>lua vim.lsp.buf.formatting()<CR>", "Format code" },
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
            end

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true

            local servers = { "clangd", "pyright", "bashls", "yamlls", "jsonls", "cssls", "html" }

            for _, ls in ipairs(servers) do
                nvim_lsp[ls].setup({
                    capabilities = capabilities,
                    on_attach = on_attach,
                    flags = {
                        debounce_text_changes = 500,
                    }
                })
            end

            -- Based on iamcco/diagnostic-languageserver
            -- Might be worth trying https://github.com/mattn/efm-langserver
            nvim_lsp.diagnosticls.setup({
                filetypes = { 'sh' },
                on_attach = on_attach,
                flags = {
                    debounce_text_changes = 150,
                },
                init_options = {
                    filetypes = { sh = "shellcheck" },
                    linters = {
                        shellcheck = {
                            sourceName = "shellcheck",
                            command = "shellcheck",
                            debounce = 100,
                            args = { '--format=gcc', '-' },
                            offsetLine = 0,
                            offsetColumn = 0,
                            formatLines = 1,
                            formatPattern = {
                                "^[^:]+:(\\d+):(\\d+):\\s+([^:]+):\\s+(.*)$",
                                {
                                    line = 1,
                                    column = 2,
                                    message = 4,
                                    security = 3,
                                }
                            },
                            securities = {
                                error = "error",
                                warning = "warning",
                                note = "info",
                            },
                        },
                    },
                },
            })

            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
                vim.lsp.diagnostic.on_publish_diagnostics, {
                    virtual_text = false,
                    signs = true,
                    update_in_insert = false,
                }
            )

            vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false})]]

            -- https://github.com/jose-elias-alvarez/null-ls.nvim allows
            -- LSP actions to be implemented in Neovim using buffers.
            -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/MAIN.md
        end
    }

    -- Highlight LSP diagnostic signs in the left column sensibly (red
    -- for error, orange for warning, that sort of thing).
    use { 'folke/lsp-colors.nvim' }

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
        },
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = "maintained",
                context_commentstring = {
                    enable = true,
                    enable_autocmd = false,
                },
                highlight = {
                    enable = false,
                    disable = { "c", "rust" },
                    additional_vim_regex_highlighting = false,
                    custom_captures = {},
                },
                indent = {
                    enable = false,
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
        'romgrk/nvim-treesitter-context', after = { 'nvim-treesitter' },
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
            'nvim-lua/popup.nvim',
            'nvim-lua/plenary.nvim',
        },
        config = function ()
            local telescope = require('telescope')
            local actions = require("telescope.actions")
            telescope.setup({
                extensions = {
                },
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
            })
            require('which-key').register({
                ["<C-f>"] = {
                    "<cmd>lua require('telescope-files').project_files()<CR>",
                    "Find files",
                },
                ["<C-b>"] = { "<cmd>Telescope buffers<CR>", "Buffers" },
                ["<C-g>"] = { "<cmd>Telescope live_grep<CR>", "Live grep" },
                ["T"] = {
                    name = "+Telescope",
                    ["T"] = { "<cmd>Telescope builtin<CR>", "Builtins" },
                    h = { "<cmd>Telescope help_tags<CR>", "Help tags" },
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
            require('config.luasnip')
        end
    }

    -- A completion manager that can obtain completion data from
    -- multiple sources (paths, buffers, LuaSnip, etc.). Will be
    -- superseded by the pure-Lua nvim-cmp plugin when stable.
    use {
        'hrsh7th/nvim-compe',
        config = function()
            require('compe').setup({
                enabled = true,
                autocomplete = false,
                debug = false,
                min_length = 1,
                preselect = 'enable',
                throttle_time = 80,
                source_timeout = 200,
                resolve_timeout = 800,
                incomplete_delay = 400,
                max_abbr_width = 100,
                max_kind_width = 100,
                max_menu_width = 100,
                documentation = {
                    border = { '', '' ,'', ' ', '', '', '', ' ' },
                    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
                    max_width = 120,
                    min_width = 60,
                    max_height = math.floor(vim.o.lines * 0.3),
                    min_height = 1,
                },
                source = {
                    path = true,
                    buffer = true,
                    calc = true,
                    spell = true,
                    nvim_lsp = true,
                    nvim_lua = true,
                    vsnip = false,
                    ultisnips = false,
                    luasnip = true,
                }
            })

            vim.o.completeopt = "menuone,noselect"
            local compe_map_opts = {expr = true, noremap = true, silent = true}
            vim.api.nvim_set_keymap('i', '<C-Space>', 'compe#complete()', compe_map_opts)
            vim.api.nvim_set_keymap('i', '<CR>', "compe#confirm({ 'keys': '<CR>', 'select': v:true })", compe_map_opts)
            vim.api.nvim_set_keymap('i', '<Space>', "compe#confirm({ 'keys': '<Space>', 'select': v:true })", compe_map_opts)
            vim.api.nvim_set_keymap('i', '<BS>', "compe#close('<BS>')", compe_map_opts)
            vim.api.nvim_set_keymap('i', '<ESC>', "compe#close('<ESC>')", compe_map_opts)

            -- Configure Tab/S-Tab to scroll through the suggestions or
            -- jump between tabstops inside a completed snippet.

            local t = function(str)
                return vim.api.nvim_replace_termcodes(str, true, true, true)
            end

            local check_back_space = function()
                local col = vim.fn.col('.') - 1
                return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
            end

            local luasnip = require('luasnip')

            _G.tab_complete = function()
              if vim.fn.pumvisible() == 1 then
                return t "<C-n>"
              elseif luasnip.expand_or_jumpable() then
                return t "<Plug>luasnip-expand-or-jump"
              elseif check_back_space() then
                return t "<Tab>"
              else
                return vim.fn['compe#complete']()
              end
            end
            _G.s_tab_complete = function()
              if vim.fn.pumvisible() == 1 then
                return t "<C-p>"
              elseif luasnip.jumpable(-1) then
                return t "<Plug>luasnip-jump-prev"
              else
                return t "<S-Tab>"
              end
            end

            vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
            vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
            vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
            vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
            vim.api.nvim_set_keymap("i", "<C-E>", "<Plug>luasnip-next-choice", {})
            vim.api.nvim_set_keymap("s", "<C-E>", "<Plug>luasnip-next-choice", {})
        end
    }

    -- Invokes external formatting tools (think gofmt, black) by filetype. Can
    -- be invoked with :Format or configured to format-on-save. We don't enable
    -- the latter because it sometimes causes hangs, and doesn't play well with
    -- :Git write (leaves the formatting changes unstaged). We could also just
    -- use psf/black here instead.
    use {
        'mhartington/formatter.nvim', ft = { 'python' },
        config = function()
            require('formatter').setup({
                logging = false,
                filetype = {
                    python = {
                        function()
                            return {
                                exe = "black",
                                args = {"-"},
                                stdin = true
                            }
                        end
                    },
                }
            })
            require('which-key').register({
                ["<leader>F"] = { "<cmd>Format<CR>", "Format code" },
            })
        end
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

    -- Displays undo history visually.
    use {
        'simnalamburt/vim-mundo', cmd = 'MundoToggle',
        config = function()
            vim.g.mundo_right = 1
        end
    }

    -- Displays a "minimap"-style split display of classes/functions.
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
            S = { "<cmd>SymbolsOutline<CR>", "Code outline" },
            U = { "<cmd>MundoToggle<CR>", "Undo history" },
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
                signs = {
                    add          = {hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
                    change       = {hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
                    delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
                    topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
                    changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
                },
                numhl = false,
                linehl = false,
                keymaps = {
                    -- Default keymap options
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

                    -- Text objects
                    ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>'
                },
                watch_index = {
                    interval = 1000,
                    follow_files = true
                },
                current_line_blame = false,
                current_line_blame_delay = 1000,
                current_line_blame_position = 'eol',
                sign_priority = 6,
                update_debounce = 100,
                status_formatter = nil,
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
        'mfussenegger/nvim-dap', ft = { 'python' }
    }
    use {
        'mfussenegger/nvim-dap-python', after = { "nvim-dap" },
        config = function()
            local dappy = require('dap-python')
            dappy.setup('~/.virtualenvs/debugpy/bin/python')
            dappy.test_runner = 'pytest'
        end
        -- :lua require'dap'.toggle_breakpoint()
        -- :lua require'dap'.continue()
        -- :lua require'dap'.step_over()
        -- :lua require'dap'.step_into()
        -- :lua require'dap'.repl.open()
        -- :help dap-widgets, dap-mapping
        -- nnoremap <silent> <leader>dn :lua require('dap-python').test_method()<CR>
        -- nnoremap <silent> <leader>df :lua require('dap-python').test_class()<CR>
        -- vnoremap <silent> <leader>ds <ESC>:lua require('dap-python').debug_selection()<CR>
        -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
    }

    -- Uses virtual text to display context information with nvim-dap.
    use {
        'theHamsta/nvim-dap-virtual-text', after = { 'nvim-dap' },
        config = function()
            vim.g.dap_virtual_text = true
        end
    }

    -- Provides a basic debugger UI for nvim-dap
    use {
        "rcarriga/nvim-dap-ui", after = { 'nvim-dap' },
    }

    -- Provides a Telescope interface to nvim-dap functionality.
    use {
        'nvim-telescope/telescope-dap.nvim', after = { 'nvim-dap' },
        config = function()
            require('telescope').load_extension('dap')
        end
    }

    -- Integrates with vim-test and nvim-dap to run tests.
    use {
        { 'vim-test/vim-test', ft = { 'python' } },
        {
            "rcarriga/vim-ultest", after = { "vim-test" },
            run = function ()
                vim.cmd[[packadd vim-test vim-ultest]]
                vim.cmd[[UpdateRemotePlugins]]
            end,
            config = function()
                require('which-key').register({
                    ["[t"] = { "<Plug>(ultest-prev-fail)", "Prev test failure" },
                    ["]t"] = { "<Plug>(ultest-next-fail)", "Next test failure" },
                })
            end
        }
    }

    -- Lightweight statusbar configuration plugin and (optional) icons to use
    -- in the statusbar.
    use {
        'hoob3rt/lualine.nvim',
        requires = {
            'kyazdani42/nvim-web-devicons',
        },
        -- (I don't know what any of the extensions actually does)
        -- extensions = { 'quickfix', 'fugitive', 'nerdtree', 'nvim-tree' },
        -- If this function becomes much larger, it might be worth moving it
        -- into lua/config/lualine.lua, and invoking it as follows:
        -- config = [[require('config.lualine')]]
        config = function ()
            -- Get rid of distracting colour changes in the statusline
            -- altogether, by setting all the backgrounds to the same
            -- colour in every mode.
            -- See also https://github.com/hoob3rt/lualine.nvim/blob/master/CONTRIBUTING.md#adding-a-theme
            local custom_theme = require('lualine.themes.gruvbox')
            custom_theme.normal.a.bg = '#a89984'
            custom_theme.normal.b.bg = '#a89984'
            custom_theme.normal.b.fg = '#ffeeee'
            custom_theme.normal.c.bg = '#a89984'
            custom_theme.insert.a.bg = '#a89984'
            custom_theme.insert.b.bg = '#a89984'
            custom_theme.insert.c.bg = '#a89984'
            custom_theme.visual.a.bg = '#a89984'
            custom_theme.visual.b.bg = '#a89984'
            custom_theme.visual.c.bg = '#a89984'
            custom_theme.replace.a.bg = '#a89984'
            custom_theme.replace.b.bg = '#a89984'
            custom_theme.replace.c.bg = '#a89984'
            custom_theme.command.a.bg = '#a89984'
            custom_theme.command.b.bg = '#a89984'
            custom_theme.command.c.bg = '#a89984'
            custom_theme.inactive.a.bg = '#a89984'
            custom_theme.inactive.a.fg = '#666666'
            custom_theme.inactive.b.bg = custom_theme.normal.b.fg
            custom_theme.inactive.c.bg = custom_theme.normal.c.fg

            require('lualine').setup({
                options = {
                    theme = custom_theme,
                    icons_enabled = false,
                    component_separators = {'', ''},
                    section_separators = {'', ''},
                    disabled_filetypes = {}
                },
                sections = {
                    lualine_a = {'filename'},
                    lualine_b = {require('nvim-treesitter').statusline},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {'branch'},
                    lualine_z = {'location'}
                },
                inactive_sections = {
                    lualine_a = {'filename'},
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
end

local packer_config = {
    git = {
        clone_timeout = 1200,
    }
}

return require('packer').startup({ packer_startup, packer_config })
