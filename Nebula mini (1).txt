--[[
    NEBULA MINI HUB - Final Merged Version
    Combines N5 Duels logic with Nebula GUI
    - Full keybind system (rebindable)
    - Speed cogwheel: Normal & Carry mode config
    - Nebula steal bar with radius
    - No teleport section
    - No cogwheels except Speed
    - Modern black/dark-blue UI
]]

print("[NEBULA MINI HUB] Loading...")
repeat task.wait() until game:IsLoaded()

-- ══════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local pgui        = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════
-- SPEED / KEY DEFAULTS
-- ══════════════════════════════════════════
local NORMAL_SPEED = 60
local CARRY_SPEED  = 30

local speedToggled       = false
local autoBatToggled       = false
local autoBatKey         = Enum.KeyCode.E
local speedToggleKey     = Enum.KeyCode.Q
local autoLeftKey        = Enum.KeyCode.Z
local autoRightKey       = Enum.KeyCode.C
local autoLeftPlayKey    = Enum.KeyCode.J
local autoRightPlayKey   = Enum.KeyCode.K
local floatKey           = Enum.KeyCode.F
local guiToggleKey       = Enum.KeyCode.RightAlt
local tpDownKey          = Enum.KeyCode.G
local dropKey            = Enum.KeyCode.H

local guiVisible = true

-- ══════════════════════════════════════════
-- WAYPOINTS  (offset-editable, K7 style)
-- ══════════════════════════════════════════
local WP = {
    Left = {
        { label="L1", pos=Vector3.new(-476.48,-6.28, 92.73), offset=Vector3.new(0,0,0) },
        { label="L2", pos=Vector3.new(-483.12,-4.95, 94.80), offset=Vector3.new(0,0,0) },
    },
    Right = {
        { label="R1", pos=Vector3.new(-476.16,-6.52, 25.62), offset=Vector3.new(0,0,0) },
        { label="R2", pos=Vector3.new(-483.04,-5.09, 23.14), offset=Vector3.new(0,0,0) },
    },
    LeftPlay = {
        { label="LP1", pos=Vector3.new(-476.2,-6.5,  94.8), offset=Vector3.new(0,0,0) },
        { label="LP2", pos=Vector3.new(-484.1,-4.7,  94.7), offset=Vector3.new(0,0,0) },
        { label="LP3", pos=Vector3.new(-476.5,-6.1,   7.5), offset=Vector3.new(0,0,0) },
    },
    RightPlay = {
        { label="RP1", pos=Vector3.new(-476.2,-6.1,  25.8), offset=Vector3.new(0,0,0) },
        { label="RP2", pos=Vector3.new(-484.1,-4.7,  25.9), offset=Vector3.new(0,0,0) },
        { label="RP3", pos=Vector3.new(-476.2,-6.2, 113.5), offset=Vector3.new(0,0,0) },
    },
}
local function wpPos(wp) return wp.pos + wp.offset end

-- Keep legacy names working for the rest of the code
local POSITION_L1 = Vector3.new(-476.48, -6.28, 92.73)
local POSITION_L2 = Vector3.new(-483.12, -4.95, 94.80)
local POSITION_R1 = Vector3.new(-476.16, -6.52, 25.62)
local POSITION_R2 = Vector3.new(-483.04, -5.09, 23.14)

local ALP_P1 = Vector3.new(-476.2, -6.5, 94.8)
local ALP_P2 = Vector3.new(-484.1, -4.7, 94.7)
local ALP_P3 = Vector3.new(-476.5, -6.1, 7.5)

local ARP_P1 = Vector3.new(-476.2, -6.1, 25.8)
local ARP_P2 = Vector3.new(-484.1, -4.7, 25.9)
local ARP_P3 = Vector3.new(-476.2, -6.2, 113.5)

-- ══════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════
local Values = {
    STEAL_RADIUS       = 8,
    STEAL_DURATION     = 0.2,
    DEFAULT_GRAVITY    = 196.2,
    GalaxyGravityPercent = 70,
    HOP_POWER          = 35,
    HOP_COOLDOWN       = 0.08,
}

local Enabled = {
    AntiRagdoll        = false,
    AutoSteal          = false,
    Galaxy             = false,
    Optimizer          = false,
    Unwalk             = false,
    AutoLeftEnabled    = false,
    AutoRightEnabled   = false,
    AutoLeftPlayEnabled  = false,
    AutoRightPlayEnabled = false,
    FloatEnabled       = false,
    NoClip             = false,
    DarkMode           = false,
    MiniGuiEnabled     = false,
    WaypointESP        = false,
    Spinbot            = false,
    RagdollTP          = false,
    BatAimbot          = false,
    CounterMedusa      = false,
    MobileButtonsVisible = true,
    UILocked           = false,
    AutoCarryOnPickup  = false,
}

local Connections  = {}
local StealData    = {}
local VisualSetters = {}

local isStealing     = false
local stealStartTime = nil

local AutoLeftEnabled      = false
local AutoRightEnabled     = false
local AutoLeftPlayEnabled  = false
local AutoRightPlayEnabled = false

local autoLeftConnection      = nil
local autoRightConnection     = nil
local autoLeftPlayConnection  = nil
local autoRightPlayConnection = nil
local autoLeftPhase      = 1
local autoRightPhase     = 1
local autoLeftPlayPhase  = 1
local autoRightPlayPhase = 1

local galaxyVectorForce  = nil
local galaxyAttachment   = nil
local galaxyEnabled      = false
local hopsEnabled        = false
local lastHopTime        = 0
local spaceHeld          = false
local originalJumpPower  = 50

local floatEnabled   = false
local floatTargetY   = nil
local floatConn      = nil
local FLOAT_HEIGHT   = 10

local originalTransparency = {}
local xrayEnabled    = false
local savedAnimations = {}
local noClipTracked  = {}

local currentTransparency = 0
local h, hrp, speedLbl    = nil, nil, nil

-- Ragdoll TP state
local tpWasRagdolled   = false
local tpCooldown       = false
local tpStateConn, tpChildConn, tpChildRemConn = nil, nil, nil

-- Steal bar UI refs
local SBFill, SBPct, SBStatus, SBRadBtn, StealBarFrame
local stealBarTimer = 0

local modeLabel    = nil
local autoSaveLabel = nil

-- ══════════════════════════════════════════
-- CHARACTER HELPERS
-- ══════════════════════════════════════════
local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ══════════════════════════════════════════
-- STEAL HELPERS
-- ══════════════════════════════════════════
local function isMyPlotByName(pn)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(pn)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
    end
    return false
end

local function findNearestPrompt()
    local myHrp = getHRP()
    if not myHrp then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local np, nd, nn = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then continue end
        for _, pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local base  = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - myHrp.Position).Magnitude
                    if dist < nd and dist <= Values.STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then
                                    np, nd, nn = ch, dist, pod.Name; break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    return np, nd, nn
end

-- ══════════════════════════════════════════
-- STEAL
-- ══════════════════════════════════════════
local progressConnection = nil

local function ResetProgressBar()
    for _, lbl in ipairs(phantomLetterLabels) do lbl.TextTransparency = 1 end
    if SBPct    then SBPct.Visible = false end
    if SBFill   then SBFill.Size = UDim2.new(0,0,1,0) end
    if SBStatus then SBStatus.Text = "READY" end
end

local function UpdatePhantomLetters(prog)
    local numLetters = 7
    local lettersToShow = math.clamp(math.floor(prog * numLetters + 0.999), 0, numLetters)
    for i, lbl in ipairs(phantomLetterLabels) do lbl.TextTransparency = i <= lettersToShow and 0 or 1 end
    if SBPct then SBPct.Visible = true; SBPct.Text = math.floor(prog*100).."%" end
end

local function cachePromptData(prompt)
    if StealData[prompt] then return StealData[prompt] end
    local data = {hold={}, trigger={}, ready=true}
    pcall(function()
        if getconnections then
            for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if c.Function then table.insert(data.hold, c.Function) end end
            for _, c in ipairs(getconnections(prompt.Triggered)) do if c.Function then table.insert(data.trigger, c.Function) end end
        end
    end)
    StealData[prompt] = data
    return data
end

local function executeSteal(prompt, name)
    if isStealing then return end
    local data = cachePromptData(prompt)
    if not data.ready then return end
    data.ready = false isStealing = true stealStartTime = tick()
    if progressConnection then progressConnection:Disconnect() end
    progressConnection = RunService.Heartbeat:Connect(function()
        if not isStealing then if progressConnection then progressConnection:Disconnect() progressConnection = nil end return end
        local prog = math.clamp((tick()-stealStartTime)/Values.STEAL_DURATION, 0, 1)
        UpdatePhantomLetters(prog)
    end)
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(pcall, f) end
        task.wait(Values.STEAL_DURATION)
        for _, f in ipairs(data.trigger) do task.spawn(pcall, f) end
        if progressConnection then progressConnection:Disconnect() progressConnection = nil end
        ResetProgressBar()
        data.ready = true isStealing = false
    end)
end

local lastStealScan = 0
local function startAutoSteal()
    if Connections.autoSteal then return end
    Connections.autoSteal = RunService.Heartbeat:Connect(function()
        if not Enabled.AutoSteal or isStealing then return end
        local now = tick()
        if now - lastStealScan < 0.05 then return end
        lastStealScan = now
        local p, _, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
end

local function stopAutoSteal()
    if Connections.autoSteal then Connections.autoSteal:Disconnect() Connections.autoSteal = nil end
    isStealing = false
    if progressConnection then progressConnection:Disconnect() progressConnection = nil end
    ResetProgressBar()
end

-- ══════════════════════════════════════════
-- ANTI RAGDOLL
-- ══════════════════════════════════════════
local function startAntiRagdoll()
    if Connections.antiRagdoll then return end
    Connections.antiRagdoll = RunService.Heartbeat:Connect(function()
        if not Enabled.AntiRagdoll then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local humState = hum:GetState()
            if humState == Enum.HumanoidStateType.Physics or humState == Enum.HumanoidStateType.Ragdoll or humState == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum
                pcall(function()
                    if LocalPlayer.Character then
                        local PM = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
                        if PM then require(PM:FindFirstChild("ControlModule")):Enable() end
                    end
                end)
                if root then root.AssemblyLinearVelocity = Vector3.new(0,0,0) root.AssemblyAngularVelocity = Vector3.new(0,0,0) end
            end
        end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
        end
    end)
end

local function stopAntiRagdoll()
    if Connections.antiRagdoll then Connections.antiRagdoll:Disconnect(); Connections.antiRagdoll = nil end
end

-- ══════════════════════════════════════════
-- GALAXY
-- ══════════════════════════════════════════
local function captureJumpPower()
    local c = LocalPlayer.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid") if hum and hum.JumpPower > 0 then originalJumpPower = hum.JumpPower end end
end
task.spawn(function() task.wait(1); captureJumpPower() end)
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); captureJumpPower() end)

local function setupGalaxyForce()
    pcall(function()
        local c = LocalPlayer.Character; if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart"); if not r then return end
        if galaxyVectorForce then galaxyVectorForce:Destroy() end
        if galaxyAttachment  then galaxyAttachment:Destroy()  end
        galaxyAttachment = Instance.new("Attachment"); galaxyAttachment.Parent = r
        galaxyVectorForce = Instance.new("VectorForce")
        galaxyVectorForce.Attachment0 = galaxyAttachment
        galaxyVectorForce.ApplyAtCenterOfMass = true
        galaxyVectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
        galaxyVectorForce.Force = Vector3.new(0,0,0)
        galaxyVectorForce.Parent = r
    end)
end

local function updateGalaxyForce()
    if not galaxyEnabled or not galaxyVectorForce then return end
    local c = LocalPlayer.Character; if not c then return end
    local mass = 0
    for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then mass = mass + p:GetMass() end end
    local tg = Values.DEFAULT_GRAVITY * (Values.GalaxyGravityPercent/100)
    galaxyVectorForce.Force = Vector3.new(0, mass*(Values.DEFAULT_GRAVITY-tg)*0.95, 0)
end

local function adjustGalaxyJump()
    pcall(function()
        local c = LocalPlayer.Character; if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid"); if not hum then return end
        if not galaxyEnabled then hum.JumpPower = originalJumpPower; return end
        local ratio = math.sqrt((Values.DEFAULT_GRAVITY*(Values.GalaxyGravityPercent/100))/Values.DEFAULT_GRAVITY)
        hum.JumpPower = originalJumpPower * ratio
    end)
end

local function doMiniHop()
    if not hopsEnabled then return end
    pcall(function()
        local c = LocalPlayer.Character; if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not r or not hum then return end
        if tick() - lastHopTime < Values.HOP_COOLDOWN then return end
        lastHopTime = tick()
        if hum.FloorMaterial == Enum.Material.Air then
            r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, Values.HOP_POWER, r.AssemblyLinearVelocity.Z)
        end
    end)
end

local function startGalaxy() galaxyEnabled=true; hopsEnabled=true; setupGalaxyForce(); adjustGalaxyJump() end
local function stopGalaxy()
    galaxyEnabled=false; hopsEnabled=false
    if galaxyVectorForce then galaxyVectorForce:Destroy(); galaxyVectorForce=nil end
    if galaxyAttachment  then galaxyAttachment:Destroy();  galaxyAttachment=nil  end
    adjustGalaxyJump()
end

RunService.Heartbeat:Connect(function()
    if hopsEnabled and spaceHeld then doMiniHop() end
    if galaxyEnabled then updateGalaxyForce() end
end)

-- ══════════════════════════════════════════
-- UNWALK / NOCLIP
-- ══════════════════════════════════════════
local function startUnwalk()
    local c = LocalPlayer.Character; if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim = c:FindFirstChild("Animate")
    if anim then savedAnimations.Animate = anim:Clone(); anim:Destroy() end
end

local function stopUnwalk()
    local c = LocalPlayer.Character
    if c and savedAnimations.Animate then savedAnimations.Animate:Clone().Parent = c; savedAnimations.Animate = nil end
end

local function startNoClip()
    if Connections.noClip then return end
    Connections.noClip = RunService.Stepped:Connect(function()
        if not Enabled.NoClip then return end
        local playerParts = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                for _, part in ipairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        playerParts[part] = true
                        if part.CanCollide then part.CanCollide = false; noClipTracked[part] = true end
                    end
                end
            end
        end
        for part, _ in pairs(noClipTracked) do
            if not playerParts[part] then pcall(function() part.CanCollide = true end); noClipTracked[part] = nil end
        end
    end)
end

local function stopNoClip()
    if Connections.noClip then Connections.noClip:Disconnect(); Connections.noClip = nil end
    for part, _ in pairs(noClipTracked) do pcall(function() part.CanCollide = true end) end
    noClipTracked = {}
end

-- ══════════════════════════════════════════
-- DROP / TP DOWN
-- ══════════════════════════════════════════
local function doDropBrainrots()
    local r = getHRP(); if not r then return end
    r.AssemblyLinearVelocity = Vector3.new(0, 125, 0)
    task.wait(0.4)
    r.AssemblyLinearVelocity = Vector3.new(0, -600, 0)
end

local function doTPDown()
    local r = getHRP(); if r then r.CFrame = r.CFrame * CFrame.new(0, -20, 0) end
end

-- ══════════════════════════════════════════
-- OPTIMIZER / DARK MODE
-- ══════════════════════════════════════════
local function enableOptimizer()
    if getgenv and getgenv().NEBULA_OPT_ACTIVE then return end
    if getgenv then getgenv().NEBULA_OPT_ACTIVE = true end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false; Lighting.Brightness = 2; Lighting.FogEnd = 9e9; Lighting.FogStart = 9e9
        for _, fx in ipairs(Lighting:GetChildren()) do if fx:IsA("PostEffect") then fx.Enabled = false end end
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false; obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false; obj.Material = Enum.Material.Plastic
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then child:Destroy() end
                    end
                elseif obj:IsA("Sky") then obj:Destroy() end
            end)
        end
    end)
    xrayEnabled = true
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored and (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.88
            end
        end
    end)
end

local function disableOptimizer()
    if getgenv then getgenv().NEBULA_OPT_ACTIVE = false end
    if xrayEnabled then
        for part, value in pairs(originalTransparency) do if part then part.LocalTransparencyModifier = value end end
        originalTransparency = {}; xrayEnabled = false
    end
end

local darkCC = nil
local function enableDarkMode()
    if darkCC and darkCC.Parent then return end
    darkCC = Instance.new("ColorCorrectionEffect")
    darkCC.Name = "NebulaDarkMode"; darkCC.Brightness = -0.25; darkCC.Contrast = 0.1
    darkCC.Saturation = -0.1; darkCC.Enabled = true; darkCC.Parent = Lighting
end
local function disableDarkMode()
    if darkCC then darkCC:Destroy(); darkCC = nil end
end

-- ══════════════════════════════════════════
-- FLOAT
-- ══════════════════════════════════════════
local function updateFloatHeight()
    if not floatEnabled then return end
    local c = LocalPlayer.Character; if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart"); if not r then return end
    floatTargetY = r.Position.Y + FLOAT_HEIGHT
end

local function startFloat()
    local c = LocalPlayer.Character; if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart"); if not r then return end
    floatTargetY = r.Position.Y + FLOAT_HEIGHT; floatEnabled = true
    if floatConn then floatConn:Disconnect() end
    floatConn = RunService.Heartbeat:Connect(function()
        if not floatEnabled then floatConn:Disconnect(); floatConn = nil; return end
        local char = LocalPlayer.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
        local diff = floatTargetY - root.Position.Y
        if math.abs(diff) > 0.05 then
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, diff*12, root.AssemblyLinearVelocity.Z)
        end
    end)
end

local function stopFloat()
    floatEnabled = false; floatTargetY = nil
    if floatConn then floatConn:Disconnect(); floatConn = nil end
    local c = LocalPlayer.Character
    if c then local r = c:FindFirstChild("HumanoidRootPart") if r then r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X,-150,r.AssemblyLinearVelocity.Z) end end
end

-- ══════════════════════════════════════════
-- AUTO MOVEMENTS
-- ══════════════════════════════════════════
local function faceSouth()
    if Enabled.Spinbot then return end
    local c = LocalPlayer.Character; if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
    h.CFrame = CFrame.new(h.Position) * CFrame.Angles(0,0,0)
end
local function faceNorth()
    if Enabled.Spinbot then return end
    local c = LocalPlayer.Character; if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
    h.CFrame = CFrame.new(h.Position) * CFrame.Angles(0,math.rad(180),0)
end

local function stopAutoLeft()
    if autoLeftConnection then autoLeftConnection:Disconnect(); autoLeftConnection=nil end
    autoLeftPhase=1; AutoLeftEnabled=false; Enabled.AutoLeftEnabled=false
    local c = LocalPlayer.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid") if hum then hum:Move(Vector3.zero,false) end end
    if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(false, true) end
end

local function stopAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect(); autoRightConnection=nil end
    autoRightPhase=1; AutoRightEnabled=false; Enabled.AutoRightEnabled=false
    local c = LocalPlayer.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid") if hum then hum:Move(Vector3.zero,false) end end
    if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(false, true) end
end

local function stopAutoLeftPlay()
    if autoLeftPlayConnection then autoLeftPlayConnection:Disconnect(); autoLeftPlayConnection=nil end
    autoLeftPlayPhase=1; AutoLeftPlayEnabled=false; Enabled.AutoLeftPlayEnabled=false
    speedToggled=true; if modeLabel then modeLabel.Text="Mode: Carry" end
    local c = LocalPlayer.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid") if hum then hum:Move(Vector3.zero,false) end end
    if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(false, true) end
end

local function stopAutoRightPlay()
    if autoRightPlayConnection then autoRightPlayConnection:Disconnect(); autoRightPlayConnection=nil end
    autoRightPlayPhase=1; AutoRightPlayEnabled=false; Enabled.AutoRightPlayEnabled=false
    speedToggled=true; if modeLabel then modeLabel.Text="Mode: Carry" end
    local c = LocalPlayer.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid") if hum then hum:Move(Vector3.zero,false) end end
    if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(false, true) end
end

