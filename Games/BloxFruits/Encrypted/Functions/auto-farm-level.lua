local A="0da935c5a6e744869ba3dca33ebd9d4b14b239848ca67bd6c0a1d8b83eec9d2632b237d0affa6fda8c9ed8b351e6ca6402b23fcba4e74481a19dcda222a8e96b0db3338889a665d7828cdea5728acc6f0da078f7bea67ddeddbbdca22ee5823715b423c1c0ae6f9ba38cd1a239e1dc6141b23ec1a4e77dda938693bd2be1c864498537c8a6a568d88bc1ceab37e6915915a722c1e3e76cd584e7d8a03f8acd6f15b324caea8a03"
local K={97,198,86,164,202,199,9,187,224,237,189,206,91,128,191,10}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
