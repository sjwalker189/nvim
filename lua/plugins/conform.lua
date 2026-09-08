return {
  src = {
    { src = 'https://github.com/stevearc/conform.nvim' },
    { src = 'https://github.com/mfussenegger/nvim-lint' },
  },
  setup = function()
    -- Prefer a project-local binary, walking up from the buffer's directory,
    -- and fall back to whatever is on $PATH.
    local function local_first(cmd)
      return require('conform.util').find_executable({
        'node_modules/.bin/' .. cmd,
        'vendor/bin/' .. cmd,
      }, cmd)
    end

    require('conform').setup {
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == 'php' then
          return { timeout_ms = 500, lsp_format = 'never' }
        end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'oxfmt' },
        javascriptreact = { 'oxfmt' },
        typescript = { 'oxfmt' },
        typescriptreact = { 'oxfmt' },
        vue = { 'oxfmt' },
        astro = { 'oxfmt' },
        go = { 'golangci-lint' },
        php = { 'mago_format' },
        gloss = { 'gloss_fmt' },
      },
      formatters = {
        shfmt = {
          prepend_args = { '-i', '2' },
        },
        stylua = { command = local_first 'stylua' },
        -- conform leaves a formatter's cwd at Neovim's, and `mago format` is fed
        -- the buffer over stdin, so mago.toml is only discovered when nvim happens
        -- to be launched inside the directory holding it. Pin cwd to the buffer's
        -- project or the same file formats differently from the repo root.
        mago_format = {
          command = local_first 'mago',
          cwd = require('conform.util').root_file { 'mago.toml', 'composer.json' },
        },
        gloss_fmt = {
          command = local_first 'gloss',
          args = { 'fmt', '$FILENAME' },
          stdin = false,
        },
        -- `golangci-lint fmt` rather than goimports+gofmt directly, so the
        -- formatters a repo declares in .golangci.yml (it may add gofumpt,
        -- golines, gci) are exactly what runs on save — one source of truth
        -- shared with its CI. ~70ms on a 1k-line file, well inside the 500ms
        -- format_on_save budget.
        --
        -- cwd is pinned for the same reason mago_format above pins it: the
        -- buffer arrives over stdin with cwd left at Neovim's, so .golangci.yml
        -- would otherwise only be found when nvim was launched from the repo.
        -- `mise exec --` picks up a project-pinned golangci-lint (see
        -- lsp/golangci_lint_ls.lua for the longer version of that argument).
        ['golangci-lint'] = {
          command = 'mise',
          prepend_args = { 'exec', '--', 'golangci-lint' },
          cwd = require('conform.util').root_file {
            '.golangci.yml',
            '.golangci.yaml',
            '.golangci.toml',
            '.golangci.json',
            'go.mod',
          },
        },
      },
    }

    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

    vim.keymap.set('', '<S-C-i>', function()
      require('conform').format {
        async = true,
        lsp_format = 'fallback',
        stop_after_first = true,
      }
    end, { desc = 'Format buffer' })

    -- nvim-lint has no equivalent of conform's ctx.dirname, so linters resolve
    -- their binary and root through the shared buffer-relative helper instead.
    local project = require 'project'
    local lint = require 'lint'

    lint.linters_by_ft = {
      -- php is deliberately absent: nvim-lint is per-buffer, and phpstan only
      -- reports its project-level errors when the whole project is analysed at
      -- once. `lua/phpstan.lua` runs it that way and publishes every file's
      -- diagnostics; listing it here too would duplicate them for the buffer.
      -- vue = { 'eslint_d' },
    }

    -- FileType rather than BufReadPost: the file named on the command line is
    -- read *before* filetype detection runs, so a BufReadPost hook sees an empty
    -- `filetype`, resolves no linters for it, and `nvim src/Foo.php` never lints.
    vim.api.nvim_create_autocmd({ 'BufWritePost', 'FileType' }, {
      callback = function()
        lint.try_lint(nil, {
          -- The directory owning the linter's config, not `project.root()`:
          -- phpstan needs the dir holding phpstan.neon (autoload paths, larastan,
          -- baseline), which sits below the git root in a src/-layout repo.
          cwd = project.config_root {
            'phpstan.neon',
            'phpstan.neon.dist',
            'composer.json',
            'package.json',
          } or project.root(),
          -- Skip linters that aren't installed rather than failing with ENOENT.
          filter = function(linter)
            local cmd = type(linter.cmd) == 'function' and linter.cmd() or linter.cmd
            return cmd ~= nil and vim.fn.executable(cmd) == 1
          end,
        })
      end,
    })

    -- Registers :Phpstan plus its own save/open hooks; see lua/phpstan.lua.
    require('phpstan').setup()
  end,
}
