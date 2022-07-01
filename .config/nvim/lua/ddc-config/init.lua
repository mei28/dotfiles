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


vim.cmd[[
" <TAB>: completion.
inoremap <silent><expr> <TAB>
\ ddc#map#pum_visible() ? '<C-n>' :
\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
\ '<TAB>' : ddc#map#manual_complete()

]]


vim.keymap.set('i','<S-TAB>', function()
  return vim.fn.pumvisible()==1 and '<C-p>' or '<C-h>' end
,{expr=true, noremap=true})


