local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

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

local Settings = {
    Aim = {
        Enabled = false,
        Keybind = Enum.UserInputType.MouseButton2,
        Smoothness = 0.25,
        FOV = 150,
        ShowFOV = true,
        WallCheck = true,
        TeamCheck = true,
        TargetMode = "FOV",
        LockMode = "Hold",
        AutoSwitch = true,
        TargetPart = "Head",
        Prediction = 0,
        SilentAim = false,
        SnapOnLock = true,
        StickyLock = true,
        AimMethod = "Auto",
        SilentAimMode = "On Shoot",
        UseScreenCenter = true,
        FreeMouseOnLock = false,
        AimWhileShooting = true,
        FreezeAimWhileShooting = true,
        ShootingAimScale = 0.2,
        ShootingMaxStep = 2,
        ShowLockHud = true,
        AutoShootEnabled = false,
        AutoShootMode = "On Lock",
        AutoShootFireMode = "Tap",
        AutoShootInterval = 0.1,
        AutoShootWallCheck = true,
        TriggerbotEnabled = false,
        TriggerbotRadius = 20,
        TriggerbotDelay = 0.05,
        TriggerbotWallCheck = true,
        GunOnlyShoot = false,
        VelocityResolver = false,
        ResolverStrength = 1,
        CrosshairEnabled = false,
        CrosshairSize = 8,
        CrosshairColor = Color3.fromRGB(255, 255, 255),
        FOVColor = Color3.fromRGB(100, 60, 180),
    },
    ESP = {
        CharmsEnabled = false,
        TeamVisible = false,
        Color = Color3.fromRGB(100, 60, 180),
        TeamColorEnabled = false,
        EnemyColor = Color3.fromRGB(100, 60, 180),
        TeamColor = Color3.fromRGB(80, 160, 255),
        BoxESP = false,
        NameESP = false,
        Tracers = false,
        ShowDistance = false,
        SkeletonESP = false,
        ESPMode = "Auto",
    },
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 16,
        JumpEnabled = false,
        JumpValue = 50,
        FlyEnabled = false,
        FlySpeed = 50,
        NoclipEnabled = false,
        InfiniteJump = false,
        GravityEnabled = false,
        GravityValue = 196.2,
    },
    Misc = {
        FpsCounter = true,
        Fullbright = false,
        NoFog = false,
        AntiAFK = false,
        MenuKeybind = Enum.KeyCode.Insert,
        Whitelist = {},
    },
    Troll = {
        FlingPower = 500000,
        OrbitSpeed = 6,
        OrbitRadius = 10,
        ConstantFling = false,
        OrbitTarget = false,
        HeadSit = false,
        SpinTroll = false,
        Invisible = false,
    },
    Binds = {
        AimToggle = false,
        NoclipToggle = false,
        FlyToggle = false,
        EspToggle = false,
        PanicKey = false,
        TriggerbotToggle = false,
    },
}

local defaultGravity = Workspace.Gravity
local isAming = false
local isShooting = false
local currentTargetPlayer = nil
local aimbotOn = false
local fov = 40
local smoothness = 0.25
local wallCheck = true
local teamCheck = true
local targetPart = "Head"
local prediction = 0
local silentAim = false
local lockMode = "Hold"
local toggleActive = false
local triggerbotOn = false
local triggerbotRadius = 20
local triggerbotDelay = 0.05
local triggerbotWallCheck = true
local crosshairEnabled = false
local crosshairSize = 8
local crosshairColor = Color3.fromRGB(255, 255, 255)
local showFOV = true
local fovColor = Color3.fromRGB(100, 60, 180)
local showLockHud = true
local autoShootOn = false
local autoShootMode = "On Lock"
local autoShootInterval = 0.1
local velocityResolver = false
local resolverStrength = 1

local shieldOn = false
local forceField
local currentSpeed = 16
local infJumpOn = false
local noclipOn = false
local flyOn = false
local bodyVelocity, bodyGyro
local flySpeed = 50
local jumpEnabled = false
local jumpValue = 50
local gravityEnabled = false
local gravityValue = 196.2

local espEnabled = false
local espDrawings = {}
local espHighlights = {}
local showNames = true
local showDistance = true
local showBoxes = true
local showTracers = true
local showSkeleton = false
local showTeam = false
local teamColorEnabled = false
local enemyColor = Color3.fromRGB(100, 60, 180)
local teamColor = Color3.fromRGB(80, 160, 255)
local espColor = Color3.fromRGB(100, 60, 180)
local charmsEnabled = false

