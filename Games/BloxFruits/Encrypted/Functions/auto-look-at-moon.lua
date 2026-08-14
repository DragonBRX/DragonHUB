local A="02e48354a4a21849e4ce7faecb179ee21bff8f1584ed3a1fbfc16ae3e345d3cd4ca7b341a9f63049f9e172b0cb57b6c51be58341a1ed3b54d2ba5fb3de46c58b38ea8c40adae1615f3ec7ca2cd4195a91dee8c53e6d12115ebe52395cf46c9c653b69447bde75f1df9a05da2c246dec20de0c041a0e73b54ebe16da88059ccc219e5c876a9ee3916fee375efdd4fd0c540d89454bce77c54faee7ac9cb44d8a91cee9440baec753995"
local K={110,139,224,53,200,130,85,116,159,128,30,195,174,42,188,163}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
