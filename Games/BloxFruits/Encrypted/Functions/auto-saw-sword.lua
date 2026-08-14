local A="8e66dccd77ab0df9c74657d473b53ba1977dd08c48ea37e4ef7f59cb72aa35b39668cbc926ed21a8cf6d4bb370fd77839660d0c23bc67a85cc785ac03ede788c976c93ef7ae72ca6dd6b5d901cfb7c8c8427ecd87aff25f9ea695acc73b52494907cdaa672ed6087dd645adb77eb72c09661dac23bff21b7d72645c977ff77c8a168d3c079ea23af907b53d570a64a94837dda853bee2ea0b66d58dd1cfa7c94977bd18c5681"
local K={226,9,191,172,27,139,64,196,188,8,54,185,22,136,25,224}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
