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

                local opts = { noremap = true, silent = true }

                buf_nmap('gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                buf_nmap('gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                buf_nmap('K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                buf_nmap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                buf_nmap('<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
                buf_nmap('<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
                buf_nmap('<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
                buf_nmap('<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
                buf_nmap('<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
                buf_nmap('<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                buf_nmap('<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                buf_nmap('gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                buf_nmap('<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
                buf_nmap('[e', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
                buf_nmap(']e', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
                buf_nmap('<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
                buf_nmap("<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

                buf_setopt('omnifunc', 'v:lua.vim.lsp.omnifunc')
            end

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true

            local servers = { "pyright", "bashls", "yamlls", "jsonls", "cssls", "html" }

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
        end
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

    -- Snippet manager for vim. There are neovim-specific snippet managers
    -- like luasnip, but they require snippets to be defined as lua code.
    -- https://github.com/neovim/nvim-lspconfig/wiki/Snippets
    use {
        'sirver/ultisnips',
        -- This is a collection of optional UltiSnips snippets for various
        -- languages, which I don't use often, and is hence disabled. This
        -- restricts the use of UltiSnips to custom snippets.
        -- requires = { 'honza/vim-snippets' },
        config = function()
            vim.g.UltiSnipsExpandTrigger = "<C-j>"
            vim.g.UltiSnipsJumpForwardTrigger = "<C-b>"
            vim.g.UltiSnipsJumpBackwardTrigger = "<C-z>"
            vim.g.UltiSnipsSnippetDirectories = {
                '/home/ams/.config/nvim/UltiSnips',
            }
        end
    }

    -- Displays a popup with previews of UltiSnips snippets applicable to the
    -- current filetype. Promising, but still slightly buggy (e.g., it breaks
    -- when previewing snippets containing ^M).
    --
    use {
        'fhill2/telescope-ultisnips.nvim',
        after = {
            'ultisnips',
            'telescope.nvim',
        },
        config = function()
            require('telescope').load_extension('ultisnips')
        end
    }

    -- A completion manager that can obtain completion data from multiple
    -- sources (paths, buffers, UltiSnips, etc.).
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
                    nvim_lsp = true,
                    nvim_lua = true,
                    vsnip = false,
                    ultisnips = true,
                    luasnip = false,
                }
            })

            vim.o.completeopt = "menuone,noselect"
            local compe_map_opts = {expr = true, noremap = true, silent = true}
            vim.api.nvim_set_keymap('i', '<C-Space>', 'compe#complete()', compe_map_opts)
            vim.api.nvim_set_keymap('i', '<CR>', "compe#confirm('<CR>')", compe_map_opts)
            vim.api.nvim_set_keymap('i', '<ESC>', "compe#close('<ESC>')", compe_map_opts)
            -- vim.api.nvim_set_keymap('i', '<C-f>', "compe#scroll({'delta': +4})", compe_map_opts)
            -- vim.api.nvim_set_keymap('i', '<C-d>', "compe#scroll({'delta': -4})", compe_map_opts)
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
        end
    }

    -- Make plugin loading conditional on the presence of .git
    local in_git_worktree = function()
        local res = vim.fn.system("git rev-parse --is-inside-work-tree")
        if string.find(res, 'true') then
            return true
        else
            return false
        end
    end

    -- Provides a Telescope-based interface to the github cli. More complete
    -- than nvim-telescope/telescope-github.nvim (e.g., access to comments).
    use {
        'pwntester/octo.nvim', cond = in_git_worktree,
        config = function()
            require('octo').setup({})
        end
    }

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

    -- Displays undo history visually.
    use {
        'simnalamburt/vim-mundo',
        cmd = 'MundoToggle',
        config = function()
            vim.g.mundo_right = 1
            vim.cmd[[MundoToggle]]
        end
    }

    -- Makes it easier to input and identify Unicode characters and
    -- digraphs. <C-x><C-z> in insert mode completes based on the name
    -- of the unicode character, :Digraphs xxx searches digraphs for
    -- matches.
    use {
        'chrisbra/unicode.vim',
        config = function()
            vim.cmd[[nmap ga <Plug>(UnicodeGA)]]
        end
    }

    -- Displays a "minimap"-style split display of classes/functions, but is
    -- distressingly slow to detect movement through the source code.
    use {
        'preservim/tagbar',
        cmd = 'TagbarToggle',
        config = 'vim.cmd[[TagbarToggle]]',
    }

    -- Ask Sourcetrail to open the current symbol in the IDE or, conversely,
    -- accept requests from Sourcetrail to open a particular symbol in vim.
    use {
        'CoatiSoftware/vim-sourcetrail', cond = in_git_worktree
    }

    -- File managers
    --
    -- Nice, but the functionality overlaps with fzf/Telescope to some extent,
    -- so not as frequently used. The lua version is fast and offers more file
    -- management functionality (like rename/delete), but is considerably less
    -- polished.
    use {
        'scrooloose/nerdtree',
        cmd = 'NERDTreeToggle',
        config = function ()
            -- We need to set this to \u00a0 (non-breaking space)
            -- because the default works only with :syntax on
            vim.g.NERDTreeNodeDelimiter = " "
            vim.g.NERDTreeIgnore = { '.pyc' }
            vim.cmd[[NERDTreeToggle]]
        end
    }
    use {
        'kyazdani42/nvim-tree.lua',
        cmd = 'NvimTreeToggle',
        config = 'vim.cmd[[NvimTreeToggle]]',
        requires = { 'kyazdani42/nvim-web-devicons' },
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

    -- Works with fugitive.vim to enable Github integration via :GBrowse and
    -- completion of issue numbers etc. via C-x C-o in commit messages (:help
    -- compl-omni). May be unnecessary given octo.
    --
    --use 'tpope/vim-rhubarb'

    -- Interactive `git log --oneline --graph` that can open commits either
    -- in a split or in the browser. Nice, but not used very often, nor much
    -- better than `Git log --oneline --graph` via fugitive.vim.
    --
    -- use 'junegunn/gv.vim'
    use {
        'rbong/vim-flog', cond = in_git_worktree,
        after = { 'vim-fugitive' },
    }

    -- Displays git change annotations and provides inline previews of
    -- diff hunks.
    use {
        'lewis6991/gitsigns.nvim',
        after = { 'vim-fugitive' },
        config = function()
            require('gitsigns').setup()
        end
    }

    -- Magit-inspired git integration, disabled because of various minor bugs
    -- (e.g., context highlighting keeps complaining about unknown highlight
    -- definitions).
    -- use {
    --     'TimUntersberger/neogit',
    --     config = function()
    --         require('neogit').setup({
    --             disable_context_highlighting = true,
    --             disable_commit_confirmations = true,
    --             integrations = {
    --                 diffview = true,
    --             }
    --         })
    --     end
    -- }
    -- use {
    --     'sindrets/diffview.nvim',
    --     config = function()
    --         require('diffview').setup({})
    --     end
    -- }
    -- use 'mhinz/vim-signify'

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
            "rcarriga/vim-ultest", ft = { 'python' },
            after = { "vim-test" },
            run = ":UpdateRemotePlugins",
            config = function()
                vim.cmd[[nmap ]t <Plug>(ultest-next-fail)]]
                vim.cmd[[nmap [t <Plug>(ultest-prev-fail)]]
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
            custom_theme.inactive.b.bg = '#a89984'
            custom_theme.inactive.c.bg = '#a89984'

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
                    lualine_y = {},
                    lualine_z = {'location'}
                },
                inactive_sections = {
                    lualine_a = {},
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
