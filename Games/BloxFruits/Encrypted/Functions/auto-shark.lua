local A="c346e3737217fa28e48c79f8b0098456da5def324d5fd667f4e034c6a155d272924fe17e6d52ca1ff9b776f6a15dc9798f64ba536e47db6cb79479f9a0518a54ce45ec707f54dc3c95b17df9b31af563ce5de52f4856db60faff25e1a741c31dc64fa0517f5bdb77fea173b5a15cc3798f5de1617519c465feb576bd9655ca7bcd48e3793244d279f9ec4be1b440c33e8f4cee761452d97195b07de1a046c837e223"
local K={175,41,128,18,30,55,183,21,159,194,24,149,213,52,166,23}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
