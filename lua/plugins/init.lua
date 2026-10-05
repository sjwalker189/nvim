-- Plugin loader built on Neovim's built-in plugin manager (`:help vim.pack`).
--
-- Each module under `lua/plugins/` returns a table of the form:
--   { src = { <vim.pack specs> }, setup = function() ... end }
-- `src` lists the plugins that module needs; `setup` configures them and runs
-- after every plugin has been added to the runtimepath. vim.pack has no
-- lazy-loading / opts / build hooks of its own, so everything is explicit here.

-- Build hooks must be registered BEFORE the first vim.pack.add() so they also
-- fire on the very first install. See `:help vim.pack-events`.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then
      return
    end

    if name == 'tree-sitter-test' then
      -- Mirrors the old lazy `build` step for the corpus-test grammar.
      vim.system({ 'sh', '-c', 'mkdir -p parser && tree-sitter build -o parser/test.so' }, { cwd = ev.data.path })
    elseif name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd 'nvim-treesitter'
      end
      pcall(function()
        require('nvim-treesitter').update()
      end)
    end
  end,
})

-- Order matters: shared deps and colours first, then everything else.
local modules = {
  'plugins.base',
  'plugins.oil',
  'plugins.colors',
  'plugins.treesitter',
  'plugins.blink',
  'plugins.lsp',
  'plugins.rust',
  'plugins.reason',
  'plugins.conform',
  'plugins.git',
  'plugins.sql',
  'plugins.snap',
  'plugins.tstest',
  'plugins.devcontainer',
}

local specs = {}
local seen = {}
local setups = {}

for _, mod in ipairs(modules) do
  local m = require(mod)
  for _, spec in ipairs(m.src or {}) do
    local src = type(spec) == 'string' and spec or spec.src
    if not seen[src] then
      seen[src] = true
      specs[#specs + 1] = spec
    end
  end
  if m.setup then
    setups[#setups + 1] = m.setup
  end
end

vim.pack.add(specs)

for _, setup in ipairs(setups) do
  setup()
end
