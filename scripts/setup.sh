#!/usr/bin/env bash

# Bootstrap this Neovim config on a fresh machine:
#   1. verify Neovim is new enough and the build toolchain is present
#   2. install all plugins (vim.pack clones them synchronously on first launch)
#   3. install treesitter parsers
#   4. report external tools the config expects on $PATH
#
# It is safe to re-run; everything here is idempotent.

set -euo pipefail

# Formatting
if [ -t 1 ]; then
  bold=$'\033[1m'; red=$'\033[31m'; yellow=$'\033[33m'; green=$'\033[32m'; reset=$'\033[0m'
else
  bold=""; red=""; yellow=""; green=""; reset=""
fi
ok()   { printf '  %s✓%s %s\n' "$green" "$reset" "$1"; }
warn() { printf '  %s•%s %s\n' "$yellow" "$reset" "$1"; }
err()  { printf '  %s✗%s %s\n' "$red" "$reset" "$1"; }
head() { printf '\n%s%s%s\n' "$bold" "$1" "$reset"; }

is_darwin() { [ "$(uname -s)" = "Darwin" ]; }
have() { command -v "$1" >/dev/null 2>&1; }

# Requirements
head "Checking requirements"

if ! have nvim; then
  err "neovim is not installed — install it first (>= 0.12)"
  exit 1
fi

