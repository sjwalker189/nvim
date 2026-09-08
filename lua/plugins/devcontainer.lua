-- Devcontainer support: build / start / attach to a project's `.devcontainer`
-- from the host. The plugin orchestrates Docker and docker-compose, both of
-- which it auto-detects -- there's no podman here, so no `container_runtime` /
-- `compose_command` overrides are needed. Reading devcontainer.json relies on
-- the treesitter `json` parser, which plugins.treesitter already installs.
-- See `:help devcontainer`.
return {
  src = {
    -- Primary development is on codeberg.org/esensar/nvim-dev-container; this
    -- is the maintained GitHub mirror, kept consistent with the rest of `src`.
    { src = 'https://github.com/esensar/nvim-dev-container' },
  },
  setup = function()
    require('devcontainer').setup {
      -- Drive everything explicitly via the keymaps below -- don't auto-start,
      -- clean, or restart containers off buffer/vim events.
      autocommands = {
        init = false,
        clean = false,
        update = false,
      },
    }

    local function map(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { desc = desc, silent = true })
    end

    map('<leader>ds', '<cmd>DevcontainerStart<cr>', '[D]evcontainer [S]tart')
    map('<leader>da', '<cmd>DevcontainerAttach<cr>', '[D]evcontainer [A]ttach')
    map('<leader>de', '<cmd>DevcontainerExec<cr>', '[D]evcontainer [E]xec')
    map('<leader>dx', '<cmd>DevcontainerStop<cr>', '[D]evcontainer stop')
    map('<leader>dX', '<cmd>DevcontainerStopAll<cr>', '[D]evcontainer stop all')
    map('<leader>dR', '<cmd>DevcontainerRemoveAll<cr>', '[D]evcontainer remove all')
    map('<leader>dl', '<cmd>DevcontainerLogs<cr>', '[D]evcontainer [L]ogs')
    map('<leader>dc', '<cmd>DevcontainerEditNearestConfig<cr>', '[D]evcontainer [C]onfig')
  end,
}
