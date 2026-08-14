local A="7e9d7e0d97bc0b9bad7343ae3a80d2de6786724cabf534c7b85543e173ee84fe6697200a9af035c3ab3744b631de84f67d9c3d21c1dd36d6ba440a953ed185fa3eb17c0097fe27c5bd1428b03ad196b141867c189ea110c7ba4847fe62c982ea77f8740adbdf27caba5f43a0349d84f7779c3d189aef2d88a54d43b43195b3fe7e9e7f0d98f76ad5b35144ed0cc991eb77db3d0995f84cc3b85928b13ac985ed7cd25066"
local K={18,242,29,108,251,156,70,166,214,61,34,195,95,189,240,159}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
