local A="3ff8f2c1d72b6be10fb8b57c8e283ec926e3fe80eb644ab954a0e631b0457dfc30fff4c4e6290a8f0097a074d6737de420f2ecaadd7e48bf009fbb7fcb5826c923e7fdd9935d47b00193f8528a7970ea32f4fa89b17843b012d887658a6179b505f6fdd5de361ba80683b11b82733ccb32fbfdc2da684dfc009eb17fcb617dfb38b9e2d0da7c48f43797b87d89747fe37fe4f4ccdd2575a81582b138cb7072ec59f2ffc4b17943a80184ba31a61f"
local K={83,151,145,160,187,11,38,220,116,246,212,17,235,21,28,136}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
