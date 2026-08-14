local DragonLib = {}

local lp = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local playerGui = lp:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("NagaxHUBUI")
if old then
    old:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "NagaxHUBUI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
sg.Parent = playerGui

local win = Instance.new("Frame")
win.Name = "Win"
win.Size = UDim2.new(0, 560, 0, 390)
win.Position = UDim2.new(0.5, -280, 0.5, -195)
win.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Active = true
win.Draggable = false
win.Parent = sg

local winCorner = Instance.new("UICorner")
winCorner.CornerRadius = UDim.new(0, 12)
winCorner.Parent = win

local winStroke = Instance.new("UIStroke")
winStroke.Thickness = 1
winStroke.Color = Color3.fromRGB(42, 42, 66)
winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
winStroke.Parent = win

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(19, 19, 31)
header.BorderSizePixel = 0
header.ZIndex = 3
header.Parent = win

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerBottom = Instance.new("Frame")
headerBottom.Size = UDim2.new(1, 0, 0, 14)
headerBottom.Position = UDim2.new(0, 0, 1, -14)
headerBottom.BackgroundColor3 = Color3.fromRGB(19, 19, 31)
headerBottom.BorderSizePixel = 0
headerBottom.ZIndex = 3
headerBottom.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 18, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DragonHUB | BloxFruits"
title.TextColor3 = Color3.fromRGB(232, 232, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 4
title.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 26, 0, 20)
close.Position = UDim2.new(1, -34, 0.5, -10)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.BorderSizePixel = 0
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextSize = 10
close.Font = Enum.Font.GothamBold
close.ZIndex = 5
close.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = close

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 46)
status.Position = UDim2.new(0, 20, 0, 70)
status.BackgroundColor3 = Color3.fromRGB(34, 34, 53)
status.BorderSizePixel = 0
status.Text = "Interface DragonHUB funcionando"
status.TextColor3 = Color3.fromRGB(45, 190, 90)
status.TextSize = 14
status.Font = Enum.Font.GothamBold
status.Parent = win

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 7)
statusCorner.Parent = status

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -40, 0, 38)
button.Position = UDim2.new(0, 20, 0, 136)
button.BackgroundColor3 = Color3.fromRGB(108, 79, 255)
button.BorderSizePixel = 0
button.Text = "Testar botao"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 12
button.Font = Enum.Font.GothamBold
button.Parent = win

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 7)
buttonCorner.Parent = button

button.MouseButton1Click:Connect(function()
    status.Text = "O botao tambem esta funcionando"
    status.TextColor3 = Color3.fromRGB(245, 158, 11)
end)

close.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

local dragging = false
local dragStart
local winStart

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        winStart = win.Position
    end
end)

uis.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        win.Position = UDim2.new(winStart.X.Scale, winStart.X.Offset + delta.X, winStart.Y.Scale, winStart.Y.Offset + delta.Y)
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

return DragonLib
