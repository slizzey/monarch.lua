local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/slizzey/monarch.lua/main/neverlose_ui.lua"))()

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera

local function ensureCamera()
    local cam = Workspace.CurrentCamera
    if cam then
        Camera = cam
    end
    return Camera
end

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

local hasFileSystem = (writefile and readfile and isfile)
local LOGO_FILE_NAME = "Monarch_Logo.png"

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
        ChamsEnabled = false,
        TeamVisible = false,
        Color = Color3.fromRGB(100, 60, 180),
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
        MenuKeybind = Enum.KeyCode.RightShift,
        LogoAssetId = "",
        LogoFileName = "Monarch_Logo.png",
        UnlockMouseOnMenu = true,
        TopMostUI = true,
        StreamProof = false,
        Whitelist = {},
        HitNotifyLock = false,
        HitNotifyShot = false,
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
}

local defaultGravity = Workspace.Gravity
local AimState = {
    isAming = false,
    isShooting = false,
    currentTargetPlayer = nil,
    aimbotOn = false,
    fov = 40,
    smoothness = 0.25,
    wallCheck = true,
    teamCheck = true,
    targetPart = "Head",
    prediction = 0,
    silentAim = false,
    lockMode = "Hold",
    toggleActive = false,
    triggerbotOn = false,
    triggerbotRadius = 20,
    triggerbotDelay = 0.05,
    triggerbotWallCheck = true,
    crosshairEnabled = false,
    crosshairSize = 8,
    crosshairColor = Color3.fromRGB(255, 255, 255),
    showFOV = true,
    fovColor = Color3.fromRGB(100, 60, 180),
    showLockHud = true,
    autoShootOn = false,
    autoShootMode = "On Lock",
    autoShootInterval = 0.1,
    velocityResolver = false,
    resolverStrength = 1,
}

local GUI = {
    LockStatusGui = nil,
    lockStatusLabel = nil,
    BindToastGui = nil,
    BindToastFrame = nil,
    BindToastLabel = nil,
    bindToastToken = 0,
    menuOpen = false,
    KeybindCaptureActive = false,
    savedMouseState = nil,
    mouseUnlockConnection = nil,
    spectating = false,
    spectateTarget = nil,
    originalCameraSubject = nil,
    originalCameraType = nil,
}
local espSkeletonLines = {}
local SKELETON_BONES = {
    {"Head", "UpperTorso"}, {"Head", "Torso"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}
local MouseDriver = {name = "NONE", moveRel = nil, moveAbs = nil}
local MouseState = {
    globalsScanned = false,
    lastMouseMove = Vector2.zero,
    apiName = "unknown",
    lastRefreshAt = 0,
}

local MovementState = {
    shieldOn = false,
    forceField = nil,
    currentSpeed = 16,
    speedEnabled = false,
    infJumpOn = false,
    noclipOn = false,
    flyOn = false,
    bodyVelocity = nil,
    bodyGyro = nil,
    flySpeed = 50,
    jumpEnabled = false,
    jumpValue = 50,
    gravityEnabled = false,
    gravityValue = 196.2,
}

local ESPState = {
    enabled = false,
    drawings = {},
    highlights = {},
    showNames = true,
    showDistance = true,
    showBoxes = true,
    showTracers = true,
    showSkeleton = false,
    showTeam = false,
    espColor = Color3.fromRGB(100, 60, 180),
    chamsEnabled = false,
    chamsFillColor = Color3.fromRGB(100, 60, 180),
    chamsOutlineColor = Color3.fromRGB(100, 60, 180),
    chamsFillTransparency = 0.5,
    chamsOutlineTransparency = 0,
}

local MiscState = {
    fullbright = false,
    noFog = false,
    antiAFK = false,
    fpsCounter = true,
}

local TrollState = {
    whitelist = {},
    trollTargetIndex = 1,
    trollTarget = nil,
    flingPower = 500000,
    orbitSpeed = 6,
    orbitRadius = 10,
    constantFling = false,
    orbitTarget = false,
    headSit = false,
    spinTroll = false,
    invisible = false,
}

local flingConnection = nil
local orbitConnection = nil
local spinConnection = nil
local headSitConnection = nil
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
FOVring.Color = AimState.fovColor
FOVring.Filled = false
FOVring.Radius = AimState.fov
FOVring.Position = Camera.ViewportSize / 2
FOVring.Transparency = 0.5

local crosshairDrawings = {}
for i = 1, 4 do
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = AimState.crosshairColor
    line.Thickness = 1
    table.insert(crosshairDrawings, line)
end


local function initLockHud()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 20)
    if not playerGui then return false end
    local old = playerGui:FindFirstChild("Monarch_LockStatus")
    if old then old:Destroy() end
    GUI.LockStatusGui = Instance.new("ScreenGui")
    GUI.LockStatusGui.Name = "Monarch_LockStatus"
    GUI.LockStatusGui.ResetOnSpawn = false
    GUI.LockStatusGui.IgnoreGuiInset = true
    GUI.LockStatusGui.DisplayOrder = 10000000
    GUI.LockStatusGui.Parent = playerGui
    GUI.lockStatusLabel = Instance.new("TextLabel")
    GUI.lockStatusLabel.Size = UDim2.new(0, 200, 0, 30)
    GUI.lockStatusLabel.Position = UDim2.new(0.5, -100, 0, 10)
    GUI.lockStatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    GUI.lockStatusLabel.BackgroundTransparency = 0.2
    GUI.lockStatusLabel.BorderSizePixel = 0
    GUI.lockStatusLabel.TextColor3 = Color3.fromRGB(100, 60, 180)
    GUI.lockStatusLabel.Font = Enum.Font.GothamBold
    GUI.lockStatusLabel.TextSize = 14
    GUI.lockStatusLabel.Text = ""
    GUI.lockStatusLabel.Visible = false
    GUI.lockStatusLabel.Parent = GUI.LockStatusGui
    Instance.new("UICorner", GUI.lockStatusLabel).CornerRadius = UDim.new(0, 6)
    return true
end

local function setLockHud(text, visible)
    if not AimState.showLockHud then
        if GUI.LockStatusGui then GUI.LockStatusGui.Enabled = false end
        return
    end
    if not GUI.lockStatusLabel then initLockHud() end
    if GUI.LockStatusGui then GUI.LockStatusGui.Enabled = true end
    if GUI.lockStatusLabel then
        GUI.lockStatusLabel.Text = text or ""
        GUI.lockStatusLabel.Visible = visible ~= false
    end