local function startAutoLeft()
    if autoLeftConnection then autoLeftConnection:Disconnect() end
    autoLeftPhase = 1
    autoLeftConnection = RunService.Heartbeat:Connect(function()
        if not AutoLeftEnabled then return end
        local c = LocalPlayer.Character if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local currentSpeed = NORMAL_SPEED
        local T1 = wpPos(WP.Left[1]); local T2 = wpPos(WP.Left[2])
        if autoLeftPhase == 1 then
            local dist = (Vector3.new(T1.X, h.Position.Y, T1.Z) - h.Position).Magnitude
            if dist < 1 then autoLeftPhase = 2 return end
            local dir = Vector3.new((T1-h.Position).X,0,(T1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity = Vector3.new(dir.X*currentSpeed,h.AssemblyLinearVelocity.Y,dir.Z*currentSpeed)
        elseif autoLeftPhase == 2 then
            local dist = (Vector3.new(T2.X, h.Position.Y, T2.Z) - h.Position).Magnitude
            if dist < 1 then
                hum:Move(Vector3.zero,false) h.AssemblyLinearVelocity = Vector3.new(0,0,0)
                AutoLeftEnabled=false Enabled.AutoLeftEnabled=false
                if autoLeftConnection then autoLeftConnection:Disconnect() autoLeftConnection=nil end
                autoLeftPhase=1
                if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(false,true) end
                faceSouth() return
            end
            local dir = Vector3.new((T2-h.Position).X,0,(T2-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity = Vector3.new(dir.X*currentSpeed,h.AssemblyLinearVelocity.Y,dir.Z*currentSpeed)
        end
    end)
end

local function startAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect() end
    autoRightPhase=1
    local arLastPos, arStuckTimer = nil, 0
    autoRightConnection = RunService.Heartbeat:Connect(function(dt)
        if not AutoRightEnabled then return end
        local c = LocalPlayer.Character if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local currentSpeed = NORMAL_SPEED
        local T1 = wpPos(WP.Right[1]); local T2 = wpPos(WP.Right[2])
        local currentPos = h.Position
        if arLastPos then
            if (currentPos-arLastPos).Magnitude < 0.05 then arStuckTimer=arStuckTimer+dt else arStuckTimer=0 end
        end
        arLastPos = currentPos
        if autoRightPhase == 1 then
            local dist = (Vector3.new(T1.X,h.Position.Y,T1.Z)-h.Position).Magnitude
            if dist < 1 then autoRightPhase=2 arStuckTimer=0 return end
            if arStuckTimer > 0.4 then
                arStuckTimer=0
                local sd=(T1-h.Position)
                local ss=Vector3.new(sd.X,0,sd.Z).Unit*math.min(4,sd.Magnitude)
                h.CFrame=CFrame.new(h.Position+ss) h.AssemblyLinearVelocity=Vector3.zero return
            end
            local dir=Vector3.new((T1-h.Position).X,0,(T1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*currentSpeed,h.AssemblyLinearVelocity.Y,dir.Z*currentSpeed)
        elseif autoRightPhase == 2 then
            local dist=(Vector3.new(T2.X,h.Position.Y,T2.Z)-h.Position).Magnitude
            if dist < 1 then
                hum:Move(Vector3.zero,false) h.AssemblyLinearVelocity=Vector3.new(0,0,0)
                AutoRightEnabled=false Enabled.AutoRightEnabled=false
                if autoRightConnection then autoRightConnection:Disconnect() autoRightConnection=nil end
                autoRightPhase=1
                if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(false,true) end
                faceNorth() return
            end
            if arStuckTimer > 0.4 then
                arStuckTimer=0
                local sd=(T2-h.Position)
                local ss=Vector3.new(sd.X,0,sd.Z).Unit*math.min(4,sd.Magnitude)
                h.CFrame=CFrame.new(h.Position+ss) h.AssemblyLinearVelocity=Vector3.zero return
            end
            local dir=Vector3.new((T2-h.Position).X,0,(T2-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*currentSpeed,h.AssemblyLinearVelocity.Y,dir.Z*currentSpeed)
        end
    end)
end

local function startAutoLeftPlay()
    if autoLeftPlayConnection then autoLeftPlayConnection:Disconnect() end
    autoLeftPlayPhase=1
    autoLeftPlayConnection=RunService.Heartbeat:Connect(function()
        if not AutoLeftPlayEnabled then return end
        local c=LocalPlayer.Character if not c then return end
        local h=c:FindFirstChild("HumanoidRootPart")
        local hum=c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local P1=wpPos(WP.LeftPlay[1]); local P2=wpPos(WP.LeftPlay[2]); local P3=wpPos(WP.LeftPlay[3])
        if autoLeftPlayPhase==1 then
            local dist=(Vector3.new(P1.X,h.Position.Y,P1.Z)-h.Position).Magnitude
            if dist<1.5 then speedToggled=true autoLeftPlayPhase=2 if modeLabel then modeLabel.Text="Mode: Carry" end return end
            local dir=Vector3.new((P1-h.Position).X,0,(P1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*NORMAL_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*NORMAL_SPEED)
        elseif autoLeftPlayPhase==2 then
            local dist=(Vector3.new(P2.X,h.Position.Y,P2.Z)-h.Position).Magnitude
            if dist<1.5 then autoLeftPlayPhase=3 return end
            local dir=Vector3.new((P2-h.Position).X,0,(P2-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        elseif autoLeftPlayPhase==3 then
            local dist=(Vector3.new(P1.X,h.Position.Y,P1.Z)-h.Position).Magnitude
            if dist<1.5 then autoLeftPlayPhase=4 return end
            local dir=Vector3.new((P1-h.Position).X,0,(P1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        elseif autoLeftPlayPhase==4 then
            local dist=(Vector3.new(P3.X,h.Position.Y,P3.Z)-h.Position).Magnitude
            if dist<1.5 then
                hum:Move(Vector3.zero,false) h.AssemblyLinearVelocity=Vector3.new(0,0,0)
                AutoLeftPlayEnabled=false Enabled.AutoLeftPlayEnabled=false
                if autoLeftPlayConnection then autoLeftPlayConnection:Disconnect() autoLeftPlayConnection=nil end
                autoLeftPlayPhase=1 speedToggled=true
                if modeLabel then modeLabel.Text="Mode: Carry" end
                if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(false,true) end
                return
            end
            local dir=Vector3.new((P3-h.Position).X,0,(P3-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        end
    end)
end

local function startAutoRightPlay()
    if autoRightPlayConnection then autoRightPlayConnection:Disconnect() end
    autoRightPlayPhase=1
    autoRightPlayConnection=RunService.Heartbeat:Connect(function()
        if not AutoRightPlayEnabled then return end
        local c=LocalPlayer.Character if not c then return end
        local h=c:FindFirstChild("HumanoidRootPart")
        local hum=c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local P1=wpPos(WP.RightPlay[1]); local P2=wpPos(WP.RightPlay[2]); local P3=wpPos(WP.RightPlay[3])
        if autoRightPlayPhase==1 then
            local dist=(Vector3.new(P1.X,h.Position.Y,P1.Z)-h.Position).Magnitude
            if dist<1.5 then speedToggled=true autoRightPlayPhase=2 if modeLabel then modeLabel.Text="Mode: Carry" end return end
            local dir=Vector3.new((P1-h.Position).X,0,(P1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*NORMAL_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*NORMAL_SPEED)
        elseif autoRightPlayPhase==2 then
            local dist=(Vector3.new(P2.X,h.Position.Y,P2.Z)-h.Position).Magnitude
            if dist<1.5 then autoRightPlayPhase=3 return end
            local dir=Vector3.new((P2-h.Position).X,0,(P2-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        elseif autoRightPlayPhase==3 then
            local dist=(Vector3.new(P1.X,h.Position.Y,P1.Z)-h.Position).Magnitude
            if dist<1.5 then autoRightPlayPhase=4 return end
            local dir=Vector3.new((P1-h.Position).X,0,(P1-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        elseif autoRightPlayPhase==4 then
            local dist=(Vector3.new(P3.X,h.Position.Y,P3.Z)-h.Position).Magnitude
            if dist<1.5 then
                hum:Move(Vector3.zero,false) h.AssemblyLinearVelocity=Vector3.new(0,0,0)
                AutoRightPlayEnabled=false Enabled.AutoRightPlayEnabled=false
                if autoRightPlayConnection then autoRightPlayConnection:Disconnect() autoRightPlayConnection=nil end
                autoRightPlayPhase=1 speedToggled=true
                if modeLabel then modeLabel.Text="Mode: Carry" end
                if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(false,true) end
                return
            end
            local dir=Vector3.new((P3-h.Position).X,0,(P3-h.Position).Z).Unit
            hum:Move(dir,false) h.AssemblyLinearVelocity=Vector3.new(dir.X*CARRY_SPEED,h.AssemblyLinearVelocity.Y,dir.Z*CARRY_SPEED)
        end
    end)
end



-- ══════════════════════════════════════════
-- BAT AIMBOT
-- ══════════════════════════════════════════
local function getBat()
    local char = LocalPlayer.Character; if not char then return nil end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool and tool.Name == "Bat" then return tool end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then local bt = bp:FindFirstChild("Bat"); if bt then return bt end end
    return nil
end

local function findNearestEnemy(myHRP)
    local nearest, nearestDist, nearestTorso = nil, math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local eh    = p.Character:FindFirstChild("HumanoidRootPart")
            local torso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
            local hum   = p.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health > 0 then
                local d = (eh.Position - myHRP.Position).Magnitude
                if d < nearestDist then nearestDist=d; nearest=eh; nearestTorso=torso or eh end
            end
        end
    end
    return nearest, nearestDist, nearestTorso
end

local function startBatAimbot()
    if Connections.batAimbot then return end
    Connections.batAimbot = RunService.Heartbeat:Connect(function()
        if not Enabled.BatAimbot then return end
        local c = LocalPlayer.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local bat = getBat()
        if not bat then return end -- only run if bat exists, but don't force equip
        local target, dist, torso = findNearestEnemy(h)
        if not target or not torso then return end
        local targetVel = torso.AssemblyLinearVelocity
        local dir = torso.Position - h.Position
        local flatDir = Vector3.new(dir.X, 0, dir.Z)
        local flatDist = flatDir.Magnitude
        local timeToReach = flatDist / 80
        local predictedPos = torso.Position + targetVel * timeToReach
        local spd = 58
        if flatDist > 1 then
            local moveDir = Vector3.new(predictedPos.X-h.Position.X, 0, predictedPos.Z-h.Position.Z).Unit
            local yDiff = torso.Position.Y - h.Position.Y
            local ySpeed = math.abs(yDiff) > 0.5 and math.clamp(yDiff*8, -100, 100) or targetVel.Y
            h.AssemblyLinearVelocity = Vector3.new(moveDir.X*spd, ySpeed, moveDir.Z*spd)
        else
            h.AssemblyLinearVelocity = Vector3.new(targetVel.X, targetVel.Y, targetVel.Z)
        end
    end)
end

local function stopBatAimbot()
    if Connections.batAimbot then Connections.batAimbot:Disconnect(); Connections.batAimbot = nil end
end

-- ══════════════════════════════════════════
-- SPEED HEARTBEAT
-- ══════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not (h and hrp) then return end
    if not h.Parent then return end
    if not (AutoLeftEnabled or AutoRightEnabled or AutoLeftPlayEnabled or AutoRightPlayEnabled) then
        local md = h.MoveDirection
        local speed = speedToggled and CARRY_SPEED or NORMAL_SPEED
        if md.Magnitude > 0.1 then
            hrp.AssemblyLinearVelocity = Vector3.new(md.X*speed, hrp.AssemblyLinearVelocity.Y, md.Z*speed)
        end
    end
    if speedLbl then
        local v = hrp.AssemblyLinearVelocity
        local spd = math.floor(Vector3.new(v.X,0,v.Z).Magnitude)
        local mode = speedToggled and "CARRY" or "NORMAL"
        speedLbl.Text = spd .. " — " .. mode
    end
end)

-- ══════════════════════════════════════════
-- CONFIG SAVE / LOAD
-- ══════════════════════════════════════════
local function saveConfig()
    local cfg = {
        normalSpeed=NORMAL_SPEED, carrySpeed=CARRY_SPEED,
        autoBatKey=autoBatKey.Name, speedToggleKey=speedToggleKey.Name,
        autoLeftKey=autoLeftKey.Name, autoRightKey=autoRightKey.Name,
        autoLeftPlayKey=autoLeftPlayKey.Name, autoRightPlayKey=autoRightPlayKey.Name,
        floatKey=floatKey.Name, guiToggleKey=guiToggleKey.Name,
        tpDownKey=tpDownKey.Name, dropKey=dropKey.Name,
        autoSteal=Enabled.AutoSteal, stealRadius=Values.STEAL_RADIUS, stealDuration=Values.STEAL_DURATION,
        antiRagdoll=Enabled.AntiRagdoll, galaxy=Enabled.Galaxy,
        galaxyGravity=Values.GalaxyGravityPercent, hopPower=Values.HOP_POWER,
        optimizer=Enabled.Optimizer, unwalk=Enabled.Unwalk, noClip=Enabled.NoClip,
        darkMode=Enabled.DarkMode, floatHeight=FLOAT_HEIGHT,
        uiTransparency=currentTransparency, miniGuiEnabled=Enabled.MiniGuiEnabled,
        batAimbot=Enabled.BatAimbot,
    }
    local ok = false
    if writefile then pcall(function() writefile("NebulaHubConfig.json", HttpService:JSONEncode(cfg)); ok=true end) end
    return ok
end

local function loadConfig()
    if not isfile or not readfile then return end
    local ex; pcall(function() ex = isfile("NebulaHubConfig.json") end); if not ex then return end
    local ok, cfg = pcall(function() return HttpService:JSONDecode(readfile("NebulaHubConfig.json")) end)
    if not ok or not cfg then return end
    if cfg.normalSpeed and cfg.normalSpeed >= 10 and cfg.normalSpeed <= 300 then NORMAL_SPEED = cfg.normalSpeed end
    if cfg.carrySpeed  and cfg.carrySpeed  >= 10 and cfg.carrySpeed  <= 300 then CARRY_SPEED  = cfg.carrySpeed  end
    if cfg.speedToggleKey     and Enum.KeyCode[cfg.speedToggleKey]     then speedToggleKey     = Enum.KeyCode[cfg.speedToggleKey]     end
    if cfg.autoLeftKey        and Enum.KeyCode[cfg.autoLeftKey]        then autoLeftKey        = Enum.KeyCode[cfg.autoLeftKey]        end
    if cfg.autoRightKey       and Enum.KeyCode[cfg.autoRightKey]       then autoRightKey       = Enum.KeyCode[cfg.autoRightKey]       end
    if cfg.autoLeftPlayKey    and Enum.KeyCode[cfg.autoLeftPlayKey]    then autoLeftPlayKey    = Enum.KeyCode[cfg.autoLeftPlayKey]    end
    if cfg.autoRightPlayKey   and Enum.KeyCode[cfg.autoRightPlayKey]   then autoRightPlayKey   = Enum.KeyCode[cfg.autoRightPlayKey]   end
    if cfg.floatKey           and Enum.KeyCode[cfg.floatKey]           then floatKey           = Enum.KeyCode[cfg.floatKey]           end
    if cfg.guiToggleKey       and Enum.KeyCode[cfg.guiToggleKey]       then guiToggleKey       = Enum.KeyCode[cfg.guiToggleKey]       end
    if cfg.tpDownKey          and Enum.KeyCode[cfg.tpDownKey]          then tpDownKey          = Enum.KeyCode[cfg.tpDownKey]          end
    if cfg.dropKey            and Enum.KeyCode[cfg.dropKey]            then dropKey            = Enum.KeyCode[cfg.dropKey]            end
    if cfg.stealRadius        then Values.STEAL_RADIUS = cfg.stealRadius       end
    if cfg.stealDuration      then Values.STEAL_DURATION = cfg.stealDuration   end
    if cfg.galaxyGravity      then Values.GalaxyGravityPercent = cfg.galaxyGravity end
    if cfg.hopPower           then Values.HOP_POWER = cfg.hopPower             end
    if cfg.floatHeight        then FLOAT_HEIGHT = math.clamp(cfg.floatHeight, 1, 20) end
    if cfg.uiTransparency     then currentTransparency = math.clamp(cfg.uiTransparency, 0, 1) end
    if cfg.antiRagdoll ~= nil then Enabled.AntiRagdoll = cfg.antiRagdoll end
    if cfg.autoSteal   ~= nil then Enabled.AutoSteal   = cfg.autoSteal   end
    if cfg.galaxy      ~= nil then Enabled.Galaxy      = cfg.galaxy      end
    if cfg.optimizer   ~= nil then Enabled.Optimizer   = cfg.optimizer   end
    if cfg.unwalk      ~= nil then Enabled.Unwalk      = cfg.unwalk      end
    if cfg.noClip      ~= nil then Enabled.NoClip      = cfg.noClip      end
    if cfg.darkMode    ~= nil then Enabled.DarkMode    = cfg.darkMode    end
    if cfg.miniGuiEnabled ~= nil then Enabled.MiniGuiEnabled = cfg.miniGuiEnabled end
    if cfg.autoBatKey  and Enum.KeyCode[cfg.autoBatKey]  then autoBatKey  = Enum.KeyCode[cfg.autoBatKey]  end
    if cfg.batAimbot ~= nil then Enabled.BatAimbot = cfg.batAimbot end
end

loadConfig()


-- ══════════════════════════════════════════
-- COUNTER MEDUSA  (Eppilson source, faster cooldowns)
-- ══════════════════════════════════════════
local medusaNames = { ["medusa's head"]=true, ["medusa"]=true }
local medusaCounterConn    = nil
local medusaToolConns      = {}
local medusaPlayerConns    = {}
local lastMedusaUse        = 0
local lastBoogieUse        = 0

local function isMedusaToolName(name)
    if not name then return false end
    local lower = name:lower()
    if medusaNames[lower] then return true end
    return lower:find("medusa") ~= nil
end

local function isBoogieName(name)
    if not name then return false end
    return name:lower():find("boogie") ~= nil
end

local function safeDiscMedusa(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function() conn:Disconnect() end)
    end
end

local function getMedusaTool()
    local char = LocalPlayer.Character
    if char then
        for _, i in ipairs(char:GetChildren()) do
            if i:IsA("Tool") and isMedusaToolName(i.Name) then return i end
        end
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, i in ipairs(bp:GetChildren()) do
            if i:IsA("Tool") and isMedusaToolName(i.Name) then return i end
        end
    end
end

local function getBoogieTool()
    local char = LocalPlayer.Character
    if char then
        for _, i in ipairs(char:GetChildren()) do
            if i:IsA("Tool") and isBoogieName(i.Name) then return i end
        end
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, i in ipairs(bp:GetChildren()) do
            if i:IsA("Tool") and isBoogieName(i.Name) then return i end
        end
    end
end

local function enemyHasMedusa(character)
    if not character then return false end
    for _, i in ipairs(character:GetChildren()) do
        if i:IsA("Tool") and isMedusaToolName(i.Name) then return true end
    end
    return false
end

local function activateMedusa(tool)
    if not tool then return end
    local now = workspace:GetServerTimeNow()
    if now - lastMedusaUse <= 0.3 then return end  -- faster: was 1.5s
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if tool.Parent ~= LocalPlayer.Character then pcall(function() hum:EquipTool(tool) end) end
    pcall(function() if type(tool.Activate) == "function" then tool:Activate() end end)
    lastMedusaUse = now
    task.delay(0.1, function()  -- faster: was 0.35s
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h:UnequipTools() end) end
    end)
end

local function activateBoogie(tool)
    if not tool then return end
    local now = workspace:GetServerTimeNow()
    if now - lastBoogieUse <= 0.3 then return end  -- faster: was 1.5s
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if tool.Parent ~= LocalPlayer.Character then pcall(function() hum:EquipTool(tool) end) end
    pcall(function() if type(tool.Activate) == "function" then tool:Activate() end end)
    lastBoogieUse = now
    task.delay(0.1, function()  -- faster: was 0.35s
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h:UnequipTools() end) end
    end)
end

local function useCounterTool()
    local now = workspace:GetServerTimeNow()
    if now - lastMedusaUse > 0.3 then
        local t = getMedusaTool()
        if t then activateMedusa(t); return true end
    end
    if now - lastBoogieUse > 0.3 then
        local t = getBoogieTool()
        if t then activateBoogie(t); return true end
    end
    return false
end

local function unbindMedusaTool(tool)
    if medusaToolConns[tool] then
        safeDiscMedusa(medusaToolConns[tool])
        medusaToolConns[tool] = nil
    end
end

local function bindMedusaTool(tool)
    if not tool or not tool:IsA("Tool") or medusaToolConns[tool] then return end
    if not isMedusaToolName(tool.Name) then return end
    local conn = tool.Activated:Connect(function()
        if not Enabled.CounterMedusa then return end
        local attackerRoot = tool.Parent and tool.Parent:FindFirstChild("HumanoidRootPart")
        local myHRP = getHRP()
        if not (attackerRoot and myHRP) then return end
        if (attackerRoot.Position - myHRP.Position).Magnitude <= 20 then
            useCounterTool()
        end
    end)
    medusaToolConns[tool] = conn
    tool.Destroying:Connect(function() unbindMedusaTool(tool) end)
end

local function unbindPlayerMedusa(plr)
    local list = medusaPlayerConns[plr]
    if list then
        for _, c in ipairs(list) do safeDiscMedusa(c) end
        medusaPlayerConns[plr] = nil
    end
end

local function bindPlayerMedusa(plr)
    if not plr or plr == LocalPlayer then return end
    unbindPlayerMedusa(plr)
    local conns = {}
    local function scan(char)
        if not char then return end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then bindMedusaTool(child) end
        end
        table.insert(conns, char.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then bindMedusaTool(obj) end
        end))
    end
    local cChar = plr.Character or plr.CharacterAdded:Wait()
    scan(cChar)
    table.insert(conns, plr.CharacterAdded:Connect(function(c) scan(c) end))
    medusaPlayerConns[plr] = conns
end

local function startCounterMedusa()
    if medusaCounterConn then return end
    Enabled.CounterMedusa = true
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then bindPlayerMedusa(plr) end
    end
    medusaPlayerConns["_added"] = Players.PlayerAdded:Connect(bindPlayerMedusa)
    medusaCounterConn = RunService.Heartbeat:Connect(function()
        if not Enabled.CounterMedusa then return end
        local myHRP = getHRP(); if not myHRP then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local ch = plr.Character
                local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                if hrp and enemyHasMedusa(ch) then
                    if (hrp.Position - myHRP.Position).Magnitude <= 5 then
                        useCounterTool(); break
                    end
                end
            end
        end
    end)
end

local function stopCounterMedusa()
    Enabled.CounterMedusa = false
    if medusaCounterConn then safeDiscMedusa(medusaCounterConn); medusaCounterConn = nil end
    if medusaPlayerConns["_added"] then safeDiscMedusa(medusaPlayerConns["_added"]); medusaPlayerConns["_added"] = nil end
    for tool, _ in pairs(medusaToolConns) do unbindMedusaTool(tool) end
    for plr, _ in pairs(medusaPlayerConns) do
        if plr ~= "_added" then unbindPlayerMedusa(plr) end
    end
end

-- ══════════════════════════════════════════
-- RAGDOLL TP
-- ══════════════════════════════════════════
local TP_PRE_STEP = Vector3.new(-452.5, -6.6, 57.7)
local TP_STEPS = {
    Left  = { Vector3.new(-475.0, -6.6, 94.7), Vector3.new(-482.6, -4.7, 94.6) },
    Right = { Vector3.new(-475.2, -6.6, 23.5), Vector3.new(-482.2, -4.7, 23.4) },
}
local TP_PRE_STEP_DELAY = 0.10
local TP_STEP_DELAY     = 0.10
local TP_COOLDOWN_SEC   = 1.2

local MEDUSA_OBJECT_NAMES = {
    ["Petrified"]=true,["Petrify"]=true,["Stone"]=true,["MedusaStone"]=true,
    ["MedusaEffect"]=true,["Stoned"]=true,["MedusaHead"]=true,["Frozen"]=true,
    ["Statue"]=true,["PetrifyEffect"]=true,
}

local function isCharacterPetrified(char)
    if not char then return false end
    for _, obj in ipairs(char:GetChildren()) do
        if MEDUSA_OBJECT_NAMES[obj.Name] then return true end
        if obj:IsA("BoolValue") or obj:IsA("IntValue") then
            local low = obj.Name:lower()
            if low:find("medusa") or low:find("petri") or low:find("stone") or low:find("statue") then return true end
        end
    end
    local ok, CS = pcall(function() return game:GetService("CollectionService") end)
    if ok and CS then
        for _, tag in ipairs(CS:GetTags(char)) do
            local low = tag:lower()
            if low:find("medusa") or low:find("petri") or low:find("stone") or low:find("statue") then return true end
        end
    end
    return false
end

local function tpMoveTo(pos)
    local r = getHRP(); if not r then return end
    r.CFrame = CFrame.new(pos)
    r.AssemblyLinearVelocity = Vector3.zero
end

local function detectEnemySide()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return "Left" end
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        if sign then
            local yb = sign:FindFirstChild("YourBase")
            if yb and yb:IsA("BillboardGui") and yb.Enabled then
                local part = plot:FindFirstChildWhichIsA("BasePart")
                local z = part and part.Position.Z or 0
                return z > 60 and "Right" or "Left"
            end
        end
    end
    return "Left"
end

local function teleportToBase()
    if tpCooldown then return end
    if isCharacterPetrified(LocalPlayer.Character) then return end
    tpCooldown = true
    local side = detectEnemySide()
    local steps = TP_STEPS[side]
    tpMoveTo(TP_PRE_STEP)
    task.delay(TP_PRE_STEP_DELAY, function()
        tpMoveTo(steps[1])
        task.delay(TP_STEP_DELAY, function()
            tpMoveTo(steps[2])
            task.wait(0.05)
            tpMoveTo(steps[2])
            task.delay(TP_COOLDOWN_SEC, function() tpCooldown = false end)
        end)
    end)
end

local TP_RAGDOLL_STATES = {
    [Enum.HumanoidStateType.Physics]     = true,
    [Enum.HumanoidStateType.FallingDown] = true,
    [Enum.HumanoidStateType.Ragdoll]     = true,
}

local function hookTPCharacter(char)
    if tpStateConn    then tpStateConn:Disconnect();    tpStateConn    = nil end
    if tpChildConn    then tpChildConn:Disconnect();    tpChildConn    = nil end
    if tpChildRemConn then tpChildRemConn:Disconnect(); tpChildRemConn = nil end
    local hum = char:WaitForChild("Humanoid")
    tpStateConn = hum.StateChanged:Connect(function(_, newState)
        if not Enabled.RagdollTP then return end
        if TP_RAGDOLL_STATES[newState] then
            if isCharacterPetrified(char) then return end
            if not tpWasRagdolled then tpWasRagdolled = true; task.defer(teleportToBase) end
        else
            tpWasRagdolled = false
        end
    end)
    tpChildConn = char.ChildAdded:Connect(function(child)
        if not Enabled.RagdollTP then return end
        if MEDUSA_OBJECT_NAMES[child.Name] then tpWasRagdolled = false; return end
        if child:IsA("BoolValue") or child:IsA("IntValue") then
            local low = child.Name:lower()
            if low:find("medusa") or low:find("petri") or low:find("stone") or low:find("statue") then
                tpWasRagdolled = false; return
            end
        end
        if child.Name == "Ragdoll" or child.Name == "IsRagdoll" then
            if not tpWasRagdolled then tpWasRagdolled = true; task.defer(teleportToBase) end
        end
    end)
    tpChildRemConn = char.ChildRemoved:Connect(function(child)
        if child.Name == "Ragdoll" or child.Name == "IsRagdoll" then tpWasRagdolled = false end
    end)
end

local function startRagdollTP()
    tpWasRagdolled = false; tpCooldown = false
    local char = LocalPlayer.Character
    if char then hookTPCharacter(char) end
end

local function stopRagdollTP()
    if tpStateConn    then tpStateConn:Disconnect();    tpStateConn    = nil end
    if tpChildConn    then tpChildConn:Disconnect();    tpChildConn    = nil end
    if tpChildRemConn then tpChildRemConn:Disconnect(); tpChildRemConn = nil end
    tpWasRagdolled = false
end

LocalPlayer.CharacterAdded:Connect(function(char)
    tpWasRagdolled = false; tpCooldown = false
    if Enabled.RagdollTP then hookTPCharacter(char) end
end)


local espConn   = nil

-- All waypoints across all 4 routes — covers Left, Right, LeftPlay, RightPlay
-- Each entry holds a direct reference to the WP entry so offset changes propagate instantly
local ESP_DEFS = {
    { wpFn = function() return WP.Left[1]      end, label = "L1",  color = Color3.fromRGB(109, 112, 255) },
    { wpFn = function() return WP.Left[2]      end, label = "L2",  color = Color3.fromRGB(150,  90, 255) },
    { wpFn = function() return WP.Right[1]     end, label = "R1",  color = Color3.fromRGB(52,  211, 153) },
    { wpFn = function() return WP.Right[2]     end, label = "R2",  color = Color3.fromRGB(36,  180, 120) },
    { wpFn = function() return WP.LeftPlay[1]  end, label = "LP1", color = Color3.fromRGB(251, 191,  36) },
    { wpFn = function() return WP.LeftPlay[2]  end, label = "LP2", color = Color3.fromRGB(255, 160,  30) },
    { wpFn = function() return WP.LeftPlay[3]  end, label = "LP3", color = Color3.fromRGB(255, 120,  20) },
    { wpFn = function() return WP.RightPlay[1] end, label = "RP1", color = Color3.fromRGB(248, 113, 113) },
    { wpFn = function() return WP.RightPlay[2] end, label = "RP2", color = Color3.fromRGB(240,  80,  80) },
    { wpFn = function() return WP.RightPlay[3] end, label = "RP3", color = Color3.fromRGB(220,  50,  50) },
}

-- Direct part references keyed by def index — rebuilt in buildESP
local espParts = {}

-- Call this any time a waypoint offset changes to immediately move its ESP marker
local function refreshESPPart(defIdx)
    local entry = espParts[defIdx]
    if not entry then return end
    local def = ESP_DEFS[defIdx]
    local wp  = def.wpFn()
    local newPos = wpPos(wp)
    entry.part.CFrame = CFrame.new(newPos)
    -- Update billboard label to show offset if non-zero
    local ox, oz = math.floor(wp.offset.X), math.floor(wp.offset.Z)
    local suffix = (ox ~= 0 or oz ~= 0) and (" [" .. ox .. "," .. oz .. "]") or ""
    entry.lbl.Text = def.label .. suffix
end

-- Expose so the waypoint editor can call it immediately on offset change
_G.NebulaESPRefresh = refreshESPPart
-- Expose the full rebuild for when ESP is toggled back on
_G.NebulaESPRebuild = nil  -- set below

local function buildESP()
    if espFolder then espFolder:Destroy() end
    espFolder = Instance.new("Folder")
    espFolder.Name = "NebulaMiniHubESP"
    espFolder.Parent = workspace
    espParts = {}

    for idx, def in ipairs(ESP_DEFS) do
        local wp  = def.wpFn()
        local pos = wpPos(wp)

        local part = Instance.new("Part")
        part.Name = "ESPBox_" .. def.label
        part.Size = Vector3.new(1.5, 2.5, 1.5)
        part.CFrame = CFrame.new(pos)
        part.Anchored = true
        part.CanCollide = false; part.CanQuery = false; part.CanTouch = false
        part.Transparency = 1
        part.Parent = espFolder

        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = part; box.Size = part.Size
        box.Color3 = def.color; box.AlwaysOnTop = true
        box.ZIndex = 5; box.Transparency = 0.5
        box.Parent = part

        local sel = Instance.new("SelectionBox")
        sel.Adornee = part; sel.Color3 = def.color
        sel.LineThickness = 0.04; sel.SurfaceTransparency = 1
        sel.Parent = part

        local bb = Instance.new("BillboardGui")
        bb.Adornee = part; bb.Size = UDim2.new(0, 110, 0, 22)
        bb.StudsOffset = Vector3.new(0, 2.5, 0); bb.AlwaysOnTop = true
        bb.Parent = part

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
        lbl.Text = def.label; lbl.TextColor3 = def.color
        lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 12
        lbl.TextStrokeTransparency = 0.1; lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        lbl.Parent = bb

        -- Store direct refs so refreshESPPart can update without searching
        espParts[idx] = { part = part, box = box, lbl = lbl }
    end

    -- Animate box pulse on heartbeat — pure visual, no position recalc needed here
    -- (positions are updated immediately via refreshESPPart on offset change)
    if espConn then espConn:Disconnect() end
    espConn = RunService.Heartbeat:Connect(function()
        if not Enabled.WaypointESP or not espFolder or not espFolder.Parent then return end
        local t = tick()
        for _, entry in pairs(espParts) do
            if entry.box and entry.box.Parent then
                entry.box.Transparency = 0.45 + 0.25 * math.abs(math.sin(t * 1.8))
            end
        end
    end)
end

_G.NebulaESPRebuild = buildESP

local function startWaypointESP()
    buildESP(); Enabled.WaypointESP = true
end

local function stopWaypointESP()
    Enabled.WaypointESP = false
    if espConn then espConn:Disconnect(); espConn = nil end
    if espFolder then espFolder:Destroy(); espFolder = nil end
    espParts = {}
end

-- ══════════════════════════════════════════
-- SPINBOT
-- ══════════════════════════════════════════
local spinConn        = nil
local spinAngle       = 0
local spinAutoRotConn = nil
local SPIN_SPEED      = 18 -- degrees per frame (kept for nudge compat)
local SPIN_RAD_S      = 60 -- radians per second of angular velocity

local function cleanupSpin()
    if spinAutoRotConn then spinAutoRotConn:Disconnect(); spinAutoRotConn = nil end
    RunService:UnbindFromRenderStep("NebulaSpinbot")
    -- Zero out any leftover angular velocity
    local hrp = getHRP()
    if hrp then pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end) end
    -- Restore AutoRotate
    local c = LocalPlayer.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.AutoRotate = true end) end
end

local function startSpinbot()
    if spinConn then return end
    Enabled.Spinbot = true
    spinAngle = 0

    RunService:UnbindFromRenderStep("NebulaSpinbot")

    -- Suppress AutoRotate every heartbeat so shiftlock can never reclaim it
    if spinAutoRotConn then spinAutoRotConn:Disconnect() end
    spinAutoRotConn = RunService.Heartbeat:Connect(function()
        if not Enabled.Spinbot then return end
        local c = LocalPlayer.Character; if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum and hum.AutoRotate then
            pcall(function() hum.AutoRotate = false end)
        end
    end)

    local c = LocalPlayer.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.AutoRotate = false end) end

    -- Drive spin via raw angular velocity — nothing can override this,
    -- not shiftlock, not BodyGyro, not AlignOrientation conflicts.
    -- Y-axis = yaw. Positive = counter-clockwise from above.
    RunService:BindToRenderStep("NebulaSpinbot", Enum.RenderPriority.Last.Value + 1, function()
        if not Enabled.Spinbot then return end
        local hrp = getHRP(); if not hrp then return end
        spinAngle = (spinAngle + SPIN_SPEED) % 360
        hrp.AssemblyAngularVelocity = Vector3.new(0, SPIN_RAD_S, 0)
    end)

    spinConn = true
end

local function stopSpinbot()
    Enabled.Spinbot = false
    spinConn = nil
    cleanupSpin()
end

LocalPlayer.CharacterAdded:Connect(function()
    if Enabled.Spinbot then
        spinConn = nil
        if spinAutoRotConn then spinAutoRotConn:Disconnect(); spinAutoRotConn = nil end
        RunService:UnbindFromRenderStep("NebulaSpinbot")
        task.wait(0.5)
        startSpinbot()
    end
end)

-- ══════════════════════════════════════════
-- WAYPOINT EDITOR UI  (vertical card layout)
-- ══════════════════════════════════════════
local wpEditorGui = nil

local WP_C = {
    bg        = Color3.fromRGB(7,  7,  14),
    card      = Color3.fromRGB(12, 12, 24),
    cardInner = Color3.fromRGB(17, 17, 34),
    border    = Color3.fromRGB(60, 55,140),
    borderDim = Color3.fromRGB(24, 22, 56),
    accent    = Color3.fromRGB(120,100,255),
    accent2   = Color3.fromRGB(190, 80,255),
    accentGlow= Color3.fromRGB(190,180,255),
    text      = Color3.fromRGB(245,245,255),
    textDim   = Color3.fromRGB(150,150,210),
    textMid   = Color3.fromRGB(70, 68,120),
    headerBg  = Color3.fromRGB(5,  5,  12),
    btnBg     = Color3.fromRGB(22, 22, 46),
    axX       = Color3.fromRGB(248,113,113),
    axZ       = Color3.fromRGB(100,180,255),
}

local function openWPPanel(side)
    if wpEditorGui and wpEditorGui.Parent then
        if wpEditorGui:GetAttribute("Side") == side then
            wpEditorGui:Destroy(); wpEditorGui = nil; return
        end
        wpEditorGui:Destroy(); wpEditorGui = nil
    end

    local wps = WP[side]
    if not wps then return end

    local PANEL_W = 220
    local HDR_H   = 52
    local CARD_H  = 80
    local CARD_GAP= 6
    local PAD     = 10
    local RESET_H = 32
    local PANEL_H = HDR_H + PAD + #wps*(CARD_H+CARD_GAP) - CARD_GAP + PAD + RESET_H + PAD

    local sideName = side:gsub("Play"," PLAY"):upper()

    local eGui = Instance.new("ScreenGui")
    eGui.Name="NebulaWPEditor"; eGui.ResetOnSpawn=false
    eGui.DisplayOrder=20; eGui.Parent=pgui
    eGui:SetAttribute("Side",side)
    wpEditorGui = eGui

    local panel = Instance.new("Frame")
    panel.Size=UDim2.new(0,PANEL_W,0,PANEL_H)
    panel.Position=UDim2.new(0.5,-PANEL_W/2,0.5,-PANEL_H/2)
    panel.BackgroundColor3=WP_C.bg
    panel.BorderSizePixel=0; panel.Active=true; panel.Draggable=true
    panel.ZIndex=50; panel.Parent=eGui
    Instance.new("UICorner",panel).CornerRadius=UDim.new(0,16)
    do local s=Instance.new("UIStroke"); s.Color=WP_C.accent; s.Thickness=1.5; s.Transparency=0.45; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=panel end
    do local g=Instance.new("Frame"); g.Size=UDim2.new(0.45,0,0,1); g.Position=UDim2.new(0.275,0,0,1); g.BackgroundColor3=Color3.fromRGB(200,195,255); g.BackgroundTransparency=0.5; g.BorderSizePixel=0; g.ZIndex=60; g.Parent=panel; Instance.new("UICorner",g).CornerRadius=UDim.new(1,0) end

    -- Header
    local hdr=Instance.new("Frame"); hdr.Size=UDim2.new(1,0,0,HDR_H); hdr.BackgroundColor3=WP_C.headerBg; hdr.BorderSizePixel=0; hdr.ZIndex=51; hdr.Parent=panel
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,16)
    do local sq=Instance.new("Frame"); sq.Size=UDim2.new(1,0,0,16); sq.Position=UDim2.new(0,0,1,-16); sq.BackgroundColor3=WP_C.headerBg; sq.BorderSizePixel=0; sq.ZIndex=51; sq.Parent=hdr end
    do local tint=Instance.new("Frame"); tint.Size=UDim2.new(1,0,1,0); tint.BackgroundColor3=WP_C.headerBg; tint.BackgroundTransparency=0; tint.BorderSizePixel=0; tint.ZIndex=51; tint.Parent=hdr; Instance.new("UICorner",tint).CornerRadius=UDim.new(0,16); local tg=Instance.new("UIGradient"); tg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(20,10,56)),ColorSequenceKeypoint.new(0.6,Color3.fromRGB(7,7,18)),ColorSequenceKeypoint.new(1,Color3.fromRGB(16,6,44))}; tg.Rotation=115; tg.Parent=tint end
    do local rule=Instance.new("Frame"); rule.Size=UDim2.new(1,0,0,2); rule.Position=UDim2.new(0,0,1,-2); rule.BackgroundColor3=WP_C.accent; rule.BorderSizePixel=0; rule.ZIndex=53; rule.Parent=hdr; local rg=Instance.new("UIGradient"); rg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.35,WP_C.accent),ColorSequenceKeypoint.new(0.65,WP_C.accent2),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}; rg.Parent=rule end
    do local ico=Instance.new("Frame"); ico.Size=UDim2.new(0,32,0,32); ico.Position=UDim2.new(0,12,0.5,-16); ico.BorderSizePixel=0; ico.ZIndex=53; ico.Parent=hdr; Instance.new("UICorner",ico).CornerRadius=UDim.new(0,9); do local ig=Instance.new("UIGradient"); ig.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,WP_C.accent2),ColorSequenceKeypoint.new(1,WP_C.accent)}; ig.Rotation=135; ig.Parent=ico end; local ic=Instance.new("TextLabel"); ic.Size=UDim2.new(1,0,1,0); ic.BackgroundTransparency=1; ic.Text="⚙"; ic.TextColor3=Color3.fromRGB(255,255,255); ic.Font=Enum.Font.Gotham; ic.TextSize=15; ic.ZIndex=54; ic.Parent=ico end
    do local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-80,0,20); t.Position=UDim2.new(0,52,0.5,-20); t.BackgroundTransparency=1; t.Text="AUTO "..sideName; t.TextColor3=WP_C.text; t.Font=Enum.Font.GothamBlack; t.TextSize=13; t.TextXAlignment=Enum.TextXAlignment.Left; t.ZIndex=53; t.Parent=hdr; local s=Instance.new("TextLabel"); s.Size=UDim2.new(1,-80,0,14); s.Position=UDim2.new(0,52,0.5,3); s.BackgroundTransparency=1; s.Text="checkpoint offsets"; s.TextColor3=WP_C.textMid; s.Font=Enum.Font.GothamBold; s.TextSize=9; s.TextXAlignment=Enum.TextXAlignment.Left; s.ZIndex=53; s.Parent=hdr end
    local closeBtn=Instance.new("TextButton"); closeBtn.Size=UDim2.new(0,26,0,26); closeBtn.Position=UDim2.new(1,-36,0.5,-13); closeBtn.BackgroundColor3=WP_C.btnBg; closeBtn.BorderSizePixel=0; closeBtn.Text="✕"; closeBtn.TextColor3=WP_C.textDim; closeBtn.Font=Enum.Font.GothamBlack; closeBtn.TextSize=12; closeBtn.ZIndex=54; closeBtn.Parent=hdr; Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,7); do local cs=Instance.new("UIStroke"); cs.Color=WP_C.borderDim; cs.Thickness=1; cs.Parent=closeBtn end; closeBtn.MouseButton1Click:Connect(function() eGui:Destroy(); wpEditorGui=nil end)

    local boxRefs = {}

    for i, wp in ipairs(wps) do
        local cardY = HDR_H + PAD + (i-1)*(CARD_H+CARD_GAP)
        local tag   = i==1 and "START" or (i==#wps and "END" or "MID")
        local tagCol= i==1 and WP_C.accent or (i==#wps and WP_C.accent2 or WP_C.accentGlow)

        local card=Instance.new("Frame"); card.Size=UDim2.new(1,-PAD*2,0,CARD_H); card.Position=UDim2.new(0,PAD,0,cardY); card.BackgroundColor3=WP_C.card; card.BorderSizePixel=0; card.ZIndex=51; card.Parent=panel; Instance.new("UICorner",card).CornerRadius=UDim.new(0,10); do local cs=Instance.new("UIStroke"); cs.Color=WP_C.borderDim; cs.Thickness=1; cs.Parent=card end

        -- Left colour bar
        local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,3,0.7,0); bar.Position=UDim2.new(0,0,0.15,0); bar.BackgroundColor3=tagCol; bar.BorderSizePixel=0; bar.ZIndex=53; bar.Parent=card; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)

        -- Label + tag badge
        local wpNameLbl=Instance.new("TextLabel"); wpNameLbl.Size=UDim2.new(0,60,0,18); wpNameLbl.Position=UDim2.new(0,10,0,8); wpNameLbl.BackgroundTransparency=1; wpNameLbl.Text=wp.label; wpNameLbl.TextColor3=WP_C.accentGlow; wpNameLbl.Font=Enum.Font.GothamBlack; wpNameLbl.TextSize=11; wpNameLbl.TextXAlignment=Enum.TextXAlignment.Left; wpNameLbl.ZIndex=53; wpNameLbl.Parent=card
        local tagBadge=Instance.new("Frame"); tagBadge.Size=UDim2.new(0,40,0,16); tagBadge.Position=UDim2.new(0,72,0,9); tagBadge.BackgroundColor3=WP_C.cardInner; tagBadge.BorderSizePixel=0; tagBadge.ZIndex=53; tagBadge.Parent=card; Instance.new("UICorner",tagBadge).CornerRadius=UDim.new(1,0); do local ts=Instance.new("UIStroke"); ts.Color=tagCol; ts.Thickness=1; ts.Transparency=0.5; ts.Parent=tagBadge end; local tagTxt=Instance.new("TextLabel"); tagTxt.Size=UDim2.new(1,0,1,0); tagTxt.BackgroundTransparency=1; tagTxt.Text=tag; tagTxt.TextColor3=tagCol; tagTxt.Font=Enum.Font.GothamBlack; tagTxt.TextSize=8; tagTxt.ZIndex=54; tagTxt.Parent=tagBadge

        -- X and Z spinners
        local function makeSpinner(axis, spinX)
            local axCol = axis=="X" and WP_C.axX or WP_C.axZ
            local sf=Instance.new("Frame"); sf.Size=UDim2.new(0,88,0,28); sf.Position=UDim2.new(0,spinX,0,36); sf.BackgroundColor3=WP_C.cardInner; sf.BorderSizePixel=0; sf.ZIndex=52; sf.Parent=card; Instance.new("UICorner",sf).CornerRadius=UDim.new(0,7); do local ss=Instance.new("UIStroke"); ss.Color=WP_C.borderDim; ss.Thickness=1; ss.Parent=sf end
            local axTag=Instance.new("TextLabel"); axTag.Size=UDim2.new(0,14,1,0); axTag.Position=UDim2.new(0,4,0,0); axTag.BackgroundTransparency=1; axTag.Text=axis; axTag.TextColor3=axCol; axTag.Font=Enum.Font.GothamBlack; axTag.TextSize=9; axTag.ZIndex=54; axTag.Parent=sf
            local minus=Instance.new("TextButton"); minus.Size=UDim2.new(0,18,0,18); minus.Position=UDim2.new(0,17,0.5,-9); minus.BackgroundColor3=WP_C.btnBg; minus.BorderSizePixel=0; minus.Text="−"; minus.TextColor3=axCol; minus.Font=Enum.Font.GothamBlack; minus.TextSize=14; minus.ZIndex=55; minus.Parent=sf; Instance.new("UICorner",minus).CornerRadius=UDim.new(0,4); do local ms=Instance.new("UIStroke"); ms.Color=WP_C.borderDim; ms.Thickness=1; ms.Parent=minus end
            local valBox=Instance.new("TextBox"); valBox.Size=UDim2.new(0,28,0,18); valBox.Position=UDim2.new(0,37,0.5,-9); valBox.BackgroundColor3=WP_C.bg; valBox.BorderSizePixel=0; valBox.Text="0"; valBox.TextColor3=WP_C.text; valBox.Font=Enum.Font.GothamBlack; valBox.TextSize=10; valBox.ClearTextOnFocus=false; valBox.ZIndex=55; valBox.Parent=sf; Instance.new("UICorner",valBox).CornerRadius=UDim.new(0,4); do local vs=Instance.new("UIStroke"); vs.Color=axCol; vs.Thickness=1; vs.Transparency=0.65; vs.Parent=valBox end
            local plus=Instance.new("TextButton"); plus.Size=UDim2.new(0,18,0,18); plus.Position=UDim2.new(0,67,0.5,-9); plus.BackgroundColor3=WP_C.btnBg; plus.BorderSizePixel=0; plus.Text="+"; plus.TextColor3=axCol; plus.Font=Enum.Font.GothamBlack; plus.TextSize=12; plus.ZIndex=55; plus.Parent=sf; Instance.new("UICorner",plus).CornerRadius=UDim.new(0,4); do local ps=Instance.new("UIStroke"); ps.Color=WP_C.borderDim; ps.Thickness=1; ps.Parent=plus end
            local function applyVal(val)
                val=math.floor(val); local cur=wp.offset
                if axis=="X" then wp.offset=Vector3.new(val,cur.Y,cur.Z) else wp.offset=Vector3.new(cur.X,cur.Y,val) end
                valBox.Text=tostring(val)
                -- Immediately move the matching ESP marker if ESP is active
                if _G.NebulaESPRefresh then
                    -- Find the def index whose wpFn returns this same wp table entry
                    for defIdx, def in ipairs(ESP_DEFS) do
                        if def.wpFn() == wp then
                            _G.NebulaESPRefresh(defIdx)
                            break
                        end
                    end
                end
            end
            minus.MouseButton1Click:Connect(function() applyVal((tonumber(valBox.Text) or 0)-1) end)
            plus.MouseButton1Click:Connect(function()  applyVal((tonumber(valBox.Text) or 0)+1) end)
            valBox.FocusLost:Connect(function() applyVal(tonumber(valBox.Text:match("^%-?%d+") or "0") or 0) end)
            if not boxRefs[i] then boxRefs[i]={} end
            boxRefs[i][axis]=valBox
        end
        makeSpinner("X", 8)
        makeSpinner("Z", 104)
    end

    -- Reset button
    local rstY = HDR_H + PAD + #wps*(CARD_H+CARD_GAP) - CARD_GAP + PAD
    local resetBtn=Instance.new("TextButton"); resetBtn.Size=UDim2.new(1,-PAD*2,0,RESET_H-6); resetBtn.Position=UDim2.new(0,PAD,0,rstY); resetBtn.BackgroundColor3=WP_C.btnBg; resetBtn.BorderSizePixel=0; resetBtn.Text="RESET ALL"; resetBtn.TextColor3=WP_C.accentGlow; resetBtn.Font=Enum.Font.GothamBlack; resetBtn.TextSize=11; resetBtn.ZIndex=52; resetBtn.Parent=panel; Instance.new("UICorner",resetBtn).CornerRadius=UDim.new(0,8); do local rs=Instance.new("UIStroke"); rs.Color=WP_C.border; rs.Thickness=1; rs.Transparency=0.45; rs.Parent=resetBtn end
    resetBtn.MouseButton1Click:Connect(function()
        for i, wp in ipairs(wps) do
            wp.offset = Vector3.new(0,0,0)
            if boxRefs[i] then
                if boxRefs[i]["X"] then boxRefs[i]["X"].Text="0" end
                if boxRefs[i]["Z"] then boxRefs[i]["Z"].Text="0" end
            end
        end
        -- Refresh all ESP parts for this side
        if _G.NebulaESPRefresh then
            for defIdx, def in ipairs(ESP_DEFS) do
                for _, wp in ipairs(wps) do
                    if def.wpFn() == wp then
                        _G.NebulaESPRefresh(defIdx)
                    end
                end
            end
        end
    end)
end
;(function()

-- Destroy old instance if reloading
if pgui:FindFirstChild("NebulaMiniHub") then pgui.NebulaMiniHub:Destroy() end

local C = {
    bg        = Color3.fromRGB(7, 7, 14),
    panel     = Color3.fromRGB(11, 11, 22),
    rowBg     = Color3.fromRGB(13, 13, 26),
    rowActive = Color3.fromRGB(24, 20, 54),
    border    = Color3.fromRGB(60, 55, 140),
    borderDim = Color3.fromRGB(28, 26, 64),
    accent    = Color3.fromRGB(120, 100, 255),
    accentGlow= Color3.fromRGB(190, 180, 255),
    accent2   = Color3.fromRGB(190, 80, 255),
    text      = Color3.fromRGB(245, 245, 255),
    textDim   = Color3.fromRGB(160, 160, 215),
    textMid   = Color3.fromRGB(80, 78, 130),
    headerBg  = Color3.fromRGB(5, 5, 12),
    btnBg     = Color3.fromRGB(18, 18, 38),
    toggleOn  = Color3.fromRGB(120, 100, 255),
    toggleOff = Color3.fromRGB(20, 20, 44),
    circleOn  = Color3.fromRGB(255, 255, 255),
    circleOff = Color3.fromRGB(55, 55, 100),
    success   = Color3.fromRGB(52, 211, 153),
    danger    = Color3.fromRGB(248, 113, 113),
    stealFill = Color3.fromRGB(120, 100, 255),
    stealTrack= Color3.fromRGB(14, 14, 30),
}

local GUI_W = 340
local GUI_H = 760

local gui = Instance.new("ScreenGui")
gui.Name = "NebulaMiniHub"; gui.ResetOnSpawn = false
gui.DisplayOrder = 10; gui.Parent = pgui

-- ── MAIN FRAME ─────────────────────────────────────────────
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, GUI_W, 0, GUI_H)
main.Position = UDim2.new(0, 16, 0.5, -(GUI_H/2))
main.BackgroundColor3 = C.bg
main.BackgroundTransparency = currentTransparency
main.BorderSizePixel = 0
main.Active = true; main.Draggable = true; main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
do
    local s = Instance.new("UIStroke")
    s.Color = C.accent; s.Thickness = 1.5; s.Transparency = 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = main
end

-- ── HEADER ─────────────────────────────────────────────────
local HEADER_H = 80
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundColor3 = C.headerBg
header.BorderSizePixel = 0; header.ZIndex = 6; header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
do local sq = Instance.new("Frame"); sq.Size = UDim2.new(1,0,0,14); sq.Position = UDim2.new(0,0,1,-14); sq.BackgroundColor3 = C.headerBg; sq.BorderSizePixel = 0; sq.ZIndex = 6; sq.Parent = header end

-- deep purple gradient in header
do
    local tint = Instance.new("Frame"); tint.Size = UDim2.new(1,0,1,0)
    tint.BackgroundColor3 = C.headerBg; tint.BackgroundTransparency = 0
    tint.BorderSizePixel = 0; tint.ZIndex = 6; tint.Parent = header
    Instance.new("UICorner", tint).CornerRadius = UDim.new(0,14)
    local tg = Instance.new("UIGradient"); tg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(22, 12, 60)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8,  8,  20)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(18, 8,  50)),
    }; tg.Rotation = 125; tg.Parent = tint
