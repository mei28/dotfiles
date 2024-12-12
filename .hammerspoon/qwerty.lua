local Layout = require('keyLayout')

-- キーマップのテーブルを定義
-- qwerty -> ebi
local ebiKeyMap = {
  [0x0c] = 0x0c, 
  [0x0d] = 0x0d, 
  [0x0e] = 0x0e, 
  [0x0f] = 0x0f, 
  [0x11] = 0x11, 
  [0x10] = 0x10, 
  [0x20] = 0x20, 
  [0x22] = 0x22, 
  [0x1f] = 0x1f, 
  [0x23] = 0x23, 
               
  [0x00] = 0x00, 
  [0x01] = 0x01, 
  [0x02] = 0x02, 
  [0x03] = 0x03, 
  [0x05] = 0x05, 
  [0x04] = 0x04, 
  [0x26] = 0x26, 
  [0x28] = 0x28, 
  [0x25] = 0x25, 
  [0x29] = 0x29, 
               
  [0x06] = 0x06, 
  [0x07] = 0x07, 
  [0x08] = 0x08, 
  [0x09] = 0x09, 
  [0x0b] = 0x0b, 
  [0x2d] = 0x2d, 
  [0x2e] = 0x2e, 
  [0x2b] = 0x2b, 
  [0x2f] = 0x2f, 
  [0x2c] = 0x2c, 
}

local qwertyKeyMap = {
  [0x0c] = 0x0c, -- q -> q
  [0x0d] = 0x0d, -- l -> w
  [0x0e] = 0x0e, -- , -> e
  [0x0f] = 0x0f, -- . -> r
  [0x11] = 0x11, -- ; -> t
  [0x10] = 0x10, -- f -> y
  [0x20] = 0x20, -- w -> u
  [0x22] = 0x22, -- r -> i
  [0x1f] = 0x1f, -- y -> o
  [0x23] = 0x23, -- p -> p
               
  [0x00] = 0x00, -- a -> a
  [0x01] = 0x01, -- o -> s
  [0x02] = 0x02, -- e -> d
  [0x03] = 0x03, -- i -> f
  [0x05] = 0x05, -- u -> g
  [0x04] = 0x04, -- k -> h
  [0x26] = 0x26, -- t -> j
  [0x28] = 0x28, -- n -> k
  [0x25] = 0x25, -- s -> l
  [0x29] = 0x29, -- h -> ;
               
  [0x06] = 0x06, -- z -> z
  [0x07] = 0x07, -- x -> x
  [0x08] = 0x08, -- c -> c
  [0x09] = 0x09, -- v -> v
  [0x0b] = 0x0b, -- b -> b
  [0x2d] = 0x2d, -- g -> n
  [0x2e] = 0x2e, -- d -> m
  [0x2b] = 0x2b, -- m -> ,
  [0x2f] = 0x2f, -- j -> .
  [0x2c] = 0x2c, -- / -> /
}

return Layout:new("Qwerty", ebiKeyMap, qwertyKeyMap)