end

local function notify(title, text, duration)
    duration = duration or 4
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = duration,
        })
    end)
end

local function initBindToast()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 20)
    if not playerGui then return false end
    local old = playerGui:FindFirstChild("Monarch_BindToast")
    if old then old:Destroy() end
    GUI.BindToastGui = Instance.new("ScreenGui")
    GUI.BindToastGui.Name = "Monarch_BindToast"
    GUI.BindToastGui.ResetOnSpawn = false
    GUI.BindToastGui.IgnoreGuiInset = true
    GUI.BindToastGui.DisplayOrder = 10000001
    GUI.BindToastGui.Parent = playerGui
    GUI.BindToastFrame = Instance.new("Frame")
    GUI.BindToastFrame.Name = "Toast"
    GUI.BindToastFrame.Size = UDim2.new(0, 300, 0, 46)
    GUI.BindToastFrame.Position = UDim2.new(0.5, -150, 0, 52)
    GUI.BindToastFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    GUI.BindToastFrame.BackgroundTransparency = 0.05
    GUI.BindToastFrame.BorderSizePixel = 0
    GUI.BindToastFrame.Visible = false
    GUI.BindToastFrame.Parent = GUI.BindToastGui
    Instance.new("UICorner", GUI.BindToastFrame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 60, 180)
    stroke.Thickness = 1.5
    stroke.Parent = GUI.BindToastFrame
    GUI.BindToastLabel = Instance.new("TextLabel")
    GUI.BindToastLabel.Size = UDim2.new(1, -16, 1, 0)
    GUI.BindToastLabel.Position = UDim2.new(0, 8, 0, 0)
    GUI.BindToastLabel.BackgroundTransparency = 1
    GUI.BindToastLabel.Font = Enum.Font.GothamBold
    GUI.BindToastLabel.TextSize = 16
    GUI.BindToastLabel.Text = ""
    GUI.BindToastLabel.Parent = GUI.BindToastFrame
    return true
end

local function showBindToggleToast(featureName, enabled)
    pcall(function()
        if not GUI.BindToastFrame or not GUI.BindToastLabel or not GUI.BindToastGui.Parent then
            if not initBindToast() then
                notify("Monarch", featureName .. ": " .. (enabled and "ENABLED" or "DISABLED"), 3)
                return
            end
        end
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui and GUI.BindToastGui.Parent ~= playerGui then
            GUI.BindToastGui.Parent = playerGui
        end
        GUI.BindToastGui.Enabled = true
        GUI.bindToastToken = GUI.bindToastToken + 1
        local token = GUI.bindToastToken
        local stateText = enabled and "ENABLED" or "DISABLED"
        local accent = enabled and Color3.fromRGB(70, 220, 110) or Color3.fromRGB(220, 70, 70)
        GUI.BindToastLabel.Text = featureName .. ": " .. stateText
        GUI.BindToastLabel.TextColor3 = accent
        GUI.BindToastFrame.Visible = true
        local stroke = GUI.BindToastFrame:FindFirstChild("UIStroke")
        if stroke then stroke.Color = accent end
        task.delay(2, function()
            if GUI.bindToastToken ~= token or not GUI.BindToastFrame then return end
            GUI.BindToastFrame.Visible = false
        end)
    end)
end

task.spawn(initBindToast)

local function updateCrosshair()
    local center = Camera.ViewportSize / 2
    local size = AimState.crosshairSize
    for i, line in ipairs(crosshairDrawings) do
        line.Visible = AimState.crosshairEnabled
        line.Color = AimState.crosshairColor
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
    FOVring.Position = Camera.ViewportSize / 2
    FOVring.Radius = AimState.fov
    FOVring.Color = AimState.fovColor
    FOVring.Visible = AimState.aimbotOn and AimState.showFOV
    updateCrosshair()
end

local function isWhitelisted(plr)
    if type(Settings.Misc.Whitelist) ~= "table" then return false end
    for _, uid in ipairs(Settings.Misc.Whitelist) do
        if tonumber(uid) == plr.UserId then return true end
    end
    return false
end

local AIM_PART_FALLBACKS = {
    Head = {"Head", "HeadHB", "HitboxHead", "UpperTorso", "Torso", "HumanoidRootPart"},
    HumanoidRootPart = {"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Root"},
    UpperTorso = {"UpperTorso", "Torso", "Chest", "HumanoidRootPart", "Head"},
}

local function getTargetPart(character)
    if not character then return nil end
    local preferred = AimState.targetPart
    local fallbacks = AIM_PART_FALLBACKS[preferred] or {preferred}
    for _, name in ipairs(fallbacks) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    return character:FindFirstChildWhichIsA("BasePart", true)
end

local function lookupGlobalFunction(...)
    for i = 1, select("#", ...) do
        local name = select(i, ...)
        local fn = rawget(_G, name)
        if type(fn) == "function" then return fn, name end
    end
    if getgenv then
        local ok, env = pcall(getgenv)
        if ok and type(env) == "table" then
            for i = 1, select("#", ...) do
                local name = select(i, ...)
                if type(env[name]) == "function" then return env[name], "getgenv." .. name end
            end
        end
    end
    if syn then
        for i = 1, select("#", ...) do
            local name = select(i, ...)
            if type(syn[name]) == "function" then return syn[name], "syn." .. name end
        end
    end
    return nil, nil
end

local function lookupInputMouseMove()
    local tables = {}
    if type(Input) == "table" then table.insert(tables, {tbl = Input, prefix = "Input"}) end
    if type(input) == "table" then table.insert(tables, {tbl = input, prefix = "input"}) end
    if getgenv then
        local ok, env = pcall(getgenv)
        if ok and type(env) == "table" then
            if type(env.Input) == "table" then table.insert(tables, {tbl = env.Input, prefix = "getgenv.Input"}) end
            if type(env.input) == "table" then table.insert(tables, {tbl = env.input, prefix = "getgenv.input"}) end
        end
    end
    for _, entry in ipairs(tables) do
        local moveFn = entry.tbl.MouseMove or entry.tbl.move or entry.tbl.Move
        if type(moveFn) == "function" then
            local key = entry.tbl.MouseMove and "MouseMove" or (entry.tbl.move and "move" or "Move")
            return moveFn, entry.prefix .. "." .. key
        end
    end
    return nil, nil
end

