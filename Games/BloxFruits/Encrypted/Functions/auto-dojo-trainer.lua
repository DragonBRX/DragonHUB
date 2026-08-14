local A="dc31e6fdb9e9e9037bf671b71e52e669c52aeabc91a6ce5120ec62bb1201a15a9272d6e8b4bdc10366d97ca91e12ce4ec530e6e8bca6ca1e4d8251aa0b03bd00e63fe9e9b0e5e75f6cd472bb1804ed22c33be9fafb9ad05f74dd2d8c1a03b14d8d63f1eea0acae57669853bb1703a649d335a5e8bdacca1e74d963b1551cb449c730addfb4a5c85c61db7bf6080aa84e9e0df1fda1ac8d1e65d674d01e01a022c23bf1e9a7a784730a"
local K={176,94,133,156,213,201,164,62,0,184,16,218,123,111,196,40}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
