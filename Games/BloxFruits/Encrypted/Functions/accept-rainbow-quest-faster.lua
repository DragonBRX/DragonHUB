local A="52fc9922b5afc76a16721f25bb9f629b5df09f33adafd83604521c27a98211af5be08e639feef923084e5c648dd621ae5bae9c22b5fcef2a675a0b26bdd629b550b3b77998fffa3b14142829b2d725f67df2962fbbeee93c44360d2db2c46e894af28e26e4d9eb3b18594375aad035bf34fa9c639aeee63b0f5d1d23fed628bf50b38e22aae4a4241d5d0926f6e121b652f19b20b2a3f932015a501baac334bf17b39f2dbd85ef3909360c2daad732b41edef0"
local K={62,147,250,67,217,143,138,87,109,60,126,72,222,162,64,218}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
