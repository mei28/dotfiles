local status, easymotion = pcall(require, 'vim-easymotion')
if not status then
  return 
end

vim.g.EasyMotion_keys="hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB"
