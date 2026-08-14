local A="f3adac078e0eb08ea20997b84abadcb0eab6a046a35a89d2ba2cd6864ae6deb3faa3bc12c002aec7b83393e849e69282fabfc50097409ec7b02898f562bdbf81efaeb64eb44f91c6bc6bb5b443eb9c90fca9e66c914b91d5f71482b45be2c3a7feaeba03df1389c1ac22fcbc49a7bd90f3aead078145ddc7b12298f55be68d9ab1b1bf079540d5f0b82b9ab74ee495ddeca7a300cc7d89d2ad22dff54ae99afbfaacab6c904b89c6ab29d69825"
local K={159,194,207,102,226,46,253,179,217,71,246,213,47,135,254,241}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
