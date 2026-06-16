-- tree-sitter-test's ftplugin enables treesitter folds (foldmethod=expr), which
-- start collapsed under the global foldlevel=0. Open them by default so corpus
-- files are readable; folding is still available via zc/zo/zM.
vim.wo.foldlevel = 99
