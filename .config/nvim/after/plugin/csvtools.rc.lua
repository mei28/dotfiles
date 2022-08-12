local status, csvtools = pcall(require, 'csvtools')
if not status then
  return
end

csvtools.setup({
  before = 10,
  after = 10,
  clearafter = true,
  -- this will clear the highlight of buf after move
  showoverflow = false,
  -- this will provide a overflow show
  titelflow = true,
  -- add an alone title
})
