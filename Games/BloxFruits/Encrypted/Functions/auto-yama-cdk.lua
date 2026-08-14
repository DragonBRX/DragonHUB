local A="c92509eb3750438b7ac58010bab5f586d03e05aa021163d721c8a536fda484b3c43e0fb73d1162c564f6eb1baae6b4b3cc2504aa164a4fc671e7985589e9bbb2c06629eb371c6cd762e0c877acedbba18b191eeb2f1533e060e79418e2b5a3b5d02f60e33d504dd76de7831cbce3f7b3cd2f04aa2f117ddd2ff8911ca8e6ff84c42606e83a13659a72ee8d1bf1dba3a6d12f43aa3e1e6abc64e58577adeda3b2d7244ac751"
local K={165,74,106,138,91,112,14,182,1,139,225,125,223,136,215,199}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
