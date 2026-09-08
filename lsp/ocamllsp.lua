-- OCaml / Reason language server (ocaml-lsp-server).
--
-- ocamllsp is opam-managed, NOT mason-managed: it must be compiled against the
-- project's OCaml switch (merlin bundled inside it is compiler-version-specific),
-- so it's installed with `opam install ocaml-lsp-server` and kept out of mason's
-- `ensure_installed` list. See lua/plugins/lsp.lua.
--
-- Running through `opam exec --` resolves ocamllsp *and* the tools it shells out
-- to (refmt for Reason formatting, dune, etc.) from the active switch, even when
-- nvim wasn't launched from a shell that ran `eval $(opam env)`.
return {
  cmd = { 'opam', 'exec', '--', 'ocamllsp' },
  filetypes = { 'ocaml', 'ocaml.interface', 'ocaml.menhir', 'ocaml.ocamllex', 'reason', 'dune' },
  root_markers = { 'dune-project', 'dune-workspace', 'esy.json', '.git' },
  settings = {},
}
