local status, registers = pcall(require, 'registers')
if not status then return end
registers.setup()
