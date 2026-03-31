local Layout = require('keyLayout')

-- QWERTY (reference):
-- q  w  e  r  t    y  u  i  o  p
-- a  s  d  f  g    h  j  k  l  ;
-- z  x  c  v  b    n  m  ,  .  /

return Layout:new("Eucalyn", {
  "q  w  ,  .  ;    m  r  d  y  p",
  "a  o  e  i  u    g  t  k  s  n",
  "z  x  c  v  f    b  h  j  l  /",
})
