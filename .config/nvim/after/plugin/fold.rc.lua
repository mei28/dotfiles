local status, fold = pcall(require, 'pretty-fold')

if not status then return end

fold.setup()
