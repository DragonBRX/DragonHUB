local M = {Name = "Melee", Flags = {"Auto_SuperHuman", "AutoDeathStep", "Auto_SharkMan_Karate", "Auto_Electric_Claw", "AutoDragonTalon", "Auto_God_Human"}, State = {}}
function M:Apply(Name, Value, Callback) self.State[Name] = Value if Callback then task.spawn(Callback, Value) end end
return M
