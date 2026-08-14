local A="96a193fcc3268179833efa8b278b0f798fba9fbdfd67a220971dbba42dd8484bd8e2a3e9ce72a9799e11f79527cb275e8fa093e9c669a264b54ada9632da5410acaf9ce8ca2a8f25941cf98721dd043289ab9cfb8155b8258c15a6b023da585dc7f384efda63c62d9e50d8872eda4f5999a5d0e9c763a2648c11e88d6cc55d598da0d8dece6aa0269913f0ca31d3415ed49d84fcdb63e5649d1effec27d8493288ab84e8dd68ec09f2"
local K={250,206,240,157,175,6,204,68,248,112,155,230,66,182,45,56}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
