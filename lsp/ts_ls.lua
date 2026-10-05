-- Mason installs `@vue/typescript-plugin` alongside the Vue language server.
-- Resolved from stdpath rather than $MASON, which is only set once mason.setup()
-- has run -- this file is read before that.
local vue_typescript_plugin = vim.fs.joinpath(
  vim.fn.stdpath 'data',
  'mason/packages/vue-language-server/node_modules/@vue/typescript-plugin'
)

return {
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
  root_markers = { 'package.json', 'tsconfig.json' },
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = vue_typescript_plugin,
        languages = { 'vue' },
        configNamespace = 'typescript',
        enableForWorkspaceTypeScriptVersions = true,
      },
    },
    preferences = {
      importModuleSpecifierEnding = 'auto',
      importModuleSpecifierPreference = 'shortest',
      includeCompletionsForImportStatements = true,
      includeCompletionsForModuleExports = true,
      updateImportsOnFileMove = { enabled = 'always' },
      completeFunctionCalls = true,
    },
  },
}