local function refreshMouseDriver()
    if MouseState.globalsScanned then return end
    MouseState.globalsScanned = true
    MouseDriver.name = "NONE"
    MouseDriver.moveRel = nil
    MouseDriver.moveAbs = nil
    pcall(function()
        if type(mousemoverel) == "function" and not MouseDriver.moveRel then
            MouseDriver.moveRel = mousemoverel
            MouseDriver.name = "mousemoverel"
        end
        if type(mousemoveabs) == "function" and not MouseDriver.moveAbs then
            MouseDriver.moveAbs = mousemoveabs
        end
    end)
    local relFn, relName = lookupGlobalFunction("mousemoverel", "mouse_move_relative", "MouseMoveRelative", "MouseMoveRel", "mouse_move_rel", "mousereco")
    if relFn then
        MouseDriver.moveRel = relFn
        MouseDriver.name = relName
    end
    if not MouseDriver.moveRel then
        local inputMove, inputMoveName = lookupInputMouseMove()
        if inputMove then
            MouseDriver.moveRel = inputMove
            MouseDriver.name = inputMoveName
        end
    end
    local absFn, absName = lookupGlobalFunction("mousemoveabs", "MouseMoveAbs", "mouse_move_absolute")
    if absFn then
        MouseDriver.moveAbs = absFn
        if MouseDriver.name == "NONE" then MouseDriver.name = absName end
    end
    if input and type(input.move) == "function" then
        MouseDriver.moveRel = MouseDriver.moveRel or input.move
        if MouseDriver.name == "NONE" then MouseDriver.name = "input.move" end
    end
    if not MouseDriver.moveRel and VirtualInputManager then
        MouseDriver.name = "VIM"
        MouseDriver.moveRel = function(ix, iy)
            local pos = UserInputService:GetMouseLocation()
            pcall(function() VirtualInputManager:SendMouseMoveEvent(pos.X + ix, pos.Y + iy, game) end)
        end
        MouseDriver.moveAbs = function(x, y)
            pcall(function() VirtualInputManager:SendMouseMoveEvent(x, y, game) end)
        end
    end
    MouseState.apiName = MouseDriver.name
end

refreshMouseDriver()

local function mouseMoveRel(dx, dy)
    if math.abs(dx) < 0.5 and math.abs(dy) < 0.5 then return end
    local ix = math.floor(dx + 0.5)
    local iy = math.floor(dy + 0.5)
    if ix == 0 and math.abs(dx) >= 1 then ix = dx > 0 and 1 or -1 end
    if iy == 0 and math.abs(dy) >= 1 then iy = dy > 0 and 1 or -1 end
    if ix == 0 and iy == 0 then return end
    MouseState.lastMouseMove = Vector2.new(ix, iy)
    if tick() - MouseState.lastRefreshAt > 3 then
        refreshMouseDriver()
        MouseState.lastRefreshAt = tick()
    end
    if MouseDriver.moveRel then pcall(MouseDriver.moveRel, ix, iy) end
end

local function isOnTeam(plr)
    if not AimState.teamCheck then return false end
    local localTeam = LocalPlayer.Team
    local targetTeam = plr.Team
    return localTeam and targetTeam and localTeam == targetTeam
end

local function isWallBetween(part1, part2)
    if not AimState.wallCheck then return false end
    local ray = Ray.new(part1.Position, (part2.Position - part1.Position).Unit * (part1.Position - part2.Position).Magnitude)
    local hit, _ = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
    return hit ~= nil
end

local function getClosestPlayerInFOV()
    local closest = nil
    local last = math.huge
    local center = Camera.ViewportSize / 2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if isWhitelisted(plr) then continue end
            if isOnTeam(plr) then continue end
            local part = getTargetPart(plr.Character)
            if part then
                if AimState.wallCheck and isWallBetween(Camera, part) then continue end
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if onScreen and dist < last and dist < AimState.fov then
                    last = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

local function getPredictedPosition(target)
    if AimState.prediction == 0 then return target.Position end
    local velocity = target.Velocity
    return target.Position + (velocity * AimState.prediction)
end

local function lookAt(targetPos)
    local lookVector = (targetPos - Camera.CFrame.Position).Unit
    local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
    if AimState.smoothness > 0 then
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, AimState.smoothness)
    else
        Camera.CFrame = newCFrame
    end
end

local AIM_MAX_STEP = 14
local AIM_PULL_FRACTION = 0.68
local lastAimErrX = 0
local lastAimErrY = 0

local function aimAtScreen(screenX, screenY)
    local viewportSize = Camera.ViewportSize
    local centerX = viewportSize.X / 2
    local centerY = viewportSize.Y / 2
    
    local errX = screenX - centerX
    local errY = screenY - centerY
    
    local stepX = math.clamp(errX, -AIM_MAX_STEP, AIM_MAX_STEP)
    local stepY = math.clamp(errY, -AIM_MAX_STEP, AIM_MAX_STEP)
    
    stepX = stepX * AIM_PULL_FRACTION
    stepY = stepY * AIM_PULL_FRACTION
    
    if math.abs(stepX) < 0.5 and math.abs(stepY) < 0.5 then
        return false
    end
    
    mouseMoveRel(stepX, stepY)
    return true
end

local function aimAtTarget(target)
    if not target or not target.Character then return end
    local part = getTargetPart(target.Character)
    if part then
        local predictedPos = getPredictedPosition(part)
        local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
        if onScreen then
            aimAtScreen(screenPos.X, screenPos.Y)
            if AimState.showLockHud then
                setLockHud("LOCKED: " .. target.Name, true)
            end
        end
    end
end

local lastTriggerbotAt = 0

local function checkTriggerbot()
    if not AimState.triggerbotOn then return end
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if isWhitelisted(plr) then continue end
            if isOnTeam(plr) then continue end
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < AimState.triggerbotRadius then
                        if AimState.triggerbotWallCheck and isWallBetween(Camera, head) then continue end
                        if tick() - lastTriggerbotAt >= AimState.triggerbotDelay then
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
    if not AimState.autoShootOn then return end
    if AimState.autoShootMode == "On Lock" and AimState.currentTargetPlayer then
        if tick() - lastAutoShootAt >= AimState.autoShootInterval then
            lastAutoShootAt = tick()
            mouse1click()
        end
    end
end

local function cycleTrollTarget()
    local targets = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            table.insert(targets, plr)
        end
    end
    if #targets == 0 then
        TrollState.trollTarget = nil
        return
    end
    TrollState.trollTargetIndex = TrollState.trollTargetIndex % #targets + 1
    TrollState.trollTarget = targets[TrollState.trollTargetIndex]
end

