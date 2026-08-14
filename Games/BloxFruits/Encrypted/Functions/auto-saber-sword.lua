local A="f824ae3ee728c236f4eb07de3f0bd981e13fa27fd869ed6efd8535c435449fe2b818b93eff6db26deec915d6273c9db5fa28b936e466af46b5e416c3364fd396f527b83aa74bee67e3c707d0311ff1b3f127ab71d87cee7fea9830d236439efda93fbf2aee02e66dafe607df36549aa3ff6bb937ee66af7feed60d9d29469ab7fa638e3ee764ed6aecce4ac03f5a9deec73fac2bee21af6ee1c16cd63452f1b2f13fb82de528c201"
local K={148,75,205,95,139,8,143,11,143,165,102,179,90,54,251,192}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
