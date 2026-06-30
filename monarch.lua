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
}

local defaultGravity = Workspace.Gravity

local GUI = {
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
    antiAFK = false,
    fpsCounter = true,
    atmosphericFog = false,
    atmosphericFogColor = Color3.fromRGB(185, 195, 210),
    rain = false,
    floatingLamps = false,
    rtxEnabled = false,
    currentSkyPreset = "Default",
    bloomEnabled = false,
    bloomIntensity = 0.8,
    bloomSize = 20,
    bloomThreshold = 0.8,
    colorCorrectionEnabled = false,
    colorContrast = 0.15,
    colorSaturation = 0.2,
    colorTint = Color3.fromRGB(255, 255, 255),
    sunRaysEnabled = false,
    sunRaysIntensity = 0.2,
    sunRaysSpread = 0.75,
    dofEnabled = false,
    dofFarIntensity = 0.15,
    dofFocusDistance = 35,
    dofInFocusRadius = 25,
    dofNearIntensity = 0,
    forceLighting = false,
}

local trollTarget = nil

local WaypointState = {
    enabled = false,
    waypoints = {},
    drawings = {},
    showDistance = true,
    showDirection = true,
    selectedWaypoint = nil
}

local originalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
}

local atmosphericFogSaved = {}
local atmosphericFogInstance = nil

local function enableAtmosphericFog()
    if MiscState.atmosphericFog then return end
    MiscState.atmosphericFog = true
    atmosphericFogSaved.FogColor = Lighting.FogColor
    atmosphericFogSaved.FogStart = Lighting.FogStart
    atmosphericFogSaved.FogEnd = Lighting.FogEnd
    atmosphericFogSaved.Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj.Name == "PortalAura" and obj:IsA("Atmosphere") then
            obj:Destroy()
        end
    end
    atmosphericFogInstance = Instance.new("Atmosphere", Lighting)
    atmosphericFogInstance.Name = "PortalAura"
    atmosphericFogInstance.Color = MiscState.atmosphericFogColor
    atmosphericFogInstance.Decay = MiscState.atmosphericFogColor
    atmosphericFogInstance.Density = 0.42
    atmosphericFogInstance.Haze = 3.5
    atmosphericFogInstance.Glare = 0.5
    atmosphericFogInstance.Offset = 0
    Lighting.FogColor = MiscState.atmosphericFogColor
    Lighting.FogStart = 50
    Lighting.FogEnd = 900
end

local function disableAtmosphericFog()
    if not MiscState.atmosphericFog then return end
    MiscState.atmosphericFog = false
    Lighting.FogColor = atmosphericFogSaved.FogColor
    Lighting.FogStart = atmosphericFogSaved.FogStart
    Lighting.FogEnd = atmosphericFogSaved.FogEnd
    if atmosphericFogInstance then
        atmosphericFogInstance:Destroy()
        atmosphericFogInstance = nil
    end
end

local rainHeartbeatConn = nil
local rainFolder = nil
local rainRayParams = nil
local rainSplashPool = {}
local rainSplashIndex = 0
local rainActiveSplashes = {}
local rainDrops = {}
local rainDropParts = {}
local rainFrameCount = 0

local RAIN_CONFIG = {
    RAIN_COUNT = 200,
    RAIN_RADIUS = 40,
    RAIN_HEIGHT = 30,
    FALL_SPEED = 80,
    WIND_X = 2,
    SPEED_VARIANCE = 15,
    RAYCAST_EVERY = 8,
    SPLASH_POOL = 60,
}

local rainWindAngleCF = CFrame.Angles(math.rad(RAIN_CONFIG.WIND_X * 3), 0, 0)
local RAIN_LERP_SPEED = 25

local function rainGetGroundY(pos)
    local result = Workspace:Raycast(pos, Vector3.new(0, -100, 0), rainRayParams)
    return result and result.Position.Y or (pos.Y - 100)
end

local function rainPlaySplash(pos)
    rainSplashIndex = (rainSplashIndex % RAIN_CONFIG.SPLASH_POOL) + 1
    local s = rainSplashPool[rainSplashIndex]
    if not s then return end
    s.Size = Vector3.new(0.08, 0.03, 0.08)
    s.Position = Vector3.new(pos.X, pos.Y + 0.04, pos.Z)
    s.Transparency = 0.3
    rainActiveSplashes[s] = { timer = 0 }
end

local function initRain()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local rootPos = rootPart.Position

    rainRayParams = RaycastParams.new()
    rainRayParams.FilterType = Enum.RaycastFilterType.Exclude
    rainRayParams.FilterDescendantsInstances = {rainFolder, character}

    for i = 1, RAIN_CONFIG.SPLASH_POOL do
        local s = Instance.new("Part")
        s.Size = Vector3.new(0.1, 0.03, 0.1)
        s.Material = Enum.Material.Glass
        s.Color = Color3.fromRGB(200, 225, 255)
        s.Transparency = 0.5
        s.CanCollide = false
        s.Anchored = true
        s.CastShadow = false
        s.Parent = rainFolder
        rainSplashPool[i] = s
    end

    for i = 1, RAIN_CONFIG.RAIN_COUNT do
        local angle = math.random() * math.pi * 2
        local radius = math.sqrt(math.random()) * RAIN_CONFIG.RAIN_RADIUS

        local drop = Instance.new("Part")
        drop.Size = Vector3.new(0.04, 2.2, 0.04)
        drop.Material = Enum.Material.Glass
        drop.Color = Color3.fromRGB(200, 225, 255)
        drop.Transparency = 0.45
        drop.CanCollide = false
        drop.Anchored = true
        drop.CastShadow = false
        drop.Parent = rainFolder
        rainDropParts[i] = drop

        local spawnX = rootPos.X + math.cos(angle) * radius
        local spawnY = rootPos.Y + math.random(5, RAIN_CONFIG.RAIN_HEIGHT)
        local spawnZ = rootPos.Z + math.sin(angle) * radius

        rainDrops[i] = {
            x = spawnX,
            y = spawnY,
            z = spawnZ,
            speed = RAIN_CONFIG.FALL_SPEED + math.random(-RAIN_CONFIG.SPEED_VARIANCE, RAIN_CONFIG.SPEED_VARIANCE),
            groundY = spawnY - 100,
            rayTimer = math.random(1, RAIN_CONFIG.RAYCAST_EVERY),
            px = spawnX,
            py = spawnY,
            pz = spawnZ,
        }

        drop.CFrame = CFrame.new(spawnX, spawnY, spawnZ) * rainWindAngleCF
    end
