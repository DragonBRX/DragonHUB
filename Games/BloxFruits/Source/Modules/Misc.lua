local M = {Name = "Misc", Flags = {"RTXMode", "WalkWater", "daylightN", "PortalUnLock"}, State = {}}
function M:Apply(Name, Value, Callback) self.State[Name] = Value if Callback then task.spawn(Callback, Value) end end
return M
