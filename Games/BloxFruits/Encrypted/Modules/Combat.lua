local A="c2f6b566088e6bde9c1bf28beec35917f3fcac711b946989f23cf38fa98d590890e8e352138d06c0a612f08aecd25917f1faac501b8d6989f258cb9e9e9200179cb3e3401f9222c4be13eb97ec83043f"
local K={176,147,193,19,122,224,75,165,210,122,159,238,206,254,121,53}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