end

local function rainOnHeartbeat(dt)
    if not MiscState.rain then return end
    dt = math.min(dt, 0.05)
    rainFrameCount = rainFrameCount + 1

    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    if rainFrameCount % 60 == 0 then
        rainRayParams.FilterDescendantsInstances = {rainFolder, character}
    end

    local rootPos = rootPart.Position

    for s, data in pairs(rainActiveSplashes) do
        data.timer = data.timer + dt
        local t = math.min(data.timer / 0.22, 1)
        local ease = 1 - (1 - t) * (1 - t)
        s.Size = Vector3.new(0.08 + 0.65 * ease, 0.03, 0.08 + 0.65 * ease)
        s.Transparency = 0.3 + 0.7 * ease
        if t >= 1 then
            rainActiveSplashes[s] = nil
        end
    end

    for i = 1, RAIN_CONFIG.RAIN_COUNT do
        local d = rainDrops[i]
        local drop = rainDropParts[i]
        if not d or not drop then continue end

        d.x = d.x + RAIN_CONFIG.WIND_X * dt
        d.y = d.y - d.speed * dt

        local alpha = math.min(RAIN_LERP_SPEED * dt, 1)
        d.px = d.px + (d.x - d.px) * alpha
        d.py = d.py + (d.y - d.py) * alpha
        d.pz = d.pz + (d.z - d.pz) * alpha

        d.rayTimer = d.rayTimer + 1
        if d.rayTimer >= RAIN_CONFIG.RAYCAST_EVERY then
            d.rayTimer = 0
            d.groundY = rainGetGroundY(Vector3.new(d.x, d.y + 5, d.z))
        end

        if d.y <= d.groundY + 1.1 then
            rainPlaySplash(Vector3.new(d.x, d.groundY, d.z))

            local angle = math.random() * math.pi * 2
            local radius = math.sqrt(math.random()) * RAIN_CONFIG.RAIN_RADIUS
            d.x = rootPos.X + math.cos(angle) * radius
            d.y = rootPos.Y + RAIN_CONFIG.RAIN_HEIGHT
            d.z = rootPos.Z + math.sin(angle) * radius
            d.px = d.x
            d.py = d.y
            d.pz = d.z
            d.groundY = d.y - 100
            d.rayTimer = 0
        end

        drop.CFrame = CFrame.new(d.px, d.py, d.pz) * rainWindAngleCF
    end
end

local function enableRain()
    if MiscState.rain then return end
    MiscState.rain = true
    rainFolder = Instance.new("Folder")
    rainFolder.Name = "RainEffect"
    rainFolder.Parent = Workspace
    rainSplashPool = {}
    rainSplashIndex = 0
    rainActiveSplashes = {}
    rainDrops = {}
    rainDropParts = {}
    rainFrameCount = 0
    initRain()
    rainHeartbeatConn = RunService.Heartbeat:Connect(rainOnHeartbeat)
end

local function disableRain()
    MiscState.rain = false
    if rainHeartbeatConn then rainHeartbeatConn:Disconnect() end
    if rainFolder then rainFolder:Destroy() end
    rainSplashPool = {}
    rainActiveSplashes = {}
    rainDrops = {}
    rainDropParts = {}
end

local lampsUpdateConn = nil
local lampsFolder = nil
local lamps = {}
local LAMPS_MAX = 7

