local spec = {
  {
    'nvim-lualine/lualine.nvim',
    event = { 'BufNewFile', 'BufRead' },
    config = function()
      lualine_setup()
    end,
  }
}
function lualine_setup()
  local status, lualine = pcall(require, 'lualine')
  if not status then
    return
  end

  local lsp_names = function()
    local clients = {}
    for _, client in ipairs(vim.lsp.get_active_clients { bufnr = 0 }) do
      if client.name == 'null-ls' then
        local sources = {}
        for _, source in ipairs(require('null-ls.sources').get_available(vim.bo.filetype)) do
          table.insert(sources, source.name)
        end
        table.insert(clients, 'null-ls(' .. table.concat(sources, ', ') .. ')')
      else
        table.insert(clients, client.name)
      end
    end
    return ' ' .. table.concat(clients, '/')
  end

  lualine.setup {
    options = {
      icons_enabled = true,
      theme = 'nord',
      section_separators = { left = '', right = '' },
      component_separators = { left = '', right = '' },
      disabled_filetypes = {}
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'diff' },
      lualine_c = {
        {
          'filename',
          path = 1,
          file_status = true,
          shorting_target = 40,
          symbols = {
            modified = '[+]',
            readonly = '[RO]',
            unnamed = 'Untitled',
          }
        }
      },
      lualine_x = {
        {
          'diagnostics',
          sources = { "nvim_diagnostic" },
          symbols = {
            error = ' ',
            warn = ' ',
            info = ' ',
            hint = ' '
          }
        },
      },
      -- lualine_y = { 'progress' },
      -- lualine_z = { 'location' }
      lualine_y = {
        'filetype',
        'encoding',
      },
      lualine_z = {
        lsp_names
      },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { {
        'filename',
        file_status = true, -- displays file status (readonly status, modified status)
        path = 1            -- 0 = just filename, 1 = relative path, 2 = absolute path
      } },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {}
    },
    tabline = {},
    extensions = { 'fugitive' }
  }
end

return spec
