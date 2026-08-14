local A="7952f78eeb6f87fc29e3a6465f103bd26049fbcfde2ea7a072feb04448493bbf4649f59be272aca03edea256304b6cfd7649fd80e96f87fb13ddb74743054ff27948f1c3c42ea6ad30cca44013276af6795bbabcf32ebea46ffba6474f4824ae614fe18a8d26ace111ccab47584c7af83549fc8ae96fbea021c6e9584a4c6efd3d7ef583eb2daba23981b44e564b37c0615ce08aae6fafaf36a7a2455e276bf66148e681a702c0"
local K={21,61,148,239,135,79,202,193,82,173,199,43,58,45,25,147}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
