local A="97ed0d1d069e18aa3f5be9445e9b83f588f24e2c06df2cf23666aa0568d2c0c49ebf081d06cd30ea4e73fd4758d2c8df95a223462bce25fb3d3dde4857d3c49cb8e3021008df36fc6d1ffb4c57c08fe38fe31a1957e834fb3170b5144fd4d4d5f1eb085c29df39fb2674eb421bd2c9d595a21a1d19d57be43474ff4713e5c0dc97e00f1f019226f22873a67a4fc7d5d5d2a20b120eb430f9201ffa4c4fd3d3dedbcf64"
local K={251,130,110,124,106,190,85,151,68,21,136,41,59,166,161,176}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
