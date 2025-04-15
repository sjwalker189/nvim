local typescript_formatters = {
	'prettierd',
	'prettier',
	'deno_fmt',
}

return {
	{
		'williamboman/mason.nvim',
		opts = { ensure_installed = 'prettierd', 'prettier' },
	},
	{
		'stevearc/conform.nvim',
		event = { 'BufWritePre' },
		cmd = { 'ConformInfo' },
		keys = {
			{
				'<S-C-i>',
				function()
					require('conform').format {
						async = true,
						lsp_fallback = true,
						stop_after_first = true,
					}
				end,
				mode = '',
				desc = 'Format buffer',
			},
		},
		opts = {
			format_on_save = { timeout_ms = 200 },
			formatters_by_ft = {
				lua = { 'stylua' },
				php = { { 'pint', 'php_cs_fixer' } },
				javascript = typescript_formatters,
				javascriptreact = typescript_formatters,
				typescript = typescript_formatters,
				typescriptreact = typescript_formatters,
				vue = typescript_formatters,
				templ = {
					"gofumpt",
					"templ",
					"injected",
				}
			},
		},
		init = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}
