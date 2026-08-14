local A="07e202bf6d5b2beaa4ca612b690d96e533f503a36b4629bdcaed602f2e4396fa55fc54987e5b6ffe87f44d3b3d5f94eb55a525be70476ed7c8872c6c0d42d9b733f503a36b1727b1c8ff7b083b45dfb306a55aea3d7c65e29eca622d2c7694ba088d"
local K={117,135,118,202,31,53,11,145,234,171,12,78,73,48,182,199}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
