vim.o.cmdheight = 0
vim.o.laststatus = 3

vim.opt.termguicolors = true

local augroup = vim.api.nvim_create_augroup("CmdlineToggle", { clear = true })

vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = augroup,
    callback = function ()
        vim.o.laststatus = 0
        vim.o.cmdheight = 1
    end
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = augroup,
    callback = function ()
        vim.o.cmdheight = 0
        vim.o.laststatus = 3
    end
})

vim.cmd('colo 256_noir')
vim.cmd('highlight SignColumn guibg=#000000')

vim.g.loaded_gitsigns = 1
vim.g.loaded_matchparen = 1

vim.cmd('set clipboard=unnamedplus')

vim.cmd('set cursorline')
vim.cmd('highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=233 guifg=NONE guibg=#121212')
vim.cmd('autocmd InsertEnter * highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=234 guifg=NONE guibg=#1c1c1c')
vim.cmd('autocmd InsertLeave * highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=233 guifg=NONE guibg=#121212')

-- Statusline: active window (white on black)
vim.cmd('highlight StatusLine cterm=NONE ctermfg=0 ctermbg=15 guifg=#000000 guibg=#ffffff')

-- Statusline: inactive windows (optional, slightly dimmed)
vim.cmd('highlight StatusLineNC cterm=NONE ctermfg=0 ctermbg=7 guifg=#000000 guibg=#aaaaaa')

vim.opt.mouse = ""

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." }
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.o.relativenumber = true

vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], { silent = true })

vim.keymap.set("", "<up>", "<nop>", { noremap = true })
vim.keymap.set("", "<down>", "<nop>", { noremap = true })
vim.keymap.set("i", "<up>", "<nop>", { noremap = true })
vim.keymap.set("i", "<down>", "<nop>", { noremap = true })

vim.keymap.set("n", "<leader>bd", "<CMD>bdelete<CR>", { desc = "Delete buffer" })

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Keep Lazy's lockfile writable while seeding it from the Nix-managed config.
local lazy_lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json"
local config_lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
if vim.fn.filereadable(lazy_lockfile) == 0 and vim.fn.filereadable(config_lockfile) == 1 then
    vim.fn.mkdir(vim.fn.fnamemodify(lazy_lockfile, ":h"), "p")
    vim.fn.writefile(vim.fn.readfile(config_lockfile), lazy_lockfile)
end

