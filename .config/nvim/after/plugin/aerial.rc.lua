local status, aerial = pcall(require, 'aerial')
if not status then return end
local set=  vim.keymap.set
aerial.setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
    set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
  end,
  layout = {
    -- These control the width of the aerial window.
    -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_width and max_width can be a list of mixed types.
    -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
    max_width = { 40, 0.2 },
    width = nil,
    min_width = 20,


    -- Determines the default direction to open the aerial window. The 'prefer'
    -- options will open the window in the other direction *if* there is a
    -- different buffer in the way of the preferred direction
    -- Enum: prefer_right, prefer_left, right, left, float
    default_direction = "prefer_left",

  },
})
-- You probably also want to set a keymap to toggle aerial
set('n', ';a', '<CMD>AerialToggle!<CR>')
