-- bufferline
local spec = {
  {
    'akinsho/bufferline.nvim',
    -- 'mei28/bufferline.nvim',
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      bufferline_setup()
    end,
    keys = {
      { '<Tab>',   '<Cmd>BufferLineCycleNext<CR>' },
      { '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>' }
    },
    dependencies = { 'mei28/chromabuffer' }
  }
}

function bufferline_setup()
  local status, bufferline = pcall(require, "bufferline")
  if not status then return end
  local status, chroma = pcall(require, "chromabuffer")
  if not status then return end


  chroma.setup({ highlight_template = 'default' })
  local highlights = chroma.get_bufferline_highlights()

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
        fg = highlights.separator_fg,
        bg = highlights.bg,
      },
      separator_selected = {
        fg = highlights.separator_fg,
      },
      background = {
        fg = highlights.background_fg,
        bg = highlights.bg,
      },
      buffer_selected = {
        fg = highlights.selected_fg,
        bold = true,
        italic = false,
      },
      fill = {
        bg = highlights.fill_bg,
      },
    }
  })
end

return spec


-- Nord
--
-- highlights = {
--   separator = {
--     fg = '#4C566A',
--     bg = '#2E3440',
--   },
--   separator_selected = {
--     fg = '#4C566A',
--   },
--   background = {
--     fg = '#D8DEE9',
--     bg = '#2E3440'
--   },
--   buffer_selected = {
--     fg = '#ECEFF4',
--     bold = true,
--     italic = false
--   },
--   fill = {
--     bg = '#3B4252'
--   }
-- }

-- Dracula
-- highlights = {
--   separator = {
--     fg = '#6272A4',
--     bg = '#282A36',
--   },
--   separator_selected = {
--     fg = '#6272A4',
--   },
--   background = {
--     fg = '#F8F8F2',
--     bg = '#282A36'
--   },
--   buffer_selected = {
--     fg = '#FF79C6',
--     bold = true,
--     italic = false
--   },
--   fill = {
--     bg = '#44475A'
--   }
-- }

-- Gruvbox
-- highlights = {
--   separator = {
--     fg = '#504945',
--     bg = '#282828',
--   },
--   separator_selected = {
--     fg = '#504945',
--   },
--   background = {
--     fg = '#EBDBB2',
--     bg = '#282828'
--   },
--   buffer_selected = {
--     fg = '#FABD2F',
--     bold = true,
--     italic = false
--   },
--   fill = {
--     bg = '#3C3836'
--   }
-- }
