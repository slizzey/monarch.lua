local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

local CheatName = "Monarch"

Library.Folders = {
    Directory = CheatName,
    Configs = CheatName .. "/Configs",
    Assets = CheatName .. "/Assets",
}

local Accent = Color3.fromRGB(100, 60, 180)
local Gradient = Color3.fromRGB(60, 30, 120)

Library.Theme.Accent = Accent
Library.Theme.AccentGradient = Gradient
Library:ChangeTheme("Accent", Accent)
Library:ChangeTheme("AccentGradient", Gradient)

local Window = Library:Window({
    Name = "Monarch",
    SubName = "Premium Script",
    Logo = "120959262762131"
})

local KeybindList = Library:KeybindList("Keybinds")
Library:Watermark({
    "Monarch",
    "Premium",
    120959262762131
})

task.spawn(function()
    while true do
        local FPS = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
        Library:Watermark({
            "Monarch",
            "Premium",
            120959262762131,
            "FPS: " .. FPS
        })
        task.wait(0.5)
    end
end)

Window:Category("Combat")

local CombatPage = Window:Page({Name = "Combat", Icon = "138827881557940"})
local MainSection = CombatPage:Section({Name = "Main Features", Side = 1})

local shieldOn = false
local forceField

MainSection:Toggle({
    Name = "Shield",
    Flag = "Shield",
    Default = false,
    Callback = function(Value)
        shieldOn = Value
        local char = player.Character
        if char then
            if shieldOn then
                forceField = Instance.new("ForceField")
                forceField.Parent = char
            else
                if forceField then forceField:Destroy() end
            end
        end
    end
})

local currentSpeed = 16

MainSection:Slider({
    Name = "Walk Speed",
    Flag = "SpeedSlider",
    Min = 16,
    Max = 100,
    Default = 16,
    Suffix = " studs",
    Callback = function(Value)
        currentSpeed = Value
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = currentSpeed end
    end
})

local infJumpOn = false

MainSection:Toggle({
    Name = "Infinite Jump",
    Flag = "InfiniteJump",
    Default = false,
    Callback = function(Value)
        infJumpOn = Value
    end
})

local noclipOn = false

MainSection:Toggle({
    Name = "Noclip",
    Flag = "Noclip",
    Default = false,
    Callback = function(Value)
        noclipOn = Value
    end
})

local flyOn = false
local bodyVelocity, bodyGyro

MainSection:Toggle({
    Name = "Fly",
    Flag = "Fly",
    Default = false,
    Callback = function(Value)
        flyOn = Value
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if flyOn then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = root
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.CFrame = root.CFrame
            bodyGyro.Parent = root
        else
            if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        end
    end
})

local aimbotOn = false
local fov = 40

MainSection:Toggle({
    Name = "Aimbot",
    Flag = "Aimbot",
    Default = false,
    Callback = function(Value)
        aimbotOn = Value
    end
})

MainSection:Slider({
    Name = "Aimbot FOV",
    Flag = "AimbotFOV",
    Min = 10,
    Max = 100,
    Default = 40,
    Suffix = "",
    Callback = function(Value)
        fov = Value
    end
})

local MiscSection = CombatPage:Section({Name = "Keybinds", Side = 2})

MiscSection:Keybind({
    Name = "Menu Toggle",
    Flag = "MenuKeybind",
    Default = Enum.KeyCode.Insert,
    Mode = "Toggle",
    Callback = function(Value)
        Library:Toggle()
    end
})

Window:Category("Visual")

local VisualPage = Window:Page({Name = "Visual", Icon = "122669828593160"})
local ESPSection = VisualPage:Section({Name = "ESP Settings", Side = 1})

local espEnabled = false
local espDrawings = {}
local showNames = true
local showDistance = true
local showBoxes = true
local showTracers = true

ESPSection:Toggle({
    Name = "Enable ESP",
    Flag = "ESPEnabled",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
    end
})

ESPSection:Toggle({
    Name = "Show Names",
    Flag = "ShowNames",
    Default = true,
    Callback = function(Value)
        showNames = Value
    end
})

ESPSection:Toggle({
    Name = "Show Distance",
    Flag = "ShowDistance",
    Default = true,
    Callback = function(Value)
        showDistance = Value
    end
})

ESPSection:Toggle({
    Name = "Show Boxes",
    Flag = "ShowBoxes",
    Default = true,
    Callback = function(Value)
        showBoxes = Value
    end
})

ESPSection:Toggle({
    Name = "Show Tracers",
    Flag = "ShowTracers",
    Default = true,
    Callback = function(Value)
        showTracers = Value
    end
})

local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 1.5
FOVring.Color = Color3.fromRGB(150, 100, 220)
FOVring.Filled = false
FOVring.Radius = fov
FOVring.Position = Cam.ViewportSize / 2
FOVring.Transparency = 1

