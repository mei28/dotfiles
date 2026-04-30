local Layout = require('keyLayout')

-- QWERTY (reference):
-- q  w  e  r  t    y  u  i  o  p
-- a  s  d  f  g    h  j  k  l  ;
-- z  x  c  v  b    n  m  ,  .  /

return Layout:new("Waddlier", {
  "q  l  e  ,  .    f  w  r  y  p",
  "a  o  i  u  ;    k  t  n  s  h",
  "z  x  c  v  b    g  d  m  j  /",
}, {
  shiftPassthrough = { ",", "." },
})
