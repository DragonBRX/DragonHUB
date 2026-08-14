local A="56d7ba81fbe43bc557cb09d4b25f20334fccb6c0d4b6179e58a53ed6bb01631c53dbf9adf6a3189d58a744eaa303761707deb88ce4a10bf24af006daa30b6d1c1af5e3a1e7b41a8104d309d5a2072e315bd4b582f6a71dd126f60dd5b14c51065bccbcddc1a51a8d49b855cda517677853def9a3f6a81a9a4de60399a30a671c1accb893fcea05884df2069194036e1e58d9ba8bbbb713944aab3bcdb616675b1addb7849da1189c26f70dcda2106c5277b2"
local K={58,184,217,224,151,196,118,248,44,133,104,185,215,98,2,114}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