local function updateDrawings()
    FOVring.Position = Cam.ViewportSize / 2
    FOVring.Radius = fov
end

local function getClosestPlayerInFOV(targetPart)
    local closest = nil
    local last = math.huge
    local center = Cam.ViewportSize / 2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local part = plr.Character:FindFirstChild(targetPart)
            if part then
                local screenPos, onScreen = Cam:WorldToViewportPoint(part.Position)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if onScreen and dist < last and dist < fov then
                    last = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

local function lookAt(targetPos)
    local lookVector = (targetPos - Cam.CFrame.Position).Unit
    local newCFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector)
    Cam.CFrame = newCFrame
end

RunService.Heartbeat:Connect(function()
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = currentSpeed end
end)

UserInputService.JumpRequest:Connect(function()
    if not infJumpOn then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if hum and root and hum.Health > 0 then
        hum.JumpPower = 80
        root.Velocity = Vector3.new(root.Velocity.X, 70, root.Velocity.Z)
    end
end)

RunService.Stepped:Connect(function()
    if not noclipOn then return end
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if not flyOn then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local moveDir = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
        root.CFrame = root.CFrame + (moveDir * (currentSpeed * 1.5) * dt)
    end
    root.CFrame = CFrame.new(root.Position) * Cam.CFrame.Rotation
end)

RunService.RenderStepped:Connect(function()
    updateDrawings()
    FOVring.Visible = aimbotOn
    if not aimbotOn then
        FOVring.Transparency = 0
        return
    end
    local closest = getClosestPlayerInFOV("Head")
    if closest and closest.Character and closest.Character:FindFirstChild("Head") then
        lookAt(closest.Character.Head.Position)
        local screenPos, onScreen = Cam:WorldToViewportPoint(closest.Character.Head.Position)
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - (Cam.ViewportSize / 2)).Magnitude
        FOVring.Transparency = (1 - (dist / fov)) * 0.1
    else
        FOVring.Transparency = 0.1
    end
end)

player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    local hum = newChar:WaitForChild("Humanoid")
    hum.WalkSpeed = currentSpeed
    if shieldOn then
        forceField = Instance.new("ForceField")
        forceField.Parent = newChar
    end
    if flyOn then
        flyOn = false
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    end
end)

local function createESP(plr)
    if plr == player then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.fromRGB(150, 100, 220)
    box.Transparency = 0.8
    box.Visible = false
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(150, 100, 220)
    tracer.Transparency = 0.7
    tracer.Visible = false
    local nameText = Drawing.new("Text")
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Font = 2
    nameText.Visible = false
    local distText = Drawing.new("Text")
    distText.Size = 12
    distText.Center = true
    distText.Outline = true
    distText.Color = Color3.fromRGB(200, 180, 255)
    distText.Font = 2
    distText.Visible = false
    espDrawings[plr] = {
        box = box,
        tracer = tracer,
        name = nameText,
        dist = distText
    }
end

local function removeESP(plr)
    if espDrawings[plr] then
        for _, v in pairs(espDrawings[plr]) do
            v:Remove()
        end
        espDrawings[plr] = nil
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if not espEnabled then
        for _, data in pairs(espDrawings) do
            data.box.Visible = false
            data.tracer.Visible = false
            data.name.Visible = false
            data.dist.Visible = false
        end
        return
    end
    for plr, data in pairs(espDrawings) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
            local hrp = plr.Character.HumanoidRootPart
            local head = plr.Character.Head
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local rootPos, onScreen = Cam:WorldToViewportPoint(hrp.Position)
                local headPos = Cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))
                if onScreen then
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.45
                    if showBoxes then
                        data.box.Size = Vector2.new(width, height)
                        data.box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                        data.box.Visible = true
                    else
                        data.box.Visible = false
                    end
                    if showTracers then
                        data.tracer.From = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y)
                        data.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        data.tracer.Visible = true
                    else
                        data.tracer.Visible = false
                    end
                    if showNames then
                        data.name.Text = plr.Name
                        data.name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 18)
                        data.name.Visible = true
                    else
                        data.name.Visible = false
                    end
                    if showDistance then
                        local distance = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) and
                            (player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude or 0
                        data.dist.Text = math.floor(distance) .. " studs"
                        data.dist.Position = Vector2.new(rootPos.X, rootPos.Y + height/2 + 2)
                        data.dist.Visible = true
                    else
                        data.dist.Visible = false
                    end
                else
                    data.box.Visible = false
                    data.tracer.Visible = false
                    data.name.Visible = false
                    data.dist.Visible = false
                end
            else
                data.box.Visible = false
                data.tracer.Visible = false
                data.name.Visible = false
                data.dist.Visible = false
            end
        else
            data.box.Visible = false
            data.tracer.Visible = false
            data.name.Visible = false
            data.dist.Visible = false
        end
    end
end)

Window:Category("Settings")
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)
Window:Init()