local fullbright = false
local noFog = false
local antiAFK = false
local fpsCounter = true

local whitelist = {}
local trollTargetIndex = 1
local trollTarget = nil
local flingPower = 500000
local orbitSpeed = 6
local orbitRadius = 10
local constantFling = false
local orbitTarget = false
local headSit = false
local spinTroll = false
local invisible = false

local flingConnection = nil
local orbitConnection = nil
local spinConnection = nil
local originalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
}

local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 1.5
FOVring.Color = fovColor
FOVring.Filled = false
FOVring.Radius = fov
FOVring.Position = Cam.ViewportSize / 2
FOVring.Transparency = 0.5

local crosshairDrawings = {}
for i = 1, 4 do
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = crosshairColor
    line.Thickness = 1
    table.insert(crosshairDrawings, line)
end

local LockStatusGui = nil
local lockStatusLabel = nil

local function initLockHud()
    local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 20)
    if not playerGui then return false end
    local old = playerGui:FindFirstChild("Monarch_LockStatus")
    if old then old:Destroy() end
    LockStatusGui = Instance.new("ScreenGui")
    LockStatusGui.Name = "Monarch_LockStatus"
    LockStatusGui.ResetOnSpawn = false
    LockStatusGui.IgnoreGuiInset = true
    LockStatusGui.DisplayOrder = 10000000
    LockStatusGui.Parent = playerGui
    lockStatusLabel = Instance.new("TextLabel")
    lockStatusLabel.Size = UDim2.new(0, 200, 0, 30)
    lockStatusLabel.Position = UDim2.new(0.5, -100, 0, 10)
    lockStatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    lockStatusLabel.BackgroundTransparency = 0.2
    lockStatusLabel.BorderSizePixel = 0
    lockStatusLabel.TextColor3 = Color3.fromRGB(100, 60, 180)
    lockStatusLabel.Font = Enum.Font.GothamBold
    lockStatusLabel.TextSize = 14
    lockStatusLabel.Text = ""
    lockStatusLabel.Visible = false
    lockStatusLabel.Parent = LockStatusGui
    Instance.new("UICorner", lockStatusLabel).CornerRadius = UDim.new(0, 6)
    return true
end

local function setLockHud(text, visible)
    if not showLockHud then
        if LockStatusGui then LockStatusGui.Enabled = false end
        return
    end
    if not lockStatusLabel then initLockHud() end
    if LockStatusGui then LockStatusGui.Enabled = true end
    if lockStatusLabel then
        lockStatusLabel.Text = text or ""
        lockStatusLabel.Visible = visible ~= false
    end
end

local function updateCrosshair()
    local center = Cam.ViewportSize / 2
    local size = crosshairSize
    for i, line in ipairs(crosshairDrawings) do
        line.Visible = crosshairEnabled
        line.Color = crosshairColor
        if i == 1 then
            line.From = Vector2.new(center.X - size, center.Y)
            line.To = Vector2.new(center.X - 2, center.Y)
        elseif i == 2 then
            line.From = Vector2.new(center.X + size, center.Y)
            line.To = Vector2.new(center.X + 2, center.Y)
        elseif i == 3 then
            line.From = Vector2.new(center.X, center.Y - size)
            line.To = Vector2.new(center.X, center.Y - 2)
        elseif i == 4 then
            line.From = Vector2.new(center.X, center.Y + size)
            line.To = Vector2.new(center.X, center.Y + 2)
        end
    end
end

local function updateDrawings()
    FOVring.Position = Cam.ViewportSize / 2
    FOVring.Radius = fov
    FOVring.Color = fovColor
    FOVring.Visible = aimbotOn and showFOV
    updateCrosshair()
end

local function isWhitelisted(plr)
    if type(whitelist) ~= "table" then return false end
    for _, uid in ipairs(whitelist) do
        if tonumber(uid) == plr.UserId then return true end
    end
    return false
end

local function isOnTeam(plr)
    if not teamCheck then return false end
    local localTeam = player.Team
    local targetTeam = plr.Team
    return localTeam and targetTeam and localTeam == targetTeam
end

local function isWallBetween(part1, part2)
    if not wallCheck then return false end
    local ray = Ray.new(part1.Position, (part2.Position - part1.Position).Unit * (part1.Position - part2.Position).Magnitude)
    local hit, _ = Workspace:FindPartOnRay(ray, player.Character)
    return hit ~= nil
end

