local A="07c1285c4cd5bc7648c0dbfd0973cabb27c5354d4d99b02d40cdd7ff5a6ed7b90e861d5c4ad4c35e72c0c4ec7b2f83fd57887c0b6cdaf5696fcfd1ba056ec8d800d033767fccfd6663cfd3ea0b62cabb3ecd30457699e1700c"
local K={117,164,92,41,62,187,156,13,6,161,182,152,41,78,234,153}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