local function createLamp(index)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local cap = Instance.new("Part")
    cap.Size = Vector3.new(1.4, 0.2, 1.4)
    cap.Material = Enum.Material.SmoothPlastic
    cap.Color = Color3.fromRGB(200, 45, 45)
    cap.CanCollide = false
    cap.CastShadow = false
    cap.Anchored = true
    cap.Parent = lampsFolder

    local body = Instance.new("Part")
    body.Size = Vector3.new(1.2, 1.8, 1.2)
    body.Material = Enum.Material.Neon
    body.Color = Color3.fromRGB(255, 220, 150)
    body.Transparency = 0.25
    body.CanCollide = false
    body.CastShadow = false
    body.Anchored = true
    body.Parent = lampsFolder

    local gold = Instance.new("Part")
    gold.Size = Vector3.new(1.3, 0.12, 1.3)
    gold.Material = Enum.Material.Metal
    gold.Color = Color3.fromRGB(220, 170, 50)
    gold.CanCollide = false
    gold.CastShadow = false
    gold.Anchored = true
    gold.Parent = lampsFolder

    local bottom = Instance.new("Part")
    bottom.Size = Vector3.new(1.4, 0.2, 1.4)
    bottom.Material = Enum.Material.SmoothPlastic
    bottom.Color = Color3.fromRGB(200, 45, 45)
    bottom.CanCollide = false
    bottom.CastShadow = false
    bottom.Anchored = true
    bottom.Parent = lampsFolder

    local fringes = {}
    for i = 1, 6 do
        local fringe = Instance.new("Part")
        fringe.Size = Vector3.new(0.06, 0.7, 0.06)
        fringe.Material = Enum.Material.Fabric
        fringe.Color = Color3.fromRGB(220, 60, 60)
        fringe.CanCollide = false
        fringe.CastShadow = false
        fringe.Anchored = true
        fringe.Parent = lampsFolder
        table.insert(fringes, fringe)
    end

    local tassel = Instance.new("Part")
    tassel.Size = Vector3.new(0.1, 0.9, 0.1)
    tassel.Material = Enum.Material.Fabric
    tassel.Color = Color3.fromRGB(200, 50, 50)
    tassel.CanCollide = false
    tassel.CastShadow = false
    tassel.Anchored = true
    tassel.Parent = lampsFolder

    local flame = Instance.new("Part")
    flame.Size = Vector3.new(0.35, 0.45, 0.35)
    flame.Material = Enum.Material.Neon
    flame.Color = Color3.fromRGB(255, 240, 180)
    flame.CanCollide = false
    flame.CastShadow = false
    flame.Anchored = true
    flame.Parent = lampsFolder

    local hook = Instance.new("Part")
    hook.Size = Vector3.new(0.08, 0.4, 0.08)
    hook.Material = Enum.Material.Metal
    hook.Color = Color3.fromRGB(180, 140, 40)
    hook.CanCollide = false
    hook.CastShadow = false
    hook.Anchored = true
    hook.Parent = lampsFolder

    local chain = Instance.new("Part")
    chain.Size = Vector3.new(0.05, 1.5, 0.05)
    chain.Material = Enum.Material.Metal
    chain.Color = Color3.fromRGB(160, 120, 40)
    chain.CanCollide = false
    chain.CastShadow = false
    chain.Anchored = true
    chain.Parent = lampsFolder

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 200, 100)
    light.Brightness = 5
    light.Range = 16
    light.Shadows = false
    light.Parent = flame

    local trail = Instance.new("Trail")
    trail.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 120)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 180, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 140, 30))
    }
    trail.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    }
    trail.Lifetime = 0.8
    trail.WidthScale = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0)
    }
    trail.LightEmission = 0.6
    trail.Parent = flame

    local att0 = Instance.new("Attachment")
    att0.Position = Vector3.new(0, 0.3, 0)
    att0.Parent = flame

    local att1 = Instance.new("Attachment")
    att1.Position = Vector3.new(0, -0.3, 0)
    att1.Parent = flame

    trail.Attachment0 = att0
    trail.Attachment1 = att1

    local angle = (index / LAMPS_MAX) * math.pi * 2
    local radius = 35 + math.random(0, 150) / 10
    local height = 12 + math.random(0, 100) / 10

    local startPos = hrp.Position + Vector3.new(
        math.cos(angle) * radius,
        height,
        math.sin(angle) * radius
    )

    local p = startPos
    hook.CFrame = CFrame.new(p + Vector3.new(0, 2.2, 0))
    chain.CFrame = CFrame.new(p + Vector3.new(0, 1.2, 0))
    cap.CFrame = CFrame.new(p + Vector3.new(0, 0.9, 0))
    body.CFrame = CFrame.new(p)
    gold.CFrame = CFrame.new(p)
    bottom.CFrame = CFrame.new(p - Vector3.new(0, 0.9, 0))
    flame.CFrame = CFrame.new(p + Vector3.new(0, 0.1, 0))
    tassel.CFrame = CFrame.new(p - Vector3.new(0, 1.4, 0))

    for i, fringe in ipairs(fringes) do
        local a = (i - 1) * math.pi / 3
        fringe.CFrame = CFrame.new(p - Vector3.new(0, 1.1, 0) + Vector3.new(math.cos(a) * 0.5, 0, math.sin(a) * 0.5))
    end

    table.insert(lamps, {
        cap = cap,
        body = body,
        gold = gold,
        bottom = bottom,
        fringes = fringes,
        tassel = tassel,
        flame = flame,
        hook = hook,
        chain = chain,
        light = light,
        trail = trail,
        angle = angle,
        radius = radius,
        baseHeight = height,
        bobPhase = math.random(0, 1000) / 100,
        bobSpeed = math.random(15, 35) / 100,
        bobAmp = math.random(60, 120) / 100,
        orbitSpeed = math.random(6, 15) / 100,
        orbitDir = math.random() > 0.5 and 1 or -1,
        swayPhase = math.random(0, 1000) / 100,
        flamePhase = math.random(0, 1000) / 100,
        fringePhase = math.random(0, 1000) / 100,
        targetPos = startPos,
        currentPos = startPos,
        velocity = Vector3.zero,
        accel = Vector3.zero,
    })
end

