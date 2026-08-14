local A="04c1cd0ae08a4ee0989eb903deabda311ddac14bc1cb70a986a2a14efde48d191cdd8c47dfde62a986edbe0fd7e59d0d62c8db05efde6ab28df09554fae6881c1186f80ae0df66f1a0b1b402d9f79b1b41a4dd0ee0cc2d8e97b1ac0b86c0991c1dcb9356f8d876b8e9b9be4ef8f7941c0acfcd00acde6bb88df0ac0fc8fdd60318cfd905a4e962b18fb2b90dd0ba8b1504c88038f8cb77b8caf0bd00df9c9d1e0ca4dc0ef8df71b3c39dd2"
local K={104,174,174,107,140,170,3,221,227,208,216,110,187,150,248,112}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
