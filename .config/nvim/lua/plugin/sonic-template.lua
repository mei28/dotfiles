local spec = {
  -- template
  {
    'mattn/vim-sonictemplate',
    config = function()
      vim.g.sonictemplate_vim_template_dir = '~/dotfiles/.config/nvim/template/'
    end,
    cmd = { 'Template' }
  }
}

return spec
