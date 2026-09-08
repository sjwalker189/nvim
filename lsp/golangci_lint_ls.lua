-- golangci-lint as a language server (nametake/golangci-lint-langserver), which
-- mason installs. It's a thin wrapper: it shells out to the `golangci-lint`
-- binary and republishes the JSON as diagnostics. gopls stays the primary Go
-- server; this only adds the lint findings gopls doesn't produce.
--
-- `mise exec --` for the same reason lsp/ocamllsp.lua uses `opam exec --`. The
-- binary is pinned per-project (a repo's own mise.toml), and this shell uses
-- `mise activate` rather than shims, so nvim only inherits a PATH containing it
-- when nvim happened to be launched from inside that project. Going through
-- mise resolves the version the project pins — matching what its CI runs —
-- and falls back to the one in ~/.config/nvim/mise.toml everywhere else.
--
-- Overriding init_options.command also sidesteps upstream's before_init, which
-- probes `vim.fn.executable('golangci-lint')` and silently leaves a v2-shaped
-- command when the binary isn't on PATH.
return {
  init_options = {
    command = {
      'mise',
      'exec',
      '--',
      'golangci-lint',
      'run',
      '--output.json.path',
      'stdout',
      '--show-stats=false',
    },
  },
}