end

-- accent rule at base of header
do
    local rule = Instance.new("Frame"); rule.Size = UDim2.new(1,0,0,2); rule.Position = UDim2.new(0,0,1,-2)
    rule.BackgroundColor3 = C.accent; rule.BorderSizePixel = 0; rule.ZIndex = 9; rule.Parent = header
    local rg = Instance.new("UIGradient"); rg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.3, C.accent),
        ColorSequenceKeypoint.new(0.7, C.accent2),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
    }; rg.Parent = rule
end

-- logo square (rounded, gradient, shine, bold N)
do
    local logo = Instance.new("Frame")
    logo.Size = UDim2.new(0,46,0,46); logo.Position = UDim2.new(0,14,0.5,-23)
    logo.BorderSizePixel = 0; logo.ZIndex = 9; logo.Parent = header
    Instance.new("UICorner", logo).CornerRadius = UDim.new(0,10)
    do local lg = Instance.new("UIGradient"); lg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, C.accent2),
        ColorSequenceKeypoint.new(1, C.accent),
    }; lg.Rotation = 140; lg.Parent = logo end
    do -- top shine
        local sh = Instance.new("Frame"); sh.Size = UDim2.new(1,0,0.45,0); sh.Position = UDim2.new(0,0,0,0)
        sh.BackgroundColor3 = Color3.fromRGB(255,255,255); sh.BackgroundTransparency = 0.86
        sh.BorderSizePixel = 0; sh.ZIndex = 10; sh.Parent = logo
        Instance.new("UICorner", sh).CornerRadius = UDim.new(0,10)
    end
    local n = Instance.new("TextLabel"); n.Size = UDim2.new(1,0,1,0)
    n.BackgroundTransparency = 1; n.Text = "N"
    n.TextColor3 = Color3.fromRGB(255,255,255); n.Font = Enum.Font.GothamBlack
    n.TextSize = 24; n.ZIndex = 11; n.Parent = logo
    n.TextStrokeTransparency = 0.5; n.TextStrokeColor3 = Color3.fromRGB(0,0,30)
