local spec = {
  "rmagatti/goto-preview",
  config = function()
    require('goto-preview').setup({
      default_mappings = true,
      dismiss_on_move = true
    })
  end,
  keys = {
    { 'gpd', function() require('goto-preview').goto_preview_definition() end,      'n' },
    { 'gpt', function() require('goto-preview').goto_preview_type_definition() end, 'n' },
    { 'gpi', function() require('goto-preview').goto_preview_implementation() end,  'n' },
    { 'gpD', function() require('goto-preview').goto_preview_declaration() end,     'n' },
    { 'qP',  function() require('goto-preview').close_all_windows() end,            'n' },
    { 'gpr', function() require('goto-preview').goto_preview_references() end },
  }
}

return spec
