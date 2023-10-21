local spec = {

  {
    'atusy/tsnode-marker.nvim',
    event = { 'BufNewFile', 'BufRead' },
    config = function() tsnode_setup() end
  }
}

function tsnode_setup()
  local status, marker = pcall(require, 'tsnode-marker')
  if not status then return end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("tsnode-marker-markdown", {}),
    pattern = "markdown",
    callback = function(ctx)
      require("tsnode-marker").set_automark(ctx.buf, {
        target = { "code_fence_content" }, -- list of target node types
        hl_group = "CursorLine",           -- highlight group
      })
    end,
  })

  ---ノードが関数定義か判定する関数
  ---@param node tsnode
  ---@return bool
  local function is_def(node)
    return vim.tbl_contains({
      "func_literal",
      "function_declaration",
      "function_definition",
      "method_declaration",
      "method_definition",
    }, node:type())
  end

  ---ノードが関数定義中の関数定義か判定する関数
  ---@param _ bufnr
  ---@param node tsnode
  ---@return bool
  local function is_nested_def(_, node)
    if not is_def(node) then
      return false
    end
    local parent = node:parent()
    while parent do
      if is_def(parent) then
        return true
      end
      parent = parent:parent()
    end
    return false
  end

  -- autocmd
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("tsnode-marker-nested-func", {}),
    pattern = { "lua", "python", "go" },
    callback = function(ctx)
      require("tsnode-marker").set_automark(ctx.buf, {
        target = is_nested_def,
        hl_group = "CursorLine",
      })
    end,
  })
end

return spec
