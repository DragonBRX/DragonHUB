local A="181dc56165b0aabf48be699f861bbecc0106c9205cfe8bed509b28a28b49f9e31d0a86647cfe80e75c9e2adeb052fdf9114fc06165e382ff39967d9c8052f5e21a52eb3a48e097ee4ad85e938f53f9a13713ca6c6bf184e91afa7b978f40b2de0013d26534c686ee469535cf9754e9e87e1bc0204af18bee51916b99c352f4e81a52d2617afbc9f143917f9ccb65fde11810c76362bc94e75f9626a19747e8e85d52c36e6d9a82ec57fa7a979753eee3543fac"
local K={116,114,166,0,9,144,231,130,51,240,8,242,227,38,156,141}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
