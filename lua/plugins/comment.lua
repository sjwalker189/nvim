return {
  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
	{
		"folke/todo-comments.nvim",
		opts = {},
		lazy = true
	}
}
