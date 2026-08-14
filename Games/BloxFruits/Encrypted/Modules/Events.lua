local A="2dae0b736eff242458f814647a1e2b021abd1a6868e2267336df15603d502b1d7fb05d557df8681d79f80d72780f2b020cae1e4479f0772b27bb552178776e522da40d5574f0763434b559230a516e4836b8204075ff607d3ab95b51284663492c942c6d75fd682c34e4040b"
local K={95,203,127,6,28,145,4,95,22,153,121,1,90,35,11,32}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
