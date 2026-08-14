local A="70f0e980bee994fa4444e61bdb4b4c7969ebe5c191a6b4b7536ff3139e221c517df3aab3b3aabce51359f317ca13535e7df3f984afc3bfb25169f31fd1184e7526defa91beb0f1915e66f21392350f5470fdeb82b9e0d3b45a66e158ed020f4c79a2dc80bebcbcfa027ef503db7c075e3cdceb8dbeabb8a4542af31edb184e4c7dece1cfa1b9b8b05122c417d21a0c597ff4a692b7a5bfe96c7ee602db5f4e5d72fb8084bcadd3b55a7ef204d0562332"
local K={28,159,138,225,210,201,217,199,63,10,135,118,190,118,110,56}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
