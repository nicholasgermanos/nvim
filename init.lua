--
-- Globals
--

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.g.asyncrun_open = 16

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.o.linebreak = true

--
-- Auto commands
--

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

--
-- Pre-install required external dependencies if they do not exist
--

-- Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

--
-- Mappings
--

local function remap(mode, rhs, lhs, desc)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	bufopts.desc = desc
	vim.keymap.set(mode, rhs, lhs, bufopts)
end

local function nnoremap(rhs, lhs, desc)
	remap("n", rhs, lhs, desc)
end

local function vnoremap(rhs, lhs, desc)
	remap("v", rhs, lhs, desc)
end

local function tnoremap(rhs, lhs, desc)
	remap("t", rhs, lhs, desc)
end

local function inoremap(rhs, lhs, desc)
	remap("i", rhs, lhs, desc)
end

inoremap("<C-j>", function()
	local r, c = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { r + 1, c })
end, "Move down in insert mode")

inoremap("<C-k>", function()
	local r, c = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { r - 1, c })
end, "Move up in insert mode")

inoremap("<C-l>", function()
	local r, c = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { r, c + 1 })
end, "Move right in insert mode")

inoremap("<C-h>", function()
	local r, c = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { r, math.max(c - 1, 0) })
end, "Move left in insert mode")

nnoremap("k", "gk", "Up (disrespect wrapping)")
nnoremap("j", "gj", "Down (disrespect wrapping)")

vnoremap("k", "gk", "Up (disrespect wrapping)")
vnoremap("j", "gj", "Down (disrespect wrapping)")

nnoremap("<cr>", "o<esc>", "Insert new line in normal mode")

nnoremap("H", function()
	vim.cmd("wincmd h")
end, "Move to left window")

nnoremap("L", function()
	local win_num = vim.api.nvim_win_get_number(vim.api.nvim_get_current_win())
	vim.cmd("wincmd l")
	local win_num_new = vim.api.nvim_win_get_number(vim.api.nvim_get_current_win())

	-- Move down if we are already as far right as we can go
	if win_num == win_num_new then
		vim.cmd("wincmd j")
	end

	-- Move up if we are also as far down as we can go
	win_num_new = vim.api.nvim_win_get_number(vim.api.nvim_get_current_win())
	if win_num == win_num_new then
		vim.cmd("wincmd k")
	end
end, "Move to right window or down")

nnoremap("<leader>dd", "<cmd> lua vim.diagnostic.open_float() <CR>", "?   toggles local troubleshoot")
nnoremap("<leader>s!", "<cmd>wqa<cr>", "Save everything and quit")
nnoremap("<leader>S!", "<cmd>qa!<cr>", "Discard all and quit")
nnoremap("<leader>w", "<cmd>wa<cr>", "Save all")

tnoremap("zz", "<C-\\><C-n>", "Exit terminal insert mode")

--
-- LAZY PLUGINS
--

