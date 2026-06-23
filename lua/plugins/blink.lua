return {
  src = {
    -- Track the 1.x release tags so blink can fetch its prebuilt fuzzy binary.
    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1' },
    { src = 'https://github.com/rafamadriz/friendly-snippets' },
  },
  setup = function()
    require('blink.cmp').setup {
      keymap = {
        preset = 'default',
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
      },

      appearance = {
        nerd_font_variant = 'mono',
      },

      completion = {
        documentation = {
          auto_show = true,
        },
        ghost_text = {
          enabled = false,
        },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },

        providers = {
          snippets = {
            opts = {
              friendly_snippets = true,
              extended_filetypes = {
                php = { 'phpdoc' },
                vue = { 'vue' },
                typescript = { 'typescript' },
                go = { 'go' },
                lua = { 'lua' },
              },
            },
          },
        },
      },

      signature = {
        enabled = true,
      },
      fuzzy = {
        implementation = 'rust',
      },
    }
  end,
}
