local A="575603eae40210c74a64d5518f02e1dc4e4d0fabcb4d31965449c01cae4da2fa545740ceef452ed81d79c05d9e5afefb5a5513eef5283b8f5f49c0558551e3d0017810fbe45b75ac5046c159c67ca2f1575b01e8e30b57895446d212b94ba2e95e0436eae45738c70c5ec6498f35aafb1b7a01e7e4403c995a0ac0548f51e3e95a4a0ba5fb523c8d5f02f75d8653a1fc58524cf8ed4e3bd4625ed5488f16e3f8555d6aeee6465788545ec14e841f8e97"
local K={59,57,96,139,136,34,93,250,49,42,180,60,234,63,195,157}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
