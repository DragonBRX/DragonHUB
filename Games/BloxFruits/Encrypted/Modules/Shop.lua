local A="4e2e1bf2fb2873f4f3bf14641c0677316f2300f7ab6a73c9d1bf1e721c0677681e091afec03236e29ff259237e4e2e40483203e2ab6a73adfeac186748722376516912fa83"
local K={60,75,111,135,137,70,83,143,189,222,121,1,60,59,87,19}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