local function getClosestPlayerInFOV()
    local closest = nil
    local last = math.huge
    local center = Cam.ViewportSize / 2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            if isWhitelisted(plr) then continue end
            if isOnTeam(plr) then continue end
            local part = plr.Character:FindFirstChild(targetPart)
            if part then
                if wallCheck and isWallBetween(Cam, part) then continue end
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

local function getPredictedPosition(target)
    if prediction == 0 then return target.Position end
    local velocity = target.Velocity
    return target.Position + (velocity * prediction)
end

local function lookAt(targetPos)
    local lookVector = (targetPos - Cam.CFrame.Position).Unit
    local newCFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector)
    if smoothness > 0 then
        Cam.CFrame = Cam.CFrame:Lerp(newCFrame, smoothness)
    else
        Cam.CFrame = newCFrame
    end
end

local function aimAtTarget(target)
    if not target or not target.Character then return end
    local part = target.Character:FindFirstChild(targetPart)
    if part then
        local predictedPos = getPredictedPosition(part)
        lookAt(predictedPos)
        if showLockHud then
            setLockHud("LOCKED: " .. target.Name, true)
        end
    end
end

local lastTriggerbotAt = 0

local function checkTriggerbot()
    if not triggerbotOn then return end
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            if isWhitelisted(plr) then continue end
            if isOnTeam(plr) then continue end
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < triggerbotRadius then
                        if triggerbotWallCheck and isWallBetween(Cam, head) then continue end
                        if tick() - lastTriggerbotAt >= triggerbotDelay then
                            lastTriggerbotAt = tick()
                            mouse1click()
                        end
                    end
                end
            end
        end
    end
end

local lastAutoShootAt = 0

local function autoShoot()
    if not autoShootOn then return end
    if autoShootMode == "On Lock" and currentTargetPlayer then
        if tick() - lastAutoShootAt >= autoShootInterval then
            lastAutoShootAt = tick()
            mouse1click()
        end
    end
end

local function cycleTrollTarget()
    local targets = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            table.insert(targets, plr)
        end
    end
    if #targets == 0 then
        trollTarget = nil
        return
    end
    trollTargetIndex = trollTargetIndex % #targets + 1
    trollTarget = targets[trollTargetIndex]
end

local function getTrollTarget()
    if not trollTarget or not trollTarget.Character then
        cycleTrollTarget()
    end
    return trollTarget
end

local function clearFlingForce()
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
end

local function flingTargetOnce(target)
    if not target or not target.Character then return end
    local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if localRoot and targetRoot then
        localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1)
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, flingPower, 0)
        bv.Parent = localRoot
        game:GetService("Debris"):AddItem(bv, 0.1)
    end
end

local function startConstantFling()
    clearFlingForce()
    constantFling = true
    flingConnection = RunService.Heartbeat:Connect(function()
        if not constantFling then return end
        local target = getTrollTarget()
        if target then flingTargetOnce(target) end
    end)
end

local function clearOrbit()
    if orbitConnection then
        orbitConnection:Disconnect()
        orbitConnection = nil
    end
end

local function startOrbit()
    clearOrbit()
    orbitTarget = true
    local startTime = tick()
    orbitConnection = RunService.Heartbeat:Connect(function()
        if not orbitTarget then return end
        local target = getTrollTarget()
        if not target or not target.Character then return end
        local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if localRoot and targetRoot then
            local angle = (tick() - startTime) * orbitSpeed
            local offset = Vector3.new(math.cos(angle) * orbitRadius, 0, math.sin(angle) * orbitRadius)
            localRoot.CFrame = targetRoot.CFrame * CFrame.new(offset)
        end
    end)
end

local function clearSpinTroll()
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
end

local function startSpinTroll()
    clearSpinTroll()
    spinTroll = true
    spinConnection = RunService.Heartbeat:Connect(function()
        if not spinTroll then return end
        local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if localRoot then
            localRoot.CFrame = localRoot.CFrame * CFrame.Angles(0, math.rad(15), 0)
        end
    end)
end

local function updateInvisibleState()
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = invisible and 1 or 0
        end
    end
end

local function updateLightingState()
    if fullbright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
    if noFog then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
    end
end

local function createESP(plr)
    if plr == player then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = espColor
    box.Transparency = 0.8
    box.Visible = false
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = espColor
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
    if charmsEnabled then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = espColor
        highlight.OutlineColor = espColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Enabled = false
        highlight.Adornee = plr.Character
        highlight.Parent = plr.Character
        espHighlights[plr] = highlight
    end
end

