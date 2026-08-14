local A="2173fd8334b18628e05d807b9b69b6873868f1c20dffa77af878c1529121f3ae6d78eb8c3ff4a47bb93fb2629f20f1fb2b7df2913decc173ee7d8262973bfae60026df9228fdb23dcd728d639b78d7a72170fc833bfae21fe8768d70d007e0a73979a3b439fdbe70a62e95648b319eaf2b3cdd8334fda974f878c1629631fae6397ded8976e2bb74ec7dc9559f38f8a42c7ff5ce2bf4a773b54095778a31bde62872fae83dffaf1fe97695638c3ab48b47"
local K={77,28,158,226,88,145,203,21,155,19,225,22,254,84,148,198}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
