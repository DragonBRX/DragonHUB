local M = {Name = "Events", Flags = {"SailBoats", "SeaBeast1", "TerrorShark", "Prehis_Find", "Prehis_Skills"}, State = {}}
function M:Apply(Name, Value, Callback) self.State[Name] = Value if Callback then task.spawn(Callback, Value) end end
return M
