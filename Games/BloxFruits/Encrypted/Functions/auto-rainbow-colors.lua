local A="a737c028e78b55ca3deb2bd3e72dbf56be2ccc69d9ca719924ca3d9ec17ff178b92b8165d8df798323982cdfee63f86ac13ed627e8df719828850784c360ed7bb270f528e7de7ddb05c426d2e071fe7ce252d02ce7cd36a432c43edbbf46fc7bbe3d9e74ffd96d924ccc2c9ec171f17ba939c022abdf709228853edff17bb364bb39d427a3e8799b2ac72bdde93cee72a73e8d1affca6c926f852fd0e61af879af52d12cffde6a9966e840"
local K={203,88,163,73,139,171,24,247,70,165,74,190,130,16,157,23}
local O=table.create(#A/2)
local N=0
for I=1,#A,2 do
N=N+1
O[N]=string.char(bit32.bxor(tonumber(string.sub(A,I,I+1),16),K[(N-1)%#K+1]))
end
return loadstring(table.concat(O))()
