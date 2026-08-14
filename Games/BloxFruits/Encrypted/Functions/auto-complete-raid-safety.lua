local A="acd554ae3184e54d76c1a1deddf6c302b5ce58ef1ecbc50061eab4d69899802aa49a6c9c3cc2cd0474d2e29febbf8037a58751ae31d7cd0d07e9b5dddbbf882cae9a7af51cd4d81c74a796d2d4be846f83db5ba33fc5cb1b2485b3d6d4adcf10b4db43aa60f2c91c78eafd8eccb99426cad351ef1ec5c41c6feea3d898bf8926ae9a43ae2ecf86037deeb7dd9088802facd856ac3688db1561e9eee0ccaa9526e99a52a139aecd1e6985b2d6ccbe932de0f73d"
local K={192,186,55,207,93,164,168,112,13,143,192,179,184,203,225,67}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