local function getTrollTarget()
    if not TrollState.trollTarget or not TrollState.trollTarget.Character then
        cycleTrollTarget()
    end
    return TrollState.trollTarget
end

local function clearFlingForce()
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
end

local function flingTargetOnce(target)
    if not target or not target.Character then return end
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if localRoot and targetRoot then
        localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1)
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, TrollState.flingPower, 0)
        bv.Parent = localRoot
        game:GetService("Debris"):AddItem(bv, 0.1)
    end
end

local function startConstantFling()
    clearFlingForce()
    TrollState.constantFling = true
    flingConnection = RunService.Heartbeat:Connect(function()
        if not TrollState.constantFling then return end
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
    TrollState.orbitTarget = true
    local startTime = tick()
    orbitConnection = RunService.Heartbeat:Connect(function()
        if not TrollState.orbitTarget then return end
        local target = getTrollTarget()
        if not target or not target.Character then return end
        local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if localRoot and targetRoot then
            local angle = (tick() - startTime) * TrollState.orbitSpeed
            local offset = Vector3.new(math.cos(angle) * TrollState.orbitRadius, 0, math.sin(angle) * TrollState.orbitRadius)
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
    TrollState.spinTroll = true
    spinConnection = RunService.Heartbeat:Connect(function()
        if not TrollState.spinTroll then return end
        local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if localRoot then
            localRoot.CFrame = localRoot.CFrame * CFrame.Angles(0, math.rad(15), 0)
        end
    end)
end

local function clearHeadSit()
    if headSitConnection then
        headSitConnection:Disconnect()
        headSitConnection = nil
    end
end

local function startHeadSit()
    clearHeadSit()
    TrollState.headSit = true
    headSitConnection = RunService.Heartbeat:Connect(function()
        if not TrollState.headSit then return end
        if not TrollState.trollTarget or not TrollState.trollTarget.Character then return end
        local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHead = TrollState.trollTarget.Character:FindFirstChild("Head")
        if localRoot and targetHead then
            localRoot.CFrame = targetHead.CFrame * CFrame.new(0, 0, 0)
        end
    end)
end

local function updateInvisibleState()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = TrollState.invisible and 1 or 0
        end
    end
end

local function updateLightingState()
    if MiscState.fullbright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.GlobalShadows = true
    end
    if MiscState.noFog then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
    end
end

local function fixCharacterAppearance()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Ensure proper character quality
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
    
    -- Fix lighting on character parts
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.SmoothPlastic
            part.Reflectance = 0
        end
    end
end

local function createESP(plr)
    if plr == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = ESPState.espColor
    box.Transparency = 0.8
    box.Visible = false
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = ESPState.espColor
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
    ESPState.drawings[plr] = {
        box = box,
        tracer = tracer,
        name = nameText,
        dist = distText
    }
    -- Create charm (Highlight) immediately if enabled
    if ESPState.chamsEnabled and plr.Character then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Monarch_Charm"
        highlight.FillColor = ESPState.chamsFillColor
        highlight.OutlineColor = ESPState.chamsOutlineColor
        highlight.FillTransparency = ESPState.chamsFillTransparency
        highlight.OutlineTransparency = ESPState.chamsOutlineTransparency
        highlight.Enabled = true
        highlight.Adornee = plr.Character
        highlight.Parent = plr.Character
        ESPState.highlights[plr] = highlight
    end
    if ESPState.showSkeleton then
        espSkeletonLines[plr] = {}
        for _, bonePair in ipairs(SKELETON_BONES) do
            local line = Drawing.new("Line")
            line.Thickness = 1
            line.Color = ESPState.espColor
            line.Transparency = 0.6
            line.Visible = false
            table.insert(espSkeletonLines[plr], line)
        end
    end
end

local function removeESP(plr)
    if ESPState.drawings[plr] then
        for _, v in pairs(ESPState.drawings[plr]) do
            v:Remove()
        end
        ESPState.drawings[plr] = nil
    end
    if ESPState.highlights[plr] then
        ESPState.highlights[plr]:Destroy()
        ESPState.highlights[plr] = nil
    end
    if espSkeletonLines[plr] then
        for _, line in ipairs(espSkeletonLines[plr]) do
            line:Remove()
        end
        espSkeletonLines[plr] = nil
    end
end

local function refreshChams()
    for plr, highlight in pairs(ESPState.highlights) do
        if highlight and highlight.Parent then
            highlight.Enabled = ESPState.chamsEnabled and ESPState.enabled
            highlight.FillColor = ESPState.chamsFillColor
            highlight.OutlineColor = ESPState.chamsOutlineColor
            highlight.FillTransparency = ESPState.chamsFillTransparency
            highlight.OutlineTransparency = ESPState.chamsOutlineTransparency
        end
    end
    -- Re-create charms for players who don't have them but should
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and ESPState.chamsEnabled and ESPState.enabled then
            if not ESPState.highlights[plr] or not ESPState.highlights[plr].Parent then
                if plr.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "Monarch_Charm"
                    highlight.FillColor = ESPState.chamsFillColor
                    highlight.OutlineColor = ESPState.chamsOutlineColor
                    highlight.FillTransparency = ESPState.chamsFillTransparency
                    highlight.OutlineTransparency = ESPState.chamsOutlineTransparency
                    highlight.Enabled = true
                    highlight.Adornee = plr.Character
                    highlight.Parent = plr.Character
                    ESPState.highlights[plr] = highlight
                end
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
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        if MovementState.speedEnabled then
            hum.WalkSpeed = MovementState.currentSpeed
        else
            hum.WalkSpeed = 16
        end
        if MovementState.jumpEnabled then
            hum.JumpPower = MovementState.jumpValue
        else
            hum.JumpPower = 50
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not MovementState.infJumpOn then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if hum and root and hum.Health > 0 then
        root.Velocity = Vector3.new(root.Velocity.X, MovementState.jumpValue, root.Velocity.Z)
    end
end)

RunService.Stepped:Connect(function()
    if not MovementState.noclipOn then return end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Simple flight using BodyVelocity (working version)
RunService.RenderStepped:Connect(function(dt)
    if not MovementState.flyOn then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not MovementState.bodyVelocity then return end

    -- Calculate target velocity based on input
    local targetVel = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then targetVel += Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then targetVel -= Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then targetVel -= Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then targetVel += Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then targetVel += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then targetVel -= Vector3.new(0, 1, 0) end

    -- Flatten movement direction to horizontal plane for WASD
    local horizontalMove = Vector3.new(targetVel.X, 0, targetVel.Z)
    if horizontalMove.Magnitude > 0 then
        horizontalMove = horizontalMove.Unit * MovementState.flySpeed
    end
    targetVel = Vector3.new(horizontalMove.X, targetVel.Y * MovementState.flySpeed, horizontalMove.Z)

    -- Apply to BodyVelocity
    MovementState.bodyVelocity.Velocity = targetVel

    -- Update BodyGyro to face camera direction
    if MovementState.bodyGyro then
        MovementState.bodyGyro.CFrame = CFrame.new(root.Position) * Camera.CFrame.Rotation
    end
end)

RunService.RenderStepped:Connect(function()
    updateDrawings()
    if AimState.aimbotOn and AimState.isAming then
        if AimState.lockMode == "Hold" or AimState.toggleActive then
            AimState.currentTargetPlayer = getClosestPlayerInFOV()
            if AimState.currentTargetPlayer then
                aimAtTarget(AimState.currentTargetPlayer)
            else
                setLockHud("", false)
            end
        end
    else
        setLockHud("", false)
        AimState.currentTargetPlayer = nil
    end
    if AimState.triggerbotOn then checkTriggerbot() end
    if AimState.autoShootOn then autoShoot() end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    local hum = newChar:WaitForChild("Humanoid")
    if MovementState.speedEnabled then
        hum.WalkSpeed = MovementState.currentSpeed
    else
        hum.WalkSpeed = 16
    end
    if MovementState.jumpEnabled then
        hum.JumpPower = MovementState.jumpValue
    else
        hum.JumpPower = 50
    end
    if MovementState.shieldOn then
        MovementState.forceField = Instance.new("ForceField")
        MovementState.forceField.Parent = newChar
    end
    if MovementState.flyOn then
        MovementState.flyOn = false
        if MovementState.bodyVelocity then MovementState.bodyVelocity:Destroy() MovementState.bodyVelocity = nil end
        if MovementState.bodyGyro then MovementState.bodyGyro:Destroy() MovementState.bodyGyro = nil end
    end
    if TrollState.invisible then updateInvisibleState() end
    fixCharacterAppearance()
end)

RunService.RenderStepped:Connect(function()
    if not ESPState.enabled then
        for _, data in pairs(ESPState.drawings) do
            data.box.Visible = false
            data.tracer.Visible = false
            data.name.Visible = false
            data.dist.Visible = false
        end
        for _, highlight in pairs(ESPState.highlights) do
            highlight.Enabled = false
        end
        for _, lines in pairs(espSkeletonLines) do
            for _, line in ipairs(lines) do
                line.Visible = false
            end
        end
        return
    end
    for plr, data in pairs(ESPState.drawings) do
        if isWhitelisted(plr) and not ESPState.showTeam then
            data.box.Visible = false
            data.tracer.Visible = false
            data.name.Visible = false
            data.dist.Visible = false
            if ESPState.highlights[plr] then ESPState.highlights[plr].Enabled = false end
            if espSkeletonLines[plr] then
                for _, line in ipairs(espSkeletonLines[plr]) do
                    line.Visible = false
                end
            end
            continue
        end
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
            local hrp = plr.Character.HumanoidRootPart
            local head = plr.Character.Head
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))
                if onScreen then
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.45
                    local color = ESPState.espColor
                    data.box.Color = color
                    data.tracer.Color = color
                    if ESPState.showBoxes then
                        data.box.Size = Vector2.new(width, height)
                        data.box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                        data.box.Visible = true
                    else
                        data.box.Visible = false
                    end
                    if ESPState.showTracers then
                        data.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        data.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        data.tracer.Visible = true
                    else
                        data.tracer.Visible = false
                    end
                    if ESPState.showNames then
                        data.name.Text = plr.Name
                        data.name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 18)
                        data.name.Visible = true
                    else
                        data.name.Visible = false
                    end
                    if ESPState.showDistance then
                        local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and
                            (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude or 0
                        data.dist.Text = math.floor(distance) .. " studs"
                        data.dist.Position = Vector2.new(rootPos.X, rootPos.Y + height/2 + 2)
                        data.dist.Visible = true
                    else
                        data.dist.Visible = false
                    end
                    if ESPState.showSkeleton and espSkeletonLines[plr] then
                        for i, bonePair in ipairs(SKELETON_BONES) do
                            local part1 = plr.Character:FindFirstChild(bonePair[1])
                            local part2 = plr.Character:FindFirstChild(bonePair[2])
                            local line = espSkeletonLines[plr][i]
                            if part1 and part2 and line then
                                local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
                                local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
                                if onScreen1 and onScreen2 then
                                    line.From = Vector2.new(pos1.X, pos1.Y)
                                    line.To = Vector2.new(pos2.X, pos2.Y)
                                    line.Color = color
                                    line.Visible = true
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        end
                    elseif espSkeletonLines[plr] then
                        for _, line in ipairs(espSkeletonLines[plr]) do
                            line.Visible = false
                        end
                    end
                else
                    data.box.Visible = false
                    data.tracer.Visible = false
                    data.name.Visible = false
                    data.dist.Visible = false
                    if espSkeletonLines[plr] then
                        for _, line in ipairs(espSkeletonLines[plr]) do
                            line.Visible = false
                        end
                    end
                end
            else
                data.box.Visible = false
                data.tracer.Visible = false
                data.name.Visible = false
                data.dist.Visible = false
                if espSkeletonLines[plr] then
                    for _, line in ipairs(espSkeletonLines[plr]) do
                        line.Visible = false
                    end
                end
            end
        else
            data.box.Visible = false
            data.tracer.Visible = false
            data.name.Visible = false
            data.dist.Visible = false
            if espSkeletonLines[plr] then
                for _, line in ipairs(espSkeletonLines[plr]) do
                    line.Visible = false
                end
            end
        end
    end
    refreshCharms()
end)

