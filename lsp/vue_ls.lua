-- Since v3 the Vue language server only handles the .vue file itself and
-- forwards everything TypeScript to ts_ls via the @vue/typescript-plugin
-- declared in lsp/ts_ls.lua. Takeover mode (and the `hybridMode` option) is gone.
return {
  filetypes = { 'vue' },
  root_markers = { 'package.json', 'tsconfig.json' },
}
