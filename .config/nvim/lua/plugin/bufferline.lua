-- bufferline
local spec = {
  {
    -- 'akinsho/bufferline.nvim',
    'mei28/bufferline.nvim',
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      bufferline_setup()
    end,
    keys = {
      { '<Tab>',   '<Cmd>BufferLineCycleNext<CR>' },
      { '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>' }
    }
  }


}

function bufferline_setup()
  local status, bufferline = pcall(require, "bufferline")
  if not status then
    return
  end

  bufferline.setup({
    options = {
      mode = "buffers",
      separator_style = 'thin',
      always_show_bufferline = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      color_icons = true,
      indicator = { style = 'underline' },
    },
    highlights = {
      separator = {
        fg = '#073642',
        bg = '#002b36',
      },
      separator_selected = {
        fg = '#073642',
      },
      background = {
        fg = '#657b83',
        bg = '#002b36'
      },
      buffer_selected = {
        fg = '#fdf6e3',
        bold = true,
        italic = false
      },
      fill = {
        bg = '#073642'
      }
    },
  })
end

return spec
