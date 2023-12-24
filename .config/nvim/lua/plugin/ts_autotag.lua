local spec = {
  {
    'windwp/nvim-ts-autotag',
    config = function()
      require 'nvim-ts-autotag'.setup()
    end,
    ft = {
      'astro',
      'glimmer',
      'handlebars',
      'html',
      'javascript',
      'jsx',
      'markdown',
      'php',
      'rescript',
      'svelte',
      'tsx',
      'typescript',
      'vue',
      'xml',
    },
  },
}

return spec
