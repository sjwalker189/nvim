-- Erlang language server (ELP, Erlang Language Platform).
--
-- Mason-managed (package `elp`), listed in `servers` in lua/plugins/lsp.lua.
-- ELP is WhatsApp's rust-analyzer-style server and supersedes erlang_ls; it
-- needs an OTP install on $PATH (`erl`) to build its OTP index.
--
-- https://whatsapp.github.io/erlang-language-platform
return {
  cmd = { 'elp', 'server' },
  filetypes = { 'erlang' },
  root_markers = { 'rebar.config', 'rebar.lock', 'erlang.mk', '.elp.toml', '.git' },
}