# vim.pack and the treesitter `main` branch both require Neovim 0.12+.
nvim_version_out=$(nvim --version)
nvim_first_line=${nvim_version_out%%$'\n'*}
nvim_ver=$(printf '%s' "$nvim_first_line" | sed -E 's/^NVIM v?([0-9]+\.[0-9]+).*/\1/')
nvim_major=${nvim_ver%%.*}
nvim_minor=${nvim_ver##*.}
if [ "$nvim_major" -eq 0 ] && [ "$nvim_minor" -lt 12 ]; then
  err "neovim $nvim_ver found, but this config needs >= 0.12 (vim.pack / treesitter main)"
  exit 1
fi
ok "neovim $nvim_ver"

missing_required=0
for tool in git cc; do
  if have "$tool"; then
    ok "$tool"
  else
    err "$tool is required"
    missing_required=1
  fi
done
if [ "$missing_required" -ne 0 ]; then
  if is_darwin; then
    warn "on macOS run: xcode-select --install"
  fi
  exit 1
fi

# Plugins
head "Installing plugins and treesitter parsers"
echo "  (first run clones ~30 repos and compiles parsers — this can take a few minutes)"

# vim.pack.add() inside the config clones any missing plugins synchronously
# while init.lua is sourced. Treesitter parser installs are async, so poll
# get_installed() until the set stops growing, then quit.
boot_lua=$(mktemp -t nvim-setup.XXXXXX.lua)
trap 'rm -f "$boot_lua" "${fzy_lua:-}"' EXIT
cat >"$boot_lua" <<'LUA'
local cfg = require('nvim-treesitter.config')
local prev, idle = -1, 0
vim.wait(600000, function()
  local n = #cfg.get_installed()
  if n == prev then idle = idle + 1 else prev, idle = n, 0 end
  return idle >= 10 -- ~5s with no newly installed parser
end, 500)
print(('treesitter parsers installed: %d'):format(#cfg.get_installed()))
LUA

if ! nvim --headless -c "luafile $boot_lua" -c 'qa!'; then
  err "nvim bootstrap failed — run 'nvim' manually and check :messages / :checkhealth"
  exit 1
fi
ok "plugins and parsers installed"

# ---- 3b. luarocks + fzy matcher for snap --------------------------------
# snap prefers a native `fzy` matcher when available, otherwise it falls back
# to the bundled fzf consumer. Enabling fzy means "preparing" luarocks
# (python3 venv + hererocks + LuaJIT/luarocks) and installing the `fzy` rock.
# snap's setup already registers the rock, so build.build() installs it.
head "Building the snap fzy matcher (optional)"
if ! have python3; then
  warn "python3 not found — skipping; snap will use the fzf fallback"
else
  fzy_lua=$(mktemp -t nvim-fzy.XXXXXX.lua)
  cat >"$fzy_lua" <<'LUA'
local ok, build = pcall(require, 'luarocks.build')
if not ok then
  print('FZY:noluarocks')
else
  if build.is_prepared() then
    -- luarocks is already built; snap's setup ensured the rock during init.
    print('FZY:prepared')
  else
    -- build() runs synchronously and installs the `fzy` rock that snap
    -- registered via ensure_rocks_after_build.
    print(pcall(build.build) and 'FZY:built' or 'FZY:failed')
  end
  print('FZY:available=' .. tostring((pcall(require, 'fzy'))))
end
LUA
  echo "  (first run creates a python venv, installs hererocks, builds LuaJIT — takes a minute)"
  fzy_out=$(nvim --headless -c "luafile $fzy_lua" -c 'qa!' 2>&1 || true)
  if printf '%s' "$fzy_out" | grep -q 'FZY:available=true'; then
    ok "snap fzy matcher ready"
  elif printf '%s' "$fzy_out" | grep -Eq 'FZY:(built|prepared)'; then
    # luarocks built fine but the fzy rock isn't loadable (the bundled
    # luarocks installs into the home tree, not snap's package.cpath).
    warn "luarocks is prepared but the fzy rock isn't loadable here — snap uses the fzf fallback"
  else
    warn "luarocks build failed — snap uses the fzf fallback"
    printf '%s\n' "$fzy_out" | sed 's/^/      /' || true
  fi
fi

# External tools
script_dir=$(cd "$(dirname "$0")" && pwd)
config_dir=$(dirname "$script_dir")

head "Provisioning tools with mise"
if have mise; then
  if (cd "$config_dir" && mise trust --quiet . && mise install); then
    ok "mise tools installed (see mise.toml)"
  else
    warn "mise install reported errors — check 'mise doctor' / 'mise ls'"
  fi
else
  warn "mise not found — install it: https://mise.jdx.dev (then re-run)"
fi

# Verify what's actually on PATH now. "cmd|hint|source".
head "Tool check"
tools="rg|ripgrep — snap pickers|mise
fd|fd — snap pickers|mise
tree-sitter|tree-sitter CLI — tree-sitter-test grammar|mise
lazygit|lazygit — <leader>lg|mise
node|node — mason LSP servers (ts_ls, vue, tailwind, ...)|mise
stylua|stylua — lua formatting|mise
shfmt|shfmt — shell formatting|mise
oxfmt|oxfmt — js/ts/vue/astro formatting|mise
goimports|goimports — go imports/format|mise
curl|curl — blink prebuilt fuzzy + mason downloads|system
python3|python3 — optional luarocks/fzy matcher|system
rust-analyzer|rust-analyzer — rustaceanvim|rustup component add rust-analyzer
pint|pint — php formatting|composer (project-local)
phpstan|phpstan — php linting|composer (project-local)"

# mise-managed tools live on mise's shims/managed path, not necessarily on the
# bare PATH of this shell, so resolve those via `mise which`; check the rest on PATH.
tool_present() { # $1 = binary, $2 = source
  if [ "$2" = "mise" ] && have mise; then
    (cd "$config_dir" && mise which "$1" >/dev/null 2>&1)
  else
    have "$1"
  fi
}

printf '%s\n' "$tools" | while IFS='|' read -r cmd hint source; do
  if tool_present "$cmd" "$source"; then ok "$hint"; else warn "missing: $hint  [$source]"; fi
done

head "Done"
echo "  Plugins and parsers are installed. Launch 'nvim' to use it."
echo "  LSP servers install on first file open via Mason (:Mason to inspect)."
echo "  Tooling is managed by mise (mise.toml); rust-analyzer via rustup, php tools via composer."
