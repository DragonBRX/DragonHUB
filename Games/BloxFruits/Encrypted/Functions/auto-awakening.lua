local A="c70c8380eb3179cbe81ae3a1f0bb2381de178fc1c666559df63aeba2f2a42d93df029484ba77559ae031ffc6f3f36fa3df0a8f8fa75c0eb7e324eeb5bdd060acde06cca2e67d5894f237e9e59ff564accd4db395e66551cbc535eeb9f0bb3cb4d91685ebee7714b5f238eeaef4e56ae0df0b858f8d655585f87af1bcf4f16fe8cd168e82f3785b98bb7d88a0fae560ac8b309582e4744785bf11f0befaf43cb0c8028c8daf52559aff36e3affeaa72a5c705ceb2f3704093ba5eebaab5e86eb48b309582e4744785b320eaa9fba65e8785279280e07e5abee636c4b9fbe575a9c40da593f57e46cbe031eeaabbc860adce4dcec3bd3116d8bd20edbfe1f468aecc4ba593f57e46dfb331eca89fe36fa48269858fe31b5198f75ef0a9e1f373ae8b2eea"
local K={171,99,224,225,135,17,52,246,147,84,130,204,149,134,1,192}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
