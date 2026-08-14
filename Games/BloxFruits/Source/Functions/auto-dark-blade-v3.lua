local M={Name="Auto Dark Blade V3",State=false}
function M:Apply(Value,Callback)
self.State=Value==true
if Callback then
task.spawn(function()
local Success,Error=pcall(Callback,self.State)
if not Success then _G.DragonHubFunctionError=self.Name..": "..tostring(Error) end
end)
end
end
return M
