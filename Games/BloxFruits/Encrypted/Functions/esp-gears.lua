local A="aa127e652ff23ac8d6c0e6647048187fb50d3d4326b305868fa2d47d74015f07a01c717726af7d93d8e0e47d7c1a541a8b475c7433be0eddfbefeb7c7059795baa117f6520b95effdeebeb6f3b264e5bb218205222be029090b3f37b60103053a05d5e652fbe1594cee5a77d7d10541ab21c6e6f6da10794dae0af4a74195658a71e762830b71b9383ddf3686110131aa313790e26bc13ffdfebf37c671b1a77cc"
local K={198,125,29,4,67,210,119,245,173,142,135,9,21,117,58,58}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