local function lampsOnUpdate(dt)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local time = tick()
    local playerPos = hrp.Position

    for _, l in ipairs(lamps) do
        if not l.flame or not l.flame.Parent then continue end

        l.angle = l.angle + dt * l.orbitSpeed * l.orbitDir

        local roseT = time * 0.12 + l.swayPhase
        local roseX = math.sin(roseT * 2) * math.cos(roseT * 0.6) * 1.5
        local roseZ = math.sin(roseT * 2) * math.sin(roseT * 0.6) * 1.5

        local bob = math.sin(time * l.bobSpeed + l.bobPhase) * l.bobAmp
        local drift = math.sin(time * 0.1 + l.swayPhase) * 0.5

        local targetX = playerPos.X + math.cos(l.angle) * l.radius + roseX
        local targetZ = playerPos.Z + math.sin(l.angle) * l.radius + roseZ
        local targetY = playerPos.Y + l.baseHeight + bob + drift

        l.targetPos = Vector3.new(targetX, targetY, targetZ)
        local diff = l.targetPos - l.currentPos
        local omega = 2.0
        local zeta = 0.9
        l.accel = diff * (omega * omega) - l.velocity * (zeta * omega * 2)
        l.velocity = l.velocity + l.accel * dt
        l.currentPos = l.currentPos + l.velocity * dt

        local dist = (l.currentPos - playerPos).Magnitude
        if dist > 55 then
            l.currentPos = playerPos + (l.currentPos - playerPos).Unit * 55
            l.velocity = l.velocity * 0.3
        end

        local pos = l.currentPos

        local tiltX = math.clamp(l.velocity.Z * 5, -6, 6)
        local tiltZ = math.clamp(-l.velocity.X * 5, -6, 6)
        local swayTilt = math.sin(time * 0.35 + l.swayPhase) * 1.5

        local flameJump = math.sin(time * 1.8 + l.flamePhase) * 0.1
        local flameSway = math.sin(time * 2.8 + l.flamePhase * 1.2) * 0.05
        local flicker = 1 + math.sin(time * 5 + l.flamePhase) * 0.07 + math.sin(time * 9) * 0.03

        local fringeSwing = math.sin(time * 2 + l.fringePhase) * 8

        local cf = CFrame.new(pos) * CFrame.Angles(
            math.rad(tiltX + swayTilt),
            0,
            math.rad(tiltZ)
        )

        l.hook.CFrame = cf * CFrame.new(0, 2.2, 0)
        l.chain.CFrame = cf * CFrame.new(0, 1.2, 0)
        l.cap.CFrame = cf * CFrame.new(0, 0.9, 0)
        l.body.CFrame = cf
        l.gold.CFrame = cf
        l.bottom.CFrame = cf * CFrame.new(0, -0.9, 0)
        l.flame.CFrame = cf * CFrame.new(flameSway, 0.1 + flameJump, 0) * CFrame.Angles(0, time, 0)
        l.tassel.CFrame = cf * CFrame.new(0, -1.4, 0) * CFrame.Angles(math.rad(fringeSwing * 0.5), 0, 0)

        for i, fringe in ipairs(l.fringes) do
            local a = (i - 1) * math.pi / 3 + l.angle * 0.1
            local swing = math.sin(time * 2.5 + l.fringePhase + i) * 12
            fringe.CFrame = cf * CFrame.new(
                math.cos(a) * 0.5,
                -1.1,
                math.sin(a) * 0.5
            ) * CFrame.Angles(math.rad(swing), 0, 0)
        end

        l.light.Brightness = 5 * flicker
        l.light.Range = 16 + math.sin(time) * 2

        local warmth = math.sin(time * 0.5 + l.swayPhase) * 10
        l.light.Color = Color3.fromRGB(
            255,
            math.clamp(200 + warmth, 190, 215),
            math.clamp(100 + warmth * 0.3, 92, 110)
        )
        l.flame.Color = Color3.fromRGB(
            255,
            math.clamp(240 + warmth * 0.1, 235, 248),
            math.clamp(180 + warmth * 0.1, 175, 190)
        )
        l.body.Color = Color3.fromRGB(
            255,
            math.clamp(220 + warmth * 0.2, 212, 230),
            math.clamp(150 + warmth * 0.3, 142, 162)
        )
    end
end

local function enableFloatingLamps()
    if MiscState.floatingLamps then return end
    MiscState.floatingLamps = true
    local old = Workspace:FindFirstChild("PortalVisual_Lamps")
    if old then old:Destroy() end
    lampsFolder = Instance.new("Folder")
    lampsFolder.Name = "PortalVisual_Lamps"
    lampsFolder.Parent = Workspace
    lamps = {}
    for i = 1, LAMPS_MAX do
        createLamp(i)
    end
    lampsUpdateConn = RunService.RenderStepped:Connect(lampsOnUpdate)
end

local function disableFloatingLamps()
    MiscState.floatingLamps = false
    if lampsUpdateConn then lampsUpdateConn:Disconnect() end
    if lampsFolder then lampsFolder:Destroy() end
    lamps = {}
end

local rtxEffects = {
    bloom = nil,
    colorCorrection = nil,
    sunRays = nil,
    dof = nil,
    sky = nil
}
local lightingForceConn = nil

local skyPresets = {
    {
        Name = "Default",
        Time = 12,
        Exposure = 0,
        Ambient = Color3.fromRGB(128, 128, 128),
        OutdoorAmbient = Color3.fromRGB(128, 128, 128),
        Skybox = nil
    },
    {
        Name = "Golden Sunset",
        Time = 17.7,
        Exposure = 0.55,
        Ambient = Color3.fromRGB(30, 20, 15),
        OutdoorAmbient = Color3.fromRGB(40, 25, 20),
        Skybox = {
            Bk = "rbxassetid://171560994",
            Dn = "rbxassetid://171561019",
            Ft = "rbxassetid://171560968",
            Lf = "rbxassetid://171561065",
            Rt = "rbxassetid://171561026",
            Up = "rbxassetid://171561009"
        }
    },
    {
        Name = "Bright Daylight",
        Time = 13.0,
        Exposure = 0.35,
        Ambient = Color3.fromRGB(140, 140, 140),
        OutdoorAmbient = Color3.fromRGB(220, 220, 220),
        Skybox = nil
    },
    {
        Name = "Purple Nebula",
        Time = 0,
        Exposure = 0.7,
        Ambient = Color3.fromRGB(20, 10, 25),
        OutdoorAmbient = Color3.fromRGB(25, 15, 35),
        Skybox = {
            Bk = "rbxassetid://171410628",
            Dn = "rbxassetid://171410649",
            Ft = "rbxassetid://171410620",
            Lf = "rbxassetid://171410666",
            Rt = "rbxassetid://171410657",
            Up = "rbxassetid://171410636"
        }
    },
    {
        Name = "Cyberpunk Red",
        Time = 18.0,
        Exposure = 0.6,
        Ambient = Color3.fromRGB(35, 10, 15),
        OutdoorAmbient = Color3.fromRGB(45, 15, 20),
        Skybox = {
            Bk = "rbxassetid://12064107",
            Dn = "rbxassetid://12064107",
            Ft = "rbxassetid://12064107",
            Lf = "rbxassetid://12064107",
            Rt = "rbxassetid://12064107",
            Up = "rbxassetid://12064107"
        }
    }
}