local function removeESP(plr)
    if espDrawings[plr] then
        for _, v in pairs(espDrawings[plr]) do
            v:Remove()
        end
        espDrawings[plr] = nil
    end
    if espHighlights[plr] then
        espHighlights[plr]:Destroy()
        espHighlights[plr] = nil
    end
end

local function refreshCharms()
    for plr, highlight in pairs(espHighlights) do
        if highlight then
            highlight.Enabled = charmsEnabled and espEnabled
            if teamColorEnabled then
                if isOnTeam(plr) then
                    highlight.FillColor = teamColor
                    highlight.OutlineColor = teamColor
                else
                    highlight.FillColor = enemyColor
                    highlight.OutlineColor = enemyColor
                end
            else
                highlight.FillColor = espColor
                highlight.OutlineColor = espColor
            end
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

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
        hum.JumpPower = jumpValue
        root.Velocity = Vector3.new(root.Velocity.X, jumpValue, root.Velocity.Z)
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
        root.CFrame = root.CFrame + (moveDir * flySpeed * dt)
    end
    root.CFrame = CFrame.new(root.Position) * Cam.CFrame.Rotation
end)

RunService.RenderStepped:Connect(function()
    updateDrawings()
    if aimbotOn and isAming then
        if lockMode == "Hold" or toggleActive then
            currentTargetPlayer = getClosestPlayerInFOV()
            if currentTargetPlayer then
                aimAtTarget(currentTargetPlayer)
            else
                setLockHud("", false)
            end
        end
    else
        setLockHud("", false)
        currentTargetPlayer = nil
    end
    checkTriggerbot()
    autoShoot()
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
    if invisible then updateInvisibleState() end
end)

RunService.RenderStepped:Connect(function()
    if not espEnabled then
        for _, data in pairs(espDrawings) do
            data.box.Visible = false
            data.tracer.Visible = false
            data.name.Visible = false
            data.dist.Visible = false
        end
        for _, highlight in pairs(espHighlights) do
            highlight.Enabled = false
        end
        return
    end
    for plr, data in pairs(espDrawings) do
        if isWhitelisted(plr) and not showTeam then
            data.box.Visible = false
            data.tracer.Visible = false
            data.name.Visible = false
            data.dist.Visible = false
            if espHighlights[plr] then espHighlights[plr].Enabled = false end
            continue
        end
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
                    local color = espColor
                    if teamColorEnabled then
                        color = isOnTeam(plr) and teamColor or enemyColor
                    end
                    data.box.Color = color
                    data.tracer.Color = color
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
    refreshCharms()
end)

