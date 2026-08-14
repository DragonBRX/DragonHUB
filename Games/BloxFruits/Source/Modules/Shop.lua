local M = {Name = "Shop", Flags = {"BuyItem", "BuyStyle", "CraftItem"}, State = {}}
function M:Apply(Name, Value, Callback) self.State[Name] = Value if Callback then task.spawn(Callback, Value) end end
return M
