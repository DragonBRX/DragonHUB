local A="22e3d8fd59609461608f03e8e99049453dfc9bcf50219c2a7eaf16a5c5de076120e899b06634b8287efc04e4e0de0e7d44eacef25634b03375e12fbfcddd1b6c37a4edfd5935bc7058a00ee9eecc086b6786c8f95926f70f6fa016e0b1fb0a6c3be986a14132ac3911a804a5cfcc076c2cedd8f71534b13975e116e4ffc645733eedccf21d03b83077a303e6e781186522ea95cf4121ad3932e107ebe8a70e6e2a86c9f94135ab323b8c68"
local K={78,140,187,156,53,64,217,92,27,193,98,133,140,173,107,0}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
