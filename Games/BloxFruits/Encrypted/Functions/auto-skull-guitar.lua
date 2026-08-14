local A="4dcf5cdd7588cda93190e4b1e900c5d654d4509c4ac3f5f826fec2a9e54986e5038c6cc878dce5a92cbfe9afe940edf154ce5cc870c7eeb407e4c4acfc519ebf77c153c97c84c3f526b2e7bdef56ce9d52c553da37fbf4f53ebbb88aed5192f21c9d4bce6ccd8afd2cfec6bde05185f642cb1fc871cdeeb43ebff6b7a24e97f656ce17ff78c4ecf62bbdeef0ff588bf10ff34bdd6dcda9b42fb0e1d6e953839d53c54bc96bc6a0d940"
local K={33,160,63,188,25,168,128,148,74,222,133,220,140,61,231,151}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