LocalPlayer.Idled:Connect(function()
    if MiscState.antiAFK then
        VirtualUser:CaptureFocus()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

local function startSpectate(target)
    if GUI.spectating then return end
    if not target or not target.Character then return end
    GUI.spectating = true
    GUI.spectateTarget = target
    GUI.originalCameraSubject = Camera.CameraSubject
    GUI.originalCameraType = Camera.CameraType
    Camera.CameraType = Enum.CameraType.Fixed
    Camera.CameraSubject = target.Character:FindFirstChild("Humanoid")
    notify("Monarch", "Spectating: " .. target.Name, 3)
end

local function stopSpectate()
    if not GUI.spectating then return end
    GUI.spectating = false
    GUI.spectateTarget = nil
    if GUI.originalCameraSubject then
        Camera.CameraSubject = GUI.originalCameraSubject
    end
    if GUI.originalCameraType then
        Camera.CameraType = GUI.originalCameraType
    end
    notify("Monarch", "Stopped spectating", 2)
end

local function voteKickPlayer(target)
    if not target then return end
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService then
            local channel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")
            if channel then
                channel:SendAsync("/vk " .. target.Name)
            end
        else
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[Monarch] Vote kick: /vk " .. target.Name,
            Color = Color3.fromRGB(100, 60, 180),
        })
        end
    end)
