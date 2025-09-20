
-- HONEYY Universal Script + Part 1: GUI & Settings
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Prevent duplicate GUI
if CoreGui:FindFirstChild("HONEYY_GUI") then
    CoreGui.HONEYY_GUI:Destroy()
end

-- Main GUI container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HONEYY_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Menu Button
local menuButton = Instance.new("TextButton")
menuButton.Size = UDim2.new(0, 100, 0, 30)
menuButton.Position = UDim2.new(0, 10, 0, 10)
menuButton.Text = "MENU"
menuButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
menuButton.TextColor3 = Color3.new(1, 1, 1)
menuButton.Parent = screenGui

-- Menu Frame
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 220, 0, 250)
menuFrame.Position = UDim2.new(0, 10, 0, 50)
menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menuFrame.Visible = false
menuFrame.Parent = screenGui

-- Lock Button
local lockButton = Instance.new("TextButton")
lockButton.Size = UDim2.new(0, 200, 0, 30)
lockButton.Position = UDim2.new(0, 10, 0, 10)
lockButton.Text = "LOCK: OFF"
lockButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
lockButton.TextColor3 = Color3.new(1, 1, 1)
lockButton.Parent = menuFrame

local locked = false
lockButton.MouseButton1Click:Connect(function()
    locked = not locked
    lockButton.Text = "LOCK: " .. (locked and "ON" or "OFF")
    lockButton.BackgroundColor3 = locked and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 0, 0)
end)

-- Toggle Menu Visibility
menuButton.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)

-- Team Check Toggle
local teamCheck = false
local teamButton = Instance.new("TextButton")
teamButton.Size = UDim2.new(0, 200, 0, 30)
teamButton.Position = UDim2.new(0, 10, 0, 50)
teamButton.Text = "TEAM CHECK: OFF"
teamButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
teamButton.TextColor3 = Color3.new(1, 1, 1)
teamButton.Parent = menuFrame

teamButton.MouseButton1Click:Connect(function()
    teamCheck = not teamCheck
    teamButton.Text = "TEAM CHECK: " .. (teamCheck and "ON" or "OFF")
    teamButton.BackgroundColor3 = teamCheck and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 0, 0)
end)

-- FOV Circle (Centered)
local fovCircle = Instance.new("Frame")
local fovRadius = 150
local smoothness = 10

fovCircle.Size = UDim2.new(0, fovRadius*2, 0, fovRadius*2)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, -25)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Parent = screenGui

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 0)
stroke.Parent = fovCircle

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = fovCircle

-- Slider Function
local function createSlider(name, minVal, maxVal, defaultVal, callback, posY)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, posY)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = menuFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Text = name .. ": " .. tostring(defaultVal)
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 1, -12)
    bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    bar.Parent = frame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 20)
    knob.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -6, -0.5, 0)
    knob.Parent = bar

    local dragging = false
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local value = math.floor(minVal + (maxVal - minVal) * percent)
            knob.Position = UDim2.new(percent, -6, -0.5, 0)
            label.Text = name .. ": " .. tostring(value)
            callback(value)
        end
    end)
end

-- Create FOV & Smoothness Sliders
createSlider("FOV Radius", 50, 500, fovRadius, function(val)
    fovRadius = val
    fovCircle.Size = UDim2.new(0, fovRadius*2, 0, fovRadius*2)
    fovCircle.Position = UDim2.new(0.5, 0, 0.5, -25)
end, 100)

createSlider("Smoothness", 1, 50, smoothness, function(val)
    smoothness = math.max(1, val)
end, 150)

-- HITBOX EXPANDER
local hitboxSize = 50 -- default
local hitboxFrame = Instance.new("Frame")
hitboxFrame.Size = UDim2.new(0, 200, 0, 40)
hitboxFrame.Position = UDim2.new(0, 10, 0, 200) -- below sliders
hitboxFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
hitboxFrame.Parent = menuFrame

local hitboxLabel = Instance.new("TextLabel")
hitboxLabel.Size = UDim2.new(1, 0, 0, 20)
hitboxLabel.BackgroundTransparency = 1
hitboxLabel.TextColor3 = Color3.new(1, 1, 1)
hitboxLabel.Text = "Hitbox Size: " .. hitboxSize
hitboxLabel.Parent = hitboxFrame

local hitboxBox = Instance.new("TextBox")
hitboxBox.Size = UDim2.new(1, 0, 0, 20)
hitboxBox.Position = UDim2.new(0, 0, 0, 20)
hitboxBox.Text = tostring(hitboxSize)
hitboxBox.ClearTextOnFocus = false
hitboxBox.TextColor3 = Color3.new(1,1,1)
hitboxBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
hitboxBox.Parent = hitboxFrame

hitboxBox.FocusLost:Connect(function(enterPressed)
    local val = tonumber(hitboxBox.Text)
    if val and val > 0 and val <= 100 then
        hitboxSize = val
        hitboxLabel.Text = "Hitbox Size: " .. hitboxSize
    else
        hitboxBox.Text = tostring(hitboxSize)
    end
end)
