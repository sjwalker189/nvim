#!/usr/bin/env bash
#
# Remove nvim plugins that are installed on disk but no longer referenced by the
# config. Cleanup goes through `vim.pack` so the plugin directory is removed and
# nvim-pack-lock.json is updated in one step (a plain `rm -rf` would leave the
# lock file stale).
#
# Usage:
#   scripts/clean-packages.sh          # dry run: list orphaned plugins
#   scripts/clean-packages.sh --apply  # actually delete them

set -euo pipefail

case "${1:-}" in
  --apply|-y) export NVIM_CLEAN_APPLY=1 ;;
  ""|--dry-run|-n) export NVIM_CLEAN_APPLY=0 ;;
  -h|--help)
    sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
    exit 0 ;;
  *)
    echo "unknown argument: $1" >&2
    exit 2 ;;
esac

lua_file=$(mktemp -t clean-packages.XXXXXX.lua)
trap 'rm -f "$lua_file"' EXIT

cat >"$lua_file" <<'LUA'
-- init.lua has already run, so every active plugin has been added via
-- vim.pack.add(); anything vim.pack knows about but did not add is orphaned.
local orphans = {}
for _, p in ipairs(vim.pack.get()) do
  if not p.active then
    orphans[#orphans + 1] = p.spec.name
  end
end

if #orphans == 0 then
  io.stderr:write('No orphaned plugins.\n')
  return
end

table.sort(orphans)
local apply = vim.env.NVIM_CLEAN_APPLY == '1'
if apply then
  io.stderr:write('Removing ' .. #orphans .. ' orphaned plugin(s):\n')
else
  io.stderr:write(#orphans .. ' orphaned plugin(s) (run with --apply to remove):\n')
end
for _, name in ipairs(orphans) do
  io.stderr:write('  - ' .. name .. '\n')
end
if apply then
  vim.pack.del(orphans)
  io.stderr:write('Done.\n')
end
LUA

nvim --headless -c "luafile $lua_file" -c qa
