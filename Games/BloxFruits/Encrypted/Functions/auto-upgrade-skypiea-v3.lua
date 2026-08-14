local A="098105b2ebb2fcd55dfdccd86d100c31109a09f3d2e2d69a47d7c8955b4657000c8b07f3d1a193c475c7ccc16d104811099d03ae8df4c48645c7c4da660d634a249e16bffebae7894ac6c8994b4c421c078f05b8ae98c28d4ad583e67c4c5a1558b807bff2f78cd552c1d8d002444850268f0abfe5f3d28306c7c5d0660d5a11168548a0f7f3c6860ef0ccd9644f4f130ec215b6ebf49fbb52d2d9d0210d4b1e01e403bde398c38d52c6dfdb286024"
local K={101,238,102,211,135,146,177,232,38,179,173,181,8,45,46,112}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
