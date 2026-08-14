local M = {Name = "Travel", Flags = {"Teleport", "TPNpc", "TravelDres", "AutoZou"}, State = {}}
function M:Apply(Name, Value, Callback) self.State[Name] = Value if Callback then task.spawn(Callback, Value) end end
return M