end

local function respawnCharacter()
    local char = LocalPlayer.Character
    if char then
        char:BreakJoints()
    end
end


local function rejoinGame()
    TeleportService:Teleport(game.PlaceId)
end

local AimPage = Window:Page({Name = "Aim"})
local AimMainSection = AimPage:Section({Name = "Main", Side = 1})

AimMainSection:Toggle({
    Name = "Enable Aimbot",
    Flag = "AimbotEnabled",
    Default = false,
    Callback = function(Value)
        AimState.aimbotOn = Value
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
        AimState.smoothness = Value
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
        AimState.fov = Value
    end
})

AimMainSection:Toggle({
    Name = "Show FOV",
    Flag = "ShowFOV",
    Default = true,
    Callback = function(Value)
        AimState.showFOV = Value
    end
})

AimMainSection:Toggle({
    Name = "Wall Check",
    Flag = "WallCheck",
    Default = true,
    Callback = function(Value)
        AimState.wallCheck = Value
    end
})

AimMainSection:Toggle({
    Name = "Team Check",
    Flag = "TeamCheck",
    Default = true,
    Callback = function(Value)
        AimState.teamCheck = Value
    end
})

AimMainSection:Dropdown({
    Name = "Target Part",
    Flag = "TargetPart",
    Default = {"Head"},
    Items = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Multi = false,
    Callback = function(Value)
        AimState.targetPart = Value[1]
    end
})

AimMainSection:Dropdown({
    Name = "Lock Mode",
    Flag = "LockMode",
    Default = {"Hold"},
    Items = {"Hold", "Toggle"},
    Multi = false,
    Callback = function(Value)
        AimState.lockMode = Value[1]
    end
})

AimMainSection:Toggle({
    Name = "Auto Switch Target",
    Flag = "AutoSwitch",
    Default = true,
    Callback = function(Value)
        Settings.Aim.AutoSwitch = Value
    end
})

AimMainSection:Dropdown({
    Name = "Target Mode",
    Flag = "TargetMode",
    Default = {"FOV"},
    Items = {"FOV", "Distance"},
    Multi = false,
    Callback = function(Value)
        Settings.Aim.TargetMode = Value[1]
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
        AimState.prediction = Value
    end
})

AimMainSection:Toggle({
    Name = "Silent Aim",
    Flag = "SilentAim",
    Default = false,
    Callback = function(Value)
        AimState.silentAim = Value
    end
})

AimMainSection:Toggle({
    Name = "Show Lock HUD",
    Flag = "ShowLockHud",
    Default = true,
    Callback = function(Value)
        AimState.showLockHud = Value
    end
})

local AimExtraSection = AimPage:Section({Name = "Extra", Side = 2})

AimExtraSection:Toggle({
    Name = "Auto Shoot",
    Flag = "AutoShoot",
    Default = false,
    Callback = function(Value)
        AimState.autoShootOn = Value
    end
})

AimExtraSection:Dropdown({
    Name = "Auto Shoot Mode",
    Flag = "AutoShootMode",
    Default = {"On Lock"},
    Items = {"On Lock", "Always"},
    Multi = false,
    Callback = function(Value)
        AimState.autoShootMode = Value[1]
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
        AimState.autoShootInterval = Value
    end
})

AimExtraSection:Toggle({
    Name = "Triggerbot",
    Flag = "Triggerbot",
    Default = false,
    Callback = function(Value)
        AimState.triggerbotOn = Value
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
        AimState.triggerbotRadius = Value
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
        AimState.triggerbotDelay = Value
    end
})

AimExtraSection:Toggle({
    Name = "Triggerbot Wall Check",
    Flag = "TriggerbotWallCheck",
    Default = true,
    Callback = function(Value)
        AimState.triggerbotWallCheck = Value
    end
})

AimExtraSection:Toggle({
    Name = "Velocity Resolver",
    Flag = "VelocityResolver",
    Default = false,
    Callback = function(Value)
        AimState.velocityResolver = Value
    end
})

AimExtraSection:Toggle({
    Name = "Crosshair",
    Flag = "Crosshair",
    Default = false,
    Callback = function(Value)
        AimState.crosshairEnabled = Value
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
        AimState.crosshairSize = Value
    end
})

AimExtraSection:Label("FOV Color"):Colorpicker({
    Name = "FOV Color",
    Flag = "FOVColor",
    Default = Color3.fromRGB(100, 60, 180),
    Callback = function(Value)
        AimState.fovColor = Value
    end
})

AimExtraSection:Label("Crosshair Color"):Colorpicker({
    Name = "Crosshair Color",
    Flag = "CrosshairColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        AimState.crosshairColor = Value
    end
})

local VisualPage = Window:Page({Name = "Visual"})
local ESPSection = VisualPage:Section({Name = "Main", Side = 1})

ESPSection:Toggle({
    Name = "Enable ESP",
    Flag = "ESPEnabled",
    Default = false,
    Callback = function(Value)
        ESPState.enabled = Value
    end
})

ESPSection:Toggle({
    Name = "Skeletons",
    Flag = "SkeletonESP",
    Default = false,
    Callback = function(Value)
        ESPState.showSkeleton = Value
        for plr, _ in pairs(ESPState.drawings) do
            removeESP(plr)
            createESP(plr)
        end
    end
})

ESPSection:Toggle({
    Name = "Chams",
    Flag = "ChamsEnabled",
    Default = false,
    Callback = function(Value)
        ESPState.chamsEnabled = Value
        refreshChams()
    end
})

ESPSection:Toggle({
    Name = "Boxes",
    Flag = "BoxESP",
    Default = false,
    Callback = function(Value)
        ESPState.showBoxes = Value
    end
})

ESPSection:Toggle({
    Name = "Names",
    Flag = "NameESP",
    Default = false,
    Callback = function(Value)
        ESPState.showNames = Value
    end
})

