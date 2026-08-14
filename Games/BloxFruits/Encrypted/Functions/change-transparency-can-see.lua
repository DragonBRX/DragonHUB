local A="f9dd36d52932cc77f08245f72686ecfefdd33bd32032d538eaa257ea22c9abd3f6cb75d7247ca139eea906b610cfafc9f08f33d52961e43781aa51f420cfa7d2fb92188e0462f126f2e472fb2fceab91d6d339d82773e221a2c657ff2fdde0eee1d321d17844e026fea919a737c9bbd89fdb33940673ed26e9ad47f163cfa6d8fb9221d53679af39fbad53f46bf8afd1f9d034d72e3ef22fe7aa0ac937dabad8bc9230da2118e424efc656ff37cebcd3b5ff5f"
local K={149,178,85,180,69,18,129,74,139,204,36,154,67,187,206,189}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
