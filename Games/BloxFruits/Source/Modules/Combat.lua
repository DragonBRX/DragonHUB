local M = {Name = "Combat", Flags = {"AimMethod", "AimCam", "TpPly", "Seriality"}, State = {}}
function M:Apply(Name, Value, Callback) self.State[Name] = Value if Callback then task.spawn(Callback, Value) end end
return M
