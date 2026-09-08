-- vscode-css-language-server doesn't know Tailwind's at-rules (@apply,
-- @tailwind, @screen, @variants) and flags them as "unknown at rule" by
-- default. Ignore that lint since the tailwindcss server covers Tailwind
-- diagnostics separately.
return {
  settings = {
    css = { lint = { unknownAtRules = 'ignore' } },
    scss = { lint = { unknownAtRules = 'ignore' } },
    less = { lint = { unknownAtRules = 'ignore' } },
  },
}
