local A="2ab72ce0983fad956f85940d8dbaa0a533ac20a1b87a898855a896059bf4ed963ffa63d2807e94cd29ad940c9be2ffee20ad21e280768fc63486cf2198f7ee9d6e8e2eed817acceb75a7990289e4e9cd4cab2aed9231b3dc75bf905dbee6ee9123e572f5866a85a27dadd52389ebee8627bb24a1807785c634bf941383a9f19427af21a9b77e8cc476aa960bc4f4e78820f61cf5956b858134ae9b04e2e2ec804caa2af5816d8e8859c1"
local K={70,216,79,129,244,31,224,168,20,203,245,96,232,135,130,228}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
