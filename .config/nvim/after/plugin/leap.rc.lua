local status, leap = pcall(require, 'leap')
if not status then return end
leap.add_default_mappings()
local del = vim.keymap.del
local set = vim.keymap.set

-- Getting used to `d` shouldn't take long - after all, it is more comfortable
-- than `x`. Also Visual `x`/`d` are the counterparts of Operator-pending `d`
-- (not Normal `x`), so `d` is a much more obvious default choice among the two
-- redundant alternatives.
-- If you still desperately want your old `x` back, then just delete these
-- mappings set by Leap:
del({'x', 'o'}, 'x')
del({'x', 'o'}, 'X')
-- -- To set alternative keys for "exclusive" selection:
set({'x', 'o'}, '<Nop>', '<Plug>(leap-forward-till)')
set({'x', 'o'}, '<Nop>', '<Plug>(leap-backward-till)')
