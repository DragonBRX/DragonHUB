local A="314665e2686f40809f7c08972c164096104665e3736f0788f33145b4604a07c7631e31ec38520589b87c099b78524298630153e5736f07b6be7f16d0200b42f536577ed56f720fd9fd3d47b3785f01d7286774fb7b784286ac17"
local K={67,35,17,151,26,1,96,251,209,29,101,242,12,43,96,180}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
