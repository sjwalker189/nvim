local mode = {
	n = 'n',
	v = 'v',
	i = 'i',
	x = 'x',
	all = { 'n', 'v', 'i', 'x' },
}

return {
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			{ 'williamboman/mason.nvim',          config = true },
			{ 'williamboman/mason-lspconfig.nvim' },
			{ 'j-hui/fidget.nvim',                opts = {} },
			{ 'folke/neodev.nvim' },
		},
		config = function()
			require('neodev').setup {}

			vim.filetype.add { extension = { templ = 'templ' } }

			local nvim_lsp = require 'lspconfig'
			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			local servers = {
				pyright = { capabilities = capabilities },
				lua_ls = {
					capabilities = capabilities,
				},
				html = {
					capabilities = capabilities,
					filetypes = { 'html', 'vue' },
				},
				cssls = {
					capabilities = capabilities,
					settings = {
						validate = true,
						lint = {
							-- For tailwindcss @apply
							unknownAtRules = 'ignore',
						},
					},
				},
				tailwindcss = {
					capabilities = capabilities,
					filetypes = { 'templ', 'javascript', 'typescript', 'react', 'vue' },
					init_options = { userLanguages = { templ = 'html' } },
				},

				-- denols = {
				-- 	capabilities = capabilities,
				-- 	root_dir = nvim_lsp.util.root_pattern('deno.json', 'deno.jsonc'),
				-- },

				ts_ls = {
					capabilities = capabilities,
					root_dir = nvim_lsp.util.root_pattern 'package.json',
					single_file_support = false,
					filetypes = { 'javascript', 'typescript', 'typescriptreact', 'javascriptreact', 'react', 'vue' },
					init_options = {
						plugins = {
							{
								name = '@vue/typescript-plugin',
								location = vim.fn.stdpath 'data' ..
								    '/mason/packages/vue-language-server/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin',
								languages = { 'javascript', 'typescript', 'vue' },
							},
						},
					},
				},
				volar = {
					capabilities = capabilities,
				},
				eslint = {
					capabilities = capabilities,
				},

				-- phpactor = {
				--   capabilities = capabilities,
				-- },

				-- sourcekit = {
				--   capabilities = capabilities,
				-- },

				-- Go
				-- gopls = {
				--   capabilities = capabilities,
				-- },
				-- templ = {
				--   capabilities = capabilities,
				--   filetypes = { 'html', 'templ' },
				-- },
			}

			require('mason-lspconfig').setup {
				ensure_installed = vim.tbl_keys(servers),
				diagnostics = {
					underline = true,
					update_in_insert = false,
					virtual_text = {
						spacing = 4,
						source = 'if_many',
						prefix = '●',
					},
					severity_sort = true,
				},
				inlay_hints = {
					enabled = false,
				},
			}

			-- Register the LSP servers
			for server, config in pairs(servers) do
				require('lspconfig')[server].setup(config)
			end

			-- Connect keymaps when LSP servers attach to buffers
			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('UserLspConfig', {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf }
					vim.keymap.set(mode.n, 'gD', vim.lsp.buf.declaration, opts)
					vim.keymap.set(mode.n, 'gd', vim.lsp.buf.definition, opts)
					vim.keymap.set(mode.n, 'K', vim.lsp.buf.hover, opts)
					vim.keymap.set(mode.n, '<C-k>', vim.lsp.buf.signature_help, opts)
					vim.keymap.set(mode.n, '<C-T>', vim.lsp.buf.type_definition, opts)
					vim.keymap.set(mode.n, '<F2>', vim.lsp.buf.rename, opts)
					vim.keymap.set(mode.n, '<space>rn', vim.lsp.buf.rename, opts)
					vim.keymap.set(mode.all, '<C-.>', vim.lsp.buf.code_action, opts)
					vim.keymap.set(mode.all, '<F3>', vim.lsp.buf.code_action, opts)
					vim.keymap.set(mode.n, 'gr', vim.lsp.buf.references, opts)
				end,
			})
		end,
	},
	-- {
	-- 	'scalameta/nvim-metals',
	-- 	dependencies = {
	-- 		'nvim-lua/plenary.nvim',
	-- 	},
	-- 	ft = { 'scala', 'sbt', 'java' },
	-- 	opts = function()
	-- 		local metals_config = require('metals').bare_config()
	-- 		metals_config.on_attach = function(client, bufnr)
	-- 			require('metals').setup_dap()
	-- 			-- Enable completion triggered by <c-x><c-o>
	-- 			-- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
	--
	-- 			-- Buffer local mappings.
	-- 			-- See `:help vim.lsp.*` for documentation on any of the below functions
	-- 			local opts = { buffer = bufnr }
	-- 			vim.keymap.set(mode.n, 'gD', vim.lsp.buf.declaration)
	-- 			vim.keymap.set(mode.n, 'K', vim.lsp.buf.hover)
	-- 			vim.keymap.set(mode.n, '<C-k>', vim.lsp.buf.signature_help)
	-- 			vim.keymap.set(mode.n, '<C-T>', vim.lsp.buf.type_definition)
	-- 			vim.keymap.set(mode.n, '<F2>', vim.lsp.buf.rename)
	-- 			vim.keymap.set(mode.n, '<space>rn', vim.lsp.buf.rename)
	-- 			vim.keymap.set(mode.all, '<C-.>', vim.lsp.buf.code_action)
	-- 			vim.keymap.set(mode.all, '<F3>', vim.lsp.buf.code_action)
	-- 			vim.keymap.set(mode.n, 'gr', vim.lsp.buf.references)
	--
	-- 			-- vim.keymap.set('n', '<leader>ws', function()
	-- 			--   require('metals').hover_worksheet()
	-- 			-- end)
	-- 		end
	--
	-- 		return metals_config
	-- 	end,
	-- 	config = function(self, metals_config)
	-- 		local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
	-- 		vim.api.nvim_create_autocmd('FileType', {
	-- 			pattern = self.ft,
	-- 			callback = function()
	-- 				require('metals').initialize_or_attach(metals_config)
	-- 			end,
	-- 			group = nvim_metals_group,
	-- 		})
	-- 	end,
	-- },
}
