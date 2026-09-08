-- nvim-lspconfig defines eslint's `root_dir` as a function, and vim.lsp only
-- consults `root_markers` when `root_dir` is unset -- so the markers below are
-- inert on their own, and lspconfig's `vim.fs.root(...) or vim.fn.getcwd()`
-- fallback applies. With `workspace_required = true` a bad root means the client
-- is skipped with nothing but a log.info. Pin the root explicitly; this file is
-- later in the runtimepath than lspconfig's, so it wins the merge.
return {
  root_markers = { 'eslint.config.js', 'eslint.config.ts', 'eslint.config.json', '.eslintrc' },
  root_dir = function(bufnr, on_dir)
    on_dir(require('project').root(bufnr))
  end,
}
