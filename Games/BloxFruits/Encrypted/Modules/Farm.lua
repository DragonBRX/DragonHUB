local A="6c5cb5dbfd76a2f521f20fd1e22c502b5858b3c3ad34a2c803f205c7e22c50723c75a4d8ea74a0a24fb123c1b67e36686c548fcbee6aa0a24fb123c1b67e36687d4daedcf63aaeae4dd217c0ad4311607a7aa0ddfb74e7ac12ee68"
local K={30,57,193,174,143,24,130,142,111,147,98,180,194,17,112,9}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
