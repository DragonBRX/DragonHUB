local A="77df3a737bbffb22cee442fcae806faa6ec4363255f3d77cde8a70e1a2d62892399c0a6676ebd322d3cb4fe2aec0478d6ede3a667ef0d83ff89062e1bbd134c34dd1356772b3f57ed9c641f0a8d664e168d5357439ccc27ec1cf1ec7aad1388e268d2d6062fabc76d38a60f0a7d12f8a78db79667ffad83fc1cb50fae5ce3d8a6cde715176f3da7dd4c948bdb8d8218d35e32d7363fa9f3fd0c4479baed329e169d52d6765f19652bf"
local K={27,176,89,18,23,159,182,31,181,170,35,145,203,189,77,235}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
