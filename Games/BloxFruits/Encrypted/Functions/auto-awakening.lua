local A="c70c8380eb3179cbe81ae3a1f0bb2381de178fc1c666559df63aeba2f2a42d93df029484ba77559ae031ffc6f3f36fa3df0a8f8fa75c0eb7e324eeb5bdd060acde06cca2e67d5894f237e9e59ff564accd4db395e66551cbc535eeb9f0bb3cb4d91685ebee7714b5f238eeaef4e56ae0df0b858fa7655585f87af1bcf4f16fe8e8028c8de570579dbf27e7a0f3a852b4ca1785c8a7745a929931eca89ff464b4de118ec1ca1b"
local K={171,99,224,225,135,17,52,246,147,84,130,204,149,134,1,192}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