end

-- title + discord
do
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(0,210,0,28); t.Position = UDim2.new(0,70,0.5,-27)
    t.BackgroundTransparency = 1; t.Text = "NEBULA MINI HUB"
    t.Font = Enum.Font.GothamBlack; t.TextSize = 18
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.TextXAlignment = Enum.TextXAlignment.Left; t.ZIndex = 9; t.Parent = header
    t.TextStrokeTransparency = 0.75; t.TextStrokeColor3 = C.accent2

    local s = Instance.new("TextLabel")
    s.Size = UDim2.new(0,210,0,15); s.Position = UDim2.new(0,71,0.5,5)
    s.BackgroundTransparency = 1; s.Text = "discord.gg/nebula5"
    s.TextColor3 = C.accentGlow; s.Font = Enum.Font.GothamBlack
    s.TextSize = 10; s.TextXAlignment = Enum.TextXAlignment.Left; s.ZIndex = 9; s.Parent = header
end

-- v2 chip
do
    local chip = Instance.new("Frame")
    chip.Size = UDim2.new(0,46,0,24); chip.Position = UDim2.new(1,-60,0.5,-12)
    chip.BackgroundColor3 = Color3.fromRGB(22,18,55); chip.BorderSizePixel = 0; chip.ZIndex = 9; chip.Parent = header
    Instance.new("UICorner", chip).CornerRadius = UDim.new(0,7)
    do local cs = Instance.new("UIStroke"); cs.Color = C.accent; cs.Thickness = 1.5; cs.Transparency = 0.3; cs.Parent = chip end
    local cl = Instance.new("TextLabel"); cl.Size = UDim2.new(1,0,1,0)
    cl.BackgroundTransparency = 1; cl.Text = "v2.0"; cl.TextColor3 = C.accentGlow
    cl.Font = Enum.Font.GothamBlack; cl.TextSize = 12; cl.ZIndex = 10; cl.Parent = chip
end

-- ── CONTENT SCROLL ─────────────────────────────────────────
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1,0,1,-(HEADER_H+2))
content.Position = UDim2.new(0,0,0,HEADER_H+2)
content.BackgroundTransparency = 1; content.BorderSizePixel = 0
content.ScrollBarThickness = 2; content.ScrollBarImageColor3 = C.accent
content.CanvasSize = UDim2.new(0,0,0,0); content.ZIndex = 5; content.Parent = main

local yPos = 12
local waitingForKeybind = nil
local waitingForKeybindType = nil

-- ── STEAL BAR ──────────────────────────────────────────────
StealBarFrame = Instance.new("Frame")
StealBarFrame.Name = "NebulaStealBar"
StealBarFrame.Size = UDim2.new(0, GUI_W, 0, 64)
StealBarFrame.BackgroundColor3 = C.headerBg; StealBarFrame.BackgroundTransparency = 0.04
StealBarFrame.BorderSizePixel = 0; StealBarFrame.Visible = false
StealBarFrame.Active = true; StealBarFrame.Draggable = true
StealBarFrame.ZIndex = 10; StealBarFrame.Parent = gui
Instance.new("UICorner", StealBarFrame).CornerRadius = UDim.new(0, 12)
do local s = Instance.new("UIStroke"); s.Color = C.accent; s.Thickness = 1.5; s.Parent = StealBarFrame end

local function syncStealBar()
    StealBarFrame.Position = UDim2.new(
        main.Position.X.Scale, main.Position.X.Offset,
        main.Position.Y.Scale, main.Position.Y.Offset + GUI_H + 8)
end
syncStealBar()
main:GetPropertyChangedSignal("AbsolutePosition"):Connect(syncStealBar)

do
    local sbTitle = Instance.new("TextLabel")
    sbTitle.Size = UDim2.new(0,110,0,22); sbTitle.Position = UDim2.new(0,12,0,4)
    sbTitle.BackgroundTransparency = 1; sbTitle.Text = "AUTO STEAL"
    sbTitle.Font = Enum.Font.GothamBlack; sbTitle.TextSize = 12; sbTitle.TextColor3 = C.accent
    sbTitle.TextXAlignment = Enum.TextXAlignment.Left; sbTitle.ZIndex = 11; sbTitle.Parent = StealBarFrame

    SBStatus = Instance.new("TextLabel")
    SBStatus.Size = UDim2.new(0,80,0,22); SBStatus.Position = UDim2.new(0,124,0,4)
    SBStatus.BackgroundTransparency = 1; SBStatus.Text = "READY"
    SBStatus.Font = Enum.Font.GothamBlack; SBStatus.TextSize = 11; SBStatus.TextColor3 = C.textDim
    SBStatus.ZIndex = 11; SBStatus.Parent = StealBarFrame

    SBPct = Instance.new("TextLabel")
    SBPct.Size = UDim2.new(0,40,0,22); SBPct.Position = UDim2.new(0,8,0,4)
    SBPct.BackgroundTransparency = 1; SBPct.Text = "0%"
    SBPct.Font = Enum.Font.GothamBlack; SBPct.TextSize = 13; SBPct.TextColor3 = C.text
    SBPct.TextXAlignment = Enum.TextXAlignment.Left; SBPct.ZIndex = 11; SBPct.Visible = false; SBPct.Parent = StealBarFrame

    do local rLbl = Instance.new("TextLabel"); rLbl.Size = UDim2.new(0,50,0,22); rLbl.Position = UDim2.new(1,-112,0,4)
        rLbl.BackgroundTransparency=1; rLbl.Text="RADIUS"; rLbl.Font=Enum.Font.GothamBlack; rLbl.TextSize=9
        rLbl.TextColor3=C.textMid; rLbl.ZIndex=11; rLbl.Parent=StealBarFrame end

    local sbRadSteps = {5, 8, 10, 15, 20, 30}
    local sbRadIdx = 2
    SBRadBtn = Instance.new("TextButton")
    SBRadBtn.Size = UDim2.new(0,52,0,22); SBRadBtn.Position = UDim2.new(1,-58,0,4)
    SBRadBtn.BackgroundColor3 = C.btnBg; SBRadBtn.BorderSizePixel = 0
    SBRadBtn.Text = tostring(sbRadSteps[sbRadIdx]); SBRadBtn.TextColor3 = C.accentGlow
    SBRadBtn.Font = Enum.Font.GothamBlack; SBRadBtn.TextSize = 12; SBRadBtn.ZIndex = 12; SBRadBtn.Parent = StealBarFrame
    Instance.new("UICorner", SBRadBtn).CornerRadius = UDim.new(0, 6)
    do local s = Instance.new("UIStroke"); s.Color = C.border; s.Thickness = 1; s.Parent = SBRadBtn end
    SBRadBtn.MouseButton1Click:Connect(function()
        sbRadIdx = (sbRadIdx % #sbRadSteps) + 1
        Values.STEAL_RADIUS = sbRadSteps[sbRadIdx]
        SBRadBtn.Text = tostring(Values.STEAL_RADIUS)
    end)
end

local sbTrack = Instance.new("Frame")
sbTrack.Size = UDim2.new(1,-16,0,8); sbTrack.Position = UDim2.new(0,8,0,42)
sbTrack.BackgroundColor3 = C.stealTrack; sbTrack.BorderSizePixel = 0
sbTrack.ClipsDescendants = true; sbTrack.ZIndex = 11; sbTrack.Parent = StealBarFrame
Instance.new("UICorner", sbTrack).CornerRadius = UDim.new(1,0)

SBFill = Instance.new("Frame")
SBFill.Size = UDim2.new(0,0,1,0); SBFill.BackgroundColor3 = C.stealFill
SBFill.BorderSizePixel = 0; SBFill.ZIndex = 12; SBFill.Parent = sbTrack
do local fg = Instance.new("UIGradient"); fg.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, C.accent),
    ColorSequenceKeypoint.new(1, C.accent2),
}; fg.Parent = SBFill end
Instance.new("UICorner", SBFill).CornerRadius = UDim.new(1,0)

