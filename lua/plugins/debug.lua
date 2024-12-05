return {
  { 'nvim-neotest/nvim-nio' },
  { 'mfussenegger/nvim-dap' },
  {
    'leoluz/nvim-dap-go',
    ft = 'go',
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function(_, opts)
      require('dap-go').setup(opts)
    end,
  },
  { 'rcarriga/nvim-dap-ui', dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' } },
}