ESPSection:Toggle({
    Name = "Tracers",
    Flag = "Tracers",
    Default = false,
    Callback = function(Value)
        ESPState.showTracers = Value
    end
})

ESPSection:Toggle({
    Name = "Distance",
    Flag = "DistanceESP",
    Default = false,
    Callback = function(Value)
        ESPState.showDistance = Value
    end
})

ESPSection:Toggle({
    Name = "Team check",
    Flag = "ShowTeammates",
    Default = false,
    Callback = function(Value)
        ESPState.showTeam = Value
    end
})

ESPSection:Label("ESP Color"):Colorpicker({
    Name = "ESP Color",
    Flag = "ESPColor",
    Default = Color3.fromRGB(100, 60, 180),
    Callback = function(Value)
        ESPState.espColor = Value
        refreshChams()
    end
})

ESPSection:Label("Chams Fill Color"):Colorpicker({
    Name = "Chams Fill Color",
    Flag = "ChamsFillColor",
    Default = Color3.fromRGB(100, 60, 180),
    Callback = function(Value)
        ESPState.chamsFillColor = Value
        refreshChams()
    end
})

ESPSection:Label("Chams Outline Color"):Colorpicker({
    Name = "Chams Outline Color",
    Flag = "ChamsOutlineColor",
    Default = Color3.fromRGB(100, 60, 180),
    Callback = function(Value)
        ESPState.chamsOutlineColor = Value
        refreshChams()
    end
})

ESPSection:Slider({
    Name = "Chams Fill Transparency",
    Flag = "ChamsFillTransparency",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Suffix = "",
    Step = 0.1,
    Decimals = 1,
    Callback = function(Value)
        ESPState.chamsFillTransparency = Value
        refreshChams()
    end
})

ESPSection:Slider({
    Name = "Chams Outline Transparency",
    Flag = "ChamsOutlineTransparency",
    Min = 0,
    Max = 1,
    Default = 0,
    Suffix = "",
    Step = 0.1,
    Decimals = 1,
    Callback = function(Value)
        ESPState.chamsOutlineTransparency = Value
        refreshChams()
    end
})

local VisualExtraSection = VisualPage:Section({Name = "Visuals", Side = 2})

VisualExtraSection:Toggle({
    Name = "Fullbright",
    Flag = "Fullbright",
    Default = false,
    Callback = function(Value)
        MiscState.fullbright = Value
        updateLightingState()
    end
})

VisualExtraSection:Toggle({
    Name = "No Fog",
    Flag = "NoFog",
    Default = false,
    Callback = function(Value)
        MiscState.noFog = Value
        updateLightingState()
    end
})

VisualExtraSection:Slider({
    Name = "Time of Day",
    Flag = "TimeOfDay",
    Min = 0,
    Max = 24,
    Default = 12,
    Suffix = " hours",
    Step = 0.5,
    Callback = function(Value)
        local hours = math.floor(Value)
        local minutes = math.floor((Value - hours) * 60)
        local timeString = string.format("%02d:%02d:00", hours, minutes)
        Lighting.TimeOfDay = timeString
    end
})

local MovementPage = Window:Page({Name = "Movement"})
local MoveSection = MovementPage:Section({Name = "Main", Side = 1})

MoveSection:Toggle({
    Name = "Shield",
    Flag = "ShieldEnabled",
    Default = false,
    Callback = function(Value)
        MovementState.shieldOn = Value
        local char = LocalPlayer.Character
        if char then
            if MovementState.shieldOn then
                MovementState.forceField = Instance.new("ForceField")
                MovementState.forceField.Parent = char
            else
                if MovementState.forceField then MovementState.forceField:Destroy() end
            end
        end
    end
})

MoveSection:Toggle({
    Name = "Walk Speed",
    Flag = "SpeedEnabled",
    Default = false,
    Callback = function(Value)
        MovementState.speedEnabled = Value
    end
})

MoveSection:Slider({
    Name = "Speed",
    Flag = "SpeedValue",
    Min = 16,
    Max = 250,
    Default = 16,
    Suffix = " studs",
    Callback = function(Value)
        MovementState.currentSpeed = Value
    end
})

MoveSection:Toggle({
    Name = "Jump Height",
    Flag = "JumpEnabled",
    Default = false,
    Callback = function(Value)
        MovementState.jumpEnabled = Value
    end
})

MoveSection:Slider({
    Name = "Height",
    Flag = "JumpValue",
    Min = 7,
    Max = 500,
    Default = 50,
    Suffix = "",
    Callback = function(Value)
        MovementState.jumpValue = Value
    end
})

MoveSection:Toggle({
    Name = "Infinite Jump",
    Flag = "InfiniteJump",
    Default = false,
    Callback = function(Value)
        MovementState.infJumpOn = Value
    end
})

MoveSection:Toggle({
    Name = "Fly",
    Flag = "FlyEnabled",
    Default = false,
    Callback = function(Value)
        MovementState.flyOn = Value
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if MovementState.flyOn then
            MovementState.bodyVelocity = Instance.new("BodyVelocity")
            MovementState.bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            MovementState.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            MovementState.bodyVelocity.Parent = root
            MovementState.bodyGyro = Instance.new("BodyGyro")
            MovementState.bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            MovementState.bodyGyro.CFrame = root.CFrame
            MovementState.bodyGyro.Parent = root
        else
            if MovementState.bodyVelocity then MovementState.bodyVelocity:Destroy() MovementState.bodyVelocity = nil end
            if MovementState.bodyGyro then MovementState.bodyGyro:Destroy() MovementState.bodyGyro = nil end
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
        MovementState.flySpeed = Value
    end
})

MoveSection:Toggle({
    Name = "Noclip",
    Flag = "NoclipEnabled",
    Default = false,
    Callback = function(Value)
        MovementState.noclipOn = Value
    end
})

MoveSection:Toggle({
    Name = "Custom Gravity",
    Flag = "GravityEnabled",
    Default = false,
    Callback = function(Value)
        MovementState.gravityEnabled = Value
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
        MovementState.gravityValue = Value
        if MovementState.gravityEnabled then Workspace.Gravity = MovementState.gravityValue end
    end
})

local PlayersPage = Window:Page({Name = "Players"})
local PlayersSection = PlayersPage:Section({Name = "Main", Side = 1})

local playerList = {}
local selectedPlayerName = ""

local function updatePlayerList()
    playerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playerList, plr.Name)
        end
    end
end

updatePlayerList()

