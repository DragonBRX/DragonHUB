local A="0a659827957ae8e88585f95e7e8a81de137e9466ad28c4b19bebd9496ec5c6bf236799238b7889868aaaec5626d1c2f3156f864c9f2fcbb68aa2f75d3bfa99de167a973fd10cc4b98baeb4707adbcffd0769906ff329c0b998e5cb477ac3c6a2306b97339c6798a18cbefd3972d183dc076697249839cef58aa3fd5d3bc3c2ec0d248836982dcbfdbdaaf45f79d6c0f44a799e2a9f74f6a19fbffd1a3bd2cdfb6c6f9522f328c0a18bb9f61356bd"
local K={102,10,251,70,249,90,165,213,254,203,152,51,27,183,163,159}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