local function applySkyPreset(presetName)
    local preset
    for _, p in ipairs(skyPresets) do
        if p.Name == presetName then
            preset = p
            break
        end
    end
    if not preset then return end

    local sky = Lighting:FindFirstChildOfClass("Sky")

    if preset.Skybox then
        if not sky then
            sky = Instance.new("Sky")
            sky.Parent = Lighting
        end
        sky.SkyboxBk = preset.Skybox.Bk
        sky.SkyboxDn = preset.Skybox.Dn
        sky.SkyboxFt = preset.Skybox.Ft
        sky.SkyboxLf = preset.Skybox.Lf
        sky.SkyboxRt = preset.Skybox.Rt
        sky.SkyboxUp = preset.Skybox.Up
        sky.SunAngularSize = 15
        sky.MoonAngularSize = 10
        rtxEffects.sky = sky
    else
        if sky then sky:Destroy() end
        rtxEffects.sky = nil
    end

    Lighting.ClockTime = preset.Time
    Lighting.ExposureCompensation = preset.Exposure
    Lighting.Ambient = preset.Ambient
    Lighting.OutdoorAmbient = preset.OutdoorAmbient
    Lighting.GlobalShadows = true
    Lighting.Brightness = 2
end

local function enableBloom()
    if rtxEffects.bloom then return end
    rtxEffects.bloom = Instance.new("BloomEffect")
    rtxEffects.bloom.Name = "Monarch_Bloom"
    rtxEffects.bloom.Intensity = MiscState.bloomIntensity
    rtxEffects.bloom.Size = MiscState.bloomSize
    rtxEffects.bloom.Threshold = MiscState.bloomThreshold
    rtxEffects.bloom.Parent = Lighting
end

local function updateBloom()
    if rtxEffects.bloom then
        rtxEffects.bloom.Intensity = MiscState.bloomIntensity
        rtxEffects.bloom.Size = MiscState.bloomSize
        rtxEffects.bloom.Threshold = MiscState.bloomThreshold
    end
end

local function disableBloom()
    if rtxEffects.bloom then
        rtxEffects.bloom:Destroy()
        rtxEffects.bloom = nil
    end
end

local function enableColorCorrection()
    if rtxEffects.colorCorrection then return end
    rtxEffects.colorCorrection = Instance.new("ColorCorrectionEffect")
    rtxEffects.colorCorrection.Name = "Monarch_ColorCorrection"
    rtxEffects.colorCorrection.Contrast = MiscState.colorContrast
    rtxEffects.colorCorrection.Saturation = MiscState.colorSaturation
    rtxEffects.colorCorrection.TintColor = MiscState.colorTint
    rtxEffects.colorCorrection.Parent = Lighting
end

local function updateColorCorrection()
    if rtxEffects.colorCorrection then
        rtxEffects.colorCorrection.Contrast = MiscState.colorContrast
        rtxEffects.colorCorrection.Saturation = MiscState.colorSaturation
        rtxEffects.colorCorrection.TintColor = MiscState.colorTint
    end
end

local function disableColorCorrection()
    if rtxEffects.colorCorrection then
        rtxEffects.colorCorrection:Destroy()
        rtxEffects.colorCorrection = nil
    end
end

local function enableSunRays()
    if rtxEffects.sunRays then return end
    rtxEffects.sunRays = Instance.new("SunRaysEffect")
    rtxEffects.sunRays.Name = "Monarch_SunRays"
    rtxEffects.sunRays.Intensity = MiscState.sunRaysIntensity
    rtxEffects.sunRays.Spread = MiscState.sunRaysSpread
    rtxEffects.sunRays.Parent = Lighting
end

local function updateSunRays()
    if rtxEffects.sunRays then
        rtxEffects.sunRays.Intensity = MiscState.sunRaysIntensity
        rtxEffects.sunRays.Spread = MiscState.sunRaysSpread
    end
end

local function disableSunRays()
    if rtxEffects.sunRays then
        rtxEffects.sunRays:Destroy()
        rtxEffects.sunRays = nil
    end
end

local function enableDOF()
    if rtxEffects.dof then return end
    rtxEffects.dof = Instance.new("DepthOfFieldEffect")
    rtxEffects.dof.Name = "Monarch_DOF"
    rtxEffects.dof.FarIntensity = MiscState.dofFarIntensity
    rtxEffects.dof.FocusDistance = MiscState.dofFocusDistance
    rtxEffects.dof.InFocusRadius = MiscState.dofInFocusRadius
    rtxEffects.dof.NearIntensity = MiscState.dofNearIntensity
    rtxEffects.dof.Parent = Lighting
end

local function updateDOF()
    if rtxEffects.dof then
        rtxEffects.dof.FarIntensity = MiscState.dofFarIntensity
        rtxEffects.dof.FocusDistance = MiscState.dofFocusDistance
        rtxEffects.dof.InFocusRadius = MiscState.dofInFocusRadius
        rtxEffects.dof.NearIntensity = MiscState.dofNearIntensity
    end
end

local function disableDOF()
    if rtxEffects.dof then
        rtxEffects.dof:Destroy()
        rtxEffects.dof = nil
    end
end

local function enableLightingForce()
    if lightingForceConn then return end
    lightingForceConn = RunService.RenderStepped:Connect(function()
        if not MiscState.forceLighting then return end
        local preset
        for _, p in ipairs(skyPresets) do
            if p.Name == MiscState.currentSkyPreset then
                preset = p
                break
            end
        end
        if preset then
            Lighting.ClockTime = preset.Time
            Lighting.ExposureCompensation = preset.Exposure
            if preset.Ambient then Lighting.Ambient = preset.Ambient end
            if preset.OutdoorAmbient then Lighting.OutdoorAmbient = preset.OutdoorAmbient end
            Lighting.GlobalShadows = true
        end
    end)
end

local function disableLightingForce()
    if lightingForceConn then
        lightingForceConn:Disconnect()
        lightingForceConn = nil
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

local function isWhitelisted(plr)
    if type(Settings.Misc.Whitelist) ~= "table" then return false end
    for _, uid in ipairs(Settings.Misc.Whitelist) do
        if tonumber(uid) == plr.UserId then return true end
    end
    return false
end

local function getTrollTarget()
    return trollTarget
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

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    local hum = newChar:WaitForChild("Humanoid")
    if MovementState.speedEnabled then
        hum.WalkSpeed = MovementState.currentSpeed
    end
    if MovementState.jumpEnabled then
        hum.JumpPower = MovementState.jumpValue
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
    Camera.CameraType = Enum.CameraType.Follow
    Camera.CameraSubject = target.Character:FindFirstChild("Head")
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

