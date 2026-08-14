local A="f1cd95f9d1158410651f11c3f93aa891e8d699b8fe54a75b7b3f14c7ef6faa83eacd84fc9f199a597f251593fa66e6a3f8dffcfec85baa59773e1e8ed13dcba0edce8fb0eb54a5587b7d33cff06be8b1fec9df92ce50a54b300204cfe862b786fcce83fd8008bd5f6b347ac7fa27c9b1f1ce94f9de5ee95976341e8ee866f9bbb3d186f9ca5be16e7f3d1cccfd64e1fceec79afe9366bd4c6a34598ef969eedaf8cc9292cf50bd586c3f50e396"
local K={157,162,246,152,189,53,201,45,30,81,112,174,156,7,138,208}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
