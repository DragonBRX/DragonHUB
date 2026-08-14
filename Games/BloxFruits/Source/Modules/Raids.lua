local M = {Name = "Raids", Flags = {"Auto_StartRaid", "Raiding", "Auto_Awakener", "KillH"}, State = {}}
function M:Apply(Name, Value, Callback) self.State[Name] = Value if Callback then task.spawn(Callback, Value) end end
return M
