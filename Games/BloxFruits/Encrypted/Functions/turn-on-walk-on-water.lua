local A="092ac4129991f3a8f0ececd952a4a3691037c9539adf9ec2eacee69458f7a16a0431c201d79dede1ead6e88951f8ed4e0038ad1580dfdde1e2cde3947aa3c04d1529de5ba3d0d2e0ee8eced55bf5e35c062e8e7986d4d2f3a5f1f9d543fcbc6b0429d216c88ccae7fec787dd51b9c25c0929c51296da9ee1e3c7e39443f8f2564b36d71282df96d6eacee1d656faea111620cb15dbe2caf4ffc7a49452f7e537002bc37987d4cae0f9ccadf93d"
local K={101,69,167,115,245,177,190,149,139,162,141,180,55,153,129,61}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
