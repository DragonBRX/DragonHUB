local A="0c43818b1581f641b457479a9da397fc15588dca2bc4d51ba07253d7abe9dacf040eceb90dc0cf19f27f479b8bfbc8b706598c890dc8d412ef541cb688eed9c4487a83860cc4973fae754a9599fdde946a5f87861f8fe808ae6d43caaeffd9c80511df9e0bd4de76a67f06b499f2d9df014f89ca0dc9de12ef6d478493b0c6cd015b8cc23ac0d710ad78459cd4edd0d10602b19e18d5de55ef7c4893f2fbdbd96a5e879e0cd3d55c8213"
local K={96,44,226,234,121,161,187,124,207,25,38,247,248,158,181,189}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
