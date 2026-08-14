local Players = game:GetService("Players")
local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = Player:WaitForChild("PlayerGui")
local PlaceId = game.PlaceId
local World = "Unknown"

for Name, Ids in pairs(_G.DragonLinks.Worlds or {}) do
    for _, Id in ipairs(Ids) do
        if Id == PlaceId then World = Name:gsub("Sea", "Sea ") end
    end
end

_G.DragonDetectedGame = "Blox Fruits"
_G.DragonDetectedWorld = World
_G.DragonSelectedMode = nil

local Old = PlayerGui:FindFirstChild("DragonHUBModeSelector")
if Old then Old:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "DragonHUBModeSelector"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(430, 190)
Main.Position = UDim2.new(0.5, -215, 0.5, -95)
Main.BackgroundColor3 = Color3.fromRGB(12, 13, 21)
Main.BorderSizePixel = 0
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(75, 78, 120)
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -24, 0, 54)
Title.Position = UDim2.fromOffset(12, 8)
Title.BackgroundTransparency = 1
Title.Text = "DragonHUB\nBlox Fruits  •  " .. World
Title.TextColor3 = Color3.fromRGB(238, 238, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local function Button(Text, Position, Color, Mode)
    local Control = Instance.new("TextButton")
    Control.Size = UDim2.new(0.5, -18, 0, 88)
    Control.Position = Position
    Control.BackgroundColor3 = Color
    Control.BorderSizePixel = 0
    Control.Text = Text
    Control.TextColor3 = Color3.new(1, 1, 1)
    Control.TextSize = 12
    Control.TextWrapped = true
    Control.Font = Enum.Font.GothamBold
    Control.Parent = Main
    Instance.new("UICorner", Control).CornerRadius = UDim.new(0, 10)
    Control.MouseButton1Click:Connect(function() _G.DragonSelectedMode = Mode end)
end

Button("AUTOMÁTICO\nA conta evolui sozinha", UDim2.new(0, 12, 0, 82), Color3.fromRGB(37, 99, 235), "AUTOMATIC")
Button("HUB\nEscolha cada função", UDim2.new(0.5, 6, 0, 82), Color3.fromRGB(124, 58, 237), "HUB")

repeat task.wait() until _G.DragonSelectedMode
Gui:Destroy()
