-- Buffer-relative project root detection.
--
-- Everything here searches upward from the *buffer's* path rather than Neovim's
-- cwd, so the config keeps working when nvim is launched inside a project
-- subdirectory (`nvim app/Http/Controllers`).
local M = {}

-- Checked only when the buffer isn't inside a git repo.
local MARKERS = { 'composer.json', 'package.json', 'go.mod', 'dune-project', 'Cargo.toml' }

---Project root for a buffer: git root, then ecosystem marker, then cwd.
---@param bufnr? integer defaults to the current buffer
---@return string
function M.root(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  -- Unnamed buffers (and `nvim` with no file) have nothing to search up from.
  local from = name ~= '' and name or vim.fn.getcwd()
  -- Two calls, not one flat list: `vim.fs.root` returns the *nearest* directory
  -- holding any marker, so a combined list would let a nested package.json win
  -- over the enclosing repo.
  return vim.fs.root(from, '.git') or vim.fs.root(from, MARKERS) or vim.fn.getcwd()
end

---Nearest ancestor holding one of `markers`, without preferring the git root.
---A tool reads its config from the directory that owns its manifest, which is
---not always the repo root: a Laravel app kept in `src/` has its phpstan.neon
---and composer.json there, several levels below `.git`.
---@param markers string|string[]
---@param bufnr? integer defaults to the current buffer
---@return string|nil
function M.config_root(markers, bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  local from = name ~= '' and name or vim.fn.getcwd()
  return vim.fs.root(from, markers)
end

---First executable at <ancestor>/<rel>, walking up from the buffer.
---@param rel string relative path, e.g. 'vendor/bin/phpstan'
---@param bufnr? integer defaults to the current buffer
---@return string|nil
function M.find_bin(rel, bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  if name == '' then
    return nil
  end
  for dir in vim.fs.parents(name) do
    local candidate = dir .. '/' .. rel
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  -- Explicit, so callers get nil rather than zero values.
  return nil
end

return M