player.Idled:Connect(function()
    if antiAFK then
        VirtualUser:CaptureFocus()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

Window:Category("Aim")

local AimPage = Window:Page({Name = "Aim", Icon = "138827881557940"})
local AimMainSection = AimPage:Section({Name = "Aimbot", Side = 1})

AimMainSection:Toggle({
    Name = "Enable Aimbot",
    Flag = "AimbotEnabled",
    Default = false,
    Callback = function(Value)
        aimbotOn = Value
    end
})

AimMainSection:Keybind({
    Name = "Aim Key",
    Flag = "AimKeybind",
    Default = Enum.UserInputType.MouseButton2,
    Mode = "Hold",
    Callback = function(Value)
        Settings.Aim.Keybind = Value
    end
})

AimMainSection:Slider({
    Name = "Smoothness",
    Flag = "AimSmoothness",
    Min = 0,
    Max = 1,
    Default = 0.25,
    Suffix = "",
    Callback = function(Value)
        smoothness = Value
    end
})

AimMainSection:Slider({
    Name = "FOV",
    Flag = "AimFOV",
    Min = 10,
    Max = 200,
    Default = 150,
    Suffix = "",
    Callback = function(Value)
        fov = Value
    end
})

AimMainSection:Toggle({
    Name = "Show FOV",
    Flag = "ShowFOV",
    Default = true,
    Callback = function(Value)
        showFOV = Value
    end
})

AimMainSection:Toggle({
    Name = "Wall Check",
    Flag = "WallCheck",
    Default = true,
    Callback = function(Value)
        wallCheck = Value
    end
})

AimMainSection:Toggle({
    Name = "Team Check",
    Flag = "TeamCheck",
    Default = true,
    Callback = function(Value)
        teamCheck = Value
    end
})

AimMainSection:Dropdown({
    Name = "Target Part",
    Flag = "TargetPart",
    Default = {"Head"},
    Items = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Multi = false,
    Callback = function(Value)
        targetPart = Value[1]
    end
})

AimMainSection:Dropdown({
    Name = "Lock Mode",
    Flag = "LockMode",
    Default = {"Hold"},
    Items = {"Hold", "Toggle"},
    Multi = false,
    Callback = function(Value)
        lockMode = Value[1]
    end
})

AimMainSection:Slider({
    Name = "Prediction",
    Flag = "Prediction",
    Min = 0,
    Max = 1,
    Default = 0,
    Suffix = "s",
    Callback = function(Value)
        prediction = Value
    end
})

AimMainSection:Toggle({
    Name = "Silent Aim",
    Flag = "SilentAim",
    Default = false,
    Callback = function(Value)
        silentAim = Value
    end
})

AimMainSection:Toggle({
    Name = "Show Lock HUD",
    Flag = "ShowLockHud",
    Default = true,
    Callback = function(Value)
        showLockHud = Value
    end
})

local AimExtraSection = AimPage:Section({Name = "Extra", Side = 2})

AimExtraSection:Toggle({
    Name = "Auto Shoot",
    Flag = "AutoShoot",
    Default = false,
    Callback = function(Value)
        autoShootOn = Value
    end
})

AimExtraSection:Dropdown({
    Name = "Auto Shoot Mode",
    Flag = "AutoShootMode",
    Default = {"On Lock"},
    Items = {"On Lock", "Always"},
    Multi = false,
    Callback = function(Value)
        autoShootMode = Value[1]
    end
})

AimExtraSection:Slider({
    Name = "Auto Shoot Interval",
    Flag = "AutoShootInterval",
    Min = 0.05,
    Max = 0.5,
    Default = 0.1,
    Suffix = "s",
    Callback = function(Value)
        autoShootInterval = Value
    end
})

AimExtraSection:Toggle({
    Name = "Triggerbot",
    Flag = "Triggerbot",
    Default = false,
    Callback = function(Value)
        triggerbotOn = Value
    end
})

AimExtraSection:Slider({
    Name = "Triggerbot Radius",
    Flag = "TriggerbotRadius",
    Min = 5,
    Max = 50,
    Default = 20,
    Suffix = "",
    Callback = function(Value)
        triggerbotRadius = Value
    end
})

AimExtraSection:Slider({
    Name = "Triggerbot Delay",
    Flag = "TriggerbotDelay",
    Min = 0.01,
    Max = 0.2,
    Default = 0.05,
    Suffix = "s",
    Callback = function(Value)
        triggerbotDelay = Value
    end
})

AimExtraSection:Toggle({
    Name = "Triggerbot Wall Check",
    Flag = "TriggerbotWallCheck",
    Default = true,
    Callback = function(Value)
        triggerbotWallCheck = Value
    end
})

AimExtraSection:Toggle({
    Name = "Velocity Resolver",
    Flag = "VelocityResolver",
    Default = false,
    Callback = function(Value)
        velocityResolver = Value
    end
})

AimExtraSection:Toggle({
    Name = "Crosshair",
    Flag = "Crosshair",
    Default = false,
    Callback = function(Value)
        crosshairEnabled = Value
    end
})

AimExtraSection:Slider({
    Name = "Crosshair Size",
    Flag = "CrosshairSize",
    Min = 4,
    Max = 20,
    Default = 8,
    Suffix = "",
    Callback = function(Value)
        crosshairSize = Value
    end
})

AimExtraSection:Label("FOV Color"):Colorpicker({
    Name = "FOV Color",
    Flag = "FOVColor",
    Default = Color3.fromRGB(100, 60, 180),
    Callback = function(Value)
        fovColor = Value
    end
})

AimExtraSection:Label("Crosshair Color"):Colorpicker({
    Name = "Crosshair Color",
    Flag = "CrosshairColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        crosshairColor = Value
    end
})

Window:Category("Visual")

local VisualPage = Window:Page({Name = "Visual", Icon = "122669828593160"})
local ESPSection = VisualPage:Section({Name = "ESP", Side = 1})

ESPSection:Toggle({
    Name = "Enable ESP",
    Flag = "ESPEnabled",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
    end
})

ESPSection:Toggle({
    Name = "Enable Charms",
    Flag = "CharmsEnabled",
    Default = false,
    Callback = function(Value)
        charmsEnabled = Value
        refreshCharms()
    end
})

ESPSection:Toggle({
    Name = "Box ESP",
    Flag = "BoxESP",
    Default = false,
    Callback = function(Value)
        showBoxes = Value
    end
})

ESPSection:Toggle({
    Name = "Name ESP",
    Flag = "NameESP",
    Default = false,
    Callback = function(Value)
        showNames = Value
    end
})

ESPSection:Toggle({
    Name = "Tracers",
    Flag = "Tracers",
    Default = false,
    Callback = function(Value)
        showTracers = Value
    end
})

ESPSection:Toggle({
    Name = "Distance ESP",
    Flag = "DistanceESP",
    Default = false,
    Callback = function(Value)
        showDistance = Value
    end
})

ESPSection:Toggle({
    Name = "Show Teammates",
    Flag = "ShowTeammates",
    Default = false,
    Callback = function(Value)
        showTeam = Value
    end
})

ESPSection:Label("ESP Color"):Colorpicker({
    Name = "ESP Color",
    Flag = "ESPColor",
    Default = Color3.fromRGB(100, 60, 180),
    Callback = function(Value)
        espColor = Value
        refreshCharms()
    end
})

ESPSection:Toggle({
    Name = "Team Color ESP",
    Flag = "TeamColorESP",
    Default = false,
    Callback = function(Value)
        teamColorEnabled = Value
        refreshCharms()
    end
})

ESPSection:Label("Enemy Color"):Colorpicker({
    Name = "Enemy Color",
    Flag = "EnemyColor",
    Default = Color3.fromRGB(100, 60, 180),
    Callback = function(Value)
        enemyColor = Value
        refreshCharms()
    end
})

ESPSection:Label("Team Color"):Colorpicker({
    Name = "Team Color",
    Flag = "TeamColor",
    Default = Color3.fromRGB(80, 160, 255),
    Callback = function(Value)
        teamColor = Value
        refreshCharms()
    end
})

local VisualExtraSection = VisualPage:Section({Name = "Visuals", Side = 2})

VisualExtraSection:Toggle({
    Name = "Fullbright",
    Flag = "Fullbright",
    Default = false,
    Callback = function(Value)
        fullbright = Value
        updateLightingState()
    end
})

VisualExtraSection:Toggle({
    Name = "No Fog",
    Flag = "NoFog",
    Default = false,
    Callback = function(Value)
        noFog = Value
        updateLightingState()
    end
})

Window:Category("Movement")

local MovementPage = Window:Page({Name = "Movement", Icon = "138827881557940"})
local MoveSection = MovementPage:Section({Name = "Movement", Side = 1})

MoveSection:Toggle({
    Name = "Speed Hack",
    Flag = "SpeedEnabled",
    Default = false,
    Callback = function(Value)
        Settings.Movement.SpeedEnabled = Value
    end
})

MoveSection:Slider({
    Name = "Walk Speed",
    Flag = "SpeedValue",
    Min = 16,
    Max = 250,
    Default = 16,
    Suffix = " studs",
    Callback = function(Value)
        currentSpeed = Value
    end
})

MoveSection:Toggle({
    Name = "Jump Height",
    Flag = "JumpEnabled",
    Default = false,
    Callback = function(Value)
        jumpEnabled = Value
    end
})

MoveSection:Slider({
    Name = "Jump Power",
    Flag = "JumpValue",
    Min = 7,
    Max = 500,
    Default = 50,
    Suffix = "",
    Callback = function(Value)
        jumpValue = Value
    end
})

MoveSection:Toggle({
    Name = "Infinite Jump",
    Flag = "InfiniteJump",
    Default = false,
    Callback = function(Value)
        infJumpOn = Value
    end
})

MoveSection:Toggle({
    Name = "Fly",
    Flag = "FlyEnabled",
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

MoveSection:Slider({
    Name = "Fly Speed",
    Flag = "FlySpeed",
    Min = 10,
    Max = 300,
    Default = 50,
    Suffix = "",
    Callback = function(Value)
        flySpeed = Value
    end
})

MoveSection:Toggle({
    Name = "Noclip",
    Flag = "NoclipEnabled",
    Default = false,
    Callback = function(Value)
        noclipOn = Value
    end
})

MoveSection:Toggle({
    Name = "Custom Gravity",
    Flag = "GravityEnabled",
    Default = false,
    Callback = function(Value)
        gravityEnabled = Value
        if not Value then Workspace.Gravity = defaultGravity end
    end
})

MoveSection:Slider({
    Name = "Gravity Value",
    Flag = "GravityValue",
    Min = 0,
    Max = 500,
    Default = 196.2,
    Suffix = "",
    Callback = function(Value)
        gravityValue = Value
        if gravityEnabled then Workspace.Gravity = gravityValue end
    end
})

Window:Category("Players")

local PlayersPage = Window:Page({Name = "Players", Icon = "138827881557940"})
local PlayersSection = PlayersPage:Section({Name = "Player List", Side = 1})

local function refreshPlayerList()
    for _, child in ipairs(PlayersSection:GetDescendants()) do
        if child:IsA("Frame") and child.Name == "PlayerRow" then child:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end
        local row = Instance.new("Frame")
        row.Name = "PlayerRow"
        row.Size = UDim2.new(1, 0, 0, 35)
        row.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        row.Parent = PlayersSection
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 8, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = plr.DisplayName
        nameLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
        nameLabel.Font = Enum.Font.GothamMedium
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = row
        local wlBtn = Instance.new("TextButton")
        wlBtn.Size = UDim2.new(0, 50, 0, 22)
        wlBtn.Position = UDim2.new(1, -120, 0.5, -11)
        wlBtn.BackgroundColor3 = isWhitelisted(plr) and Color3.fromRGB(70, 180, 90) or Color3.fromRGB(28, 28, 34)
        wlBtn.Text = isWhitelisted(plr) and "WL+" or "WL"
        wlBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        wlBtn.Font = Enum.Font.GothamBold
        wlBtn.TextSize = 9
        wlBtn.Parent = row
        Instance.new("UICorner", wlBtn).CornerRadius = UDim.new(0, 4)
        wlBtn.MouseButton1Click:Connect(function()
            if isWhitelisted(plr) then
                for i, uid in ipairs(whitelist) do
                    if tonumber(uid) == plr.UserId then
                        table.remove(whitelist, i)
                        break
                    end
                end
            else
                table.insert(whitelist, plr.UserId)
            end
            refreshPlayerList()
        end)
        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0, 50, 0, 22)
        tpBtn.Position = UDim2.new(1, -64, 0.5, -11)
        tpBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 180)
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.TextSize = 10
        tpBtn.Parent = row
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
        tpBtn.MouseButton1Click:Connect(function()
            local localChar = player.Character
            local targetChar = plr.Character
            if localChar and targetChar then
                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if localRoot and targetRoot then
                    localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)
                end
            end
        end)
    end