RunService.Heartbeat:Connect(function(dt)
    if not StealBarFrame then return end
    StealBarFrame.Visible = Enabled.AutoSteal
    if not Enabled.AutoSteal then
        stealBarTimer = 0
        if SBFill   then SBFill.Size = UDim2.new(0,0,1,0) end
        if SBPct    then SBPct.Visible = false end
        if SBStatus then SBStatus.Text = "READY" end
        return
    end
    if isStealing and stealStartTime then
        local prog = math.clamp((tick()-stealStartTime)/Values.STEAL_DURATION, 0, 1)
        if SBFill  then SBFill.Size = UDim2.new(0, math.floor(sbTrack.AbsoluteSize.X*prog), 1, 0) end
        if SBPct   then SBPct.Visible = true; SBPct.Text = math.floor(prog*100).."%" end
        if SBStatus then SBStatus.Text = "STEALING" end
    else
        stealBarTimer = stealBarTimer + dt
        local pulse = math.abs(math.sin(stealBarTimer * 1.4)) * 0.35
        if SBFill  then SBFill.Size = UDim2.new(pulse,0,1,0) end
        if SBPct   then SBPct.Visible = false end
        if SBStatus then SBStatus.Text = "SCANNING" end
    end
end)

-- ── GUI HELPERS ────────────────────────────────────────────
local function addDivider()
    local d = Instance.new("Frame")
    d.Size = UDim2.new(1,-24,0,1); d.Position = UDim2.new(0,12,0,yPos)
    d.BackgroundColor3 = Color3.fromRGB(255,255,255); d.BackgroundTransparency = 0.91
    d.BorderSizePixel = 0; d.ZIndex = 5; d.Parent = content
    local g = Instance.new("UIGradient"); g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.15, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.85, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(0,0,0)),
    }; g.Parent = d
    yPos = yPos + 16
end

local function createCategoryHeader(txt)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-20,0,22); f.Position = UDim2.new(0,10,0,yPos)
    f.BackgroundTransparency = 1; f.ZIndex = 5; f.Parent = content

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,6,0,6); dot.Position = UDim2.new(0,1,0.5,-3)
    dot.BackgroundColor3 = C.accent2; dot.BorderSizePixel = 0; dot.ZIndex = 6; dot.Parent = f
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-14,1,0); lbl.Position = UDim2.new(0,13,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = txt
    lbl.TextColor3 = C.textDim; lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6; lbl.Parent = f
    yPos = yPos + 28
end

local function createToggle(labelText, enabledKey, callback, keybindKey, cogwheelFn, rightClickCb, cogIcon)
    local ROW_H = 46
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-20,0,ROW_H); row.Position = UDim2.new(0,10,0,yPos)
    row.BackgroundColor3 = C.rowBg; row.BorderSizePixel = 0; row.ZIndex = 5; row.Parent = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)
    do local s = Instance.new("UIStroke"); s.Color = C.borderDim; s.Thickness = 1; s.Parent = row end

    local xOff = 12
    local keybindBtn = nil

    if keybindKey then
        keybindBtn = Instance.new("TextButton")
        keybindBtn.Size = UDim2.new(0,36,0,22); keybindBtn.Position = UDim2.new(0,xOff,0.5,-11)
        keybindBtn.BackgroundColor3 = C.btnBg; keybindBtn.BorderSizePixel = 0
        keybindBtn.Text = keybindKey.Name; keybindBtn.TextColor3 = C.textDim
        keybindBtn.Font = Enum.Font.GothamBlack; keybindBtn.TextSize = 9; keybindBtn.ZIndex = 7; keybindBtn.Parent = row
        Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0,5)
        do local s = Instance.new("UIStroke"); s.Color = C.borderDim; s.Thickness = 1; s.Parent = keybindBtn end

        if enabledKey=="AutoLeftEnabled"          then _G.AutoLeftKeybindBtn=keybindBtn
        elseif enabledKey=="AutoRightEnabled"     then _G.AutoRightKeybindBtn=keybindBtn
        elseif enabledKey=="AutoLeftPlayEnabled"  then _G.AutoLeftPlayKeybindBtn=keybindBtn
        elseif enabledKey=="AutoRightPlayEnabled" then _G.AutoRightPlayKeybindBtn=keybindBtn
        elseif enabledKey=="BatAimbot"            then _G.AimbotKeybindBtn=keybindBtn
        elseif enabledKey=="TPDownEnabled"        then _G.TPDownKeybindBtn=keybindBtn
        elseif enabledKey=="DropEnabled"          then _G.DropKeybindBtn=keybindBtn end
        xOff = xOff + 42
    end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-(xOff+58),1,0); label.Position = UDim2.new(0,xOff,0,0)
    label.BackgroundTransparency = 1; label.Text = labelText; label.TextColor3 = C.text
    label.Font = Enum.Font.GothamBlack; label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 6; label.Parent = row

    if cogwheelFn then
        local cog = Instance.new("TextButton")
        cog.Size = UDim2.new(0,24,0,24); cog.Position = UDim2.new(1,-78,0.5,-12)
        cog.BackgroundColor3 = C.btnBg; cog.BorderSizePixel = 0
        cog.Text = cogIcon or "⚙"; cog.TextColor3 = C.textDim; cog.Font = Enum.Font.Gotham; cog.TextSize = cogIcon and 13 or 14
        cog.ZIndex = 10; cog.Parent = row  -- above clickBtn so it receives clicks
        Instance.new("UICorner", cog).CornerRadius = UDim.new(0,6)
        do local cs = Instance.new("UIStroke"); cs.Color = C.borderDim; cs.Thickness = 1; cs.Parent = cog end
        cog.MouseButton1Click:Connect(cogwheelFn)
    end

    local defaultOn = Enabled[enabledKey] or false
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0,44,0,26); toggleBg.Position = UDim2.new(1,-52,0.5,-13)
    toggleBg.BackgroundColor3 = defaultOn and C.toggleOn or C.toggleOff
    toggleBg.ZIndex = 10; toggleBg.Parent = row  -- above clickBtn
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1,0)
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = defaultOn and C.accent or C.borderDim
    toggleStroke.Thickness = 1.5; toggleStroke.Parent = toggleBg

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0,20,0,20)
    toggleCircle.Position = defaultOn and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,3,0.5,-10)
    toggleCircle.BackgroundColor3 = defaultOn and C.circleOn or C.circleOff
    toggleCircle.ZIndex = 11; toggleCircle.Parent = toggleBg
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1,0)

    if enabledKey=="AutoLeftEnabled"          then _G.AutoLeftToggleBg=toggleBg;       _G.AutoLeftToggleCircle=toggleCircle
    elseif enabledKey=="AutoRightEnabled"     then _G.AutoRightToggleBg=toggleBg;      _G.AutoRightToggleCircle=toggleCircle
    elseif enabledKey=="AutoLeftPlayEnabled"  then _G.AutoLeftPlayToggleBg=toggleBg;   _G.AutoLeftPlayToggleCircle=toggleCircle
    elseif enabledKey=="AutoRightPlayEnabled" then _G.AutoRightPlayToggleBg=toggleBg;  _G.AutoRightPlayToggleCircle=toggleCircle end

    -- clickBtn covers only the label area; toggle and cog are above it via ZIndex
    local clickBtn = Instance.new("TextButton")
    local rightCut = cogwheelFn and 82 or 56
    clickBtn.Size = UDim2.new(1,-rightCut,1,0); clickBtn.BackgroundTransparency = 1; clickBtn.Text = ""
    clickBtn.ZIndex = 8; clickBtn.Parent = row

    -- Also make the toggle itself clickable for the toggle action
    local toggleHit = Instance.new("TextButton")
    toggleHit.Size = UDim2.new(1,0,1,0); toggleHit.BackgroundTransparency = 1; toggleHit.Text = ""
    toggleHit.ZIndex = 12; toggleHit.Parent = toggleBg

    local isOn = defaultOn
    local TI = TweenInfo.new(0.16, Enum.EasingStyle.Quint)
    local function doTween(state)
        TweenService:Create(toggleBg,     TI, {BackgroundColor3 = state and C.toggleOn or C.toggleOff}):Play()
        TweenService:Create(toggleCircle, TI, {
            Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,3,0.5,-10),
            BackgroundColor3 = state and C.circleOn or C.circleOff
        }):Play()
        TweenService:Create(toggleStroke, TI, {Color = state and C.accent or C.borderDim}):Play()
        TweenService:Create(row, TI, {BackgroundColor3 = state and C.rowActive or C.rowBg}):Play()
    end

    local function setVisual(state, skipCb)
        isOn = state; doTween(state)
        if not skipCb and callback then callback(state) end
    end
    VisualSetters[enabledKey] = setVisual

    local function handleClick()
        local ns = not isOn; isOn = ns; Enabled[enabledKey] = ns; doTween(ns)
        if callback then callback(ns) end
    end

    clickBtn.MouseButton1Click:Connect(handleClick)
    toggleHit.MouseButton1Click:Connect(handleClick)
    if rightClickCb then
        clickBtn.MouseButton2Click:Connect(rightClickCb)
        toggleHit.MouseButton2Click:Connect(rightClickCb)
    end

    yPos = yPos + ROW_H + 5
    return row, keybindBtn
end

local function createInputRow(lTxt, defVal)
    local ROW_H = 36
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,-24,0,ROW_H); row.Position = UDim2.new(0,12,0,yPos)
    row.BackgroundTransparency = 1; row.ZIndex = 5; row.Parent = content

    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.6,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Text = lTxt; lbl.TextColor3 = C.textMid; lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5; lbl.Parent = row

    local box = Instance.new("TextBox"); box.Size = UDim2.new(0,80,0,26); box.Position = UDim2.new(1,-80,0.5,-13)
    box.BackgroundColor3 = C.btnBg; box.BorderSizePixel = 0; box.Text = tostring(defVal)
    box.TextColor3 = C.text; box.Font = Enum.Font.GothamBold; box.TextSize = 12
    box.ClearTextOnFocus = false; box.ZIndex = 5; box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    do local s = Instance.new("UIStroke"); s.Color = C.border; s.Thickness = 1; s.Parent = box end

    yPos = yPos + ROW_H + 2
    return box
end

local function makeKeyRow(lTxt, defKeyName)
    local ROW_H = 34
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,-24,0,ROW_H); row.Position = UDim2.new(0,12,0,yPos)
    row.BackgroundTransparency = 1; row.ZIndex = 5; row.Parent = content

    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.55,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Text = lTxt; lbl.TextColor3 = C.textMid; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5; lbl.Parent = row

    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0,80,0,26); btn.Position = UDim2.new(1,-80,0.5,-13)
    btn.BackgroundColor3 = C.btnBg; btn.BorderSizePixel = 0; btn.Text = defKeyName
    btn.TextColor3 = C.text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.ZIndex = 5; btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    do local s = Instance.new("UIStroke"); s.Color = C.border; s.Thickness = 1; s.Parent = btn end

    yPos = yPos + ROW_H + 2
    return btn
end

-- ══════════════════════════════════════════
-- BUILD CONTENT
-- ══════════════════════════════════════════
createCategoryHeader("FEATURES")

createToggle("X-Ray + Optimizer",  "Optimizer",   function(s) if s then enableOptimizer() else disableOptimizer() end end)
createToggle("Disable Animation",  "Unwalk",      function(s) if s then startUnwalk()     else stopUnwalk()       end end)
createToggle("No Clip",            "NoClip",      function(s) if s then startNoClip()     else stopNoClip()       end end)
createToggle("Dark Mode",          "DarkMode",    function(s) if s then enableDarkMode()  else disableDarkMode()  end end)

local stealPanelToggle
createToggle("Auto Steal", "AutoSteal", function(s) if s then startAutoSteal() else stopAutoSteal() end end, nil, nil,
    function() if stealPanelToggle then stealPanelToggle() end end)

-- Steal sub-panel
local stealSubPanel, stealSubToggleFn
do
    local panelY = yPos
    stealSubPanel = Instance.new("Frame"); stealSubPanel.Size = UDim2.new(1,-24,0,92); stealSubPanel.Position = UDim2.new(0,12,0,panelY)
    stealSubPanel.BackgroundColor3 = C.panel; stealSubPanel.BorderSizePixel = 0
    stealSubPanel.Visible = false; stealSubPanel.ZIndex = 5; stealSubPanel.Parent = content
    Instance.new("UICorner", stealSubPanel).CornerRadius = UDim.new(0,6)
    do local s = Instance.new("UIStroke"); s.Color = C.border; s.Thickness = 1; s.Parent = stealSubPanel end

    do
        local ht = Instance.new("TextLabel"); ht.Size = UDim2.new(1,-16,0,14); ht.Position = UDim2.new(0,8,0,6)
        ht.BackgroundTransparency=1; ht.Text="Right-click Auto Steal to toggle panel"
        ht.TextColor3=C.textMid; ht.Font=Enum.Font.GothamBold; ht.TextSize=9; ht.TextXAlignment=Enum.TextXAlignment.Left
        ht.ZIndex=6; ht.Parent=stealSubPanel
        local function makeSubRow(lTxt, posY, defTxt, onChange)
            local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0.55,0,0,26); lbl.Position=UDim2.new(0,10,0,posY)
            lbl.BackgroundTransparency=1; lbl.Text=lTxt; lbl.TextColor3=C.textMid
            lbl.Font=Enum.Font.GothamSemibold; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6; lbl.Parent=stealSubPanel
            local bx=Instance.new("TextBox"); bx.Size=UDim2.new(0,70,0,22); bx.Position=UDim2.new(1,-82,0,posY+2)
            bx.BackgroundColor3=C.bg; bx.BorderSizePixel=0; bx.Text=defTxt
            bx.TextColor3=C.text; bx.Font=Enum.Font.GothamBold; bx.TextSize=11
            bx.ClearTextOnFocus=false; bx.ZIndex=6; bx.Parent=stealSubPanel
            Instance.new("UICorner",bx).CornerRadius=UDim.new(0,4)
            do local s=Instance.new("UIStroke"); s.Color=C.border; s.Thickness=1; s.Parent=bx end
            bx.FocusLost:Connect(function()
                local v=tonumber(bx.Text)
                if v then onChange(v); bx.Text=tostring(v) else bx.Text=defTxt end
                if SBRadBtn then SBRadBtn.Text=tostring(Values.STEAL_RADIUS) end
            end)
            return bx
        end
        makeSubRow("Steal Duration", 24, tostring(Values.STEAL_DURATION), function(v) Values.STEAL_DURATION = math.max(0.01, v) end)
        makeSubRow("Radius",         58, tostring(Values.STEAL_RADIUS),   function(v) Values.STEAL_RADIUS = math.clamp(math.floor(v), 1, 200) end)
    end

    local stealElemAfter = {}
    local stealVis = false
    stealSubToggleFn = function()
        if #stealElemAfter == 0 then
            local found = false
            for _, child in ipairs(content:GetChildren()) do
                if child == stealSubPanel then found = true elseif found then table.insert(stealElemAfter, child) end
            end
        end
        stealVis = not stealVis; stealSubPanel.Visible = stealVis
        local delta = stealVis and 92 or -92
        for _, el in ipairs(stealElemAfter) do
            if el and el.Parent then
                el.Position = UDim2.new(el.Position.X.Scale, el.Position.X.Offset, el.Position.Y.Scale, el.Position.Y.Offset + delta)
            end
        end
        content.CanvasSize = UDim2.new(0,0,0, content.CanvasSize.Y.Offset + delta)
    end
end
stealPanelToggle = stealSubToggleFn

createToggle("Anti Ragdoll",   "AntiRagdoll",   function(s) if s then startAntiRagdoll()   else stopAntiRagdoll()   end end)
createToggle("Ragdoll TP",     "RagdollTP",     function(s) if s then startRagdollTP()     else stopRagdollTP()     end end)
createToggle("Spinbot",        "Spinbot",       function(s) if s then startSpinbot()       else stopSpinbot()       end end)
createToggle("Counter Medusa", "CounterMedusa", function(s) if s then startCounterMedusa() else stopCounterMedusa() end end)
createToggle("Bat Aimbot",     "BatAimbot",     function(s) Enabled.BatAimbot=s; autoBatToggled=s; if s then startBatAimbot() else stopBatAimbot() end end, autoBatKey)
if _G.AimbotKeybindBtn then _G.AimbotKeybindBtn.MouseButton1Click:Connect(function() waitingForKeybind=_G.AimbotKeybindBtn; waitingForKeybindType="AutoBat"; _G.AimbotKeybindBtn.Text="..." end) end

addDivider()
createCategoryHeader("MOVEMENT")

createToggle("Waypoint ESP", "WaypointESP", function(s) if s then startWaypointESP() else stopWaypointESP() end end)

createToggle("Auto Left",  "AutoLeftEnabled",  function(s) AutoLeftEnabled=s;  if s then startAutoLeft()  else stopAutoLeft()  end end, autoLeftKey,  function() openWPPanel("Left")  end)
if _G.AutoLeftKeybindBtn then _G.AutoLeftKeybindBtn.MouseButton1Click:Connect(function() waitingForKeybind=_G.AutoLeftKeybindBtn; waitingForKeybindType="AutoLeft"; _G.AutoLeftKeybindBtn.Text="..." end) end

createToggle("Auto Right", "AutoRightEnabled", function(s) AutoRightEnabled=s; if s then startAutoRight() else stopAutoRight() end end, autoRightKey, function() openWPPanel("Right") end)
if _G.AutoRightKeybindBtn then _G.AutoRightKeybindBtn.MouseButton1Click:Connect(function() waitingForKeybind=_G.AutoRightKeybindBtn; waitingForKeybindType="AutoRight"; _G.AutoRightKeybindBtn.Text="..." end) end

createToggle("Auto Left Play",  "AutoLeftPlayEnabled",  function(s) AutoLeftPlayEnabled=s;  if s then startAutoLeftPlay()  else stopAutoLeftPlay()  end end, autoLeftPlayKey,  function() openWPPanel("LeftPlay")  end)
if _G.AutoLeftPlayKeybindBtn then _G.AutoLeftPlayKeybindBtn.MouseButton1Click:Connect(function() waitingForKeybind=_G.AutoLeftPlayKeybindBtn; waitingForKeybindType="AutoLeftPlay"; _G.AutoLeftPlayKeybindBtn.Text="..." end) end

createToggle("Auto Right Play", "AutoRightPlayEnabled", function(s) AutoRightPlayEnabled=s; if s then startAutoRightPlay() else stopAutoRightPlay() end end, autoRightPlayKey, function() openWPPanel("RightPlay") end)
if _G.AutoRightPlayKeybindBtn then _G.AutoRightPlayKeybindBtn.MouseButton1Click:Connect(function() waitingForKeybind=_G.AutoRightPlayKeybindBtn; waitingForKeybindType="AutoRightPlay"; _G.AutoRightPlayKeybindBtn.Text="..." end) end


