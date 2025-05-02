local state = {
  floating = {
    buf = -1,
    win = -1,
  },
}

-- Custom hl groups
-- TODO: colors from colors.lua theme (kawagawa)
vim.api.nvim_set_hl(0, 'TerminalFloatBg', { bg = '#1F1F28', fg = '#d0cfc8' })
vim.api.nvim_set_hl(0, 'TerminalFloatBorder', { bg = '#1F1F28', fg = '#54546D' })

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.85)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Create a buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  end

  -- Define window configuration
  local win_config = {
    title = ' Terminal ',
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal', -- No borders or extra UI elements
    border = 'rounded',
  }

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, win_config)

  -- Apply custom hl groups
  -- TODO: create a table to hold the hl mappings
  vim.api.nvim_set_option_value('winhighlight', 'Normal:TerminalFloatBg,FloatBorder:TerminalFloatBorder', { scope = 'local', win = win })

  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    -- Create the floating window and store its details
    state.floating = create_floating_window { buf = state.floating.buf }

    -- Ensure the buffer is a terminal buffer
    if vim.bo[state.floating.buf].buftype ~= 'terminal' then
      -- If not already a terminal, start a terminal in the buffer
      vim.cmd.terminal()
    end

    vim.api.nvim_set_current_win(state.floating.win)
    vim.cmd.startinsert()
  else
    -- If the window exists, hide it
    vim.api.nvim_win_hide(state.floating.win)
  end
end

vim.api.nvim_create_user_command('FloatTerm', toggle_terminal, {})

vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>')
vim.keymap.set('n', '<F12>', toggle_terminal, {
  desc = 'Toggle Floating Terminal',
})