require("lazy").setup({

	-- Quality of life things

	-- {
	-- 	"folke/snacks.nvim",
	-- 	priority = 1000,
	-- 	lazy = false,
	-- 	---@type snacks.Config
	-- 	opts = {
	-- 		-- your configuration comes here
	-- 		-- or leave it empty to use the default settings
	-- 		-- refer to the configuration section below
	-- 		bigfile = { enabled = true },
	-- 		dashboard = { enabled = true },
	-- 		explorer = { enabled = true },
	-- 		input = { enabled = true },
	-- 		picker = { enabled = true },
	-- 		notifier = { enabled = true },
	-- 		quickfile = { enabled = true },
	-- 		scope = { enabled = true },
	-- 		scroll = { enabled = false },
	-- 		statuscolumn = { enabled = true },
	-- 		words = { enabled = true },
	-- 	},
	-- },

	-- Popup errors and things
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
			},
		},
		-- you can enable a preset for easier configuration
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search
			command_palette = true, -- position the cmdline and popupmenu together
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = false, -- add a border to hover docs and signature help
		},
	},

	-- Status bar

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- Return to session when re opening
	-- This breaks neo-tree

	-- {
	-- 	"rmagatti/auto-session",
	-- 	lazy = false,
	--
	-- 	---enables autocomplete for opts
	-- 	---@module "auto-session"
	-- 	---@type AutoSession.Config
	-- 	opts = {
	-- 		suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
	-- 		-- log_level = 'debug',
	-- 	},
	-- },

	-- Keep cursor in middle of screen
	{
		"arnamak/stay-centered.nvim",
		opts = {},
	},

	-- Color Schemes

	{ "catppuccin/nvim", as = "catppuccin" },

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- Show <leader> .. options as you press them

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},

	-- Indent Blankline (lines to show tab spacing)

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},

	-- Telescope and its dependencies

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "html", "javascript", "typescript", "vue" },
				auto_install = true,
				highlight = { enable = true },
			})
		end,
	},
	{ "nvim-lua/plenary.nvim" },

	{ "BurntSushi/ripgrep" },

	{ "sharkdp/fd" },

	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

	{
		"nvim-telescope/telescope.nvim",
		build = "make",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")

			nnoremap("<leader>sf", "<cmd>Telescope find_files<cr>", "Find file")
			nnoremap("<leader>sg", "<cmd>Telescope live_grep<cr>", "Grep")
			nnoremap("<leader>sb", "<cmd>Telescope buffers<cr>", "Find buffer")
			nnoremap("<leader>sm", "<cmd>Telescope marks<cr>", "Find mark")
			nnoremap("<leader>sr", "<cmd>Telescope lsp_references<cr>", "Find references (LSP)")
			nnoremap("<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", "Find symbols (LSP)")
			nnoremap("<leader>sc", "<cmd>Telescope lsp_incoming_calls<cr>", "Find incoming calls (LSP)")
			nnoremap("<leader>so", "<cmd>Telescope lsp_outgoing_calls<cr>", "Find outgoing calls (LSP)")
			nnoremap("<leader>si", "<cmd>Telescope lsp_implementations<cr>", "Find implementations (LSP)")
			nnoremap("<leader>sx", "<cmd>Telescope diagnostics bufnr=0<cr>", "Find errors (LSP)")

			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			local searchVimFiles = function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end

			local searchInBuffer = function()
				-- You can pass additional configuration to Telescope to change the theme, layout, etc.
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end

			local searchInOpenFiles = function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end

			nnoremap("<leader>sn", searchVimFiles, "[S]earch [N]eovim Files")
			nnoremap("<leader>/", searchInBuffer, "[S]earch [B]uffer")
			nnoremap("<leader>s/", searchInOpenFiles, "[/] Fuzzily search in current buffer")
		end,
	},

	-- Neo Tree (File Tree View) and its dependencies

	{ "MunifTanjim/nui.nvim" },

	{
		"antosha417/nvim-lsp-file-operations",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neo-tree/neo-tree.nvim",
		},
		config = function()
			require("lsp-file-operations").setup()
		end,
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			"3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},

		config = function()
			nnoremap("<leader>nt", "<cmd>Neotree reveal toggle<cr>", "Toggle NeoTree window")
			require("neo-tree").setup({
				window = {
					mappings = {
						["l"] = function(state)
							local neo_tree = require("neo-tree.sources.filesystem.commands")
							local win_num = vim.api.nvim_win_get_number(vim.api.nvim_get_current_win())
							neo_tree.open(state)
							local r, c = unpack(vim.api.nvim_win_get_cursor(0))

							local win_num_new = vim.api.nvim_win_get_number(vim.api.nvim_get_current_win())
							if win_num == win_num_new then
								vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { r + 1, c })
							end
						end,
						["h"] = function(state, callback)
							local neo_tree = require("neo-tree.sources.common.commands")
							neo_tree.close_node(state, callback)
							local r, c = unpack(vim.api.nvim_win_get_cursor(0))
							vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { math.max(r - 1, 1), c })
						end,
					},
				},
				close_if_last_window = true,
			})
		end,
	},

	-- LSPs

	{
		-- This stops the 'global vim not recognized' warning
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			-- Mason must be loaded before its dependents so we need to set it up here.
			-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"pmizio/typescript-tools.nvim",

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by blink.cmp
			"saghen/blink.cmp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					nnoremap("grn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					nnoremap("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction")

					-- Find references for the word under your cursor.
					nnoremap("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					nnoremap("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					nnoremap("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					nnoremap("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					nnoremap("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					nnoremap("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					nnoremap("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

					-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
					---@param client vim.lsp.Client
					---@param method vim.lsp.protocol.Method
					---@param bufnr? integer some lsp support methods only in specific files
					---@return boolean
					local function client_supports_method(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if
						client
						and client_supports_method(
							client,
							vim.lsp.protocol.Methods.textDocument_documentHighlight,
							event.buf
						)
					then
						local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
							end,
						})
					end
				end,
			})

			-- Diagnostic Config
			-- See :help vim.diagnostic.Opts
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = diagnostic.message,
							[vim.diagnostic.severity.WARN] = diagnostic.message,
							[vim.diagnostic.severity.INFO] = diagnostic.message,
							[vim.diagnostic.severity.HINT] = diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

			local servers = {
				-- Vue 3
				vtsls = {
					filetypes = { "javascript", "typescript", "vue" },
					settings = {
						vtsls = {
							tsserver = {
								globalPlugins = {
									{
										name = "@vue/typescript-plugin",
										location = vim.fn.stdpath("data")
											.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
										languages = { "vue" },
										configNamespace = "typescript",
									},
								},
							},
						},
					},
					on_attach = function(client, bufnr)
						if vim.bo[bufnr].filetype == "vue" then
							client.server_capabilities.semanticTokensProvider = nil
						end
					end,
				},
				volar = {
					on_init = function(client)
						client.handlers["tsserver/request"] = function(_, result, context)
							local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
							if #clients == 0 then
								vim.notify(
									"Could not find `vtsls` lsp client, vue_lsp will not work without it!",
									vim.log.levels.ERROR
								)
								return
							end
							local ts_client = clients[1]

							local param = unpack(result)
							local id, command, payload = unpack(param)
							ts_client:exec_cmd({
								title = "vue_request_forward", -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
								command = "typescript.tsserverRequest",
								arguments = {
									command,
									payload,
								},
							}, { bufnr = context.bufnr }, function(_, r)
								local response_data = { { id, r.body } }
								---@diagnostic disable-next-line: param-type-mismatch
								client:notify("tsserver/response", response_data)
							end)
						end
					end,
					settings = {
						typescript = {
							inlayHints = {
								enumMemberValues = {
									enabled = true,
								},
								functionLikeReturnTypes = {
									enabled = true,
								},
								propertyDeclarationTypes = {
									enabled = true,
								},
								parameterTypes = {
									enabled = true,
									suppressWhenArgumentMatchesName = true,
								},
								variableTypes = {
									enabled = true,
								},
							},
						},
					},
				},
				basedpyright = {
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "basic",
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								diagnosticMode = "workspace",
							},
						},
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = {
								globals = {
									"vim",
									"bufnr",
									"describe",
									"it",
									"before_each",
									"after_each",
									"packer_plugins",
									"MiniTest",
								},
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
				html = {},
				cssls = {},
				tailwind_css_lsp = {},
				eslint = {},
			}

			for name, server in pairs(servers) do
				server.capabilities = capabilities
				require("lspconfig")[name].setup(server)
			end
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform can also run multiple formatters sequentially
				python = { "isort", "black" },
				html = { "prettierd" },
				htmldjango = { "djlint" },
				javascript = { "prettierd" },
			},
		},
	},

	-- Autocompletion
	{
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			-- Snippet Engine
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
			},
			-- `friendly-snippets` contains a variety of premade snippets.
			--    See the README about individual language/framework/plugin snippets:
			--    https://github.com/rafamadriz/friendly-snippets
			{
				"rafamadriz/friendly-snippets",
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},

			"folke/lazydev.nvim",

			-- Thesaurus and Dictionary
			{ "archie-judd/blink-cmp-words" },
		},
		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
			keymap = {
				preset = "enter",
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = { auto_show = false, auto_show_delay_ms = 500 },
			},
			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = {
					lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },

					thesaurus = {
						name = "blink-cmp-words",
						module = "blink-cmp-words.thesaurus",
						-- All available options
						opts = {
							-- A score offset applied to returned items.
							-- By default the highest score is 0 (item 1 has a score of -1, item 2 of -2 etc..).
							score_offset = 0,

							-- Default pointers define the lexical relations listed under each definition,
							-- see Pointer Symbols below.
							-- Default is as below ("antonyms", "similar to" and "also see").
							pointer_symbols = { "!", "&", "^" },
						},
					},

					dictionary = {
						name = "blink-cmp-words",
						module = "blink-cmp-words.dictionary",
						-- All available options
						opts = {
							-- The number of characters required to trigger completion.
							-- Set this higher if completion is slow, 3 is default.
							dictionary_search_threshold = 3,

							-- See above
							score_offset = 0,

							-- See above
							pointer_symbols = { "!", "&", "^" },
						},
					},
				},
				per_filetype = {
					text = { "dictionary", "thesaurus" },
					markdown = { "dictionary", "thesaurus" },
				},
			},
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
			signature = { enabled = true },
		},
	},

	-- Stylus

	{
		"ChiliConSql/neovim-stylus",
	},

	-- JAVA

	{
		"mfussenegger/nvim-jdtls",
		config = function()
			nnoremap("<leader>jo", "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports")
			nnoremap("<leader>jev", "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable")
			nnoremap("<leader>jec", "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant")

			vnoremap("<leader>jev", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable")
			vnoremap("<leader>jec", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant")
			vnoremap("<leader>jem", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method")

			nnoremap("<leader>jtc", "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class")
			nnoremap("<leader>jtm", "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Nearest Method")
		end,
	},

	-- Helper eg make JPA Entities

	{
		"andreluisos/nvim-javagenie",
		dependencies = {
			"grapp-dev/nui-components.nvim",
			"MunifTanjim/nui.nvim",
		},
	},

	-- Git

	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
		},
		config = function()
			nnoremap("<leader>ng", "<cmd>Neogit<cr>", "Open Neogit")
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		signs = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signs_staged = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signs_staged_enable = true,
		signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
		numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
		linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
		word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
		watch_gitdir = {
			follow_files = true,
		},
		auto_attach = true,
		attach_to_untracked = false,
		current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
			delay = 1000,
			ignore_whitespace = false,
			virt_text_priority = 100,
			use_focus = true,
		},
		current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
		sign_priority = 6,
		update_debounce = 100,
		status_formatter = nil, -- Use default
		max_file_length = 40000, -- Disable if file is longer than this (in lines)
		preview_config = {
			-- Options passed to nvim_open_win
			style = "minimal",
			relative = "cursor",
			row = 0,
			col = 1,
		},
		config = function()
			local gitsigns = require("gitsigns")
			nnoremap("<leader>hp", function()
				gitsigns.preview_hunk()
			end, "Preview hunk")
			nnoremap("<leader>hi", function()
				gitsigns.preview_hunk_inline()
			end, "Preview hunk")
			nnoremap("<leader>hb", function()
				gitsigns.blame_line({ full = true })
			end, "Blame")
			nnoremap("<leader>htw", function()
				gitsigns.toggle_word_diff()
			end, "Toggle word diff")
		end,
	},

	---@type LazySpec
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		dependencies = {
			"folke/snacks.nvim",
		},
		keys = {
			{
				"<leader>tf",
				mode = { "n", "v" },
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				"<leader>tw",
				"<cmd>Yazi cwd<cr>",
				desc = "Open the file manager in nvim's working directory",
			},
			{
				"<leader>tr",
				"<cmd>Yazi toggle<cr>",
				desc = "Resume the last yazi session",
			},
		},
		---@type YaziConfig | {}
		opts = {
			-- if you want to open yazi instead of netrw, see below for more info
			open_for_directories = true,
			keymaps = {
				show_help = "<f1>",
			},
		},
		init = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
		end,
	},

	-- AsynRun to let you run scripts in the background & see the output in a popup window
	{
		"skywind3000/asyncrun.vim",
		config = function()
			nnoremap("<leader>rs", "<cmd>AsyncStop<cr>", "[S]top AsyncRun background process")
			nnoremap(
				"<leader>rmi",
				"<cmd>AsyncRun -mode=term ./../bin/mvn-clean-install-skiptests.sh<cr>",
				"[R]un mvn-clean-install-skiptests.sh"
			)
			nnoremap(
				"<leader>rw",
				"<cmd>AsyncRun -mode=term -pos=TAB ./../bin/wealth-wildfly-start.sh<cr>",
				"[R]un wealth-wildfly-start.sh"
			)
			nnoremap(
				"<leader>rw",
				"<cmd>AsyncRun -mode=term -pos=TAB ./../bin/wealth-wildfly-start.sh<cr>",
				"[R]un wealth-wildfly-start.sh"
			)
		end,
	},

	{
		"mfussenegger/nvim-dap",

		dependencies = {
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},

			{
				"microsoft/vscode-js-debug",
				build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
			},

			{
				"Joakker/lua-json5",
				build = "./install.sh",
			},
		},

		config = function()
			local dap = require("dap")

			nnoremap("<leader>db", function()
				require("dap").toggle_breakpoint()
			end, "Toggle [B]reakpoint")

			nnoremap("<leader>dp", function()
				require("dap").continue()
			end, "[D]ebug [P]lay")

			nnoremap("<leader>dj", function()
				require("dap").up()
			end, "Traverse up call stack")

			nnoremap("<leader>dk", function()
				require("dap").down()
			end, "Traverse down call stack")

			local js_based_languages = {
				"typescript",
				"javascript",
				"typescriptreact",
				"javascriptreact",
				"vue",
			}

			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = {
						vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
						"${port}",
					},
				},
			}

			dap.adapters["pwa-chrome"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = {
						vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
						"${port}",
					},
				},
			}

			dap.adapters["node"] = function(cb, config)
				local nativeAdapter = dap.adapters["pwa-node"]

				config.type = "pwa-node"

				if type(nativeAdapter) == "function" then
					nativeAdapter(cb, config)
				else
					cb(nativeAdapter)
				end
			end

			dap.adapters["chrome"] = function(cb, config)
				local nativeAdapter = dap.adapters["pwa-chrome"]

				config.type = "pwa-chrome"

				if type(nativeAdapter) == "function" then
					nativeAdapter(cb, config)
				else
					cb(nativeAdapter)
				end
			end

			for _, language in ipairs(js_based_languages) do
				dap.configurations[language] = {

					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file using Node.js (nvim-dap)",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach to process using Node.js (nvim.dap)",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-chrome",
						request = "launch",
						name = "Launch and Debug Chrome (nvim-dap)",
						url = function()
							local co = coroutine.running()
							return coroutine.create(function()
								vim.ui.input({
									prompt = "Enter URL: ",
									default = "http://localhost:3000",
								}, function(url)
									if url == nil or url == "" then
										return
									else
										coroutine.resume(co, url)
									end
								end)
							end)
						end,
						webRoot = "${workspaceFolder}",
						sourceMaps = true,
					},
				}
			end
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		opts = {
			controls = {
				element = "scopes",
				enabled = true,
			},
			element_mappings = {

				stacks = {
					open = "<CR>",
					expand = "o",
				},
			},
			layouts = {
				{
					position = "bottom",
					elements = {
						{ id = "scopes", size = 0.6 },
						{ id = "watches", size = 0.4 },
					},
					size = 0.3,
				},
			},
		},
		config = function(_, opts)
			nnoremap("<leader>du", function()
				require("dapui").toggle()
			end, "Toggle Debug UI")

			nnoremap(
				"<leader>dc",
				"<cmd>lua require'dapui'.float_element( 'console', { width = 300, height = 70, position = 'center' })<cr>",
				"Toggle Floating Console"
			)
			require("dapui").setup(opts)
		end,
	},

	-- Generate Print Statements

	{
		"rareitems/printer.nvim",
		config = function()
			require("printer").setup({
				keymap = "gp", -- Plugin doesn't have any keymaps by default
			})
		end,
	},

	{
		"sphamba/smear-cursor.nvim",
		opts = {},
	},

	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = { -- set to setup table
		},
	},

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			nnoremap("<leader>aj", function()
				harpoon:list():replace_at(1)
			end, "Harpoon add 1")

			nnoremap("<leader>ak", function()
				harpoon:list():replace_at(2)
			end, "Harpoon add 2")

			nnoremap("<leader>al", function()
				harpoon:list():replace_at(3)
			end, "Harpoon add 3")

			nnoremap("<leader>a;", function()
				harpoon:list():replace_at(4)
			end, "Harpoon add 4")

			nnoremap("<leader>ac", function()
				harpoon:list():clear()
			end, "Harpoon clear all")

			nnoremap("<C-h>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, "Harpoon add")

			nnoremap("<C-j>", function()
				harpoon:list():select(1)
			end, "Harpoon add")

			nnoremap("<C-k>", function()
				harpoon:list():select(2)
			end, "Harpoon add")

			nnoremap("<C-l>", function()
				harpoon:list():select(3)
			end, "Harpoon add")

			nnoremap("<C-;>", function()
				harpoon:list():select(4)
			end, "Harpoon add")
		end,
	},

	{
		"folke/zen-mode.nvim",
		config = function()
			nnoremap("<leader>z", function()
				require("zen-mode").toggle({
					window = {
						width = 0.55,
					},
				})
			end, "Zen mode")
		end,
	},

	{
		"windwp/nvim-ts-autotag",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
			})
		end,
	},

	{
		"ludovicchabant/vim-gutentags",
		config = function()
			local cache_dir = vim.fn.stdpath("cache") .. "/ctags"
			vim.fn.mkdir(cache_dir, "p") -- Create directory if it doesn't exist

			vim.g.gutentags_enabled = 1
			vim.g.gutentags_project_root = { ".git", ".root", ".svn", ".hg", ".project" }
			vim.g.gutentags_cache_dir = cache_dir
			vim.g.gutentags_generate_on_new = 1
			vim.g.gutentags_generate_on_missing = 1
			vim.g.gutentags_generate_on_write = 1
			vim.g.gutentags_generate_on_empty_buffer = 0
			vim.g.gutentags_ctags_exclude = { "node_modules", ".git", "build", "dist" }
		end,
	},
})

-- Color Scheme
-- (I put it at the bottom so if something goes wrong on init you KNOW something is wrong)
--

vim.cmd.colorscheme("catppuccin-frappe")

require("slanted_gaps")