createToggle("Auto Carry On Pickup", "AutoCarryOnPickup", function(s)
    Enabled.AutoCarryOnPickup = s
    if s then startAutoCarryMode() else stopAutoCarryMode() end
end)

createToggle("Galaxy Mode", "Galaxy", function(s) if s then startGalaxy() else stopGalaxy() end end, Enum.KeyCode.M)

createToggle("Float", "FloatEnabled", function(s) floatEnabled=s; Enabled.FloatEnabled=s; if s then startFloat() else stopFloat() end end, floatKey)
if _G.AutoLeftKeybindBtn then end -- float key handled below in KeyConfig

-- Action buttons (TP Down, Drop) — single press style
createToggle("TP Down",        "TPDownEnabled", function(s) if s then task.spawn(doTPDown);        task.delay(0.1, function() Enabled.TPDownEnabled=false; if VisualSetters.TPDownEnabled then VisualSetters.TPDownEnabled(false,true) end end) end end, tpDownKey)
if _G.TPDownKeybindBtn then _G.TPDownKeybindBtn.MouseButton1Click:Connect(function() waitingForKeybind=_G.TPDownKeybindBtn; waitingForKeybindType="TPDown"; _G.TPDownKeybindBtn.Text="..." end) end

createToggle("Drop Brainrots", "DropEnabled",   function(s) if s then task.spawn(doDropBrainrots); task.delay(0.1, function() Enabled.DropEnabled=false; if VisualSetters.DropEnabled then VisualSetters.DropEnabled(false,true) end end) end end, dropKey)
if _G.DropKeybindBtn then _G.DropKeybindBtn.MouseButton1Click:Connect(function() waitingForKeybind=_G.DropKeybindBtn; waitingForKeybindType="Drop"; _G.DropKeybindBtn.Text="..." end) end

addDivider()
createCategoryHeader("SPEED")

-- Mode label
modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(1,-24,0,22); modeLabel.Position = UDim2.new(0,12,0,yPos)
modeLabel.BackgroundTransparency = 1; modeLabel.Text = "Mode: Normal"
modeLabel.TextColor3 = C.textDim; modeLabel.Font = Enum.Font.GothamBold; modeLabel.TextSize = 12
modeLabel.ZIndex = 5; modeLabel.Parent = content
yPos = yPos + 26

-- Normal Speed box
do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-24,0,34); row.Position = UDim2.new(0,12,0,yPos)
    row.BackgroundTransparency = 1; row.ZIndex = 5; row.Parent = content
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55,0,1,0); lbl.BackgroundTransparency = 1; lbl.Text = "Normal Speed"
    lbl.TextColor3 = C.textMid; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5; lbl.Parent = row
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0,80,0,26); box.Position = UDim2.new(1,-80,0.5,-13)
    box.BackgroundColor3 = C.btnBg; box.BorderSizePixel = 0; box.Text = tostring(NORMAL_SPEED)
    box.TextColor3 = C.text; box.Font = Enum.Font.GothamBold; box.TextSize = 12
    box.ClearTextOnFocus = false; box.ZIndex = 5; box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,5)
    do local s = Instance.new("UIStroke"); s.Color = C.border; s.Thickness = 1; s.Parent = box end
    box:GetPropertyChangedSignal("Text"):Connect(function()
        local t = box.Text
        if t:match("^-?%d*%.?%d*$") and t~="" and t~="-" and t~="." then
            local v = tonumber(t); if v then NORMAL_SPEED = v
                if miniNormalBox and not miniNormalBox:IsFocused() then miniNormalBox.Text = t end
            end
        end
    end)
    box.FocusLost:Connect(function()
        local v = tonumber(box.Text)
        if v then NORMAL_SPEED = v; box.Text = tostring(v)
        else box.Text = tostring(NORMAL_SPEED) end
    end)
    yPos = yPos + 36
end

-- Carry Speed box
do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-24,0,34); row.Position = UDim2.new(0,12,0,yPos)
    row.BackgroundTransparency = 1; row.ZIndex = 5; row.Parent = content
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55,0,1,0); lbl.BackgroundTransparency = 1; lbl.Text = "Carry Speed"
    lbl.TextColor3 = C.textMid; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5; lbl.Parent = row
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0,80,0,26); box.Position = UDim2.new(1,-80,0.5,-13)
    box.BackgroundColor3 = C.btnBg; box.BorderSizePixel = 0; box.Text = tostring(CARRY_SPEED)
    box.TextColor3 = C.text; box.Font = Enum.Font.GothamBold; box.TextSize = 12
    box.ClearTextOnFocus = false; box.ZIndex = 5; box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,5)
    do local s = Instance.new("UIStroke"); s.Color = C.border; s.Thickness = 1; s.Parent = box end
    box:GetPropertyChangedSignal("Text"):Connect(function()
        local t = box.Text
        if t:match("^-?%d*%.?%d*$") and t~="" and t~="-" and t~="." then
            local v = tonumber(t); if v then CARRY_SPEED = v
                if miniCarryBox and not miniCarryBox:IsFocused() then miniCarryBox.Text = t end
            end
        end
    end)
    box.FocusLost:Connect(function()
        local v = tonumber(box.Text)
        if v then CARRY_SPEED = v; box.Text = tostring(v)
        else box.Text = tostring(CARRY_SPEED) end
    end)
    yPos = yPos + 36
end

addDivider()
createCategoryHeader("KEY CONFIG")

local keyBtnAutoLeft      = makeKeyRow("Auto Left",       autoLeftKey.Name)
local keyBtnAutoRight     = makeKeyRow("Auto Right",      autoRightKey.Name)
local keyBtnAutoLeftPlay  = makeKeyRow("Auto Left Play",  autoLeftPlayKey.Name)
local keyBtnAutoRightPlay = makeKeyRow("Auto Right Play", autoRightPlayKey.Name)
local keyBtnSpeed         = makeKeyRow("Speed Toggle",    speedToggleKey.Name)
local keyBtnGUI           = makeKeyRow("GUI Toggle",      guiToggleKey.Name)
local keyBtnFloat         = makeKeyRow("Float",           floatKey.Name)
local keyBtnAimbot        = makeKeyRow("Aimbot",          autoBatKey.Name)
local keyBtnTPDown        = makeKeyRow("TP Down",         tpDownKey.Name)
local keyBtnDrop          = makeKeyRow("Drop Brainrots",  dropKey.Name)

keyBtnAutoLeft.MouseButton1Click:Connect(function()      keyBtnAutoLeft.Text="...";      waitingForKeybind=keyBtnAutoLeft;      waitingForKeybindType="AutoLeft" end)
keyBtnAutoRight.MouseButton1Click:Connect(function()     keyBtnAutoRight.Text="...";     waitingForKeybind=keyBtnAutoRight;     waitingForKeybindType="AutoRight" end)
keyBtnAutoLeftPlay.MouseButton1Click:Connect(function()  keyBtnAutoLeftPlay.Text="...";  waitingForKeybind=keyBtnAutoLeftPlay;  waitingForKeybindType="AutoLeftPlay" end)
keyBtnAutoRightPlay.MouseButton1Click:Connect(function() keyBtnAutoRightPlay.Text="..."; waitingForKeybind=keyBtnAutoRightPlay; waitingForKeybindType="AutoRightPlay" end)
keyBtnSpeed.MouseButton1Click:Connect(function()         keyBtnSpeed.Text="...";         waitingForKeybind=keyBtnSpeed;         waitingForKeybindType="SpeedToggle" end)
keyBtnGUI.MouseButton1Click:Connect(function()           keyBtnGUI.Text="...";           waitingForKeybind=keyBtnGUI;           waitingForKeybindType="GUIToggle" end)
keyBtnFloat.MouseButton1Click:Connect(function()         keyBtnFloat.Text="...";         waitingForKeybind=keyBtnFloat;         waitingForKeybindType="Float" end)
keyBtnAimbot.MouseButton1Click:Connect(function()        keyBtnAimbot.Text="...";        waitingForKeybind=keyBtnAimbot;        waitingForKeybindType="AutoBat" end)
keyBtnTPDown.MouseButton1Click:Connect(function()        keyBtnTPDown.Text="...";        waitingForKeybind=keyBtnTPDown;        waitingForKeybindType="TPDown" end)
keyBtnDrop.MouseButton1Click:Connect(function()          keyBtnDrop.Text="...";          waitingForKeybind=keyBtnDrop;          waitingForKeybindType="Drop" end)

addDivider()
createCategoryHeader("SETTINGS")

-- Float height slider
do
    local lRow = Instance.new("Frame"); lRow.Size = UDim2.new(1,-24,0,20); lRow.Position = UDim2.new(0,12,0,yPos)
    lRow.BackgroundTransparency = 1; lRow.ZIndex = 5; lRow.Parent = content

    local slLbl = Instance.new("TextLabel"); slLbl.Size = UDim2.new(0.6,0,1,0); slLbl.BackgroundTransparency = 1
    slLbl.Text = "Float Height"; slLbl.TextColor3 = C.textDim; slLbl.Font = Enum.Font.GothamSemibold
    slLbl.TextSize = 11; slLbl.TextXAlignment = Enum.TextXAlignment.Left; slLbl.ZIndex = 5; slLbl.Parent = lRow

    local slVal = Instance.new("TextLabel"); slVal.Size = UDim2.new(0.4,0,1,0); slVal.Position = UDim2.new(0.6,0,0,0)
    slVal.BackgroundTransparency = 1; slVal.Text = tostring(FLOAT_HEIGHT).." st"
    slVal.TextColor3 = C.textDim; slVal.Font = Enum.Font.GothamBold
    slVal.TextSize = 11; slVal.TextXAlignment = Enum.TextXAlignment.Right; slVal.ZIndex = 5; slVal.Parent = lRow
    yPos = yPos + 22

    local track = Instance.new("Frame"); track.Size = UDim2.new(1,-24,0,6); track.Position = UDim2.new(0,12,0,yPos)
    track.BackgroundColor3 = Color3.fromRGB(30,35,55); track.BorderSizePixel = 0; track.ZIndex = 5; track.Parent = content
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame"); fill.Size = UDim2.new(math.clamp((FLOAT_HEIGHT-1)/19,0,1),0,1,0)
    fill.BackgroundColor3 = C.accent; fill.BorderSizePixel = 0; fill.ZIndex = 5; fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,14,0,14)
    knob.Position = UDim2.new(math.clamp((FLOAT_HEIGHT-1)/19,0,1),-7,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(220,230,255); knob.BorderSizePixel = 0; knob.ZIndex = 6; knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local hitbox = Instance.new("TextButton"); hitbox.Size = UDim2.new(1,14,1,14); hitbox.Position = UDim2.new(0,-7,0,-7)
    hitbox.BackgroundTransparency = 1; hitbox.Text = ""; hitbox.ZIndex = 7; hitbox.Parent = track

    local isDrag = false
    local function updateSlider(ix)
        local ap = track.AbsolutePosition.X; local as = track.AbsoluteSize.X
        local pct = math.clamp((ix-ap)/as, 0, 1)
        FLOAT_HEIGHT = math.floor(1 + pct*19)
        fill.Size = UDim2.new(pct,0,1,0); knob.Position = UDim2.new(pct,-7,0.5,-7)
        slVal.Text = tostring(FLOAT_HEIGHT).." st"; updateFloatHeight()
    end
    hitbox.MouseButton1Down:Connect(function() isDrag = true end)
    UserInputService.InputChanged:Connect(function(i)
        if isDrag and i.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then isDrag = false end
    end)
    yPos = yPos + 18
end

-- UI Transparency slider
do
    local lRow = Instance.new("Frame"); lRow.Size = UDim2.new(1,-24,0,20); lRow.Position = UDim2.new(0,12,0,yPos)
    lRow.BackgroundTransparency = 1; lRow.ZIndex = 5; lRow.Parent = content

    local tLbl = Instance.new("TextLabel"); tLbl.Size = UDim2.new(0.6,0,1,0); tLbl.BackgroundTransparency = 1
    tLbl.Text = "UI Transparency"; tLbl.TextColor3 = C.textDim; tLbl.Font = Enum.Font.GothamSemibold
    tLbl.TextSize = 11; tLbl.TextXAlignment = Enum.TextXAlignment.Left; tLbl.ZIndex = 5; tLbl.Parent = lRow

    local tVal = Instance.new("TextLabel"); tVal.Size = UDim2.new(0.4,0,1,0); tVal.Position = UDim2.new(0.6,0,0,0)
    tVal.BackgroundTransparency = 1; tVal.Text = "0%"; tVal.TextColor3 = C.textDim
    tVal.Font = Enum.Font.GothamBold; tVal.TextSize = 11; tVal.TextXAlignment = Enum.TextXAlignment.Right
    tVal.ZIndex = 5; tVal.Parent = lRow
    yPos = yPos + 22

    local track = Instance.new("Frame"); track.Size = UDim2.new(1,-24,0,6); track.Position = UDim2.new(0,12,0,yPos)
    track.BackgroundColor3 = Color3.fromRGB(30,35,55); track.BorderSizePixel = 0; track.ZIndex = 5; track.Parent = content
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame"); fill.Size = UDim2.new(currentTransparency,0,1,0)
    fill.BackgroundColor3 = C.accent; fill.BorderSizePixel = 0; fill.ZIndex = 5; fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,14,0,14)
    knob.Position = UDim2.new(currentTransparency,-7,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(220,230,255); knob.BorderSizePixel = 0; knob.ZIndex = 6; knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local hitbox = Instance.new("TextButton"); hitbox.Size = UDim2.new(1,14,1,14); hitbox.Position = UDim2.new(0,-7,0,-7)
    hitbox.BackgroundTransparency = 1; hitbox.Text = ""; hitbox.ZIndex = 7; hitbox.Parent = track

    local isDrag = false
    local function updateTrans(ix)
        local ap = track.AbsolutePosition.X; local as = track.AbsoluteSize.X
        local pct = math.clamp((ix-ap)/as, 0, 1)
        currentTransparency = pct
        fill.Size = UDim2.new(pct,0,1,0); knob.Position = UDim2.new(pct,-7,0.5,-7)
        main.BackgroundTransparency = pct
        if StealBarFrame then StealBarFrame.BackgroundTransparency = math.max(0.04, pct) end
        tVal.Text = math.floor(pct*100).."%"
    end
    hitbox.MouseButton1Down:Connect(function() isDrag = true end)
    UserInputService.InputChanged:Connect(function(i)
        if isDrag and i.UserInputType == Enum.UserInputType.MouseMovement then updateTrans(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then isDrag = false end
    end)
    if currentTransparency > 0 then updateTrans(track.AbsolutePosition.X + track.AbsoluteSize.X*currentTransparency) end
    yPos = yPos + 18
end

yPos = yPos + 10

autoSaveLabel = Instance.new("TextLabel")
autoSaveLabel.Size = UDim2.new(1,-24,0,24); autoSaveLabel.Position = UDim2.new(0,12,0,yPos)
autoSaveLabel.BackgroundTransparency = 1; autoSaveLabel.Text = "Config auto-saves every 5s"
autoSaveLabel.TextColor3 = C.textMid; autoSaveLabel.Font = Enum.Font.GothamBold
autoSaveLabel.TextSize = 10; autoSaveLabel.TextXAlignment = Enum.TextXAlignment.Center
autoSaveLabel.ZIndex = 5; autoSaveLabel.Parent = content
yPos = yPos + 30

createToggle("Mobile Buttons", "MobileButtonsVisible", function(s)
    Enabled.MobileButtonsVisible = s
    if _G.NebulaMobileContainer then
        _G.NebulaMobileContainer.Visible = s
    end
end)

createToggle("Lock UI", "UILocked", function(s)
    Enabled.UILocked = s
    main.Draggable = not s
    if _G.NebulaMobileContainer then
        _G.NebulaMobileContainer.Draggable = not s
    end
    if _G.NebulaUILocked ~= nil then
        _G.NebulaUILocked = s
    end
end)

content.CanvasSize = UDim2.new(0,0,0,yPos)

-- ══════════════════════════════════════════
-- MINI GUI REMOVED
-- ══════════════════════════════════════════
if false then
    local MINI_W = 230; local PAD = 10
    local miniWaitingBtn, miniWaitingType = nil, nil

    local miniGui = Instance.new("Frame")
    miniGui.Name = "N5DuelsMiniGui"; _G.NebulaMiniGui = miniGui
    miniGui.Size = UDim2.new(0,MINI_W,0,10)
    miniGui.Position = UDim2.new(1,-(MINI_W+16),0,16)
    miniGui.BackgroundColor3 = C.bg; miniGui.BackgroundTransparency = currentTransparency
    miniGui.BorderSizePixel = 0; miniGui.Active = true; miniGui.Draggable = true
    miniGui.Visible = Enabled.MiniGuiEnabled; miniGui.ZIndex = 30; miniGui.Parent = gui
    Instance.new("UICorner", miniGui).CornerRadius = UDim.new(0,8)
    do local s = Instance.new("UIStroke"); s.Color = C.border; s.Thickness = 2; s.Parent = miniGui end

    local miniTitle = Instance.new("TextLabel")
    miniTitle.Size = UDim2.new(0,100,0,34); miniTitle.Position = UDim2.new(0,PAD,0,0)
    miniTitle.BackgroundTransparency = 1; miniTitle.Text = "NEBULA"
    miniTitle.TextColor3 = C.accentGlow; miniTitle.Font = Enum.Font.GothamBlack; miniTitle.TextSize = 12
    miniTitle.TextXAlignment = Enum.TextXAlignment.Left; miniTitle.TextYAlignment = Enum.TextYAlignment.Center
    miniTitle.ZIndex = 32; miniTitle.Parent = miniGui

    local miniFps = Instance.new("TextLabel"); miniFps.Size = UDim2.new(0,70,0,15); miniFps.Position = UDim2.new(1,-(70+PAD),0,6)
    miniFps.BackgroundTransparency=1; miniFps.Text="FPS: --"; miniFps.TextColor3=C.textMid
    miniFps.Font=Enum.Font.GothamBold; miniFps.TextSize=10; miniFps.TextXAlignment=Enum.TextXAlignment.Right; miniFps.ZIndex=32; miniFps.Parent=miniGui

    local miniMs = Instance.new("TextLabel"); miniMs.Size = UDim2.new(0,70,0,15); miniMs.Position = UDim2.new(1,-(70+PAD),0,18)
    miniMs.BackgroundTransparency=1; miniMs.Text="MS: --"; miniMs.TextColor3=C.textMid
    miniMs.Font=Enum.Font.GothamBold; miniMs.TextSize=10; miniMs.TextXAlignment=Enum.TextXAlignment.Right; miniMs.ZIndex=32; miniMs.Parent=miniGui

    local function makeMiniDiv(y)
        local d=Instance.new("Frame"); d.Size=UDim2.new(0.85,0,0,1); d.Position=UDim2.new(0.075,0,0,y)
        d.BackgroundColor3=C.border; d.BackgroundTransparency=0.5; d.BorderSizePixel=0; d.ZIndex=31; d.Parent=miniGui
    end
    makeMiniDiv(34)
    local cY = 40

    local function miniSLbl(txt)
        local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-PAD*2,0,14); l.Position=UDim2.new(0,PAD,0,cY)
        l.BackgroundTransparency=1; l.Text=txt; l.TextColor3=C.accentGlow; l.Font=Enum.Font.GothamBlack; l.TextSize=9
        l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=32; l.Parent=miniGui; cY=cY+17
    end

    miniSLbl("SPEED")

    local miniNormalBox, miniCarryBox

    local function miniSpeedRow(lTxt, defVal, onChange, getVal)
        local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0,110,0,22); lbl.Position=UDim2.new(0,PAD,0,cY)
        lbl.BackgroundTransparency=1; lbl.Text=lTxt; lbl.TextColor3=C.textMid; lbl.Font=Enum.Font.GothamSemibold; lbl.TextSize=11
        lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=32; lbl.Parent=miniGui
        local box=Instance.new("TextBox"); box.Size=UDim2.new(0,60,0,22); box.Position=UDim2.new(1,-(60+PAD),0,cY)
        box.BackgroundColor3=C.panel; box.BorderSizePixel=0; box.Text=tostring(defVal)
        box.TextColor3=C.text; box.Font=Enum.Font.GothamBold; box.TextSize=11
        box.ClearTextOnFocus=false; box.ZIndex=32; box.Parent=miniGui
        Instance.new("UICorner",box).CornerRadius=UDim.new(0,4)
        do local s=Instance.new("UIStroke"); s.Color=C.border; s.Thickness=1; s.Parent=box end
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local v=tonumber(box.Text)
            if v then onChange(v) end
        end)
        box.FocusLost:Connect(function()
            local v=tonumber(box.Text)
            if v then onChange(v); box.Text=tostring(v) else box.Text=tostring(getVal()) end
        end)
        cY=cY+26; return box
    end

    miniNormalBox = miniSpeedRow("Normal", NORMAL_SPEED, function(v) NORMAL_SPEED=v; if normalBox and not normalBox:IsFocused() then normalBox.Text=tostring(v) end end, function() return NORMAL_SPEED end)
    miniCarryBox  = miniSpeedRow("Carry",  CARRY_SPEED,  function(v) CARRY_SPEED=v;  if carryBox  and not carryBox:IsFocused()  then carryBox.Text=tostring(v)  end end, function() return CARRY_SPEED  end)

    cY=cY+2; makeMiniDiv(cY); cY=cY+8; miniSLbl("MOVEMENT")

    local KEY_W=36; local TOGGLE_W=36; local ROW_H=22; local HINT_H=11

    local function buildMovRow(lTxt, getKeyFn, isEnabledFn, setEnabledFn, onToggle)
        local keyBtn=Instance.new("TextButton"); keyBtn.Size=UDim2.new(0,KEY_W,0,ROW_H); keyBtn.Position=UDim2.new(0,PAD,0,cY)
        keyBtn.BackgroundColor3=C.panel; keyBtn.Text=getKeyFn().Name; keyBtn.TextColor3=C.textMid
        keyBtn.Font=Enum.Font.GothamBold; keyBtn.TextSize=9; keyBtn.BorderSizePixel=0; keyBtn.ZIndex=32; keyBtn.Parent=miniGui
        Instance.new("UICorner",keyBtn).CornerRadius=UDim.new(0,4)
        do local s=Instance.new("UIStroke"); s.Color=C.border; s.Thickness=1; s.Parent=keyBtn end

        local rowLbl=Instance.new("TextLabel"); rowLbl.Size=UDim2.new(0,MINI_W-PAD*2-KEY_W-6-TOGGLE_W-6,0,ROW_H)
        rowLbl.Position=UDim2.new(0,PAD+KEY_W+6,0,cY); rowLbl.BackgroundTransparency=1; rowLbl.Text=lTxt
        rowLbl.TextColor3=C.textMid; rowLbl.Font=Enum.Font.GothamSemibold; rowLbl.TextSize=11
        rowLbl.TextXAlignment=Enum.TextXAlignment.Left; rowLbl.ZIndex=32; rowLbl.Parent=miniGui

        local tbg=Instance.new("Frame"); tbg.Size=UDim2.new(0,TOGGLE_W,0,18); tbg.Position=UDim2.new(1,-(TOGGLE_W+PAD),0,cY+2)
        tbg.BackgroundColor3=isEnabledFn() and C.toggleOn or C.toggleOff; tbg.BorderSizePixel=0; tbg.ZIndex=32; tbg.Parent=miniGui
        Instance.new("UICorner",tbg).CornerRadius=UDim.new(1,0)

        local tcirc=Instance.new("Frame"); tcirc.Size=UDim2.new(0,12,0,12)
        tcirc.Position=isEnabledFn() and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)
        tcirc.BackgroundColor3=isEnabledFn() and C.circleOn or C.circleOff
        tcirc.BorderSizePixel=0; tcirc.ZIndex=33; tcirc.Parent=tbg
        Instance.new("UICorner",tcirc).CornerRadius=UDim.new(1,0)

        local thit=Instance.new("TextButton"); thit.Size=UDim2.new(1,0,1,0); thit.BackgroundTransparency=1; thit.Text=""; thit.ZIndex=34; thit.Parent=tbg

        local hintLbl=Instance.new("TextLabel"); hintLbl.Size=UDim2.new(1,-(PAD*2+KEY_W+6),0,HINT_H)
        hintLbl.Position=UDim2.new(0,PAD+KEY_W+6,0,cY+ROW_H+1); hintLbl.BackgroundTransparency=1
        hintLbl.Text="Press "..getKeyFn().Name; hintLbl.TextColor3=Color3.fromRGB(100,120,170)
        hintLbl.Font=Enum.Font.Gotham; hintLbl.TextSize=9; hintLbl.TextXAlignment=Enum.TextXAlignment.Left; hintLbl.ZIndex=32; hintLbl.Parent=miniGui

        local function setVis(state)
            TweenService:Create(tbg,TweenInfo.new(0.2),{BackgroundColor3=state and C.toggleOn or C.toggleOff}):Play()
            TweenService:Create(tcirc,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
                Position=state and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6),
                BackgroundColor3=state and C.circleOn or C.circleOff
            }):Play()
        end

        thit.MouseButton1Click:Connect(function()
            local s=not isEnabledFn(); setEnabledFn(s); setVis(s); onToggle(s)
        end)
        keyBtn.MouseButton1Click:Connect(function()
            if miniWaitingBtn and miniWaitingBtn~=keyBtn then miniWaitingBtn.Text=miniWaitingBtn:GetAttribute("BoundKey") or "?" miniWaitingBtn.TextColor3=C.textMid end
            miniWaitingBtn=keyBtn; miniWaitingType=lTxt; keyBtn.Text="..."; keyBtn.TextColor3=C.text
        end)
        keyBtn:SetAttribute("BoundKey", getKeyFn().Name)
        local function refreshHint() hintLbl.Text="Press "..getKeyFn().Name end
        cY=cY+ROW_H+HINT_H+6
        return setVis, keyBtn, refreshHint
    end

    local alSet,  alKBtn,  alHR  = buildMovRow("Auto Left",       function() return autoLeftKey      end, function() return AutoLeftEnabled      end, function(v) AutoLeftEnabled=v;      Enabled.AutoLeftEnabled=v      end, function(s) if VisualSetters.AutoLeftEnabled      then VisualSetters.AutoLeftEnabled(s,true)      end; if s then startAutoLeft()      else stopAutoLeft()      end end)
    local arSet,  arKBtn,  arHR  = buildMovRow("Auto Right",      function() return autoRightKey     end, function() return AutoRightEnabled     end, function(v) AutoRightEnabled=v;     Enabled.AutoRightEnabled=v     end, function(s) if VisualSetters.AutoRightEnabled     then VisualSetters.AutoRightEnabled(s,true)     end; if s then startAutoRight()     else stopAutoRight()     end end)
    local alpSet, alpKBtn, alpHR = buildMovRow("Auto Left Play",  function() return autoLeftPlayKey  end, function() return AutoLeftPlayEnabled  end, function(v) AutoLeftPlayEnabled=v;  Enabled.AutoLeftPlayEnabled=v  end, function(s) if VisualSetters.AutoLeftPlayEnabled  then VisualSetters.AutoLeftPlayEnabled(s,true)  end; if s then startAutoLeftPlay()  else stopAutoLeftPlay()  end end)
    local arpSet, arpKBtn, arpHR = buildMovRow("Auto Right Play", function() return autoRightPlayKey end, function() return AutoRightPlayEnabled end, function(v) AutoRightPlayEnabled=v; Enabled.AutoRightPlayEnabled=v end, function(s) if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(s,true) end; if s then startAutoRightPlay() else stopAutoRightPlay() end end)

    cY=cY+4; miniGui.Size=UDim2.new(0,MINI_W,0,cY)

    -- Wrap VisualSetters to also update mini GUI
    local _al=VisualSetters.AutoLeftEnabled;      VisualSetters.AutoLeftEnabled=function(s,sc)      if _al  then _al(s,sc)  end; alSet(s)  end
    local _ar=VisualSetters.AutoRightEnabled;     VisualSetters.AutoRightEnabled=function(s,sc)     if _ar  then _ar(s,sc)  end; arSet(s)  end
    local _alp=VisualSetters.AutoLeftPlayEnabled; VisualSetters.AutoLeftPlayEnabled=function(s,sc)  if _alp then _alp(s,sc) end; alpSet(s) end
    local _arp=VisualSetters.AutoRightPlayEnabled;VisualSetters.AutoRightPlayEnabled=function(s,sc) if _arp then _arp(s,sc) end; arpSet(s) end

    -- Mini GUI keybind handler
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not miniWaitingBtn or gpe then return end
        if input.KeyCode==Enum.KeyCode.Unknown then return end
        local k=input.KeyCode; local kName=k.Name
        if miniWaitingType=="Auto Left"       then autoLeftKey=k;      if keyBtnAutoLeft      then keyBtnAutoLeft.Text=kName      end; if _G.AutoLeftKeybindBtn      then _G.AutoLeftKeybindBtn.Text=kName      end; alKBtn:SetAttribute("BoundKey",kName);  alHR()
        elseif miniWaitingType=="Auto Right"  then autoRightKey=k;     if keyBtnAutoRight     then keyBtnAutoRight.Text=kName     end; if _G.AutoRightKeybindBtn     then _G.AutoRightKeybindBtn.Text=kName     end; arKBtn:SetAttribute("BoundKey",kName);  arHR()
        elseif miniWaitingType=="Auto Left Play"  then autoLeftPlayKey=k;  if keyBtnAutoLeftPlay  then keyBtnAutoLeftPlay.Text=kName  end; if _G.AutoLeftPlayKeybindBtn  then _G.AutoLeftPlayKeybindBtn.Text=kName  end; alpKBtn:SetAttribute("BoundKey",kName); alpHR()
        elseif miniWaitingType=="Auto Right Play" then autoRightPlayKey=k; if keyBtnAutoRightPlay then keyBtnAutoRightPlay.Text=kName end; if _G.AutoRightPlayKeybindBtn then _G.AutoRightPlayKeybindBtn.Text=kName end; arpKBtn:SetAttribute("BoundKey",kName); arpHR()
        end
        miniWaitingBtn.Text=kName; miniWaitingBtn.TextColor3=C.textMid; miniWaitingBtn=nil; miniWaitingType=nil
    end)

    -- FPS / ping update
    local fpsSampleAcc, fpsSampleCount, pingTimer = 0, 0, 0
    RunService.Heartbeat:Connect(function(dt)
        if not miniGui.Visible then return end
        fpsSampleAcc=fpsSampleAcc+(1/math.max(dt,0.001)); fpsSampleCount=fpsSampleCount+1
        if fpsSampleCount >= 10 then
            local fps=math.floor(fpsSampleAcc/fpsSampleCount); fpsSampleAcc=0; fpsSampleCount=0
            local fc=fps>=55 and C.text or fps>=30 and Color3.fromRGB(255,200,80) or Color3.fromRGB(255,80,80)
            miniFps.Text="FPS: "..fps; miniFps.TextColor3=fc
        end
        pingTimer=pingTimer+dt
        if pingTimer >= 1 then
            pingTimer=0
            pcall(function()
                local stats=game:GetService("Stats")
                local pi=stats.Network.ServerStatsItem["Data Ping"]
                if pi then local ms=math.floor(pi:GetValue()); local mc=ms<=80 and C.text or ms<=150 and Color3.fromRGB(255,200,80) or Color3.fromRGB(255,80,80); miniMs.Text="MS: "..ms; miniMs.TextColor3=mc end
            end)
        end
        if not miniWaitingBtn then
            if alKBtn.Text~=autoLeftKey.Name      and alKBtn.Text~="..."  then alKBtn.Text=autoLeftKey.Name;      alKBtn:SetAttribute("BoundKey",autoLeftKey.Name);      alHR()  end
            if arKBtn.Text~=autoRightKey.Name     and arKBtn.Text~="..."  then arKBtn.Text=autoRightKey.Name;     arKBtn:SetAttribute("BoundKey",autoRightKey.Name);     arHR()  end
            if alpKBtn.Text~=autoLeftPlayKey.Name and alpKBtn.Text~="..." then alpKBtn.Text=autoLeftPlayKey.Name; alpKBtn:SetAttribute("BoundKey",autoLeftPlayKey.Name); alpHR() end
            if arpKBtn.Text~=autoRightPlayKey.Name and arpKBtn.Text~="..." then arpKBtn.Text=autoRightPlayKey.Name; arpKBtn:SetAttribute("BoundKey",autoRightPlayKey.Name); arpHR() end
        end
    end)
