-- Reason (.re/.rei) support. There is no `reason` tree-sitter parser in
-- nvim-treesitter's registry (only `ocaml`), so highlighting comes from
-- vim-reason-plus -- the canonical Reason plugin, which ships:
--   * ftdetect for .re/.rei -> filetype `reason`
--   * syntax highlighting
--   * indentation
-- Semantic features (go-to-def, hover, diagnostics, rename, format) come from
-- ocamllsp; see lsp/ocamllsp.lua.
return {
  src = {
    { src = 'https://github.com/reasonml-editor/vim-reason-plus' },
  },
  setup = function()
    -- The generic treesitter FileType autocmd (plugins/treesitter.lua) sets
    -- `indentexpr` to the treesitter indenter for every buffer. There's no
    -- reason parser, so that indenter is a no-op for .re files and clobbers the
    -- indent vim-reason-plus installs. This module loads after treesitter (see
    -- the modules order in plugins/init.lua), so this FileType autocmd runs
    -- last and restores vim-reason-plus's indentexpr.
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'reason',
      callback = function()
        vim.bo.indentexpr = 'GetReasonIndent(v:lnum)'
      end,
    })
  end,
}
