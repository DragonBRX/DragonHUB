local M = {Name = "Items", Flags = {"AutoSaber", "KeysRen", "Auto_Tushita", "Auto_Yama", "CDK", "Auto_Soul_Guitar"}, State = {}}
function M:Apply(Name, Value, Callback) self.State[Name] = Value if Callback then task.spawn(Callback, Value) end end
return M