PlayersSection:Dropdown({
    Name = "Select Target",
    Flag = "TargetPlayer",
    Default = {},
    Items = playerList,
    Multi = false,
    Callback = function(Value)
        if Value and #Value > 0 then
            selectedPlayerName = Value[1]
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Name == selectedPlayerName then
                    trollTarget = plr
                    break
                end
            end
        end
    end
})

PlayersSection:Button({
    Name = "Refresh Player List",
    Callback = function()
        updatePlayerList()
        notify("Monarch", "Player list refreshed", 2)
    end
})

local PlayersActionSection = PlayersPage:Section({Name = "Actions", Side = 1})

PlayersActionSection:Button({
    Name = "Teleport to Target",
    Callback = function()
        if not trollTarget then
            notify("Monarch", "No target selected", 2)
            return
        end
        local localChar = LocalPlayer.Character
        local targetChar = trollTarget.Character
        if localChar and targetChar then
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if localRoot and targetRoot then
                localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)
            end
        end
    end
})

PlayersActionSection:Button({
    Name = "Spectate Target",
    Callback = function()
        if not trollTarget then
            notify("Monarch", "No target selected", 2)
            return
        end
        startSpectate(trollTarget)
    end
})

PlayersActionSection:Button({
    Name = "Stop Spectating",
    Callback = function()
        stopSpectate()
    end
})

PlayersActionSection:Button({
    Name = "Vote Kick Target",
    Callback = function()
        if not trollTarget then
            notify("Monarch", "No target selected", 2)
            return
        end
        voteKickPlayer(trollTarget)
    end
})

local WhitelistSection = PlayersPage:Section({Name = "Whitelist", Side = 2})

WhitelistSection:Dropdown({
    Name = "Whitelist Player",
    Flag = "WhitelistPlayer",
    Default = {},
    Items = playerList,
    Multi = false,
    Callback = function(Value)
        if Value and #Value > 0 then
            local name = Value[1]
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Name == name then
                    if not isWhitelisted(plr) then
                        table.insert(Settings.Misc.Whitelist, plr.UserId)
                        notify("Monarch", "Whitelisted: " .. name, 2)
                    else
                        for i, uid in ipairs(Settings.Misc.Whitelist) do
                            if tonumber(uid) == plr.UserId then
                                table.remove(Settings.Misc.Whitelist, i)
                                break
                            end
                        end
                        notify("Monarch", "Removed from whitelist: " .. name, 2)
                    end
                    break
                end
            end
        end
    end
})

WhitelistSection:Button({
    Name = "Clear Whitelist",
    Callback = function()
        Settings.Misc.Whitelist = {}
        notify("Monarch", "Whitelist cleared", 2)
    end
})

local PlayersExtraSection = PlayersPage:Section({Name = "Game Actions", Side = 2})

PlayersExtraSection:Button({
    Name = "Respawn",
    Callback = function()
        respawnCharacter()
    end
})

PlayersExtraSection:Button({
    Name = "Rejoin",
    Callback = function()
        rejoinGame()
    end
})

Players.PlayerAdded:Connect(function()
    updatePlayerList()
end)
Players.PlayerRemoving:Connect(function()
    updatePlayerList()
end)

local TrollPage = Window:Page({Name = "Troll"})
local TrollSection = TrollPage:Section({Name = "Main", Side = 1})

TrollSection:Slider({
    Name = "Fling Power",
    Flag = "FlingPower",
    Min = 100000,
    Max = 1000000,
    Default = 500000,
    Suffix = "",
    Callback = function(Value)
        TrollState.flingPower = Value
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
        TrollState.orbitRadius = Value
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
        TrollState.orbitSpeed = Value
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
        TrollState.constantFling = Value
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
        TrollState.orbitTarget = Value
        if Value then startOrbit() else clearOrbit() end
    end
})

TrollSection:Toggle({
    Name = "Head Sit",
    Flag = "HeadSit",
    Default = false,
    Callback = function(Value)
        if Value then
            startHeadSit()
        else
            clearHeadSit()
        end
    end
})

TrollSection:Toggle({
    Name = "Spin Troll",
    Flag = "SpinTroll",
    Default = false,
    Callback = function(Value)
        TrollState.spinTroll = Value
        if Value then startSpinTroll() else clearSpinTroll() end
    end
})

TrollSection:Toggle({
    Name = "Invisible Character",
    Flag = "Invisible",
    Default = false,
    Callback = function(Value)
        TrollState.invisible = Value
        updateInvisibleState()
    end
})

local MiscPage = Window:Page({Name = "Misc"})
local MiscSection = MiscPage:Section({Name = "Misc", Side = 1})

MiscSection:Toggle({
    Name = "FPS Counter",
    Flag = "FpsCounter",
    Default = true,
    Callback = function(Value)
        MiscState.fpsCounter = Value
    end
})

MiscSection:Toggle({
    Name = "Anti AFK",
    Flag = "AntiAFK",
    Default = false,
    Callback = function(Value)
        MiscState.antiAFK = Value
    end
})

MiscSection:Toggle({
    Name = "Unlock Mouse on Menu",
    Flag = "UnlockMouseOnMenu",
    Default = true,
    Callback = function(Value)
        Settings.Misc.UnlockMouseOnMenu = Value
    end
})

MiscSection:Toggle({
    Name = "Stream Proof",
    Flag = "StreamProof",
    Default = false,
    Callback = function(Value)
        Settings.Misc.StreamProof = Value
        if GUI.LockStatusGui then
            GUI.LockStatusGui.ResetOnSpawn = not Value
        end
        if GUI.BindToastGui then
            GUI.BindToastGui.ResetOnSpawn = not Value
        end
    end
})

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Settings.Misc.MenuKeybind then
        Library:Toggle()
        if Settings.Misc.UnlockMouseOnMenu then
            GUI.menuOpen = not GUI.menuOpen
            if GUI.menuOpen then
                GUI.savedMouseState = UserInputService.MouseIconEnabled
                UserInputService.MouseIconEnabled = true
            else
                if GUI.savedMouseState ~= nil then
                    UserInputService.MouseIconEnabled = GUI.savedMouseState
                end
            end
        end
    end
    if input == Settings.Aim.Keybind then
        AimState.isAming = true
        if AimState.lockMode == "Toggle" then
            AimState.toggleActive = not AimState.toggleActive
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == Settings.Aim.Keybind then
        AimState.isAming = false
        if AimState.lockMode == "Hold" then
            AimState.currentTargetPlayer = nil
        end
    end
end)

Window:Category("Settings")
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)
Window:Init()
