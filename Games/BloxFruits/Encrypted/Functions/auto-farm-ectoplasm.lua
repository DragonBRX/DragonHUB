local A="b1dcb9d510eee4056871d32d38823609a8c7b5943aafdb55337ad13432cf7829aedef8982fbac84c7602d42131cc7135d7d5afda1fbac0577d1fff7a1ccf6424a49b8cd510bbcc14505ede2c3fde7723f4b9a9d110a8876b675ec62560e97524a8d6e78908bcdc5d1956d4601ede7824bfd2b9df5cbac15d7d1fc6212ed43a3badd2adda548dc8547f5dd3233693672db1d5f4e708afdd5d3a1fd72e39b57126b9b9a8d108bbdb563372b8"
local K={221,179,218,180,124,206,169,56,19,63,178,64,93,191,20,72}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
