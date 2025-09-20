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
end, 150)-- HITBOX EXPANDER
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

-- Apply Hitbox every frame
RunService.RenderStepped:Connect(function()
    for i,v in next, Players:GetPlayers() do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local hrp = v.Character.HumanoidRootPart
                hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                hrp.Transparency = 0.7
                hrp.BrickColor = BrickColor.new("Really blue")
                hrp.Material = "Neon"
                hrp.CanCollide = false
            end)
        end
    end
end)-- ESP System
local espBoxes = {}

-- Auto-detect main part of character
local function getPrimaryPart(character)
    return character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("LowerTorso")
        or character:FindFirstChildWhichIsA("BasePart")
end

local function addESP(plr)
    if plr == player then return end
    if espBoxes[plr] then espBoxes[plr]:Destroy() end
    local char = plr.Character
    if not char then return end
    local mainPart = getPrimaryPart(char)
    if not mainPart then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(4,0,6,0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = mainPart
    billboard.Parent = screenGui

    local box = Instance.new("Frame")
    box.Size = UDim2.new(1,0,1,0)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Parent = billboard

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0,0,255)
    stroke.Parent = box

    espBoxes[plr] = billboard
end

-- Apply ESP to existing and new players
for _,plr in ipairs(Players:GetPlayers()) do
    addESP(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        addESP(plr)
    end)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        addESP(plr)
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if espBoxes[plr] then
        espBoxes[plr]:Destroy()
        espBoxes[plr] = nil
    end
end)-- Targeting / Aimbot
local target = nil

local function getTargetPart(character)
    return character:FindFirstChild("Head") or getPrimaryPart(character)
end

local function isVisible(part)
    if not part then return false end
    local origin = camera.CFrame.Position
    local direction = (part.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, rayParams)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

local function getClosestTarget()
    local closest, closestDist = nil, math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local tp = getTargetPart(plr.Character)
            if tp and (not teamCheck or (plr.Team and plr.Team ~= player.Team)) then
                local screenPos, onScreen = camera:WorldToViewportPoint(tp.Position)
                if onScreen and isVisible(tp) then
                    local dist = (Vector2.new(screenPos.X,screenPos.Y)-Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)).Magnitude
                    if dist < fovRadius and dist < closestDist then
                        closestDist = dist
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if locked then
        target = getClosestTarget()
        if target and target.Character then
            local tp = getTargetPart(target.Character)
            if tp then
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position,tp.Position),1/smoothness)
            end
        end
    end

    -- Update ESP colors
    for plr,gui in pairs(espBoxes) do
        if gui and gui:FindFirstChild("Frame") then
            local stroke = gui.Frame:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = (plr == target) and Color3.fromRGB(150,150,150) or Color3.fromRGB(0,0,255)
            end
        end
        if plr.Character then
            local main = getPrimaryPart(plr.Character)
            if main then gui.Adornee = main end
        end
    end
end)
