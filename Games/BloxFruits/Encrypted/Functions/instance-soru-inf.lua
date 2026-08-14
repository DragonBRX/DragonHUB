local A="6b68ede8f8dc52615ff4a0c7de41a47d6974fae8fa9f7a7c77d5b3df9b27a67d4941aed4b6d04c2845cea497dd1dea47627a84efe1927c284dd5af8af646c744776bf7a1c29d7329419682cbd710e455646ca783e799733a0ae9b5cbcf19bb62666bfbeca9c16b2e51dfcbc3dd5cc5556b6bece8f7973f284cdfaf8acf1df55f2974fee8e392371f45d6adc8da1fed187462e2efbaaf6b3d50dfe88ade12e23e6269ea83e6996b2956d4e1e7b1"
local K={7,7,142,137,148,252,31,92,36,186,193,170,187,124,134,52}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
