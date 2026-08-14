local A="100b34ecf7f5665a786ea33835f0a983091038addca045452f73b63424a8b6a41d0824e8e6df4d126d43b63c3fa3ab8f462527fdf7ac0331624cb7307c8eeaae100636eef0fc2114664ca47b03b9eab6195901ecf7a04e5a3e54b02035c7e2a45c2736e1f7b74a046800b63d35a3abb61d173ca3e8a54a106d0881343ca1e9a31f0f7bfefeb94d495054a32135e4aba712005de8f5b121156654b7273eedc6c8"
local K={124,100,87,141,155,213,43,103,3,32,194,85,80,205,139,194}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
