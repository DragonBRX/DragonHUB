local A="2382a1ef6cc8813c4e2e80920f149ad43a99adae5087a0641536d0dd467accf43b88ffe86184bf64486a878a044accfc2083e2c33aa9bc715919c9a90b45cdf063aea3e26c8aad625e49eb8c0f45debb1c99a3fa65d59a60591584c2575dcae02ae7abe820abad6d5902809c0109ccfd2a83e2fa619ba72f461080880401fbf42381a0ef6383e072500c87d1395dd9e12ac4e2eb6e8cc6645b04eb8d0f5dcde721cd8f84"
local K={79,237,194,142,0,232,204,1,53,96,225,255,106,41,184,149}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
