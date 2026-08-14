local A="3df6b69a6aaf111e707fa200f8b27ce524edbadb42fd35556e119702bdc727c023f8f5b275e33d4d6f13ef3ee9ee2ac16cffb49775ea21296d44ad0ee9e631ca71d4efba76ff305a2367a201e8ea72e730f5b99967ec370a0142a601fba10dd030edb0c650ee30566e0cfe19effa3bae38fff5b867e330416a52a84de9e73bca71edb4886da12f536a46ad45deee32c833f8b6902afc394f6d1f9019fcfb3b8d71fcbb9f0cea32470143a619e8fd30841c93"
local K={81,153,213,251,6,143,92,35,11,49,195,109,157,143,94,164}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
