local M = {Name = "Fruits", Flags = {"Random_Auto", "StoreF", "DropFruit", "TwFruits", "InstanceF"}, State = {}}
function M:Apply(Name, Value, Callback) self.State[Name] = Value if Callback then task.spawn(Callback, Value) end end
return M
