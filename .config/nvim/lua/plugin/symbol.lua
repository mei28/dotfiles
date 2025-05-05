local spec = {
  {
    'Wansmer/symbol-usage.nvim',
    event = { 'LspAttach' }, -- need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
    config = function()
      -- table.insert(res, { '󰌹 ', 'SymbolUsageRef' })
      -- table.insert(res, { '󰳽 ', 'SymbolUsageDef' })
      -- table.insert(res, { '󰡱 ', 'SymbolUsageImpl' })
      --
      local function text_format(symbol)
        local fragments = {}

        -- Indicator that shows if there are any other symbols in the same line
        local stacked_functions = symbol.stacked_count > 0
            and (' | +%s'):format(symbol.stacked_count)
            or ''

        if symbol.references then
          local usage = symbol.references <= 1 and 'usage' or 'usages'
          local num = symbol.references == 0 and 'no' or symbol.references
          table.insert(fragments, '󰌹 ' .. ('%s %s'):format(num, usage))
        end

        if symbol.definition then
          table.insert(fragments, '󰳽 ' .. symbol.definition .. ' defs')
        end

        if symbol.implementation then
          table.insert(fragments, '󰡱 ' .. symbol.implementation .. ' impls')
        end

        return table.concat(fragments, ', ') .. stacked_functions
      end

      require('symbol-usage').setup({
        vt_position = 'end_of_line',
        text_format = text_format,
      })
    end
  }

}

return spec
