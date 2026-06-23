local vue_language_server_path = vim.fn.expand '$MASON/packages/vue-language-server'

return {
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
  root_markers = { 'package.json', 'tsconfig.json' },
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = vue_language_server_path .. '/node_modules/@vue/language-server',
        languages = { 'vue' },
        configNamespace = 'typescript',
        enableForWorkspaceTypeScriptVersions = true,
      },
    },
    preferences = {
      importModuleSpecifierEnding = 'js',
      importModuleSpecifierPreference = 'shortest',
      includeCompletionsForImportStatements = true,
      includeCompletionsForModuleExports = true,
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
      },
    },
  },
}