local VisualPage = Window:Page({Name = "Visual"})
local ESPSection = VisualPage:Section({Name = "Main", Side = 1})

local ESPToggle = ESPSection:Toggle({
    Name = "Enable ESP",
    Flag = "ESPEnabled",
    Default = false,
    Callback = function(Value)
        ESPState.enabled = Value
    end
})

local ESPSettings = ESPToggle:Settings(60)
ESPSettings:Label("ESP Color"):Colorpicker({
    Name = "ESP Color",
    Flag = "ESPColor",
    Default = Color3.fromRGB(100, 60, 180),
    Callback = function(Value)
        ESPState.espColor = Value
        refreshChams()
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

local ChamsToggle = ESPSection:Toggle({
    Name = "Chams",
    Flag = "ChamsEnabled",
    Default = false,
    Callback = function(Value)
        ESPState.chamsEnabled = Value
        refreshChams()
    end
})

local ChamsSettings = ChamsToggle:Settings()
ChamsSettings:Label("Chams Fill Color"):Colorpicker({
    Name = "Chams Fill Color",
    Flag = "ChamsFillColor",
    Default = Color3.fromRGB(100, 60, 180),
    Callback = function(Value)
        ESPState.chamsFillColor = Value
        refreshChams()
    end
})

ChamsSettings:Label("Chams Outline Color"):Colorpicker({
    Name = "Chams Outline Color",
    Flag = "ChamsOutlineColor",
    Default = Color3.fromRGB(100, 60, 180),
    Callback = function(Value)
        ESPState.chamsOutlineColor = Value
        refreshChams()
    end
})

ChamsSettings:Slider({
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

ChamsSettings:Slider({
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
    Name = "Rain",
    Flag = "Rain",
    Default = false,
    Callback = function(Value)
        if Value then
            enableRain()
        else
            disableRain()
        end
    end
})

local FogToggle = VisualExtraSection:Toggle({
    Name = "Atmospheric Fog",
    Flag = "AtmosphericFog",
    Default = false,
    Callback = function(Value)
        if Value then
            enableAtmosphericFog()
        else
            disableAtmosphericFog()
        end
    end
})

local FogSettings = FogToggle:Settings()
FogSettings:Label("Fog Color"):Colorpicker({
    Name = "Fog Color",
    Flag = "AtmosphericFogColor",
    Default = Color3.fromRGB(185, 195, 210),
    Callback = function(Value)
        MiscState.atmosphericFogColor = Value
        if MiscState.atmosphericFog and atmosphericFogInstance then
            atmosphericFogInstance.Color = Value
            atmosphericFogInstance.Decay = Value
            Lighting.FogColor = Value
        end
    end
})

VisualExtraSection:Toggle({
    Name = "Floating Lamps",
    Flag = "FloatingLamps",
    Default = false,
    Callback = function(Value)
        if Value then
            enableFloatingLamps()
        else
            disableFloatingLamps()
        end
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

local BloomToggle = VisualExtraSection:Toggle({
    Name = "Bloom",
    Flag = "BloomEnabled",
    Default = false,
    Callback = function(Value)
        MiscState.bloomEnabled = Value
        if Value then enableBloom() else disableBloom() end
    end
})

local BloomSettings = BloomToggle:Settings()
BloomSettings:Slider({
    Name = "Intensity",
    Flag = "BloomIntensity",
    Min = 0,
    Max = 3,
    Default = 0.8,
    Suffix = "",
    Step = 0.1,
    Decimals = 1,
    Callback = function(Value)
        MiscState.bloomIntensity = Value
        updateBloom()
    end
})

BloomSettings:Slider({
    Name = "Size",
    Flag = "BloomSize",
    Min = 0,
    Max = 100,
    Default = 20,
    Suffix = "",
    Step = 1,
    Callback = function(Value)
        MiscState.bloomSize = Value
        updateBloom()
    end
})

BloomSettings:Slider({
    Name = "Threshold",
    Flag = "BloomThreshold",
    Min = 0,
    Max = 2,
    Default = 0.8,
    Suffix = "",
    Step = 0.1,
    Decimals = 1,
    Callback = function(Value)
        MiscState.bloomThreshold = Value
        updateBloom()
    end
})

local ColorCorrectionToggle = VisualExtraSection:Toggle({
    Name = "Color Correction",
    Flag = "ColorCorrectionEnabled",
    Default = false,
    Callback = function(Value)
        MiscState.colorCorrectionEnabled = Value
        if Value then enableColorCorrection() else disableColorCorrection() end
    end
})

local ColorCorrectionSettings = ColorCorrectionToggle:Settings()
ColorCorrectionSettings:Slider({
    Name = "Contrast",
    Flag = "ColorContrast",
    Min = -1,
    Max = 1,
    Default = 0.15,
    Suffix = "",
    Step = 0.05,
    Decimals = 2,
    Callback = function(Value)
        MiscState.colorContrast = Value
        updateColorCorrection()
    end
})

ColorCorrectionSettings:Slider({
    Name = "Saturation",
    Flag = "ColorSaturation",
    Min = -1,
    Max = 1,
    Default = 0.2,
    Suffix = "",
    Step = 0.05,
    Decimals = 2,
    Callback = function(Value)
        MiscState.colorSaturation = Value
        updateColorCorrection()
    end
})

ColorCorrectionSettings:Label("Tint Color"):Colorpicker({
    Name = "Tint Color",
    Flag = "ColorTint",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        MiscState.colorTint = Value
        updateColorCorrection()
    end
})

local SunRaysToggle = VisualExtraSection:Toggle({
    Name = "Sun Rays",
    Flag = "SunRaysEnabled",
    Default = false,
    Callback = function(Value)
        MiscState.sunRaysEnabled = Value
        if Value then enableSunRays() else disableSunRays() end
    end
})

local SunRaysSettings = SunRaysToggle:Settings()
SunRaysSettings:Slider({
    Name = "Intensity",
    Flag = "SunRaysIntensity",
    Min = 0,
    Max = 2,
    Default = 0.2,
    Suffix = "",
    Step = 0.05,
    Decimals = 2,
    Callback = function(Value)
        MiscState.sunRaysIntensity = Value
        updateSunRays()
    end
})

SunRaysSettings:Slider({
    Name = "Spread",
    Flag = "SunRaysSpread",
    Min = 0,
    Max = 1,
    Default = 0.75,
    Suffix = "",
    Step = 0.05,
    Decimals = 2,
    Callback = function(Value)
        MiscState.sunRaysSpread = Value
        updateSunRays()
    end
})

local DOFToggle = VisualExtraSection:Toggle({
    Name = "Depth of Field",
    Flag = "DOFEnabled",
    Default = false,
    Callback = function(Value)
        MiscState.dofEnabled = Value
        if Value then enableDOF() else disableDOF() end
    end
})

local DOFSettings = DOFToggle:Settings()
DOFSettings:Slider({
    Name = "Far Intensity",
    Flag = "DOFFarIntensity",
    Min = 0,
    Max = 1,
    Default = 0.15,
    Suffix = "",
    Step = 0.05,
    Decimals = 2,
    Callback = function(Value)
        MiscState.dofFarIntensity = Value
        updateDOF()
    end
})

DOFSettings:Slider({
    Name = "Focus Distance",
    Flag = "DOFFocusDistance",
    Min = 0,
    Max = 100,
    Default = 35,
    Suffix = "",
    Step = 1,
    Callback = function(Value)
        MiscState.dofFocusDistance = Value
        updateDOF()
    end
})

DOFSettings:Slider({
    Name = "In Focus Radius",
    Flag = "DOFInFocusRadius",
    Min = 0,
    Max = 100,
    Default = 25,
    Suffix = "",
    Step = 1,
    Callback = function(Value)
        MiscState.dofInFocusRadius = Value
        updateDOF()
    end
})

DOFSettings:Slider({
    Name = "Near Intensity",
    Flag = "DOFNearIntensity",
    Min = 0,
    Max = 1,
    Default = 0,
    Suffix = "",
    Step = 0.05,
    Decimals = 2,
    Callback = function(Value)
        MiscState.dofNearIntensity = Value
        updateDOF()
    end
})

VisualExtraSection:Toggle({
    Name = "Force Lighting",
    Flag = "ForceLighting",
    Default = false,
    Callback = function(Value)
        MiscState.forceLighting = Value
        if Value then enableLightingForce() else disableLightingForce() end
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

local WalkSpeedToggle = MoveSection:Toggle({
    Name = "Walk Speed",
    Flag = "SpeedEnabled",
    Default = false,
    Callback = function(Value)
        MovementState.speedEnabled = Value
    end
})

local WalkSpeedSettings = WalkSpeedToggle:Settings()
WalkSpeedSettings:Slider({
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

local JumpHeightToggle = MoveSection:Toggle({
    Name = "Jump Height",
    Flag = "JumpEnabled",
    Default = false,
    Callback = function(Value)
        MovementState.jumpEnabled = Value
    end
})

local JumpHeightSettings = JumpHeightToggle:Settings()
JumpHeightSettings:Slider({
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

local FlyToggle = MoveSection:Toggle({
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

local FlySettings = FlyToggle:Settings()
FlySettings:Slider({
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

local GravityToggle = MoveSection:Toggle({
    Name = "Custom Gravity",
    Flag = "GravityEnabled",
    Default = false,
    Callback = function(Value)
        MovementState.gravityEnabled = Value
        if not Value then Workspace.Gravity = defaultGravity end
    end
})

local GravitySettings = GravityToggle:Settings()
GravitySettings:Slider({
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

local playerListbox = PlayersSection:Listbox({
    Name = "Players",
    Flag = "PlayerListbox",
    Items = playerList,
    Multi = false,
    Callback = function(Value)
        if Value then
            selectedPlayerName = Value
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Name == Value then
                    trollTarget = plr
                    break
                end
            end
            notify("Monarch", "Selected: " .. Value, 2)
        end
    end
})

PlayersSection:Button({
    Name = "Refresh",
    Callback = function()
        updatePlayerList()
        playerListbox:Refresh(playerList)
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

local MiscPage = Window:Page({Name = "Misc"})
local MiscSection = MiscPage:Section({Name = "Misc", Side = 1})

local EmoteSection = MiscPage:Section({Name = "Emote", Side = 2})

local EmoteState = {
    enabled = false,
    emoteWheelLoaded = false
}

EmoteSection:Toggle({
    Name = "Enable Emote Wheel",
    Flag = "EmoteWheelEnabled",
    Default = false,
    Callback = function(Value)
        EmoteState.enabled = Value
        if Value and not EmoteState.emoteWheelLoaded then
            EmoteState.emoteWheelLoaded = true
            getgenv().Notify = function() end
            
            local success, err = pcall(function()
                local code = game:HttpGet("https://raw.githubusercontent.com/slizzey/monarch.lua/main/emote_wheel.lua")
                local func, loadErr = loadstring(code)
                if not func then
                    error("Loadstring error: " .. tostring(loadErr))
                end
                func()
            end)
            
            if not success then
                warn("Failed to load emote wheel: " .. tostring(err))
            else
                Library:Notification({
                    Title = "Emote Wheel",
                    Description = "Press . to open",
                    Icon = "71408678974152",
                    Duration = 3
                })
            end
        end
    end
})

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
        if GUI.BindToastGui then
            GUI.BindToastGui.ResetOnSpawn = not Value
        end
    end
})

local WaypointToggle = MiscSection:Toggle({
    Name = "Waypoints",
    Flag = "WaypointsEnabled",
    Default = false,
    Callback = function(Value)
        WaypointState.enabled = Value
        if not Value then
            for _, drawing in pairs(WaypointState.drawings) do
                if drawing.Text then drawing.Text:Remove() end
                if drawing.Line then drawing.Line:Remove() end
                if drawing.Dot then drawing.Dot:Remove() end
            end
            WaypointState.drawings = {}
        end
    end
})

local pendingWaypointName = ""

MiscSection:Textbox({
    Name = "Waypoint Name",
    Placeholder = "Enter name...",
    Callback = function(Value)
        pendingWaypointName = Value or ""
    end
})

MiscSection:Button({
    Name = "Add Waypoint",
    Callback = function()
        if pendingWaypointName == "" then return end

        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        table.insert(WaypointState.waypoints, {
            position = rootPart.Position,
            name = pendingWaypointName,
            color = Color3.fromRGB(100, 60, 180)
        })

        pendingWaypointName = ""
        updateWaypointDropdown()
    end
})

local waypointDropdown = MiscSection:Dropdown({
    Name = "Select Waypoint",
    Flag = "SelectedWaypoint",
    Options = {"No waypoints"},
    Default = nil,
    Callback = function(Value)
        for i, wp in ipairs(WaypointState.waypoints) do
            if wp.name == Value then
                WaypointState.selectedWaypoint = i
                break
            end
        end
    end
})

local function updateWaypointDropdown()
    local names = {}
    for _, wp in ipairs(WaypointState.waypoints) do
        table.insert(names, wp.name)
    end
    if #names == 0 then
        names = {"No waypoints"}
    end
    waypointDropdown:Refresh(names, nil)
end

updateWaypointDropdown()

MiscSection:Button({
    Name = "Teleport to Selected",
    Callback = function()
        if not WaypointState.selectedWaypoint then return end
        local waypoint = WaypointState.waypoints[WaypointState.selectedWaypoint]
        if not waypoint then return end

        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        rootPart.CFrame = CFrame.new(waypoint.position)
    end
})

MiscSection:Button({
    Name = "Delete Selected",
    Callback = function()
        if not WaypointState.selectedWaypoint then return end
        table.remove(WaypointState.waypoints, WaypointState.selectedWaypoint)
        WaypointState.selectedWaypoint = nil
        updateWaypointDropdown()
    end
})

MiscSection:Button({
    Name = "Clear All",
    Callback = function()
        WaypointState.waypoints = {}
        WaypointState.selectedWaypoint = nil
        for _, drawing in pairs(WaypointState.drawings) do
            if drawing.Text then drawing.Text:Remove() end
            if drawing.Line then drawing.Line:Remove() end
            if drawing.Dot then drawing.Dot:Remove() end
        end
        WaypointState.drawings = {}
        updateWaypointDropdown()
    end
})

MiscSection:Toggle({
    Name = "Show Distance",
    Flag = "WaypointShowDistance",
    Default = true,
    Callback = function(Value)
        WaypointState.showDistance = Value
    end
})

MiscSection:Toggle({
    Name = "Show Direction",
    Flag = "WaypointShowDirection",
    Default = true,
    Callback = function(Value)
        WaypointState.showDirection = Value
    end
})

local function worldToScreen(position)
    local screenPos, onScreen = Camera:WorldToScreenPoint(position)
    if onScreen then
        return Vector2.new(screenPos.X, screenPos.Y), true
    end
    return Vector2.new(0, 0), false
end

local function createWaypointDrawings()
    return {
        Text = Drawing.new("Text"),
        Line = Drawing.new("Line"),
        Dot = Drawing.new("Circle")
    }
end

local function configureTextDrawing(text, waypoint, screenPos, distance)
    text.Visible = true
    text.Position = screenPos + Vector2.new(0, -20)
    text.Color = waypoint.color
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.new(0, 0, 0)
    text.Text = WaypointState.showDistance and (waypoint.name .. " [" .. math.floor(distance) .. " studs]") or waypoint.name
end

local function configureLineDrawing(line, from, to, color)
    line.Visible = true
    line.From = from
    line.To = to
    line.Color = color
    line.Thickness = 1
    line.Transparency = 0.5
end

local function configureDotDrawing(dot, screenPos, color)
    dot.Visible = true
    dot.Position = screenPos
    dot.Color = color
    dot.Radius = 4
    dot.Filled = true
    dot.Thickness = 1
end

local function hideDrawings(drawings)
    drawings.Text.Visible = false
    drawings.Line.Visible = false
    drawings.Dot.Visible = false
end

local function cleanupDrawings(id, drawings)
    if drawings.Text then drawings.Text:Remove() end
    if drawings.Line then drawings.Line:Remove() end
    if drawings.Dot then drawings.Dot:Remove() end
    WaypointState.drawings[id] = nil
end

local function updateWaypoints()
    if not WaypointState.enabled then return end

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local playerPos = rootPart.Position

    for id, waypoint in pairs(WaypointState.waypoints) do
        if not WaypointState.drawings[id] then
            WaypointState.drawings[id] = createWaypointDrawings()
        end

        local drawings = WaypointState.drawings[id]
        local screenPos, onScreen = worldToScreen(waypoint.position)

        if onScreen then
            local distance = (waypoint.position - playerPos).Magnitude
            configureTextDrawing(drawings.Text, waypoint, screenPos, distance)

            if WaypointState.showDirection then
                local playerScreenPos, playerOnScreen = worldToScreen(playerPos)
                if playerOnScreen then
                    configureLineDrawing(drawings.Line, playerScreenPos, screenPos, waypoint.color)
                else
                    drawings.Line.Visible = false
                end
            else
                drawings.Line.Visible = false
            end

            configureDotDrawing(drawings.Dot, screenPos, waypoint.color)
        else
            hideDrawings(drawings)
        end
    end

    for id, drawings in pairs(WaypointState.drawings) do
        if not WaypointState.waypoints[id] then
            cleanupDrawings(id, drawings)
        end
    end
end

RunService.RenderStepped:Connect(updateWaypoints)

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
end)

Window:Category("Settings")
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)
Window:Init()