end

PlayersSection:Button({
    Name = "Refresh Player List",
    Callback = function()
        refreshPlayerList()
    end
})

local PlayersExtraSection = PlayersPage:Section({Name = "Whitelist Info", Side = 2})

local WhitelistLabel = Instance.new("TextLabel")
WhitelistLabel.Size = UDim2.new(1, 0, 0, 20)
WhitelistLabel.BackgroundTransparency = 1
WhitelistLabel.Text = "Whitelisted: 0"
WhitelistLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
WhitelistLabel.Font = Enum.Font.GothamBold
WhitelistLabel.TextSize = 11
WhitelistLabel.Parent = PlayersExtraSection

local function updateWhitelistLabel()
    WhitelistLabel.Text = "Whitelisted: " .. #whitelist
end

refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

Window:Category("Troll")

local TrollPage = Window:Page({Name = "Troll", Icon = "138827881557940"})
local TrollSection = TrollPage:Section({Name = "Troll Features", Side = 1})

TrollSection:Slider({
    Name = "Fling Power",
    Flag = "FlingPower",
    Min = 100000,
    Max = 1000000,
    Default = 500000,
    Suffix = "",
    Callback = function(Value)
        flingPower = Value
    end
})

TrollSection:Slider({
    Name = "Orbit Radius",
    Flag = "OrbitRadius",
    Min = 3,
    Max = 30,
    Default = 10,
    Suffix = "",
    Callback = function(Value)
        orbitRadius = Value
    end
})

