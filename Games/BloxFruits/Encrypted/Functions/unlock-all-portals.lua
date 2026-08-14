local A="f9e36f7ef7b530538e235603b635ec46fbe0637cf0b53c02994d6701a17caf7fe6ae204ceff4090bc80b5602a06db319f3f9627ceffc1200d5200d2fa378a26abdda6d73eef0512d94015b0cb26ba53a9fff6973fdbb2e1a941952538569a266f0b1316be9e018649c0b172db264a271f4ef673feffd1800d519561db826bd63f4fb6237d8f41102970c5405ff7bab7ff3a25f6bfae11847d508590ad96da0779ffe696beee7134eb867"
local K={149,140,12,31,155,149,125,110,245,109,55,110,211,8,206,19}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
