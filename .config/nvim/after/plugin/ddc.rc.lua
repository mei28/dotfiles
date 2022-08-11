-- -- Use around source.
vim.fn['ddc#custom#patch_global'](
'sources', {'around','nvim-lsp','file','buffer'})

vim.fn['ddc#custom#patch_global']('completionMenu', 'pum.vim')

vim.fn['ddc#custom#patch_global']('sourceOptions', {
  ['around']={mark='A'},
  ["_"]={
    matchers={'matcher_head','matcher_fuzzy','matcher_length'},
    sorters={'sorter_fuzzy','sorter_rank'},
    converters={'converter_fuzzy'}
  },
  ["nvim-lsp"]={mark='lsp',forceCompletionPattern=[['\.\w*|:\w*|->\w*']]},
  ["file"]={mark='F', isVolatile=[[v:true]],forceCompletionPattern=[['\S/\S*']]},
  ["buffer"]={mark='B'},
})

vim.fn['ddc#custom#patch_global']('sourceParams',{
  ["around"]={maxSize=500},
  ["nvim-lsp"]={kindLabels={Class='c'}},
  ["buffer"]={requireSameFiletype=[[v:false]], forceCollect=[[v:true]]},
})

vim.fn['ddc#custom#patch_global']('filterParams',{
  ["matcher_fuzzy"]={camelcase=[[v:true]]}
})


-- -- Use ddc.
vim.fn['ddc#enable']() 

-- Use signature help
vim.fn['signature_help#enable']()

-- use pop up preview
vim.fn['popup_preview#enable']()

-- define keymap
vim.keymap.set('i','<Tab>',function()
  if vim.fn['pum#visible']() == 1 then
    vim.fn['pum#map#insert_relative'](1)
    return ''
  end
  local col = vim.fn.col "."
  if col<=1 or vim.fn.getline('.'):sub(col-1):match '%s' then
    return '<Tab>'
  end
  vim.fn['ddc#manual_complete']()
  return ""
end,{expr=true,noremap=true})

local function pum_insert(key, line)
  return function()
    if vim.fn['pum#visible']() then
      vim.fn['pum#map#insert_relative'](line)
      return ''
    end
    return key
  end
end

vim.keymap.set('i','<S-Tab>', pum_insert("<S-Tab>",-1),{expr=true})
vim.keymap.set('i','<C-n>', pum_insert("<S-Tab>", 1),{expr=true})
vim.keymap.set('i','<C-p>', pum_insert("<S-Tab>",-1),{expr=true})
vim.keymap.set('i','<Up>', pum_insert("<S-Tab>", -1),{expr=true})
vim.keymap.set('i','<Down>', pum_insert("<S-Tab>",1),{expr=true})


vim.g.AutoPairsMapCR=0
vim.keymap.set('i','<CR>', function()
  if vim.fn['pum#visible']()==1 then
    vim.fn['pum#map#confirm']()
    return ''
  end
  return '<CR>'
end,{expr=true})