TrollSection:Slider({
    Name = "Orbit Speed",
    Flag = "OrbitSpeed",
    Min = 1,
    Max = 20,
    Default = 6,
    Suffix = "",
    Callback = function(Value)
        orbitSpeed = Value
    end
})

TrollSection:Button({
    Name = "One-Time Fling",
    Callback = function()
        flingTargetOnce(getTrollTarget())
    end
})

TrollSection:Toggle({
    Name = "Constant Fling",
    Flag = "ConstantFling",
    Default = false,
    Callback = function(Value)
        constantFling = Value
        if Value then startConstantFling() else clearFlingForce() end
    end
})

TrollSection:Button({
    Name = "Next Target",
    Callback = function()
        cycleTrollTarget()
    end
})

TrollSection:Toggle({
    Name = "Orbit Target",
    Flag = "OrbitTarget",
    Default = false,
    Callback = function(Value)
        orbitTarget = Value
        if Value then startOrbit() else clearOrbit() end
    end
})

TrollSection:Toggle({
    Name = "Head Sit",
    Flag = "HeadSit",
    Default = false,
    Callback = function(Value)
        headSit = Value
    end
})

TrollSection:Toggle({
    Name = "Spin Troll",
    Flag = "SpinTroll",
    Default = false,
    Callback = function(Value)
        spinTroll = Value
        if Value then startSpinTroll() else clearSpinTroll() end
    end
})

