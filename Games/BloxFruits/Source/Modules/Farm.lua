local M = {Name = "Farm", Flags = {"Level", "AutoFarmNear", "AutoFactory", "AutoRaidCastle"}, State = {}}
function M:Apply(Name, Value, Callback) self.State[Name] = Value if Callback then task.spawn(Callback, Value) end end
return M
