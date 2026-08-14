local A="a475e74a7add6f815b7b2c4eda573bcbbd6eeb0b42984ed9505a3f579f2878f8a169f04a36be4dc9535c230193396debbc7fb94d779151d95d3f2b56d1096de3a774a4662cbc52cc4c4c6575de066cefe459e5477a9f43df4b1c4750da067fa49b6ee55f73c074dd4c40281e821e6bffad10ed4d36be43d04c572c40d44a6de2ad74a45f778e499253452c54d1425aeba476e64a75960ecf45592b0dec1e78fead33a44e789928d94e514751da1e6cf8a63ac921"
local K={200,26,132,43,22,253,34,188,32,53,77,35,191,106,25,138}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