end

-- ══════════════════════════════════════════
-- REFRESH ALL KEYBIND BADGES
-- ══════════════════════════════════════════
local function refreshAllBadges()
    if _G.AutoLeftKeybindBtn      then _G.AutoLeftKeybindBtn.Text=autoLeftKey.Name      end
    if _G.AutoRightKeybindBtn     then _G.AutoRightKeybindBtn.Text=autoRightKey.Name    end
    if _G.AutoLeftPlayKeybindBtn  then _G.AutoLeftPlayKeybindBtn.Text=autoLeftPlayKey.Name   end
    if _G.AutoRightPlayKeybindBtn then _G.AutoRightPlayKeybindBtn.Text=autoRightPlayKey.Name  end
    if _G.AimbotKeybindBtn        then _G.AimbotKeybindBtn.Text=autoBatKey.Name         end
    if _G.TPDownKeybindBtn        then _G.TPDownKeybindBtn.Text=tpDownKey.Name          end
    if _G.DropKeybindBtn          then _G.DropKeybindBtn.Text=dropKey.Name              end
    if keyBtnAutoLeft      then keyBtnAutoLeft.Text=autoLeftKey.Name       end
    if keyBtnAutoRight     then keyBtnAutoRight.Text=autoRightKey.Name     end
    if keyBtnAutoLeftPlay  then keyBtnAutoLeftPlay.Text=autoLeftPlayKey.Name   end
    if keyBtnAutoRightPlay then keyBtnAutoRightPlay.Text=autoRightPlayKey.Name end
    if keyBtnSpeed         then keyBtnSpeed.Text=speedToggleKey.Name       end
    if keyBtnGUI           then keyBtnGUI.Text=guiToggleKey.Name           end
    if keyBtnFloat         then keyBtnFloat.Text=floatKey.Name             end
    if keyBtnAimbot        then keyBtnAimbot.Text=autoBatKey.Name          end
    if keyBtnTPDown        then keyBtnTPDown.Text=tpDownKey.Name           end
    if keyBtnDrop          then keyBtnDrop.Text=dropKey.Name               end
end

-- ══════════════════════════════════════════
-- GLOBAL INPUT HANDLER
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    -- Keybind capture
    if waitingForKeybind and input.KeyCode ~= Enum.KeyCode.Unknown then
        local k = input.KeyCode
        if waitingForKeybindType=="AutoLeft"      then autoLeftKey=k
        elseif waitingForKeybindType=="AutoRight" then autoRightKey=k
        elseif waitingForKeybindType=="AutoLeftPlay"  then autoLeftPlayKey=k
        elseif waitingForKeybindType=="AutoRightPlay" then autoRightPlayKey=k
        elseif waitingForKeybindType=="SpeedToggle" then speedToggleKey=k
        elseif waitingForKeybindType=="GUIToggle" then guiToggleKey=k
        elseif waitingForKeybindType=="Float"     then floatKey=k
        elseif waitingForKeybindType=="TPDown"    then tpDownKey=k
        elseif waitingForKeybindType=="AutoBat"   then autoBatKey=k
        elseif waitingForKeybindType=="Drop"      then dropKey=k end
        waitingForKeybind.Text = k.Name; waitingForKeybind.TextColor3 = Color3.fromRGB(140,160,200)
        waitingForKeybind = nil; waitingForKeybindType = nil
        refreshAllBadges(); return
    end

    -- Action keys
    if input.KeyCode == speedToggleKey then
        speedToggled = not speedToggled
        if modeLabel then modeLabel.Text = speedToggled and "Mode: Carry" or "Mode: Normal" end
    end
    if input.KeyCode == autoLeftKey then
        AutoLeftEnabled = not AutoLeftEnabled; Enabled.AutoLeftEnabled = AutoLeftEnabled
        if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(AutoLeftEnabled) end
        if AutoLeftEnabled then startAutoLeft() else stopAutoLeft() end
    end
    if input.KeyCode == autoRightKey then
        AutoRightEnabled = not AutoRightEnabled; Enabled.AutoRightEnabled = AutoRightEnabled
        if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(AutoRightEnabled) end
        if AutoRightEnabled then startAutoRight() else stopAutoRight() end
    end
    if input.KeyCode == autoLeftPlayKey then
        AutoLeftPlayEnabled = not AutoLeftPlayEnabled; Enabled.AutoLeftPlayEnabled = AutoLeftPlayEnabled
        if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(AutoLeftPlayEnabled) end
        if AutoLeftPlayEnabled then startAutoLeftPlay() else stopAutoLeftPlay() end
    end
    if input.KeyCode == autoRightPlayKey then
        AutoRightPlayEnabled = not AutoRightPlayEnabled; Enabled.AutoRightPlayEnabled = AutoRightPlayEnabled
        if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(AutoRightPlayEnabled) end
        if AutoRightPlayEnabled then startAutoRightPlay() else stopAutoRightPlay() end
    end
    if input.KeyCode == autoBatKey then
        local ns = not Enabled.BatAimbot; Enabled.BatAimbot = ns; autoBatToggled = ns
        if VisualSetters.BatAimbot then VisualSetters.BatAimbot(ns) end
        if ns then startBatAimbot() else stopBatAimbot() end
    end
    if input.KeyCode == floatKey then
        floatEnabled = not floatEnabled; Enabled.FloatEnabled = floatEnabled
        if VisualSetters.FloatEnabled then VisualSetters.FloatEnabled(floatEnabled) end
        if floatEnabled then startFloat() else stopFloat() end
    end
    if input.KeyCode == guiToggleKey or input.KeyCode == Enum.KeyCode.L then
        guiVisible = not guiVisible; main.Visible = guiVisible
    end
    if input.KeyCode == tpDownKey then task.spawn(doTPDown) end
    if input.KeyCode == dropKey   then task.spawn(doDropBrainrots) end
    if input.KeyCode == Enum.KeyCode.M then
        Enabled.Galaxy = not Enabled.Galaxy
        if VisualSetters.Galaxy then VisualSetters.Galaxy(Enabled.Galaxy) end
        if Enabled.Galaxy then startGalaxy() else stopGalaxy() end
    end
    if input.KeyCode == Enum.KeyCode.Space then spaceHeld = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then spaceHeld = false end
end)

-- ══════════════════════════════════════════
-- CHARACTER SETUP
-- ══════════════════════════════════════════
local function setupChar(char)
    h   = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    -- Clear refs when this character dies so the heartbeat doesn't touch a removed Humanoid
    h.Died:Connect(function()
        h   = nil
        hrp = nil
    end)
    local head = char:FindFirstChild("Head")
    if head then
        -- Remove any old BillboardGui
        for _, c in ipairs(head:GetChildren()) do
            if c:IsA("BillboardGui") and c.Name == "NebulaSpeedBB" then c:Destroy() end
        end
        local bb = Instance.new("BillboardGui", head)
        bb.Name = "NebulaSpeedBB"
        bb.Size = UDim2.new(0, 160, 0, 40)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true

        speedLbl = Instance.new("TextLabel", bb)
        speedLbl.Size = UDim2.new(1, 0, 1, 0)
        speedLbl.BackgroundTransparency = 1
        speedLbl.TextColor3 = Color3.fromRGB(190, 180, 255)
        speedLbl.Font = Enum.Font.GothamBlack
        speedLbl.TextSize = 15
        speedLbl.TextStrokeTransparency = 0.1
        speedLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        speedLbl.TextScaled = false
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    -- Stop all movement immediately on respawn so loops don't fire on a fresh character
    AutoLeftEnabled = false; Enabled.AutoLeftEnabled = false
    AutoRightEnabled = false; Enabled.AutoRightEnabled = false
    AutoLeftPlayEnabled = false; Enabled.AutoLeftPlayEnabled = false
    AutoRightPlayEnabled = false; Enabled.AutoRightPlayEnabled = false
    if autoLeftConnection then autoLeftConnection:Disconnect(); autoLeftConnection = nil end
    if autoRightConnection then autoRightConnection:Disconnect(); autoRightConnection = nil end
    if autoLeftPlayConnection then autoLeftPlayConnection:Disconnect(); autoLeftPlayConnection = nil end
    if autoRightPlayConnection then autoRightPlayConnection:Disconnect(); autoRightPlayConnection = nil end
    if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(false, true) end
    if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(false, true) end
    if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(false, true) end
    if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(false, true) end
    setupChar(char)
end)
task.defer(function() if LocalPlayer.Character then setupChar(LocalPlayer.Character) end end)

-- ══════════════════════════════════════════
-- AUTO CARRY ON BRAINROT PICKUP
-- ══════════════════════════════════════════
Enabled.AutoCarryOnPickup = false

