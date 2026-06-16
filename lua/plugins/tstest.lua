-- Highlighting for tree-sitter corpus test files (test/corpus/*.txt).
-- Provides the `test` parser plus the `set-language-from-grammar!` injection
-- directive and queries/test/*.scm, which auto-detect the embedded language
-- (gloss) from the sibling src/grammar.json. The s-expression section is
-- injected as the `query` language.
return {
  'tree-sitter-grammars/tree-sitter-test',
  build = 'mkdir -p parser && tree-sitter build -o parser/test.so',
  ft = 'test',
  init = function()
    vim.g.tstest_fullwidth_rules = false
    vim.g.tstest_rule_hlgroup = 'FoldColumn'
  end,
}
