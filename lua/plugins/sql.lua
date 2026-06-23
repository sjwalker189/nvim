return {
  src = {
    { src = 'https://github.com/tpope/vim-dadbod' },
    { src = 'https://github.com/kristijanhusak/vim-dadbod-completion' },
    { src = 'https://github.com/kristijanhusak/vim-dadbod-ui' },
  },
  setup = function()
    -- DBUI configuration. Commands (:DBUI, :DBUIToggle, ...) are available once
    -- the plugin is on the runtimepath.
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}