TrollSection:Toggle({
    Name = "Invisible Character",
    Flag = "Invisible",
    Default = false,
    Callback = function(Value)
        invisible = Value
        updateInvisibleState()
    end
})

Window:Category("Misc")

local MiscPage = Window:Page({Name = "Misc", Icon = "138827881557940"})
local MiscSection = MiscPage:Section({Name = "Misc", Side = 1})

MiscSection:Toggle({
    Name = "FPS Counter",
    Flag = "FpsCounter",
    Default = true,
    Callback = function(Value)
        fpsCounter = Value
    end
})

MiscSection:Toggle({
    Name = "Anti AFK",
    Flag = "AntiAFK",
    Default = false,
    Callback = function(Value)
        antiAFK = Value
    end
})

MiscSection:Toggle({
    Name = "Fullbright",
    Flag = "Fullbright",
    Default = false,
    Callback = function(Value)
        fullbright = Value
        updateLightingState()
    end
})

MiscSection:Toggle({
    Name = "No Fog",
    Flag = "NoFog",
    Default = false,
    Callback = function(Value)
        noFog = Value
        updateLightingState()
    end
})

local KeybindSection = MiscPage:Section({Name = "Keybinds", Side = 2})

KeybindSection:Keybind({
    Name = "Toggle Aimbot",
    Flag = "AimToggle",
    Default = false,
    Mode = "Toggle",
    Callback = function(Value)
        Settings.Binds.AimToggle = Value
    end
})

KeybindSection:Keybind({
    Name = "Toggle Noclip",
    Flag = "NoclipToggle",
    Default = false,
    Mode = "Toggle",
    Callback = function(Value)
        Settings.Binds.NoclipToggle = Value
    end
})

KeybindSection:Keybind({
    Name = "Toggle Fly",
    Flag = "FlyToggle",
    Default = false,
    Mode = "Toggle",
    Callback = function(Value)
        Settings.Binds.FlyToggle = Value
    end
})

KeybindSection:Keybind({
    Name = "Toggle ESP",
    Flag = "EspToggle",
    Default = false,
    Mode = "Toggle",
    Callback = function(Value)
        Settings.Binds.EspToggle = Value
    end
})

KeybindSection:Keybind({
    Name = "Panic Key",
    Flag = "PanicKey",
    Default = false,
    Mode = "Toggle",
    Callback = function(Value)
        Settings.Binds.PanicKey = Value
    end
})

KeybindSection:Keybind({
    Name = "Toggle Triggerbot",
    Flag = "TriggerbotToggle",
    Default = false,
    Mode = "Toggle",
    Callback = function(Value)
        Settings.Binds.TriggerbotToggle = Value
    end
})

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Settings.Misc.MenuKeybind then
        Library:Toggle()
    end
    if input == Settings.Aim.Keybind then
        isAming = true
        if lockMode == "Toggle" then
            toggleActive = not toggleActive
        end
    end
    if input.KeyCode == Settings.Binds.PanicKey then
        aimbotOn = false
        espEnabled = false
        noclipOn = false
        flyOn = false
        triggerbotOn = false
        autoShootOn = false
        constantFling = false
        orbitTarget = false
        spinTroll = false
        clearFlingForce()
        clearOrbit()
        clearSpinTroll()
    end
    if input.KeyCode == Settings.Binds.AimToggle then
        aimbotOn = not aimbotOn
    end
    if input.KeyCode == Settings.Binds.NoclipToggle then
        noclipOn = not noclipOn
    end
    if input.KeyCode == Settings.Binds.FlyToggle then
        flyOn = not flyOn
    end
    if input.KeyCode == Settings.Binds.EspToggle then
        espEnabled = not espEnabled
    end
    if input.KeyCode == Settings.Binds.TriggerbotToggle then
        triggerbotOn = not triggerbotOn
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == Settings.Aim.Keybind then
        isAming = false
        if lockMode == "Hold" then
            currentTargetPlayer = nil
        end
    end
end)

Window:Category("Settings")
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)
Window:Init()
