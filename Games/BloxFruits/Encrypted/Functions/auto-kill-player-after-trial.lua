local A="69e79687d9ee572f9f7da47cfa3cbc0070fc9ac6fea7767ec463a970e664ec6144ee8183c7ee4e608d52a933b352ea2071edc880d4a269779939a364f162ea286ae6d5ab8f8f6a62884aed47fe6deb2429cb948ad9ac7b718f1acf62fa6df86f56fc9492d0f34c738846a02ca275ec3460829c80958d7b7e8851a472f421ea2960e6d592d4bd713c9743a466f129dd2069e49787d6a53661815fa33fcc75ff3560a1d583dbaa10778a57cf63fa75eb336ba8b8ec"
local K={5,136,245,230,181,206,26,18,228,51,197,17,159,1,158,65}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