-- Setup lazy.nvim
require("lazy").setup({
    lockfile = lazy_lockfile,
    checker = { enabled = false, notify = false },
    spec = {
        {
            'stevearc/oil.nvim',
            ---@module 'oil'
            ---@type oil.SetupOpts
            opts = {
                -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
                -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
                default_file_explorer = true,
                -- Id is automatically added at the beginning, and name at the end
                -- See :help oil-columns
                columns = {
                    -- "icon"
                    "permissions",
                    "size",
                    "mtime"
                },
                -- Buffer-local options to use for oil buffers
                buf_options = {
                    buflisted = false,
                    bufhidden = "hide"
                },
                -- Window-local options to use for oil buffers
                win_options = {
                    wrap = false,
                    signcolumn = "no",
                    cursorcolumn = false,
                    foldcolumn = "0",
                    spell = false,
                    list = false,
                    conceallevel = 3,
                    concealcursor = "nvic"
                },
                -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
                delete_to_trash = true,
                -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
                skip_confirm_for_simple_edits = true,
                -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
                -- (:help prompt_save_on_select_new_entry)
                prompt_save_on_select_new_entry = true,
                -- Oil will automatically delete hidden buffers after this delay
                -- You can set the delay to false to disable cleanup entirely
                -- Note that the cleanup process only starts when none of the oil buffers are currently displayed
                cleanup_delay_ms = 2000,
                lsp_file_methods = {
                    -- Enable or disable LSP file operations
                    enabled = true,
                    -- Time to wait for LSP file operations to complete before skipping
                    timeout_ms = 1000,
                    -- Set to true to autosave buffers that are updated with LSP willRenameFiles
                    -- Set to "unmodified" to only save unmodified buffers
                    autosave_changes = false
                },
                -- Constrain the cursor to the editable parts of the oil buffer
                -- Set to `false` to disable, or "name" to keep it on the file names
                constrain_cursor = "editable",
                -- Set to true to watch the filesystem for changes and reload oil
                watch_for_changes = false,
                -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
                -- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
                -- Additionally, if it is a string that matches "actions.<name>",
                -- it will use the mapping at require("oil.actions").<name>
                -- Set to `false` to remove a keymap
                -- See :help oil-actions for a list of all available actions
                keymaps = {
                    ["g?"] = { "actions.show_help", mode = "n" },
                    ["<CR>"] = "actions.select",
                    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
                    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
                    ["<C-t>"] = { "actions.select", opts = { tab = true } },
                    ["<C-p>"] = "actions.preview",
                    ["<C-c>"] = { "actions.close", mode = "n" },
                    ["<C-l>"] = "actions.refresh",
                    ["-"] = { "actions.parent", mode = "n" },
                    ["_"] = { "actions.open_cwd", mode = "n" },
                    ["`"] = { "actions.cd", mode = "n" },
                    ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                    ["gs"] = { "actions.change_sort", mode = "n" },
                    ["gx"] = "actions.open_external",
                    ["g."] = { "actions.toggle_hidden", mode = "n" },
                    ["g\\"] = { "actions.toggle_trash", mode = "n" }
                },
                -- Set to false to disable all of the above keymaps
                use_default_keymaps = true,
                view_options = {
                    -- Show files and directories that start with "."
                    show_hidden = false,
                    -- This function defines what is considered a "hidden" file
                    is_hidden_file = function (name, bufnr)
                        local m = name:match("^%.")
                        return m ~= nil
                    end,
                    -- This function defines what will never be shown, even when `show_hidden` is set
                    is_always_hidden = function (name, bufnr)
                        return false
                    end,
                    -- Sort file names with numbers in a more intuitive order for humans.
    -- Can be "fast", true, or false. "fast" will turn it off for large directories.
                    natural_order = "fast",
                    -- Sort file and directory names case insensitive
                    case_insensitive = false,
                    sort = {
                        -- sort order can be "asc" or "desc"
      -- see :help oil-columns to see which columns are sortable
                        { "type", "asc" },
                        { "name", "asc" }
                    },
                    -- Customize the highlight group for the file name
                    highlight_filename = function (entry, is_hidden, is_link_target, is_link_orphan)
                        return nil
                    end
                },
                -- Extra arguments to pass to SCP when moving/copying files over SSH
                extra_scp_args = {},
                -- Extra arguments to pass to aws s3 when creating/deleting/moving/copying files using aws s3
                extra_s3_args = {},
                -- EXPERIMENTAL support for performing file operations with git
                git = {
                    -- Return true to automatically git add/mv/rm files
                    add = function (path)
                        return false
                    end,
                    mv = function (src_path, dest_path)
                        return false
                    end,
                    rm = function (path)
                        return false
                    end
                },
                -- Configuration for the floating window in oil.open_float
                float = {
                    -- Padding around the floating window
                    padding = 2,
                    -- max_width and max_height can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
                    max_width = 0,
                    max_height = 0,
                    border = nil,
                    win_options = {
                        winblend = 0
                    },
                    -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
                    get_win_title = nil,
                    -- preview_split: Split direction: "auto", "left", "right", "above", "below".
                    preview_split = "right",
                    -- This is the config that will be passed to nvim_open_win.
    -- Change values here to customize the layout
                    override = function (conf)
                        return conf
                    end
                },
                -- Configuration for the file preview window
                preview_win = {
                    -- Whether the preview window is automatically updated when the cursor is moved
                    update_on_cursor_moved = true,
                    -- How to open the preview window "load"|"scratch"|"fast_scratch"
                    preview_method = "fast_scratch",
                    -- A function that returns true to disable preview on a file e.g. to avoid lag
                    disable_preview = function (filename)
                        return false
                    end,
                    -- Window-local options to use for preview window buffers
                    win_options = {}
                },
                -- Configuration for the floating action confirmation window
                confirmation = {
                    -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_width and max_width can be a single value or a list of mixed integer/float types.
    -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
                    max_width = 0.9,
                    -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
                    min_width = { 40, 0.4 },
                    -- optionally define an integer/float for the exact width of the preview window
                    width = nil,
                    -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_height and max_height can be a single value or a list of mixed integer/float types.
    -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
                    max_height = 0.9,
                    -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
                    min_height = { 5, 0.1 },
                    -- optionally define an integer/float for the exact height of the preview window
                    height = nil,
                    border = nil,
                    win_options = {
                        winblend = 0
                    }
                },
                -- Configuration for the floating progress window
                progress = {
                    max_width = 0.9,
                    min_width = { 40, 0.4 },
                    width = nil,
                    max_height = { 10, 0.9 },
                    min_height = { 5, 0.1 },
                    height = nil,
                    border = nil,
                    minimized_border = "none",
                    win_options = {
                        winblend = 0
                    }
                },
                -- Configuration for the floating SSH window
                ssh = {
                    border = nil
                },
                -- Configuration for the floating keymaps help window
                keymaps_help = {
                    border = nil
                }
            },
            -- Optional dependencies
            dependencies = { { "nvim-mini/mini.icons", opts = {} } },
            -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
            lazy = false
        },
        {
            "folke/sidekick.nvim",
            opts = {
                -- add any options here
                cli = {
                    mux = {
                        backend = "tmux",
                        enabled = true,
                        create = "split",
                        split = {
                            vertical = true,
                            size = 0.4
                        }
                    }
                }
            },
            keys = {
                {
                    "<tab>",
                    function ()
                        -- if there is a next edit, jump to it, otherwise apply it if any
                        if not require("sidekick").nes_jump_or_apply() then
                            return "<Tab>" -- fallback to normal tab
                        end
                    end,
                    expr = true,
                    desc = "Goto/Apply Next Edit Suggestion"
                },
                {
                    "<c-.>",
                    function ()
                        require("sidekick.cli").focus()
                    end,
                    desc = "Sidekick Focus",
                    mode = { "n", "t", "i", "x" }
                },
                {
                    "<leader>aa",
                    function ()
                        require("sidekick.cli").toggle()
                    end,
                    desc = "Sidekick Toggle CLI"
                },
                {
                    "<leader>as",
                    function ()
                        require("sidekick.cli").select()
                    end,
                    -- Or to select only installed tools:
      -- require("sidekick.cli").select({ filter = { installed = true } })
                    desc = "Select CLI"
                },
                {
                    "<leader>ad",
                    function ()
                        require("sidekick.cli").close()
                    end,
                    desc = "Detach a CLI Session"
                },
                {
                    "<leader>at",
                    function ()
                        require("sidekick.cli").send({ msg = "{this}" })
                    end,
                    mode = { "x", "n" },
                    desc = "Send This"
                },
                {
                    "<leader>af",
                    function ()
                        require("sidekick.cli").send({ msg = "{file}" })
                    end,
                    desc = "Send File"
                },
                {
                    "<leader>av",
                    function ()
                        require("sidekick.cli").send({ msg = "{selection}" })
                    end,
                    mode = { "x" },
                    desc = "Send Visual Selection"
                },
                {
                    "<leader>ap",
                    function ()
                        require("sidekick.cli").prompt()
                    end,
                    mode = { "n", "x" },
                    desc = "Sidekick Select Prompt"
                },
                -- Example of a keybinding to open Claude directly
                {
                    "<leader>ac",
                    function ()
                        require("sidekick.cli").toggle({ name = "claude", focus = true })
                    end,
                    desc = "Sidekick Toggle Claude"
                }
            }
        },
        {
            "folke/snacks.nvim",
            priority = 1000,
            lazy = false,
            ---@type snacks.Config
            opts = {
                input = {
                    enabled = true -- Enhances `ask()`
                },
                picker = {
                    enabled = true, -- Enhances `select()`
                    actions = {
                        opencode_send = function (picker)
                            ---@param picker snacks.Picker
                            local items = vim.tbl_map(function (item)
                                ---@param item snacks.picker.Item
                                return item.file
                                    and require("opencode").format({
                                        path = item.file,
                                        from = item.pos,
                                        to = item.end_pos
                                    }) or item.text
                            end, picker:selected({ fallback = true }))

                            require("opencode").prompt(table.concat(items, ", ") .. " ")
                        end
                    },
                    win = {
                        input = {
                            keys = {
                                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } }
                            }
                        }
                    }
                },
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
                bigfile = { enabled = true },
                dashboard = { enabled = true },
                explorer = { enabled = true },
                -- indent = { enabled = true },
                notifier = { enabled = true },
                quickfile = { enabled = true },
                scope = { enabled = true },
                scroll = { enabled = false },
                statuscolumn = { enabled = true },
                words = { enabled = true }
            }
        },
        {
            "nickjvandyke/opencode.nvim",
            version = "*", -- Latest stable release
            config = function ()
                ---@type opencode.Opts
                vim.g.opencode_opts = {
                    -- Your configuration, if any; goto definition on the type for details
                }

                vim.o.autoread = true -- Required for `vim.g.opencode_opts.events.reload`

                -- Recommended/example keymaps
                vim.keymap.set(
                    { "n", "x" }, "<leader>oo",
                    function ()
                        require("opencode").ask("@this: ")
                    end,
                    {
                        desc = "Ask OpenCode…"
                    }
                )
                vim.keymap.set(
                    { "n", "x" }, "<leader>os",
                    function ()
                        require("opencode").select()
                    end,
                    {
                        desc = "Select OpenCode…"
                    }
                )

                vim.keymap.set({ "n", "x" }, "go", function () return require("opencode").operator("@this ") end, {
                    desc = "Append range to OpenCode",
                    expr = true
                })
                vim.keymap.set("n", "goo", function () return require("opencode").operator("@this ") .. "_" end, {
                    desc = "Append line to OpenCode",
                    expr = true
                })

                vim.keymap.set(
                    "n", "<S-C-u>",
                    function ()
                        require("opencode").command("session.half.page.up")
                    end,
                    {
                        desc = "Scroll OpenCode up"
                    }
                )
                vim.keymap.set(
                    "n", "<S-C-d>",
                    function ()
                        require("opencode").command("session.half.page.down")
                    end,
                    {
                        desc = "Scroll OpenCode down"
                    }
                )
            end
        },
        {
            'alexghergh/nvim-tmux-navigation',
            config = function ()
                require 'nvim-tmux-navigation'.setup {
                    disable_when_zoomed = false,
                    keybindings = {
                        left = "<C-h>",
                        down = "<C-j>",
                        up = "<C-k>",
                        right = "<C-l>",
                        last_active = "<C-\\>",
                        next = "<C-Space>"
                    }
                }
            end
        },
        {
            "ishiooon/codex.nvim",
            dependencies = { "folke/snacks.nvim" },
            config = true,
            keys = {
                { "<leader>cc", "<cmd>Codex<cr>", desc = "Codex: Toggle" },
                { "<leader>cf", "<cmd>CodexFocus<cr>", desc = "Codex: Focus" },
                { "<leader>cm", "<cmd>CodexMaximizeToggle<cr>", desc = "Codex: Toggle modal" },
                { "<leader>cs", "<cmd>CodexSend<cr>", mode = "v", desc = "Codex: Send selection" },
                {
                    "<leader>cs",
                    "<cmd>CodexTreeAdd<cr>",
                    desc = "Codex: Add file",
                    ft = { "neo-tree", "oil" }
                }
            }
        },
        {
            "catgoose/nvim-colorizer.lua",
            event = "BufReadPre",
            opts = {}
        },
        {
            "iamcco/markdown-preview.nvim",
            cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
            ft = { "markdown" },
            build = function ()
                vim.fn["mkdp#util#install"]()
            end
        },
        {
            "kdheepak/lazygit.nvim",
            lazy = true,
            cmd = {
                "LazyGit",
                "LazyGitConfig",
                "LazyGitCurrentFile",
                "LazyGitFilter",
                "LazyGitFilterCurrentFile"
            },
            -- optional for floating window border decoration
            dependencies = {
                "nvim-lua/plenary.nvim"
            },
            -- setting the keybinding for LazyGit with 'keys' is recommended in
            -- order to load the plugin when the command is run for the first time
            keys = {
                { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
            }
        },
        {
            "folke/which-key.nvim",
            event = "VeryLazy",
            opts = {
                -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            },
            keys = {
                {
                    "<leader>?",
                    function ()
                        require("which-key").show({ global = false })
                    end,
                    desc = "Buffer Local Keymaps (which-key)"
                }
            }
        },
        {
            'nvim-telescope/telescope.nvim',
            tag = 'v0.2.1',
            dependencies = {
                'nvim-lua/plenary.nvim',
                -- optional but recommended
                { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
            },
            config = function ()
                local builtin = require('telescope.builtin')
                vim.keymap.set('n', '<leader>ff', function ()
                    Snacks.picker.files()
                end, { desc = 'Snacks find files' }
                )
                vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
                vim.keymap.set('n', '<leader>fb', function ()
                    Snacks.picker.buffers()
                end, { desc = 'Snacks buffers' }
                )
                vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
            end
        },
        -- {
        --     "kelly-lin/ranger.nvim",
        --     config = function ()
        --         require("ranger-nvim").setup({ replace_netrw = true })
        --         vim.api.nvim_set_keymap("n", "<leader>ef", "", {
        --             noremap = true,
        --             callback = function ()
        --                 require("ranger-nvim").open(true)
        --             end
        --         })
        --     end
        -- },
        { 'sindrets/diffview.nvim' },
        {
            "ibhagwan/fzf-lua",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            opts = {}
        },
        {
            "nvim-neo-tree/neo-tree.nvim",
            branch = "v3.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
                "MunifTanjim/nui.nvim"
                -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
            }
        },
        {
            "folke/trouble.nvim",
            opts = {}, -- for default options, refer to the configuration section for custom setup.
            cmd = "Trouble",
            keys = {
                {
                    "<leader>xx",
                    "<cmd>Trouble diagnostics toggle<cr>",
                    desc = "Diagnostics (Trouble)"
                },
                {
                    "<leader>xX",
                    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                    desc = "Buffer Diagnostics (Trouble)"
                },
                {
                    "<leader>cs",
                    "<cmd>Trouble symbols toggle focus=false<cr>",
                    desc = "Symbols (Trouble)"
                },
                {
                    "<leader>cl",
                    "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                    desc = "LSP Definitions / references / ... (Trouble)"
                },
                {
                    "<leader>xL",
                    "<cmd>Trouble loclist toggle<cr>",
                    desc = "Location List (Trouble)"
                },
                {
                    "<leader>xQ",
                    "<cmd>Trouble qflist toggle<cr>",
                    desc = "Quickfix List (Trouble)"
                }
            }
        },
        {
            'windwp/nvim-autopairs',
            event = "InsertEnter",
            config = true
            -- use opts = {} for passing setup options
            -- this is equivalent to setup({}) function
        },
        {
            "lukas-reineke/indent-blankline.nvim",
            main = "ibl",
            ---@module "ibl"
            ---@type ibl.config
            opts = { indent = { char = "|" } }
        },
        {
            'nvim-orgmode/orgmode',
            event = 'VeryLazy',
            ft = { 'org' },
            config = function ()
                -- Setup orgmode
                require('orgmode').setup({
                    org_agenda_files = '~/orgfiles/**/*',
                    org_default_notes_file = '~/orgfiles/refile.org'
                })

                -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
                -- add ~org~ to ignore_install
                -- require('nvim-treesitter.configs').setup({
                --   ensure_installed = 'all',
                --   ignore_install = { 'org' },
                -- })
            end
        },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function ()
                -- local configs = require("nvim-treesitter.configs")
                --
                -- configs.setup({
                --     ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
                --     sync_install = false,
                --     highlight = { enable = true },
                --     indent = { enable = true },
                -- })

            end
        },
        {
            'williamboman/mason.nvim',
            lazy = false,
            opts = {}
        },

        -- Autocompletion
        {
            'hrsh7th/nvim-cmp',
            event = 'InsertEnter',
            config = function ()
                local cmp = require('cmp')
                local has_words_before = function ()
                    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
                    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                    return col ~= 0
                        and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
                end

                cmp.setup({
                    sources = {
                        { name = 'nvim_lsp' }
                    },
                    mapping = cmp.mapping.preset.insert({
                        ['<C-Space>'] = cmp.mapping.complete(),
                        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-d>'] = cmp.mapping.scroll_docs(4),
                        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                        ["<Tab>"] = vim.schedule_wrap(function (fallback)
                            if cmp.visible() and has_words_before() then
                                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                            else
                                fallback()
                            end
                        end)
                    }),
                    snippet = {
                        expand = function (args)
                            vim.snippet.expand(args.body)
                        end
                    }
                })
            end
        },

        -- LSP
        {
            'neovim/nvim-lspconfig',
            cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
            event = { 'BufReadPre', 'BufNewFile' },
            dependencies = {
                { 'hrsh7th/cmp-nvim-lsp' },
                { 'williamboman/mason.nvim' },
                { 'williamboman/mason-lspconfig.nvim' }
            },
            init = function ()
                -- Reserve a space in the gutter
                -- This will avoid an annoying layout shift in the screen
                vim.opt.signcolumn = 'yes'
            end,
            config = function ()
                local lsp_defaults = require('lspconfig').util.default_config

                -- Add cmp_nvim_lsp capabilities settings to lspconfig
                -- This should be executed before you configure any language server
                lsp_defaults.capabilities = vim.tbl_deep_extend(
                    'force', lsp_defaults.capabilities, require('cmp_nvim_lsp').default_capabilities()
                )

                -- LspAttach is where you enable features that only work
                -- if there is a language server active in the file
                vim.api.nvim_create_autocmd('LspAttach', {
                    desc = 'LSP actions',
                    callback = function (event)
                        local opts = { buffer = event.buf }

                        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                        vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
                    end
                })

                require('mason-lspconfig').setup({
                    ensure_installed = {},
                    handlers = {
                        -- this first function is the "default handler"
                        -- it applies to every language server without a "custom handler"
                        function (server_name)
                            require('lspconfig')[server_name].setup({})
                        end
                    }
                })
            end
        }
    },
    install = { colorscheme = { "retrobox" } }
})
