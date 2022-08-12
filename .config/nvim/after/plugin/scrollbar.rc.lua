local status, scroll = pcall(require, 'scrollbar')
if not status then
  return 
end

scroll.setup()

status, scroll = pcall(require, 'scrollbar.handlers.search')

if not status then
  return
end
scroll.setup()
