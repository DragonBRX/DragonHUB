local A="ae2d885dd3814b548c13c0bf18de509aa1218e4ccb81571c922ed5a15fcf21afa3368e01d9c06a1a9220abb4088d11afab2d851cf29b47198731d8fa2b821eaea76ea85dd3cd6408943688d80e861ebdec119f5dcbc43b3f9631d4b740de06a9b727e155d98145089b31c3b31e8852afaa27851ccbc07502d92ed1b30a8d5a98a32e875edec26d458438cdb453b006bab627c21cdacf62639233c5d80f8606aeb02ccb71b5"
local K={194,66,235,60,191,161,6,105,247,93,161,210,125,227,114,219}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
