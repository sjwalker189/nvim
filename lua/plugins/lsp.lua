-- Server configs live in `~/.config/nvim/lsp/<name>.lua` (the native nvim 0.11+
-- convention) and are merged on top of nvim-lspconfig's defaults. Servers
-- without a file here use lspconfig's config as-is.
local servers = {
  'bashls',
  'lua_ls',
  'html',
  'cssls',
  'tailwindcss',
  'ts_ls',
  'vue_ls',
  'astro',
  'gopls',
  'templ',
  'eslint',
  'intelephense',
}

-- Buffer-local LSP keymaps, wired on attach. { mode, lhs, rhs }
local function code_action()
  vim.lsp.buf.code_action {
    filter = function(action)
      return action.disabled == nil
    end,
  }
end

local lsp_maps = {
  { 'n', 'gD', vim.lsp.buf.declaration },
  { 'n', 'gd', vim.lsp.buf.definition },
  { 'n', 'K', vim.lsp.buf.hover },
  { 'n', '<C-k>', vim.lsp.buf.signature_help },
  { 'n', '<C-T>', vim.lsp.buf.type_definition },
  { 'n', '<F2>', vim.lsp.buf.rename },
  { 'n', '<space>rn', vim.lsp.buf.rename },
  { { 'n', 'v', 'i', 'x' }, '<C-.>', code_action },
  { { 'n', 'v', 'i', 'x' }, '<F3>', code_action },
  { 'n', 'gr', vim.lsp.buf.references },
  { 'n', '<space>cl', vim.lsp.codelens.run },
}

return {
  src = {
    { src = 'https://github.com/folke/neodev.nvim' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
  },
  setup = function()
    -- neodev must be set up before lua_ls attaches.
    require('neodev').setup {}

    -- Defer mason (server installer + :Mason UI) off the startup path. LSP
    -- itself is enabled eagerly below, so already-installed servers attach
    -- immediately; mason only needs to run to install any missing servers,
    -- which can wait until the first real file is opened.
    vim.api.nvim_create_autocmd('FileType', {
      once = true,
      callback = vim.schedule_wrap(function()
        require('mason').setup {}
        require('mason-lspconfig').setup {
          automatic_enable = { exclude = { 'rust_analyzer' } },
          ensure_installed = servers,
        }
      end),
    })

    vim.lsp.enable(servers)

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp_attach_maps', { clear = true }),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        for _, m in ipairs(lsp_maps) do
          vim.keymap.set(m[1], m[2], m[3], { buffer = ev.buf })
        end
      end,
    })
  end,
}
