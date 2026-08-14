local A="8acde5d360e7e032c40777d9a5826cfd95d2a6f379b5cc2ffc267adbb5cd6efc83c3ead77eb48f23ec3d77c0a58228d98ad1e3cf06a1d861dc3d7fdbae9f0382a7d2f6de75effb6ed33c739883de22d484c3e5d925cdde6ad32f38e7b4de3adddbf4e7de79a29032cb3b63d1cad62898a5c3eade6ea6ce649f3d7ed1ae9f3ad995c9a8c17ca6da61970a77d8acdd2fdb8d8ef5d760a1835ccb2862d1e99f2bd682a8e3dc68cddf6acb3c64dae0f244"
local K={230,162,134,178,12,199,173,15,191,73,22,180,192,191,78,184}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