local autoCarryToolConn = nil
local function hookAutoCarryChar(char)
    if autoCarryToolConn then autoCarryToolConn:Disconnect(); autoCarryToolConn = nil end
    if not char then return end
    autoCarryToolConn = char.ChildAdded:Connect(function(child)
        if not Enabled.AutoCarryOnPickup then return end
        if child:IsA("Tool") then
            speedToggled = true
            local hum = char:FindFirstChildOfClass("Humanoid")
            -- speed controlled by game
            if modeLabel then modeLabel.Text = "Mode: Carry" end
        end
    end)
end

local autoCarryCharConn = nil
local function startAutoCarryMode()
    hookAutoCarryChar(LocalPlayer.Character)
    if autoCarryCharConn then autoCarryCharConn:Disconnect() end
    autoCarryCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        hookAutoCarryChar(char)
    end)
end

local function stopAutoCarryMode()
    if autoCarryToolConn then autoCarryToolConn:Disconnect(); autoCarryToolConn = nil end
    if autoCarryCharConn then autoCarryCharConn:Disconnect(); autoCarryCharConn = nil end
end

-- ══════════════════════════════════════════
-- AUTO SAVE
-- ══════════════════════════════════════════
task.spawn(function()
    while task.wait(5) do
        if gui and gui.Parent then
            local ok = saveConfig()
            if autoSaveLabel and autoSaveLabel.Parent then
                if ok then autoSaveLabel.Text = "Saved ✓"; autoSaveLabel.TextColor3 = Color3.fromRGB(34,197,94)
                else       autoSaveLabel.Text = "Save failed ✗"; autoSaveLabel.TextColor3 = Color3.fromRGB(239,68,68) end
                task.delay(2, function()
                    if autoSaveLabel and autoSaveLabel.Parent then
                        autoSaveLabel.Text = "Config auto-saves every 5s"; autoSaveLabel.TextColor3 = Color3.fromRGB(100,120,170)
                    end
                end)
            end
        end
    end
end)

-- ══════════════════════════════════════════
-- RESTORE STATE FROM CONFIG
-- ══════════════════════════════════════════
task.spawn(function()
    task.wait(2)
    for key, setter in pairs(VisualSetters) do
        if Enabled[key] ~= nil then setter(Enabled[key], true) end
    end
    if Enabled.AutoSteal    then startAutoSteal()    end
    if Enabled.AntiRagdoll  then startAntiRagdoll()  end
    if Enabled.CounterMedusa then startCounterMedusa() end
    if Enabled.RagdollTP    then startRagdollTP()    end
    if Enabled.Galaxy       then startGalaxy()       end
    if Enabled.Unwalk       then startUnwalk()       end
    if Enabled.Optimizer    then enableOptimizer()   end
    if Enabled.DarkMode     then enableDarkMode()    end
    if Enabled.NoClip       then startNoClip()       end
    if Enabled.BatAimbot    then autoBatToggled=true; startBatAimbot() end
    if Enabled.FloatEnabled then floatEnabled=true; startFloat() end
    if Enabled.AutoLeftEnabled      then AutoLeftEnabled=true;      startAutoLeft()      end
    if Enabled.AutoRightEnabled     then AutoRightEnabled=true;     startAutoRight()     end
    if Enabled.AutoLeftPlayEnabled  then AutoLeftPlayEnabled=true;  startAutoLeftPlay()  end
    if Enabled.AutoRightPlayEnabled then AutoRightPlayEnabled=true; startAutoRightPlay() end
    if SBRadBtn then SBRadBtn.Text = tostring(Values.STEAL_RADIUS) end
    refreshAllBadges()
end)

-- ══════════════════════════════════════════
-- MOBILE BUTTONS (draggable, lockable, smaller)
-- ══════════════════════════════════════════
do
    local vp = workspace.CurrentCamera.ViewportSize
    local scale = math.clamp(math.min(vp.X, vp.Y) / 480, 0.7, 1.1)

    local MB = {
        bg        = Color3.fromRGB(7, 7, 14),
        bgBtn     = Color3.fromRGB(13, 13, 28),
        bgBtnOn   = Color3.fromRGB(30, 22, 72),
        bgBar     = Color3.fromRGB(10, 10, 22),
        border    = Color3.fromRGB(60, 55, 140),
        accent    = Color3.fromRGB(120, 100, 255),
        accent2   = Color3.fromRGB(190, 80, 255),
        accentGlow= Color3.fromRGB(190, 180, 255),
        text      = Color3.fromRGB(245, 245, 255),
        textDim   = Color3.fromRGB(150, 150, 210),
        textOff   = Color3.fromRGB(80, 78, 130),
        success   = Color3.fromRGB(52, 211, 153),
        danger    = Color3.fromRGB(248, 113, 113),
        locked    = Color3.fromRGB(248, 190, 80),
    }

    -- Smaller button sizes
    local BTN_W  = math.floor(62 * scale)
    local BTN_H  = math.floor(42 * scale)
    local RADIUS = math.floor(10 * scale)
    local GAP    = math.floor(5  * scale)
    local FSIZE  = math.floor(9  * scale)
    local FSIZE_S= math.floor(7  * scale)
    local COLS   = 4  -- 4 buttons per row
    local BAR_H  = math.floor(24 * scale)

    local PANEL_W = (BTN_W * COLS) + (GAP * (COLS + 1))
    local PANEL_H = BAR_H + (BTN_H * 3) + (GAP * 4)

    local mobileGui = Instance.new("ScreenGui")
    mobileGui.Name = "NebulaMobileButtons"
    mobileGui.ResetOnSpawn = false
    mobileGui.DisplayOrder = 20
    mobileGui.IgnoreGuiInset = true
    mobileGui.Parent = pgui

    -- Outer draggable panel with background
    local panel = Instance.new("Frame")
    panel.Name = "NebulaMobilePanel"
    panel.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
    panel.Position = UDim2.new(1, -(PANEL_W + 10), 1, -(PANEL_H + 10))
    panel.BackgroundColor3 = MB.bg
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.Active = true
    panel.Draggable = true
    panel.ZIndex = 18
    panel.Parent = mobileGui
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, math.floor(12 * scale))
    do
        local ps = Instance.new("UIStroke")
        ps.Color = MB.accent; ps.Thickness = 1.2; ps.Transparency = 0.45
        ps.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; ps.Parent = panel
        _G.NebulaMobilePanelStroke = ps
    end

    -- ── DRAG BAR (top strip — grab handle + lock button) ──
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, BAR_H)
    bar.Position = UDim2.new(0, 0, 0, 0)
    bar.BackgroundColor3 = MB.bgBar
    bar.BackgroundTransparency = 0.1
    bar.BorderSizePixel = 0
    bar.ZIndex = 19
    bar.Parent = panel
    do
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, math.floor(12 * scale))
        bc.Parent = bar
    end
    -- Square off bottom corners of bar
    do
        local sq = Instance.new("Frame")
        sq.Size = UDim2.new(1, 0, 0, math.floor(12 * scale))
        sq.Position = UDim2.new(0, 0, 1, -math.floor(12 * scale))
        sq.BackgroundColor3 = MB.bgBar
        sq.BackgroundTransparency = 0.1
        sq.BorderSizePixel = 0
        sq.ZIndex = 19
        sq.Parent = bar
    end

    -- Drag icon (3 dots)
    local dragLbl = Instance.new("TextLabel")
    dragLbl.Size = UDim2.new(1, -BAR_H - 4, 1, 0)
    dragLbl.Position = UDim2.new(0, 8, 0, 0)
    dragLbl.BackgroundTransparency = 1
    dragLbl.Text = "⠿ NEBULA"
    dragLbl.TextColor3 = MB.textOff
    dragLbl.Font = Enum.Font.GothamBlack
    dragLbl.TextSize = math.floor(8 * scale)
    dragLbl.TextXAlignment = Enum.TextXAlignment.Left
    dragLbl.ZIndex = 20
    dragLbl.Parent = bar

    -- Lock button (top-right of bar)
    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(0, BAR_H - 4, 0, BAR_H - 4)
    lockBtn.Position = UDim2.new(1, -(BAR_H), 0, 2)
    lockBtn.BackgroundColor3 = MB.bgBtn
    lockBtn.BorderSizePixel = 0
    lockBtn.Text = "🔓"
    lockBtn.TextColor3 = MB.textDim
    lockBtn.Font = Enum.Font.GothamBlack
    lockBtn.TextSize = math.floor(9 * scale)
    lockBtn.ZIndex = 22
    lockBtn.Parent = bar
    Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 5)
    do
        local ls = Instance.new("UIStroke")
        ls.Color = MB.border; ls.Thickness = 1; ls.Transparency = 0.4; ls.Parent = lockBtn
    end

    -- container = the grid area below the bar
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, -BAR_H)
    container.Position = UDim2.new(0, 0, 0, BAR_H)
    container.BackgroundTransparency = 1
    container.ZIndex = 19
    container.Parent = panel

    -- Apply saved visibility
    panel.Visible = Enabled.MobileButtonsVisible

    -- ── LOCK LOGIC ──
    local uiLocked = false
    _G.NebulaUILocked = false

    local function setLock(locked)
        uiLocked = locked
        _G.NebulaUILocked = locked
        panel.Draggable = not locked
        main.Draggable  = not locked
        if locked then
            lockBtn.Text = "🔒"
            lockBtn.TextColor3 = MB.locked
            dragLbl.TextColor3 = MB.locked
        else
            lockBtn.Text = "🔓"
            lockBtn.TextColor3 = MB.textDim
            dragLbl.TextColor3 = MB.textOff
        end
    end

    lockBtn.MouseButton1Click:Connect(function()
        setLock(not uiLocked)
    end)

    -- ── BUTTON BUILDER ──
    local function makeMobileBtn(col, row, labelLine1, labelLine2, accentColor, onToggle, getState)
        local xOff = GAP + (col - 1) * (BTN_W + GAP)
        local yOff = GAP + (row - 1) * (BTN_H + GAP)

        local btn = Instance.new("Frame")
        btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
        btn.Position = UDim2.new(0, xOff, 0, yOff)
        btn.BackgroundColor3 = MB.bgBtn
        btn.BorderSizePixel = 0
        btn.ZIndex = 20
        btn.Parent = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, RADIUS)

        local stroke = Instance.new("UIStroke")
        stroke.Color = MB.border; stroke.Thickness = 1.1
        stroke.Transparency = 0.4
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = btn

        local topBar = Instance.new("Frame")
        topBar.Size = UDim2.new(0.65, 0, 0, 2)
        topBar.Position = UDim2.new(0.175, 0, 0, 0)
        topBar.BackgroundColor3 = accentColor
        topBar.BorderSizePixel = 0; topBar.ZIndex = 22
        topBar.BackgroundTransparency = 0.45; topBar.Parent = btn
        Instance.new("UICorner", topBar).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 5, 0, 5)
        dot.Position = UDim2.new(1, -8, 0, 5)
        dot.BackgroundColor3 = MB.textOff
        dot.BorderSizePixel = 0; dot.ZIndex = 23; dot.Parent = btn
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local lbl1 = Instance.new("TextLabel")
        lbl1.Size = UDim2.new(1, -4, 0, math.floor(BTN_H * 0.44))
        lbl1.Position = UDim2.new(0, 2, 0, math.floor(BTN_H * 0.14))
        lbl1.BackgroundTransparency = 1; lbl1.Text = labelLine1
        lbl1.TextColor3 = MB.text; lbl1.Font = Enum.Font.GothamBlack
        lbl1.TextSize = FSIZE; lbl1.TextXAlignment = Enum.TextXAlignment.Center
        lbl1.ZIndex = 21; lbl1.Parent = btn

        local lbl2 = Instance.new("TextLabel")
        lbl2.Size = UDim2.new(1, -4, 0, math.floor(BTN_H * 0.32))
        lbl2.Position = UDim2.new(0, 2, 0, math.floor(BTN_H * 0.56))
        lbl2.BackgroundTransparency = 1; lbl2.Text = labelLine2
        lbl2.TextColor3 = accentColor; lbl2.Font = Enum.Font.GothamBlack
        lbl2.TextSize = FSIZE_S; lbl2.TextXAlignment = Enum.TextXAlignment.Center
        lbl2.ZIndex = 21; lbl2.Parent = btn

        local touch = Instance.new("TextButton")
        touch.Size = UDim2.new(1, 0, 1, 0)
        touch.BackgroundTransparency = 1; touch.Text = ""
        touch.ZIndex = 25; touch.Parent = btn

        local function updateVisual(active)
            if active then
                btn.BackgroundColor3 = MB.bgBtnOn
                stroke.Color = accentColor; stroke.Transparency = 0
                dot.BackgroundColor3 = accentColor
                topBar.BackgroundTransparency = 0
                lbl2.TextColor3 = MB.accentGlow
            else
                btn.BackgroundColor3 = MB.bgBtn
                stroke.Color = MB.border; stroke.Transparency = 0.4
                dot.BackgroundColor3 = MB.textOff
                topBar.BackgroundTransparency = 0.45
                lbl2.TextColor3 = accentColor
            end
        end

        touch.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.06, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.35}):Play()
            task.delay(0.06, function()
                onToggle()
                updateVisual(getState())
                TweenService:Create(btn, TweenInfo.new(0.06, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
            end)
        end)

        task.spawn(function()
            while panel and panel.Parent do
                updateVisual(getState())
                task.wait(0.25)
            end
        end)

        return btn, updateVisual
    end

    -- ── BUTTON LAYOUT (4 cols × 3 rows) ──
    -- Row 1: Auto Left | Auto Right | Auto L Play | Auto R Play
    makeMobileBtn(1, 1, "AUTO", "LEFT",   MB.accent,
        function() AutoLeftEnabled=not AutoLeftEnabled; Enabled.AutoLeftEnabled=AutoLeftEnabled; if VisualSetters.AutoLeftEnabled then VisualSetters.AutoLeftEnabled(AutoLeftEnabled) end; if AutoLeftEnabled then startAutoLeft() else stopAutoLeft() end end,
        function() return AutoLeftEnabled end)

    makeMobileBtn(2, 1, "AUTO", "RIGHT",  MB.accent,
        function() AutoRightEnabled=not AutoRightEnabled; Enabled.AutoRightEnabled=AutoRightEnabled; if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(AutoRightEnabled) end; if AutoRightEnabled then startAutoRight() else stopAutoRight() end end,
        function() return AutoRightEnabled end)

    makeMobileBtn(3, 1, "AUTO", "L PLAY", Color3.fromRGB(100, 180, 255),
        function() AutoLeftPlayEnabled=not AutoLeftPlayEnabled; Enabled.AutoLeftPlayEnabled=AutoLeftPlayEnabled; if VisualSetters.AutoLeftPlayEnabled then VisualSetters.AutoLeftPlayEnabled(AutoLeftPlayEnabled) end; if AutoLeftPlayEnabled then startAutoLeftPlay() else stopAutoLeftPlay() end end,
        function() return AutoLeftPlayEnabled end)

    makeMobileBtn(4, 1, "AUTO", "R PLAY", Color3.fromRGB(100, 180, 255),
        function() AutoRightPlayEnabled=not AutoRightPlayEnabled; Enabled.AutoRightPlayEnabled=AutoRightPlayEnabled; if VisualSetters.AutoRightPlayEnabled then VisualSetters.AutoRightPlayEnabled(AutoRightPlayEnabled) end; if AutoRightPlayEnabled then startAutoRightPlay() else stopAutoRightPlay() end end,
        function() return AutoRightPlayEnabled end)

    -- Row 2: Bat Aimbot | Med Counter | Float | Auto Carry | Ragdoll TP
    makeMobileBtn(1, 2, "BAT", "AIMBOT", MB.accent2,
        function() local ns=not Enabled.BatAimbot; Enabled.BatAimbot=ns; autoBatToggled=ns; if VisualSetters.BatAimbot then VisualSetters.BatAimbot(ns) end; if ns then startBatAimbot() else stopBatAimbot() end end,
        function() return Enabled.BatAimbot end)

    makeMobileBtn(2, 2, "MED", "COUNTER", Color3.fromRGB(255, 100, 200),
        function() local ns=not Enabled.CounterMedusa; Enabled.CounterMedusa=ns; if VisualSetters.CounterMedusa then VisualSetters.CounterMedusa(ns) end; if ns then startCounterMedusa() else stopCounterMedusa() end end,
        function() return Enabled.CounterMedusa end)

    makeMobileBtn(3, 2, "FLOAT", "TOGGLE", MB.success,
        function() floatEnabled=not floatEnabled; Enabled.FloatEnabled=floatEnabled; if VisualSetters.FloatEnabled then VisualSetters.FloatEnabled(floatEnabled) end; if floatEnabled then startFloat() else stopFloat() end end,
        function() return floatEnabled end)

    makeMobileBtn(4, 2, "AUTO", "CARRY", Color3.fromRGB(52, 211, 153),
        function() local ns=not Enabled.AutoCarryOnPickup; Enabled.AutoCarryOnPickup=ns; if VisualSetters.AutoCarryOnPickup then VisualSetters.AutoCarryOnPickup(ns) end; if ns then startAutoCarryMode() else stopAutoCarryMode() end end,
        function() return Enabled.AutoCarryOnPickup end)

    makeMobileBtn(5, 2, "RAGDOLL", "TP", Color3.fromRGB(248, 190, 80),
        function() local ns=not Enabled.RagdollTP; Enabled.RagdollTP=ns; if VisualSetters.RagdollTP then VisualSetters.RagdollTP(ns) end; if ns then startRagdollTP() else stopRagdollTP() end end,
        function() return Enabled.RagdollTP end)

    -- Row 3: Drop | TP Down | Hide UI | [lock mirror]
    makeMobileBtn(1, 3, "DROP", "BOTS", MB.danger,
        function() task.spawn(doDropBrainrots) end,
        function() return false end)

    makeMobileBtn(2, 3, "TP", "DOWN", Color3.fromRGB(200, 160, 255),
        function() task.spawn(doTPDown) end,
        function() return false end)

    makeMobileBtn(3, 3, "🌌", "GALAXY", Color3.fromRGB(140, 100, 255),
        function() local ns=not Enabled.Galaxy; Enabled.Galaxy=ns; if VisualSetters.Galaxy then VisualSetters.Galaxy(ns) end; if ns then startGalaxy() else stopGalaxy() end end,
        function() return Enabled.Galaxy end)

    makeMobileBtn(4, 3, "LOCK", "UI", MB.locked,
        function() setLock(not uiLocked) end,
        function() return uiLocked end)

    -- Expose globally
    _G.NebulaMobileContainer = panel

    print("[NEBULA MINI HUB] Mobile buttons loaded ✓")
end

-- ══════════════════════════════════════════
-- STANDALONE 🌌 TOGGLE BUTTON (floats freely, always on screen)
-- ══════════════════════════════════════════
do
    local stGui = Instance.new("ScreenGui")
    stGui.Name = "NebulaUIToggleBtn"
    stGui.ResetOnSpawn = false
    stGui.DisplayOrder = 30
    stGui.IgnoreGuiInset = true
    stGui.Parent = pgui

    local SIZE = 52

    local gBtn = Instance.new("TextButton")
    gBtn.Size = UDim2.new(0, SIZE, 0, SIZE)
    gBtn.Position = UDim2.new(0, 10, 0.5, -SIZE/2)
    gBtn.BackgroundColor3 = Color3.fromRGB(7, 7, 14)
    gBtn.BackgroundTransparency = 0.08
    gBtn.BorderSizePixel = 0
    gBtn.Text = "🌌"
    gBtn.TextSize = 28
    gBtn.Font = Enum.Font.GothamBlack
    gBtn.ZIndex = 30
    gBtn.Active = true
    gBtn.Draggable = true
    gBtn.Parent = stGui
    Instance.new("UICorner", gBtn).CornerRadius = UDim.new(0, 14)

    local gStroke = Instance.new("UIStroke")
    gStroke.Color = Color3.fromRGB(120, 100, 255)
    gStroke.Thickness = 1.5
    gStroke.Transparency = 0.4
    gStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    gStroke.Parent = gBtn

    local function updateBtn()
        if guiVisible then
            gBtn.BackgroundColor3 = Color3.fromRGB(7, 7, 14)
            gStroke.Transparency = 0.4
        else
            gBtn.BackgroundColor3 = Color3.fromRGB(30, 22, 72)
            gStroke.Transparency = 0
        end
    end

    gBtn.MouseButton1Click:Connect(function()
        guiVisible = not guiVisible
        main.Visible = guiVisible
        updateBtn()
    end)

    -- Keep visual in sync if toggled another way
    RunService.Heartbeat:Connect(function()
        if main.Visible ~= guiVisible then
            guiVisible = main.Visible
        end
        updateBtn()
    end)

    _G.NebulaUIToggleBtn = gBtn
end

end)()

print("[NEBULA MINI HUB] Loaded ✓ | Q=Speed | E=Bat | F=Float | Z/C/J/K=Auto | G=TPDown | H=Drop | M=Galaxy | L/RightAlt=Hide")
