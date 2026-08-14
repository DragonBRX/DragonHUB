local A="57ef932f51e44a9cf99986c5cb3a78fa4be5933a5cb06281c1bf88c7dd627af957e1892b4fb7258dd1a386dccb3a3cc857f3953337a272cfe1a38ec7c02717937af0802244ec51c0eea28284ed6636c559e1932514ce74c4eeb1c9fbda662ecc06d6912248a13a9cf6a592cda46e3c8978e19c225fa564caa2a38fcdc0272ec848ebde3d4da570cfaa9486c4c2653bca50ac832b51a229f2f6b693cd87273fc75f8a952059ce75c4f6a295c68e4a50"
local K={59,128,240,78,61,196,7,161,130,215,231,168,174,7,90,169}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
