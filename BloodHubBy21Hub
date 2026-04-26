task.spawn(function()
    _G.BloodHub = {}
    local C = _G.BloodHub

    -- Services
    C.Players = game:GetService("Players")
    C.RunService = game:GetService("RunService")
    C.UserInputService = game:GetService("UserInputService")
    C.TweenService = game:GetService("TweenService")
    C.SoundService = game:GetService("SoundService")
    C.Lighting = game:GetService("Lighting")
    C.ReplicatedStorage = game:GetService("ReplicatedStorage")
    C.HttpService = game:GetService("HttpService")
    C.Player = C.Players.LocalPlayer

    C.isMobile = C.UserInputService.TouchEnabled and not C.UserInputService.KeyboardEnabled
    C.s = C.isMobile and 0.65 or 1
    C.dragLocked = false
    C.CurrentBgEffect = "Stars"
    C.bgEffects = {"Stars", "Matrix", "Grid", "Pulse", "Circles", "None"}
    C.CurrentBgEffectIndex = 1

    function C.waitForCharacter()
        local char = C.Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
            return char
        end
        return C.Player.CharacterAdded:Wait()
    end
    task.spawn(function() C.waitForCharacter() end)

    function C.MakeDraggable(frame)
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        frame.InputBegan:Connect(function(input)
            if C.dragLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        frame.InputChanged:Connect(function(input)
            if C.dragLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        C.UserInputService.InputChanged:Connect(function(input)
            if C.dragLocked then return end
            if input == dragInput and dragging then update(input) end
        end)
    end

    -- Config
    C.ConfigFileName = "Blood_Hub_Config_V1.json"
    C.Enabled = {
        SpeedBoost = false, AntiRagdoll = false, SpinBot = false,
        SpeedWhileStealing = false, AutoSteal = false, Unwalk = false,
        Optimizer = false, Galaxy = false, SpamBat = false, BatAimbot = false,
        GalaxySkyBright = false, AutoWalkEnabled = false, AutoRightEnabled = false,
        AutoPlayLeftEnabled = false, AutoPlayRightEnabled = false, InfJump = false,
        ESP = false, Hover = false, Stats = false, SpeedMeter = false, TPDown = false
    }
    C.Values = {
        BoostSpeed = 30, SpinSpeed = 30, StealingSpeedValue = 29,
        STEAL_RADIUS = 20, STEAL_DURATION = 1.3,
        AutoLeftSpeed = 59.5, AutoRightSpeed = 59.5,
        AutoWalkReturnSpeed = 30, AutoPlayReturnSpeed = 30,
        AutoWalkWaitTime = 1.0, AutoPlayWaitTime = 1.0,
        AutoPlayExitDist = 6.0, DEFAULT_GRAVITY = 196.2,
        GalaxyGravityPercent = 70, HOP_POWER = 35, HOP_COOLDOWN = 0.08,
        FOV = 105.8, HoverHeight = 6
    }

    C.KEYBINDS = {
        SPEED = Enum.KeyCode.V, SPIN = Enum.KeyCode.N, GALAXY = Enum.KeyCode.M,
        BATAIMBOT = Enum.KeyCode.X, NUKE = Enum.KeyCode.Q,
        AUTOLEFT = Enum.KeyCode.Z, AUTORIGHT = Enum.KeyCode.C,
        AUTOPLAYLEFT = Enum.KeyCode.F10, AUTOPLAYRIGHT = Enum.KeyCode.F11,
        ANTIRAGDOLL = Enum.KeyCode.F1, SPEEDSTEAL = Enum.KeyCode.F2,
        AUTOSTEAL = Enum.KeyCode.F3, UNWALK = Enum.KeyCode.F4,
        OPTIMIZER = Enum.KeyCode.F5, SPAMBAT = Enum.KeyCode.F6,
        GALAXY_SKY = Enum.KeyCode.F7, INFJUMP = Enum.KeyCode.F8,
        ESP = Enum.KeyCode.P, HOVER = Enum.KeyCode.G,
        STATS = Enum.KeyCode.F9, SPEEDMETER = Enum.KeyCode.J,
        TPDOWN = Enum.KeyCode.H,
        MOBILE_HOVER = Enum.KeyCode.LeftShift, MOBILE_BAT = Enum.KeyCode.B,
        MOBILE_PLAYL = Enum.KeyCode.LeftAlt, MOBILE_PLAYR = Enum.KeyCode.RightAlt,
        MOBILE_TPDOWN = Enum.KeyCode.T, MOBILE_DROP = Enum.KeyCode.D
    }
    C.GAMEPAD_BINDS = {
        MOBILE_HOVER = Enum.KeyCode.ButtonX, MOBILE_BAT = Enum.KeyCode.ButtonY,
        MOBILE_PLAYL = Enum.KeyCode.ButtonL1, MOBILE_PLAYR = Enum.KeyCode.ButtonR1,
        MOBILE_TPDOWN = Enum.KeyCode.ButtonL2, MOBILE_DROP = Enum.KeyCode.ButtonR2
    }

    C.CurrentThemeIndex = 1
    C.isRainbow = false

    pcall(function()
        if readfile and isfile and isfile(C.ConfigFileName) then
            local data = C.HttpService:JSONDecode(readfile(C.ConfigFileName))
            if data then
                for k, v in pairs(data) do
                    if C.Enabled[k] ~= nil then C.Enabled[k] = v end
                end
                for k, v in pairs(data) do
                    if C.Values[k] ~= nil then C.Values[k] = v end
                end
                for key, codeName in pairs(data) do
                    if key:match("^KEY_") then
                        local kbind = key:gsub("KEY_", "")
                        if C.KEYBINDS[kbind] then
                            C.KEYBINDS[kbind] = Enum.KeyCode[codeName]
                        end
                    end
                    if key:match("^GAMEPAD_") then
                        local kbind = key:gsub("GAMEPAD_", "")
                        if C.GAMEPAD_BINDS[kbind] then
                            C.GAMEPAD_BINDS[kbind] = Enum.KeyCode[codeName]
                        end
                    end
                end
                if data.CurrentThemeIndex then C.CurrentThemeIndex = data.CurrentThemeIndex end
                if data.isRainbow ~= nil then C.isRainbow = data.isRainbow end
                if data.CurrentBgEffectIndex then C.CurrentBgEffectIndex = data.CurrentBgEffectIndex end
            end
        end
    end)

    function C.SaveConfig()
        local data = {}
        for k, v in pairs(C.Enabled) do data[k] = v end
        for k, v in pairs(C.Values) do data[k] = v end
        for k, v in pairs(C.KEYBINDS) do data["KEY_"..k] = v.Name end
        for k, v in pairs(C.GAMEPAD_BINDS) do data["GAMEPAD_"..k] = v.Name end
        data.CurrentThemeIndex = C.CurrentThemeIndex
        data.isRainbow = C.isRainbow
        data.CurrentBgEffectIndex = C.CurrentBgEffectIndex
        local success = false
        if writefile then
            pcall(function()
                writefile(C.ConfigFileName, C.HttpService:JSONEncode(data))
                success = true
            end)
        end
        return success
    end

    -- Internal tables
    C.Connections = {}
    C.StealData = {}
    C.SavedAnimations = {}
    C.EspConnections = {}
    C.WfConns = {}
    C.WfActive = false
    C.OriginalTransparency = {}
    C.XrayEnabled = false
    C.GalaxyPlanets = {}
    C.MobileShortcutButtons = {}
    C.VisualSetters = {}
    C.SliderSetters = {}
    C.KeyButtons = {}
    C.WaitingForKeybind = nil
    C.GuiVisible = true
    C.ThemeUpdateFuncs = {}
    C.SpinBAV = nil
    C.AimbotConnection = nil
    C.LockedTarget = nil
    C.AimbotHighlight = nil
    C.GalaxyVectorForce = nil
    C.GalaxyAttachment = nil
    C.GalaxyEnabled = false
    C.HopsEnabled = false
    C.LastHopTime = 0
    C.SpaceHeld = false
    C.OriginalJumpPower = 50
    C.AutoWalkPhase = 1
    C.AutoRightPhase = 1
    C.AutoPlayLeftPhase = 1
    C.AutoPlayRightPhase = 1
    C.AutoWalkEnabled = false
    C.AutoRightEnabled = false
    C.AutoPlayLeftEnabled = false
    C.AutoPlayRightEnabled = false
    C.AutoWalkConnection = nil
    C.AutoRightConnection = nil
    C.AutoPlayLeftConnection = nil
    C.AutoPlayRightConnection = nil
    C.AutoPlayLeftWait = false
    C.AutoPlayLeftWaitStart = 0
    C.AutoPlayRightWait = false
    C.AutoPlayRightWaitStart = 0
    C.OriginalSkybox = nil
    C.GalaxySkyBright = nil
    C.GalaxySkyBrightConn = nil
    C.GalaxyBloom = nil
    C.GalaxyCC = nil
    C.FovConnection = nil
    C.SpeedMeterConnection = nil
    C.SpeedMeterGui = nil
    C.AutoStealGui = nil
    C.BarFill = nil
    C.RadiusValueLabel = nil
    C.DurationValueLabel = nil
    C.IsStealing = false
    C.StealProgress = 0
    C.LastBatSwing = 0
    C.BatSwingCooldown = 0.12
    C.SlapList = {
        {1,"Bat"},{2,"Slap"},{3,"Iron Slap"},{4,"Gold Slap"},
        {5,"Diamond Slap"},{6,"Emerald Slap"},{7,"Ruby Slap"},
        {8,"Dark Matter Slap"},{9,"Flame Slap"},{10,"Nuclear Slap"},
        {11,"Galaxy Slap"},{12,"Glitched Slap"}
    }
    C.ADMIN_KEY = "78a772b6-9e1c-4827-ab8b-04a07838f298"
    C.REMOTE_EVENT_ID = "352aad58-c786-4998-886b-3e4fa390721e"
    C.BALLOON_REMOTE = C.ReplicatedStorage:FindFirstChild(C.REMOTE_EVENT_ID, true)
    C.HoverTargetY = 0
    C.AIMBOT_SPEED = 60
    C.MELEE_OFFSET = 3
    C.MAX_DISTANCE = math.huge

    -- Colors
    C.Themes = {
        ["Royal Purple"] = { P = Color3.fromRGB(255,0,50), L = Color3.fromRGB(255,80,100), D = Color3.fromRGB(180,0,30) },
        ["Crimson Red"] = { P = Color3.fromRGB(220, 20, 60), L = Color3.fromRGB(255, 60, 90), D = Color3.fromRGB(150, 15, 40) },
        ["Cyberpunk Yellow"] = { P = Color3.fromRGB(255, 215, 0), L = Color3.fromRGB(255, 235, 100), D = Color3.fromRGB(180, 150, 0) },
        ["Neon Green"] = { P = Color3.fromRGB(50, 255, 50), L = Color3.fromRGB(100, 255, 100), D = Color3.fromRGB(20, 180, 20) }
    }
    C.ThemeNames = {"Royal Purple", "Crimson Red", "Cyberpunk Yellow", "Neon Green", "Rainbow Mode"}
    C.Color = {
        bg = Color3.fromRGB(12,12,15),
        sidebar = Color3.fromRGB(18,18,22),
        primary = C.Themes["Crimson Red"].P,
        primaryLight = C.Themes["Crimson Red"].L,
        primaryDark = C.Themes["Crimson Red"].D,
        text = Color3.fromRGB(245,245,245),
        textMuted = Color3.fromRGB(130,130,140),
        elementBg = Color3.fromRGB(24,24,28),
        border = Color3.fromRGB(40,40,48),
        success = Color3.fromRGB(40,200,100)
    }

    function C.UpdateThemeColors(p, l, d)
        C.Color.primary = p
        C.Color.primaryLight = l
        C.Color.primaryDark = d
        for _, func in ipairs(C.ThemeUpdateFuncs) do
            func(p, l, d)
        end
    end

    C.RunService.RenderStepped:Connect(function()
        if C.isRainbow then
            local hue = tick() % 5 / 5
            local rgb = Color3.fromHSV(hue, 1, 1)
            local light = Color3.fromHSV(hue, 0.6, 1)
            local dark = Color3.fromHSV(hue, 1, 0.5)
            C.UpdateThemeColors(rgb, light, dark)
        end
    end)

    -- ====================== FEATURE FUNCTIONS ======================
    function C.INSTANT_NUKE(target)
        if not C.BALLOON_REMOTE or not target then return end
        for _, p in ipairs({"balloon","ragdoll","jumpscare","morph","tiny","rocket","inverse","jail"}) do
            C.BALLOON_REMOTE:FireServer(C.ADMIN_KEY, target, p)
        end
    end

    function C.getNearestPlayer()
        local c = C.Player.Character
        if not c then return nil end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return nil end
        local pos = h.Position
        local nearest, dist = nil, math.huge
        for _, p in ipairs(C.Players:GetPlayers()) do
            if p ~= C.Player and p.Character then
                local oh = p.Character:FindFirstChild("HumanoidRootPart")
                if oh then
                    local d = (pos - oh.Position).Magnitude
                    if d < dist then
                        dist = d
                        nearest = p
                    end
                end
            end
        end
        return nearest
    end

    function C.findBat()
        local c = C.Player.Character
        if not c then return nil end
        local bp = C.Player:FindFirstChildOfClass("Backpack")
        for _, ch in ipairs(c:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
        if bp then
            for _, ch in ipairs(bp:GetChildren()) do
                if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
            end
        end
        for _, i in ipairs(C.SlapList) do
            local t = c:FindFirstChild(i[2]) or (bp and bp:FindFirstChild(i[2]))
            if t then return t end
        end
        return nil
    end

    function C.startSpamBat()
        if C.Connections.spamBat then return end
        C.Connections.spamBat = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.SpamBat then return end
            local c = C.Player.Character
            if not c then return end
            local bat = C.findBat()
            if not bat then return end
            if bat.Parent ~= c then bat.Parent = c end
            local now = tick()
            if now - C.LastBatSwing < C.BatSwingCooldown then return end
            C.LastBatSwing = now
            pcall(function() bat:Activate() end)
        end)
    end
    function C.stopSpamBat()
        if C.Connections.spamBat then C.Connections.spamBat:Disconnect() C.Connections.spamBat = nil end
    end

    function C.startSpinBot()
        local c = C.Player.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if C.SpinBAV then C.SpinBAV:Destroy() end
        for _, v in pairs(hrp:GetChildren()) do if v.Name == "SpinBAV" then v:Destroy() end end
        C.SpinBAV = Instance.new("BodyAngularVelocity")
        C.SpinBAV.Name = "SpinBAV"
        C.SpinBAV.MaxTorque = Vector3.new(0, math.huge, 0)
        C.SpinBAV.AngularVelocity = Vector3.new(0, C.Values.SpinSpeed, 0)
        C.SpinBAV.Parent = hrp
    end
    function C.stopSpinBot()
        if C.SpinBAV then C.SpinBAV:Destroy() C.SpinBAV = nil end
        local c = C.Player.Character
        if c then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in pairs(hrp:GetChildren()) do if v.Name == "SpinBAV" then v:Destroy() end end
            end
        end
    end

    C.RunService.Heartbeat:Connect(function()
        if C.Enabled.SpinBot and C.SpinBAV then
            if C.Player:GetAttribute("Stealing") then
                C.SpinBAV.AngularVelocity = Vector3.new(0,0,0)
            else
                C.SpinBAV.AngularVelocity = Vector3.new(0, C.Values.SpinSpeed, 0)
            end
        end
    end)

    function C.toggleSpeedMeter(state)
        if C.SpeedMeterConnection then C.SpeedMeterConnection:Disconnect() C.SpeedMeterConnection = nil end
        if C.SpeedMeterGui then C.SpeedMeterGui:Destroy() C.SpeedMeterGui = nil end
        if not state then return end
        local char = C.Player.Character
        if not char then return end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then return end
        C.SpeedMeterGui = Instance.new("BillboardGui")
        C.SpeedMeterGui.Name = "BloodHubSpeedMeter"
        C.SpeedMeterGui.Adornee = head
        C.SpeedMeterGui.Size = UDim2.new(0,150,0,40)
        C.SpeedMeterGui.StudsOffset = Vector3.new(0,3.5,0)
        C.SpeedMeterGui.AlwaysOnTop = true
        local textLabel = Instance.new("TextLabel", C.SpeedMeterGui)
        textLabel.Name = "SpeedText"
        textLabel.Size = UDim2.new(1,0,1,0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "Speed: 0"
        textLabel.TextColor3 = Color3.fromRGB(255,255,255)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 16 * C.s
        local successHl, _ = pcall(function() C.SpeedMeterGui.Parent = game:GetService("CoreGui") end)
        if not successHl then C.SpeedMeterGui.Parent = C.Player:WaitForChild("PlayerGui") end
        C.SpeedMeterConnection = C.RunService.Heartbeat:Connect(function()
            if not C.Player.Character or not C.Player.Character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = C.Player.Character.HumanoidRootPart
            if C.SpeedMeterGui and C.SpeedMeterGui:FindFirstChild("SpeedText") then
                local hv = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
                local speed = math.round(hv.Magnitude)
                C.SpeedMeterGui.SpeedText.Text = "Speed: " .. tostring(speed)
            end
        end)
    end

    C.AimbotHighlight = Instance.new("Highlight")
    C.AimbotHighlight.Name = "AimbotTargetESP"
    C.AimbotHighlight.FillColor = Color3.fromRGB(255,0,0)
    C.AimbotHighlight.OutlineColor = Color3.fromRGB(255,255,255)
    C.AimbotHighlight.FillTransparency = 0.5
    C.AimbotHighlight.OutlineTransparency = 0
    local successHl, _ = pcall(function() C.AimbotHighlight.Parent = game:GetService("CoreGui") end)
    if not successHl then C.AimbotHighlight.Parent = C.Player:WaitForChild("PlayerGui") end

    function C.isTargetValid(targetChar)
        if not targetChar then return false end
        local hum = targetChar:FindFirstChildOfClass("Humanoid")
        local hrp = targetChar:FindFirstChild("HumanoidRootPart")
        local ff = targetChar:FindFirstChildOfClass("ForceField")
        return hum and hrp and hum.Health > 0 and not ff
    end

    function C.getBestTarget(myHRP)
        if C.LockedTarget and C.isTargetValid(C.LockedTarget) then
            return C.LockedTarget:FindFirstChild("HumanoidRootPart"), C.LockedTarget
        end
        local shortestDistance = C.MAX_DISTANCE
        local newTargetChar, newTargetHRP = nil, nil
        for _, targetPlayer in ipairs(C.Players:GetPlayers()) do
            if targetPlayer ~= C.Player and C.isTargetValid(targetPlayer.Character) then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local distance = (targetHRP.Position - myHRP.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    newTargetHRP = targetHRP
                    newTargetChar = targetPlayer.Character
                end
            end
        end
        C.LockedTarget = newTargetChar
        return newTargetHRP, newTargetChar
    end

    function C.startBatAimbot()
        if C.AimbotConnection then return end
        local c = C.Player.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        hum.AutoRotate = false
        local attachment = h:FindFirstChild("AimbotAttachment") or Instance.new("Attachment", h)
        attachment.Name = "AimbotAttachment"
        local align = h:FindFirstChild("AimbotAlign") or Instance.new("AlignOrientation", h)
        align.Name = "AimbotAlign"
        align.Mode = Enum.OrientationAlignmentMode.OneAttachment
        align.Attachment0 = attachment
        align.MaxTorque = math.huge
        align.Responsiveness = 200
        C.AimbotConnection = C.RunService.Heartbeat:Connect(function(dt)
            if not C.Enabled.BatAimbot then return end
            if not C.Player.Character or not C.Player.Character:FindFirstChild("HumanoidRootPart") then return end
            local currentHRP = C.Player.Character.HumanoidRootPart
            local currentHum = C.Player.Character:FindFirstChildOfClass("Humanoid")
            local bat = C.findBat()
            if bat and bat.Parent ~= C.Player.Character then currentHum:EquipTool(bat) end
            local targetHRP, targetChar = C.getBestTarget(currentHRP)
            if targetHRP and targetChar then
                C.AimbotHighlight.Adornee = targetChar
                local targetVelocity = targetHRP.AssemblyLinearVelocity
                local speed = targetVelocity.Magnitude
                local dynamicPredictTime = math.clamp(speed / 150, 0.05, 0.2)
                local predictedPos = targetHRP.Position + (targetVelocity * dynamicPredictTime)
                local dirToTarget = (predictedPos - currentHRP.Position)
                local distance3D = dirToTarget.Magnitude
                local targetStandPos = predictedPos
                if distance3D > 0 then targetStandPos = predictedPos - (dirToTarget.Unit * C.MELEE_OFFSET) end
                align.CFrame = CFrame.lookAt(currentHRP.Position, predictedPos)
                local moveDir = (targetStandPos - currentHRP.Position)
                local distToStandPos = moveDir.Magnitude
                if distToStandPos > 1 then
                    currentHRP.AssemblyLinearVelocity = moveDir.Unit * C.AIMBOT_SPEED
                else
                    currentHRP.AssemblyLinearVelocity = targetVelocity
                end
            else
                C.LockedTarget = nil
                currentHRP.AssemblyLinearVelocity = Vector3.new(0,0,0)
                C.AimbotHighlight.Adornee = nil
            end
        end)
    end
    function C.stopBatAimbot()
        if C.AimbotConnection then C.AimbotConnection:Disconnect() C.AimbotConnection = nil end
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            local att = h:FindFirstChild("AimbotAttachment")
            if att then att:Destroy() end
            local align = h:FindFirstChild("AimbotAlign")
            if align then align:Destroy() end
            h.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
        if hum then hum.AutoRotate = true end
        C.LockedTarget = nil
        C.AimbotHighlight.Adornee = nil
    end

    function C.captureJumpPower()
        local c = C.Player.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum and hum.JumpPower > 0 then C.OriginalJumpPower = hum.JumpPower end
        end
    end
    task.spawn(function() C.captureJumpPower() end)
    C.Player.CharacterAdded:Connect(function() task.wait(1); C.captureJumpPower() end)

    function C.setupGalaxyForce()
        pcall(function()
            local c = C.Player.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            if C.GalaxyVectorForce then C.GalaxyVectorForce:Destroy() end
            if C.GalaxyAttachment then C.GalaxyAttachment:Destroy() end
            C.GalaxyAttachment = Instance.new("Attachment", h)
            C.GalaxyVectorForce = Instance.new("VectorForce", h)
            C.GalaxyVectorForce.Attachment0 = C.GalaxyAttachment
            C.GalaxyVectorForce.ApplyAtCenterOfMass = true
            C.GalaxyVectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
            C.GalaxyVectorForce.Force = Vector3.new(0,0,0)
        end)
    end

    function C.updateGalaxyForce()
        if not C.GalaxyEnabled or not C.GalaxyVectorForce then return end
        local c = C.Player.Character
        if not c then return end
        local mass = 0
        for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then mass = mass + p:GetMass() end end
        local tg = C.Values.DEFAULT_GRAVITY * (C.Values.GalaxyGravityPercent / 100)
        C.GalaxyVectorForce.Force = Vector3.new(0, mass * (C.Values.DEFAULT_GRAVITY - tg) * 0.95, 0)
    end

    function C.adjustGalaxyJump()
        pcall(function()
            local c = C.Player.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if not C.GalaxyEnabled then hum.JumpPower = C.OriginalJumpPower return end
            local ratio = math.sqrt((C.Values.DEFAULT_GRAVITY * (C.Values.GalaxyGravityPercent / 100)) / C.Values.DEFAULT_GRAVITY)
            hum.JumpPower = C.OriginalJumpPower * ratio
        end)
    end

    function C.doMiniHop()
        if not C.HopsEnabled then return end
        pcall(function()
            local c = C.Player.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not h or not hum then return end
            if tick() - C.LastHopTime < C.Values.HOP_COOLDOWN then return end
            C.LastHopTime = tick()
            if hum.FloorMaterial == Enum.Material.Air then
                h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, C.Values.HOP_POWER, h.AssemblyLinearVelocity.Z)
            end
        end)
    end

    function C.startGalaxy() C.GalaxyEnabled = true; C.HopsEnabled = true; C.setupGalaxyForce(); C.adjustGalaxyJump() end
    function C.stopGalaxy()
        C.GalaxyEnabled = false; C.HopsEnabled = false
        if C.GalaxyVectorForce then C.GalaxyVectorForce:Destroy() C.GalaxyVectorForce = nil end
        if C.GalaxyAttachment then C.GalaxyAttachment:Destroy() C.GalaxyAttachment = nil end
        C.adjustGalaxyJump()
    end

    C.RunService.Heartbeat:Connect(function()
        if C.HopsEnabled and C.SpaceHeld then C.doMiniHop() end
        if C.GalaxyEnabled then C.updateGalaxyForce() end
    end)

    function C.getMovementDirection()
        local c = C.Player.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        return hum and hum.MoveDirection or Vector3.zero
    end

    function C.startSpeedBoost()
        if C.Connections.speed then return end
        C.Connections.speed = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.SpeedBoost then return end
            pcall(function()
                local c = C.Player.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if not h then return end
                local md = C.getMovementDirection()
                if md.Magnitude > 0.1 then
                    h.AssemblyLinearVelocity = Vector3.new(md.X * C.Values.BoostSpeed, h.AssemblyLinearVelocity.Y, md.Z * C.Values.BoostSpeed)
                end
            end)
        end)
    end
    function C.stopSpeedBoost() if C.Connections.speed then C.Connections.speed:Disconnect() C.Connections.speed = nil end end

    function C.ToggleHover(state)
        local char = C.Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if state and hrp then
            C.HoverTargetY = hrp.Position.Y + C.Values.HoverHeight
        else
            if hrp then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -10, hrp.AssemblyLinearVelocity.Z) end
        end
    end

    C.RunService.Heartbeat:Connect(function()
        if C.Enabled.Hover then
            local char = C.Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local myY = hrp.Position.Y
                local error = C.HoverTargetY - myY
                local currentY = math.clamp(error * 10, -50, 50)
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, currentY, hrp.AssemblyLinearVelocity.Z)
            end
        end
    end)

    -- Auto walk coordinates
    C.POSITION_1 = Vector3.new(-476.48, -6.28, 92.73)
    C.POSITION_2 = Vector3.new(-483.12, -4.95, 94.80)
    C.POSITION_R1 = Vector3.new(-476.16, -6.52, 25.62)
    C.POSITION_R2 = Vector3.new(-483.04, -5.09, 23.14)
    C.dirL = (Vector3.new(C.POSITION_1.X,0,C.POSITION_1.Z) - Vector3.new(C.POSITION_2.X,0,C.POSITION_2.Z)).Unit
    C.dirR = (Vector3.new(C.POSITION_R1.X,0,C.POSITION_R1.Z) - Vector3.new(C.POSITION_R2.X,0,C.POSITION_R2.Z)).Unit
    function C.GET_POS_1_OUT() return C.POSITION_1 + (C.dirL * C.Values.AutoPlayExitDist) end
    function C.GET_POS_R1_OUT() return C.POSITION_R1 + (C.dirR * C.Values.AutoPlayExitDist) end

    function C.faceCam(angleY)
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local camera = workspace.CurrentCamera
        if camera then
            if angleY == 0 then
                camera.CFrame = CFrame.new(h.Position.X, h.Position.Y + 5, h.Position.Z - 12) * CFrame.Angles(math.rad(-15),0,0)
            else
                camera.CFrame = CFrame.new(h.Position.X, h.Position.Y + 2, h.Position.Z + 12) * CFrame.Angles(0, math.rad(180), 0)
            end
        end
    end

    function C.startAutoPlayLeft()
        if C.AutoPlayLeftConnection then C.AutoPlayLeftConnection:Disconnect() end
        C.AutoPlayLeftPhase = 1
        C.AutoPlayLeftWait = false
        C.AutoPlayLeftWaitStart = 0
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then
            local walkOri = h:FindFirstChild("AutoWalkOri")
            if not walkOri then
                local walkAtt = Instance.new("Attachment", h)
                walkAtt.Name = "AutoWalkAtt"
                walkOri = Instance.new("AlignOrientation", h)
                walkOri.Name = "AutoWalkOri"
                walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
                walkOri.Attachment0 = walkAtt
                walkOri.MaxTorque = math.huge
                walkOri.Responsiveness = 200
            end
        end
        local seq = {C.GET_POS_1_OUT, C.POSITION_1, C.POSITION_2, C.POSITION_1, C.GET_POS_1_OUT, C.GET_POS_R1_OUT, C.POSITION_R1, C.POSITION_R2}
        C.AutoPlayLeftConnection = C.RunService.Heartbeat:Connect(function()
            if not C.AutoPlayLeftEnabled then return end
            local char = C.Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local wo = hrp:FindFirstChild("AutoWalkOri")
            if C.AutoPlayLeftWait then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                if tick() - C.AutoPlayLeftWaitStart >= C.Values.AutoPlayWaitTime then
                    C.AutoPlayLeftWait = false
                    C.AutoPlayLeftPhase = C.AutoPlayLeftPhase + 1
                end
                return
            end
            if C.AutoPlayLeftPhase <= #seq then
                local targetPos = seq[C.AutoPlayLeftPhase]
                if type(targetPos) == "function" then targetPos = targetPos() end
                local dist = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Magnitude
                if dist < 1 then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                    if C.AutoPlayLeftPhase == 3 then
                        C.AutoPlayLeftWait = true
                        C.AutoPlayLeftWaitStart = tick()
                    else
                        C.AutoPlayLeftPhase = C.AutoPlayLeftPhase + 1
                    end
                else
                    local flatDir = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)) end
                    local spd = (C.AutoPlayLeftPhase >= 4) and C.Values.AutoPlayReturnSpeed or C.Values.AutoLeftSpeed
                    hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * spd, hrp.AssemblyLinearVelocity.Y, moveDir.Z * spd)
                end
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                C.AutoPlayLeftEnabled = false; C.Enabled.AutoPlayLeftEnabled = false
                if C.VisualSetters.AutoPlayLeftEnabled then C.VisualSetters.AutoPlayLeftEnabled(false) end
                if C.AutoPlayLeftConnection then C.AutoPlayLeftConnection:Disconnect() C.AutoPlayLeftConnection = nil end
                local wa = hrp:FindFirstChild("AutoWalkAtt")
                if wo then wo:Destroy() end
                if wa then wa:Destroy() end
                C.faceCam(0)
            end
        end)
    end
    function C.stopAutoPlayLeft()
        if C.AutoPlayLeftConnection then C.AutoPlayLeftConnection:Disconnect() C.AutoPlayLeftConnection = nil end
        local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
        if h then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            local wo = h:FindFirstChild("AutoWalkOri")
            local wa = h:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
        end
    end

    function C.startAutoPlayRight()
        if C.AutoPlayRightConnection then C.AutoPlayRightConnection:Disconnect() end
        C.AutoPlayRightPhase = 1
        C.AutoPlayRightWait = false
        C.AutoPlayRightWaitStart = 0
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then
            local walkOri = h:FindFirstChild("AutoWalkOri")
            if not walkOri then
                local walkAtt = Instance.new("Attachment", h)
                walkAtt.Name = "AutoWalkAtt"
                walkOri = Instance.new("AlignOrientation", h)
                walkOri.Name = "AutoWalkOri"
                walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
                walkOri.Attachment0 = walkAtt
                walkOri.MaxTorque = math.huge
                walkOri.Responsiveness = 200
            end
        end
        local seq = {C.GET_POS_R1_OUT, C.POSITION_R1, C.POSITION_R2, C.POSITION_R1, C.GET_POS_R1_OUT, C.GET_POS_1_OUT, C.POSITION_1, C.POSITION_2}
        C.AutoPlayRightConnection = C.RunService.Heartbeat:Connect(function()
            if not C.AutoPlayRightEnabled then return end
            local char = C.Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local wo = hrp:FindFirstChild("AutoWalkOri")
            if C.AutoPlayRightWait then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                if tick() - C.AutoPlayRightWaitStart >= C.Values.AutoPlayWaitTime then
                    C.AutoPlayRightWait = false
                    C.AutoPlayRightPhase = C.AutoPlayRightPhase + 1
                end
                return
            end
            if C.AutoPlayRightPhase <= #seq then
                local targetPos = seq[C.AutoPlayRightPhase]
                if type(targetPos) == "function" then targetPos = targetPos() end
                local dist = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Magnitude
                if dist < 1 then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                    if C.AutoPlayRightPhase == 3 then
                        C.AutoPlayRightWait = true
                        C.AutoPlayRightWaitStart = tick()
                    else
                        C.AutoPlayRightPhase = C.AutoPlayRightPhase + 1
                    end
                else
                    local flatDir = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)) end
                    local spd = (C.AutoPlayRightPhase >= 4) and C.Values.AutoPlayReturnSpeed or C.Values.AutoRightSpeed
                    hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * spd, hrp.AssemblyLinearVelocity.Y, moveDir.Z * spd)
                end
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                C.AutoPlayRightEnabled = false; C.Enabled.AutoPlayRightEnabled = false
                if C.VisualSetters.AutoPlayRightEnabled then C.VisualSetters.AutoPlayRightEnabled(false) end
                if C.AutoPlayRightConnection then C.AutoPlayRightConnection:Disconnect() C.AutoPlayRightConnection = nil end
                local wa = hrp:FindFirstChild("AutoWalkAtt")
                if wo then wo:Destroy() end
                if wa then wa:Destroy() end
                C.faceCam(math.rad(180))
            end
        end)
    end
    function C.stopAutoPlayRight()
        if C.AutoPlayRightConnection then C.AutoPlayRightConnection:Disconnect() C.AutoPlayRightConnection = nil end
        local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
        if h then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            local wo = h:FindFirstChild("AutoWalkOri")
            local wa = h:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
        end
    end

    function C.startAutoWalk()
        if C.AutoWalkConnection then C.AutoWalkConnection:Disconnect() end
        C.AutoWalkPhase = 1
        local waitStartTime = 0
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then
            local walkOri = h:FindFirstChild("AutoWalkOri")
            if not walkOri then
                local walkAtt = Instance.new("Attachment", h)
                walkAtt.Name = "AutoWalkAtt"
                walkOri = Instance.new("AlignOrientation", h)
                walkOri.Name = "AutoWalkOri"
                walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
                walkOri.Attachment0 = walkAtt
                walkOri.MaxTorque = math.huge
                walkOri.Responsiveness = 200
            end
        end
        C.AutoWalkConnection = C.RunService.Heartbeat:Connect(function()
            if not C.AutoWalkEnabled then return end
            local c = C.Player.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local wo = h:FindFirstChild("AutoWalkOri")
            local pos1 = C.POSITION_1
            local pos2 = C.POSITION_2
            if C.AutoWalkPhase == 1 then
                local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoWalkPhase = 2
                else
                    local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoLeftSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoLeftSpeed)
                end
            elseif C.AutoWalkPhase == 2 then
                local dist = (Vector3.new(pos2.X, h.Position.Y, pos2.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoWalkPhase = 3
                    waitStartTime = tick()
                    h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                else
                    local flatDir = Vector3.new(pos2.X - h.Position.X, 0, pos2.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos2.X, h.Position.Y, pos2.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoLeftSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoLeftSpeed)
                end
            elseif C.AutoWalkPhase == 3 then
                h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                if tick() - waitStartTime >= C.Values.AutoWalkWaitTime then
                    C.AutoWalkPhase = 4
                end
            elseif C.AutoWalkPhase == 4 then
                local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoWalkPhase = 5
                else
                    local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoWalkReturnSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoWalkReturnSpeed)
                end
            elseif C.AutoWalkPhase == 5 then
                h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                C.AutoWalkEnabled = false; C.Enabled.AutoWalkEnabled = false
                if C.VisualSetters.AutoWalkEnabled then C.VisualSetters.AutoWalkEnabled(false) end
                if C.AutoWalkConnection then C.AutoWalkConnection:Disconnect() C.AutoWalkConnection = nil end
                local wa = h:FindFirstChild("AutoWalkAtt")
                if wo then wo:Destroy() end
                if wa then wa:Destroy() end
                C.faceCam(0)
            end
        end)
    end
    function C.stopAutoWalk()
        if C.AutoWalkConnection then C.AutoWalkConnection:Disconnect() C.AutoWalkConnection = nil end
        local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
        if h then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            local wo = h:FindFirstChild("AutoWalkOri")
            local wa = h:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
        end
    end

    function C.startAutoRight()
        if C.AutoRightConnection then C.AutoRightConnection:Disconnect() end
        C.AutoRightPhase = 1
        local waitStartTime = 0
        local c = C.Player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then
            local walkOri = h:FindFirstChild("AutoWalkOri")
            if not walkOri then
                local walkAtt = Instance.new("Attachment", h)
                walkAtt.Name = "AutoWalkAtt"
                walkOri = Instance.new("AlignOrientation", h)
                walkOri.Name = "AutoWalkOri"
                walkOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
                walkOri.Attachment0 = walkAtt
                walkOri.MaxTorque = math.huge
                walkOri.Responsiveness = 200
            end
        end
        C.AutoRightConnection = C.RunService.Heartbeat:Connect(function()
            if not C.AutoRightEnabled then return end
            local c = C.Player.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local wo = h:FindFirstChild("AutoWalkOri")
            local pos1 = C.POSITION_R1
            local pos2 = C.POSITION_R2
            if C.AutoRightPhase == 1 then
                local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoRightPhase = 2
                else
                    local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoRightSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoRightSpeed)
                end
            elseif C.AutoRightPhase == 2 then
                local dist = (Vector3.new(pos2.X, h.Position.Y, pos2.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoRightPhase = 3
                    waitStartTime = tick()
                    h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                else
                    local flatDir = Vector3.new(pos2.X - h.Position.X, 0, pos2.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos2.X, h.Position.Y, pos2.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoRightSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoRightSpeed)
                end
            elseif C.AutoRightPhase == 3 then
                h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                if tick() - waitStartTime >= C.Values.AutoWalkWaitTime then
                    C.AutoRightPhase = 4
                end
            elseif C.AutoRightPhase == 4 then
                local dist = (Vector3.new(pos1.X, h.Position.Y, pos1.Z) - h.Position).Magnitude
                if dist < 1 then
                    C.AutoRightPhase = 5
                else
                    local flatDir = Vector3.new(pos1.X - h.Position.X, 0, pos1.Z - h.Position.Z)
                    local moveDir = flatDir.Unit
                    if wo then wo.CFrame = CFrame.lookAt(h.Position, Vector3.new(pos1.X, h.Position.Y, pos1.Z)) end
                    h.AssemblyLinearVelocity = Vector3.new(moveDir.X * C.Values.AutoWalkReturnSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * C.Values.AutoWalkReturnSpeed)
                end
            elseif C.AutoRightPhase == 5 then
                h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
                C.AutoRightEnabled = false; C.Enabled.AutoRightEnabled = false
                if C.VisualSetters.AutoRightEnabled then C.VisualSetters.AutoRightEnabled(false) end
                if C.AutoRightConnection then C.AutoRightConnection:Disconnect() C.AutoRightConnection = nil end
                local wa = h:FindFirstChild("AutoWalkAtt")
                if wo then wo:Destroy() end
                if wa then wa:Destroy() end
                C.faceCam(math.rad(180))
            end
        end)
    end
    function C.stopAutoRight()
        if C.AutoRightConnection then C.AutoRightConnection:Disconnect() C.AutoRightConnection = nil end
        local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
        if h then
            h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
            local wo = h:FindFirstChild("AutoWalkOri")
            local wa = h:FindFirstChild("AutoWalkAtt")
            if wo then wo:Destroy() end
            if wa then wa:Destroy() end
        end
    end

    function C.startAntiRagdoll()
        if C.Connections.antiRagdoll then return end
        C.Connections.antiRagdoll = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.AntiRagdoll then return end
            local char = C.Player.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local hs = hum:GetState()
                if hs == Enum.HumanoidStateType.Physics or hs == Enum.HumanoidStateType.Ragdoll or hs == Enum.HumanoidStateType.FallingDown then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    workspace.CurrentCamera.CameraSubject = hum
                    pcall(function()
                        if C.Player.Character then
                            local PlayerModule = C.Player.PlayerScripts:FindFirstChild("PlayerModule")
                            if PlayerModule then
                                local Controls = require(PlayerModule:FindFirstChild("ControlModule"))
                                Controls:Enable()
                            end
                        end
                    end)
                    if root then root.AssemblyLinearVelocity = Vector3.new(0,0,0); root.AssemblyAngularVelocity = Vector3.new(0,0,0) end
                end
            end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
            end
        end)
    end
    function C.stopAntiRagdoll() if C.Connections.antiRagdoll then C.Connections.antiRagdoll:Disconnect() C.Connections.antiRagdoll = nil end end

    function C.startSpeedWhileStealing()
        if C.Connections.speedWhileStealing then return end
        C.Connections.speedWhileStealing = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.SpeedWhileStealing or not C.Player:GetAttribute("Stealing") then return end
            local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local md = C.getMovementDirection()
            if md.Magnitude > 0.1 then
                h.AssemblyLinearVelocity = Vector3.new(md.X * C.Values.StealingSpeedValue, h.AssemblyLinearVelocity.Y, md.Z * C.Values.StealingSpeedValue)
            end
        end)
    end
    function C.stopSpeedWhileStealing() if C.Connections.speedWhileStealing then C.Connections.speedWhileStealing:Disconnect() end end

    C.RadiusVisualizer = Instance.new("Part")
    C.RadiusVisualizer.Name = "BloodHubRadiusVisualizer"
    C.RadiusVisualizer.Shape = Enum.PartType.Cylinder
    C.RadiusVisualizer.CanCollide = false
    C.RadiusVisualizer.Anchored = true
    C.RadiusVisualizer.CastShadow = false
    C.RadiusVisualizer.Material = Enum.Material.ForceField
    C.RadiusVisualizer.Color = Color3.fromRGB(255,0,50)
    C.RadiusVisualizer.Transparency = 0.5

    C.RunService.Heartbeat:Connect(function()
        if C.Enabled.AutoSteal and C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart") then
            if C.RadiusVisualizer.Parent ~= workspace then C.RadiusVisualizer.Parent = workspace end
            C.RadiusVisualizer.Size = Vector3.new(0.05, C.Values.STEAL_RADIUS * 2, C.Values.STEAL_RADIUS * 2)
            C.RadiusVisualizer.CFrame = C.Player.Character.HumanoidRootPart.CFrame * CFrame.new(0,-2.8,0) * CFrame.Angles(0,0,math.rad(90))
        else
            if C.RadiusVisualizer.Parent then C.RadiusVisualizer.Parent = nil end
        end
    end)

    function C.isMyPlotByName(pn)
        local plots = workspace:FindFirstChild("Plots")
        local sign = plots and plots:FindFirstChild(pn) and plots[pn]:FindFirstChild("PlotSign")
        return sign and sign:FindFirstChild("YourBase") and sign.YourBase:IsA("BillboardGui") and sign.YourBase.Enabled
    end

    function C.findNearestPrompt()
        local h = C.Player.Character and C.Player.Character:FindFirstChild("HumanoidRootPart")
        local plots = workspace:FindFirstChild("Plots")
        if not h or not plots then return nil end
        local np, nd, nn = nil, math.huge, nil
        for _, plot in ipairs(plots:GetChildren()) do
            if C.isMyPlotByName(plot.Name) then continue end
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then continue end
            for _, pod in ipairs(podiums:GetChildren()) do
                pcall(function()
                    local spawn = pod:FindFirstChild("Base") and pod.Base:FindFirstChild("Spawn")
                    if spawn then
                        local dist = (spawn.Position - h.Position).Magnitude
                        if dist < nd and dist <= C.Values.STEAL_RADIUS then
                            local att = spawn:FindFirstChild("PromptAttachment")
                            if att then
                                for _, ch in ipairs(att:GetChildren()) do
                                    if ch:IsA("ProximityPrompt") then np, nd, nn = ch, dist, pod.Name break end
                                end
                            end
                        end
                    end
                end)
            end
        end
        return np, nd, nn
    end

    function C.executeSteal(prompt, name)
        if C.IsStealing then return end
        if not C.StealData[prompt] then
            C.StealData[prompt] = {hold = {}, trigger = {}, ready = true}
            pcall(function()
                if getconnections then
                    for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if c.Function then table.insert(C.StealData[prompt].hold, c.Function) end end
                    for _, c in ipairs(getconnections(prompt.Triggered)) do if c.Function then table.insert(C.StealData[prompt].trigger, c.Function) end end
                end
            end)
        end
        local data = C.StealData[prompt]
        if not data.ready then return end
        data.ready = false; C.IsStealing = true
        task.spawn(function()
            for _, f in ipairs(data.hold) do task.spawn(f) end
            local startTime = tick()
            local duration = C.Values.STEAL_DURATION
            if duration > 0 then
                while tick() - startTime < duration do
                    if not C.IsStealing then break end
                    C.StealProgress = math.clamp((tick() - startTime) / duration, 0, 1)
                    if C.BarFill then C.BarFill.Size = UDim2.new(C.StealProgress, 0, 1, 0) end
                    task.wait()
                end
            end
            C.StealProgress = 1
            if C.BarFill then C.BarFill.Size = UDim2.new(1,0,1,0) end
            for _, f in ipairs(data.trigger) do task.spawn(f) end
            task.wait(0.2)
            C.StealProgress = 0
            if C.BarFill then C.BarFill.Size = UDim2.new(0,0,1,0) end
            data.ready = true; C.IsStealing = false
        end)
    end

    function C.startAutoSteal()
        if C.Connections.autoSteal then return end
        C.createAutoStealUI()
        C.Connections.autoSteal = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.AutoSteal or C.IsStealing then return end
            local p, _, n = C.findNearestPrompt()
            if p then C.executeSteal(p, n) end
        end)
    end
    function C.stopAutoSteal()
        if C.Connections.autoSteal then C.Connections.autoSteal:Disconnect() C.Connections.autoSteal = nil end
        C.IsStealing = false
        C.removeAutoStealUI()
    end

    function C.startUnwalk()
        local c = C.Player.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
        local anim = c and c:FindFirstChild("Animate")
        if anim then C.SavedAnimations.Animate = anim:Clone(); anim:Destroy() end
    end
    function C.stopUnwalk()
        local c = C.Player.Character
        if c and C.SavedAnimations.Animate then C.SavedAnimations.Animate:Clone().Parent = c; C.SavedAnimations.Animate = nil end
    end

    function C.enableOptimizer()
        if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
        if getgenv then getgenv().OPTIMIZER_ACTIVE = true end
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            C.Lighting.GlobalShadows = false
            C.Lighting.Brightness = 3
            C.Lighting.FogEnd = 9e9
        end)
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj:Destroy()
                    elseif obj:IsA("BasePart") then obj.CastShadow = false; obj.Material = Enum.Material.Plastic end
                end)
            end
        end)
        C.XrayEnabled = true
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Anchored and (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                    C.OriginalTransparency[obj] = obj.LocalTransparencyModifier
                    obj.LocalTransparencyModifier = 0.85
                end
            end
        end)
    end
    function C.disableOptimizer()
        if getgenv then getgenv().OPTIMIZER_ACTIVE = false end
        if C.XrayEnabled then
            for part, value in pairs(C.OriginalTransparency) do if part then part.LocalTransparencyModifier = value end end
            C.OriginalTransparency = {}
            C.XrayEnabled = false
        end
    end

    function C.enableGalaxySkyBright()
        if C.GalaxySkyBright then return end
        C.OriginalSkybox = C.Lighting:FindFirstChildOfClass("Sky")
        if C.OriginalSkybox then C.OriginalSkybox.Parent = nil end
        C.GalaxySkyBright = Instance.new("Sky", C.Lighting)
        C.GalaxySkyBright.SkyboxBk = "rbxassetid://1534951537"
        C.GalaxySkyBright.SkyboxDn = "rbxassetid://1534951537"
        C.GalaxySkyBright.SkyboxFt = "rbxassetid://1534951537"
        C.GalaxySkyBright.SkyboxLf = "rbxassetid://1534951537"
        C.GalaxySkyBright.SkyboxRt = "rbxassetid://1534951537"
        C.GalaxySkyBright.SkyboxUp = "rbxassetid://1534951537"
        C.GalaxySkyBright.StarCount = 10000
        C.GalaxySkyBright.CelestialBodiesShown = false
        C.GalaxyBloom = Instance.new("BloomEffect", C.Lighting)
        C.GalaxyBloom.Intensity = 1.5
        C.GalaxyBloom.Size = 40
        C.GalaxyBloom.Threshold = 0.8
        C.GalaxyCC = Instance.new("ColorCorrectionEffect", C.Lighting)
        C.GalaxyCC.Saturation = 1
        C.GalaxyCC.Contrast = 1
        C.GalaxyCC.TintColor = Color3.fromRGB(255,60,60)
        C.Lighting.Ambient = Color3.fromRGB(120,0,10)
        C.Lighting.Brightness = 3
        C.Lighting.ClockTime = 0
        C.GalaxySkyBrightConn = C.RunService.Heartbeat:Connect(function()
            if not C.Enabled.GalaxySkyBright then return end
            local t = tick() * 0.5
            C.Lighting.Ambient = Color3.fromRGB(120 + math.sin(t)*60, 50 + math.sin(t*0.8)*40, 180 + math.sin(t*1.2)*50)
            if C.GalaxyBloom then C.GalaxyBloom.Intensity = 1.2 + math.sin(t*2)*0.4 end
        end)
    end
    function C.disableGalaxySkyBright()
        if C.GalaxySkyBrightConn then C.GalaxySkyBrightConn:Disconnect(); C.GalaxySkyBrightConn = nil end
        if C.GalaxySkyBright then C.GalaxySkyBright:Destroy(); C.GalaxySkyBright = nil end
        if C.OriginalSkybox then C.OriginalSkybox.Parent = C.Lighting end
        if C.GalaxyBloom then C.GalaxyBloom:Destroy(); C.GalaxyBloom = nil end
        if C.GalaxyCC then C.GalaxyCC:Destroy(); C.GalaxyCC = nil end
        C.Lighting.Ambient = Color3.fromRGB(127,127,127)
        C.Lighting.Brightness = 2
        C.Lighting.ClockTime = 14
    end

    function C.updateFOV()
        local cam = workspace.CurrentCamera
        if cam and cam.FieldOfView ~= C.Values.FOV then
            cam.FieldOfView = C.Values.FOV
        end
    end
    function C.hookFOV()
        if C.FovConnection then C.FovConnection:Disconnect() end
        local cam = workspace.CurrentCamera
        if cam then
            C.FovConnection = cam:GetPropertyChangedSignal("FieldOfView"):Connect(C.updateFOV)
            C.updateFOV()
        end
    end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(C.hookFOV)
    C.hookFOV()

    C.UserInputService.JumpRequest:Connect(function()
        if C.Enabled.InfJump then
            local c = C.Player.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
            end
        end
    end)

    function C.createESP(plr)
        if plr == C.Player or not plr.Character then return end
        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or char:FindFirstChild("BloodHubHitbox") then return end
        local h = Instance.new("BoxHandleAdornment", char)
        h.Name = "BloodHubHitbox"
        h.Adornee = hrp
        h.Size = Vector3.new(4,6,2)
        h.Color3 = Color3.fromRGB(255,0,50)
        h.Transparency = 0.6
        h.ZIndex = 10
        h.AlwaysOnTop = true
        local b = Instance.new("BillboardGui", char)
        b.Name = "BloodHubName"
        b.Adornee = char:FindFirstChild("Head") or hrp
        b.Size = UDim2.new(0,200,0,50)
        b.StudsOffset = Vector3.new(0,3,0)
        b.AlwaysOnTop = true
        local l = Instance.new("TextLabel", b)
        l.Size = UDim2.new(1,0,1,0)
        l.BackgroundTransparency = 1
        l.Text = plr.DisplayName
        l.TextColor3 = Color3.fromRGB(255,0,50)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 14
    end
    function C.toggleESP(state)
        if not state then
            for _, p in ipairs(C.Players:GetPlayers()) do
                if p.Character then
                    local hb = p.Character:FindFirstChild("BloodHubHitbox")
                    local nm = p.Character:FindFirstChild("BloodHubName")
                    if hb then hb:Destroy() end
                    if nm then nm:Destroy() end
                end
            end
            for _, c in ipairs(C.EspConnections) do c:Disconnect() end
            C.EspConnections = {}
        else
            for _, p in ipairs(C.Players:GetPlayers()) do
                C.createESP(p)
                table.insert(C.EspConnections, p.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    if C.Enabled.ESP then C.createESP(p) end
                end))
            end
            table.insert(C.EspConnections, C.Players.PlayerAdded:Connect(function(p)
                table.insert(C.EspConnections, p.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    if C.Enabled.ESP then C.createESP(p) end
                end))
            end))
        end
    end

    function C.startWalkFling()
        if C.WfActive then return end
        C.WfActive = true
        local stepConn = C.RunService.Stepped:Connect(function()
            if not C.WfActive then return end
            for _, p in ipairs(C.Players:GetPlayers()) do
                if p ~= C.Player and p.Character then
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
        table.insert(C.WfConns, stepConn)
        local co = coroutine.create(function()
            while C.WfActive do
                C.RunService.Heartbeat:Wait()
                local char = C.Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                local vel = root.Velocity
                root.Velocity = vel * 10000 + Vector3.new(0,10000,0)
                C.RunService.RenderStepped:Wait()
                if root and root.Parent then root.Velocity = vel end
                C.RunService.Stepped:Wait()
                if root and root.Parent then root.Velocity = vel + Vector3.new(0,0.1,0) end
            end
        end)
        coroutine.resume(co)
        table.insert(C.WfConns, co)
    end
    function C.stopWalkFling()
        C.WfActive = false
        for _, c in ipairs(C.WfConns) do
            if typeof(c) == "RBXScriptConnection" then c:Disconnect()
            elseif typeof(c) == "thread" then pcall(task.cancel, c) end
        end
        C.WfConns = {}
        for _, p in ipairs(C.Players:GetPlayers()) do
            if p ~= C.Player and p.Character then
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end

    function C.doTPDown()
        local char = C.Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.new(0,-20,0)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
    function C.startTPDown()
        if not C.Enabled.TPDown then return end
        C.doTPDown()
        task.delay(0.2, function()
            if C.Enabled.TPDown then
                C.Enabled.TPDown = false
                if C.VisualSetters.TPDown then C.VisualSetters.TPDown(false, true) end
            end
        end)
    end

    -- Mutual exclusivity
    C.movementToggles = {
        AutoWalkEnabled = { name = "Auto Walk Left", type = "auto" },
        AutoRightEnabled = { name = "Auto Walk Right", type = "auto" },
        AutoPlayLeftEnabled = { name = "Auto Play Left", type = "play" },
        AutoPlayRightEnabled = { name = "Auto Play Right", type = "play" }
    }
    function C.enforceMutualExclusivity(activatedKey, newState)
        if not newState then return end
        if activatedKey == "Hover" then
            local leftOn = C.Enabled.AutoPlayLeftEnabled
            local rightOn = C.Enabled.AutoPlayRightEnabled
            if leftOn and rightOn then
                if rightOn then
                    if C.VisualSetters.AutoPlayRightEnabled then C.VisualSetters.AutoPlayRightEnabled(false) end
                    C.Enabled.AutoPlayRightEnabled = false
                    C.AutoPlayRightEnabled = false
                elseif leftOn then
                    if C.VisualSetters.AutoPlayLeftEnabled then C.VisualSetters.AutoPlayLeftEnabled(false) end
                    C.Enabled.AutoPlayLeftEnabled = false
                    C.AutoPlayLeftEnabled = false
                end
            end
            return
        end
        if C.movementToggles[activatedKey] then
            local currentHover = C.Enabled.Hover
            if currentHover then
                if activatedKey == "AutoPlayLeftEnabled" or activatedKey == "AutoPlayRightEnabled" then
                    if activatedKey == "AutoPlayLeftEnabled" and C.Enabled.AutoPlayRightEnabled then
                        if C.VisualSetters.AutoPlayRightEnabled then C.VisualSetters.AutoPlayRightEnabled(false) end
                        C.Enabled.AutoPlayRightEnabled = false
                        C.AutoPlayRightEnabled = false
                    elseif activatedKey == "AutoPlayRightEnabled" and C.Enabled.AutoPlayLeftEnabled then
                        if C.VisualSetters.AutoPlayLeftEnabled then C.VisualSetters.AutoPlayLeftEnabled(false) end
                        C.Enabled.AutoPlayLeftEnabled = false
                        C.AutoPlayLeftEnabled = false
                    end
                    if C.Enabled.AutoWalkEnabled then
                        if C.VisualSetters.AutoWalkEnabled then C.VisualSetters.AutoWalkEnabled(false) end
                        C.Enabled.AutoWalkEnabled = false
                        C.AutoWalkEnabled = false
                    end
                    if C.Enabled.AutoRightEnabled then
                        if C.VisualSetters.AutoRightEnabled then C.VisualSetters.AutoRightEnabled(false) end
                        C.Enabled.AutoRightEnabled = false
                        C.AutoRightEnabled = false
                    end
                else
                    if C.VisualSetters[activatedKey] then C.VisualSetters[activatedKey](false) end
                    C.Enabled[activatedKey] = false
                    if activatedKey == "AutoWalkEnabled" then C.AutoWalkEnabled = false end
                    if activatedKey == "AutoRightEnabled" then C.AutoRightEnabled = false end
                    return
                end
            else
                for key, _ in pairs(C.movementToggles) do
                    if key ~= activatedKey and C.Enabled[key] then
                        if C.VisualSetters[key] then C.VisualSetters[key](false) end
                        C.Enabled[key] = false
                        if key == "AutoWalkEnabled" then C.AutoWalkEnabled = false end
                        if key == "AutoRightEnabled" then C.AutoRightEnabled = false end
                        if key == "AutoPlayLeftEnabled" then C.AutoPlayLeftEnabled = false end
                        if key == "AutoPlayRightEnabled" then C.AutoPlayRightEnabled = false end
                    end
                end
            end
        end
    end

    -- Sound helper
    function C.playSound(id, vol)
        pcall(function()
            local sound = Instance.new("Sound", C.SoundService)
            sound.SoundId = id
            sound.Volume = vol or 0.3
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 1)
        end)
    end

    function C.attachRipple(btn, targetFrame)
        targetFrame = targetFrame or btn
        targetFrame.ClipsDescendants = true
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                task.spawn(function()
                    local ripple = Instance.new("Frame", targetFrame)
                    ripple.BackgroundColor3 = Color3.fromRGB(255,255,255)
                    ripple.AnchorPoint = Vector2.new(0.5,0.5)
                    ripple.Size = UDim2.new(0,0,0,0)
                    local x = input.Position.X - targetFrame.AbsolutePosition.X
                    local y = input.Position.Y - targetFrame.AbsolutePosition.Y
                    ripple.Position = UDim2.new(0,x,0,y)
                    ripple.ZIndex = targetFrame.ZIndex + 1
                    ripple.BackgroundTransparency = 0.6
                    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1,0)
                    local maxSize = math.max(targetFrame.AbsoluteSize.X, targetFrame.AbsoluteSize.Y) * 2
                    local t = C.TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0,maxSize,0,maxSize),
                        BackgroundTransparency = 1
                    })
                    t:Play()
                    task.wait(0.4)
                    ripple:Destroy()
                end)
            end
        end)
    end

    -- These functions will be overridden in Part 2, but we need them defined here.
    C.createAutoStealUI = function() end
    C.removeAutoStealUI = function() end
    C.updateStealUIDisplay = function() end

    print("Blood Hub - Part 1 loaded.")
end)
-- Blood Hub x EclipseX – Full Merge (Updated)
-- Standalone / Run after Part 1.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- ====================== GLOBALS ======================
NORMAL_SPEED=60; SLOW_SPEED=29
POS_L1=Vector3.new(-476.48,-6.28,92.73); POS_L2=Vector3.new(-483.12,-4.95,94.80)
POS_R1=Vector3.new(-476.16,-6.52,25.62); POS_R2=Vector3.new(-483.04,-5.09,23.14)

FAP_L1=Vector3.new(-476.48,-6.28,92.73); FAP_L2=Vector3.new(-482.85,-5.03,93.13)
FAP_L3=Vector3.new(-475.68,-6.89,92.76); FAP_L4=Vector3.new(-476.50,-6.46,27.58)
FAP_L5=Vector3.new(-482.42,-5.03,27.84)
FAP_R1=Vector3.new(-476.16,-6.52,25.62); FAP_R2=Vector3.new(-483.06,-5.03,27.51)
FAP_R3=Vector3.new(-476.21,-6.63,27.46); FAP_R4=Vector3.new(-476.66,-6.39,92.44)
FAP_R5=Vector3.new(-481.94,-5.03,92.42)

aplOn=false; aprOn=false; aplPhase=1; aprPhase=1; aplConn=nil; aprConn=nil
autoLOn=false; autoROn=false; autoLConn=nil; autoRConn=nil
autoLPhase=1; autoRPhase=1
autoStealEnabled=false; isStealing=false; stealStartTime=nil
autoStealConn=nil; progressConn=nil; STEAL_RADIUS=20; STEAL_DURATION=0.35
antiRagdollEnabled=false
unwalkEnabled=false; unwalkConn=nil
batAimbotEnabled=false; BAT_ENGAGE_RANGE=5
AIMBOT_SPEED=60; MELEE_OFFSET=3
aimbotConnection=nil
galaxyEnabled=false; hopsEnabled=false; galaxyVF=nil; galaxyAtt=nil
DEFAULT_GRAVITY=196.2; GALAXY_GRAVITY=42; GALAXY_HOP=35
HOP_COOLDOWN=0.08; lastHop=0; spaceHeld=false
spinBotEnabled=false; spinBAV=nil; SPIN_SPEED=19
espEnabled=true; espConns={}
optimizerEnabled=false; xrayOrig={}
fovValue=70; fovConn=nil
slowDownEnabled=true
infJumpEnabled=true; INF_JUMP_FORCE=54; CLAMP_FALL=80
gChar=nil; gHum=nil; gHrp=nil
ProgressBarFill=nil; ProgressLabel=nil; ProgressPctLabel=nil
animalCache={}; promptCache={}; stealCache={}
toggleSetters={}
mobBtnRefs={}
AntiRagdollConns={}
CONFIG_KEY="BloodHub_EclipseX_Config"
autoSaveEnabled=false
desyncEnabled=false
brainrotDefenseEnabled=false
brainrotDefenseConn=nil
brainrotDefenseSide="left"
medusaCounterEnabled=false
goodAnimEnabled=false
goodAnimConn=nil

local BAT_SWING_COOLDOWN=0.12
local lastBatSwing=0

local DEFENSE_LEFT_FINAL=Vector3.new(-483.59,-5.04,104.24)
local DEFENSE_RIGHT_FINAL=Vector3.new(-483.51,-5.10,18.89)
local CHECKPOINT_A=Vector3.new(-472.60,-7.00,57.52)
local CHECKPOINT_L=Vector3.new(-472.65,-7.00,95.69)
local CHECKPOINT_R=Vector3.new(-471.76,-7.00,26.22)

local DESYNC_TOUCH=43; local DESYNC_NORMAL=46; local DESYNC_CARRY=21
local function getTouchSpeed() return desyncEnabled and DESYNC_TOUCH or AIMBOT_SPEED end
local function getAutoSpeed()  return desyncEnabled and DESYNC_NORMAL or NORMAL_SPEED end
local function getCarrySpeed() return desyncEnabled and DESYNC_CARRY or SLOW_SPEED end

local function getHRP() local c=player.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=player.Character; return c and c:FindFirstChildOfClass("Humanoid") end

-- ====================== GOOD ANIMATION ======================
local Anims={idle1="rbxassetid://133806214992291",idle2="rbxassetid://94970088341563",walk="rbxassetid://707897309",run="rbxassetid://707861613",jump="rbxassetid://116936326516985",fall="rbxassetid://116936326516985",climb="rbxassetid://116936326516985",swim="rbxassetid://116936326516985",swimidle="rbxassetid://116936326516985"}
local origAnims=nil
local function saveOrigAnims(char) local a=char:FindFirstChild("Animate"); if not a then return end; local function g(o) return o and o.AnimationId or nil end; origAnims={idle1=g(a.idle and a.idle.Animation1),idle2=g(a.idle and a.idle.Animation2),walk=g(a.walk and a.walk.WalkAnim),run=g(a.run and a.run.RunAnim),jump=g(a.jump and a.jump.JumpAnim),fall=g(a.fall and a.fall.FallAnim),climb=g(a.climb and a.climb.ClimbAnim),swim=g(a.swim and a.swim.Swim),swimidle=g(a.swimidle and a.swimidle.SwimIdle)} end
local function applyGoodAnims(char) local a=char:FindFirstChild("Animate"); if not a then return end; local function s(o,id) if o then o.AnimationId=id end end; s(a.idle and a.idle.Animation1,Anims.idle1); s(a.idle and a.idle.Animation2,Anims.idle2); s(a.walk and a.walk.WalkAnim,Anims.walk); s(a.run and a.run.RunAnim,Anims.run); s(a.jump and a.jump.JumpAnim,Anims.jump); s(a.fall and a.fall.FallAnim,Anims.fall); s(a.climb and a.climb.ClimbAnim,Anims.climb); s(a.swim and a.swim.Swim,Anims.swim); s(a.swimidle and a.swimidle.SwimIdle,Anims.swimidle) end
local function restoreOrigAnims(char) if not origAnims then return end; local a=char:FindFirstChild("Animate"); if not a then return end; local function s(o,id) if o and id then o.AnimationId=id end end; s(a.idle and a.idle.Animation1,origAnims.idle1); s(a.idle and a.idle.Animation2,origAnims.idle2); s(a.walk and a.walk.WalkAnim,origAnims.walk); s(a.run and a.run.RunAnim,origAnims.run); s(a.jump and a.jump.JumpAnim,origAnims.jump); s(a.fall and a.fall.FallAnim,origAnims.fall); s(a.climb and a.climb.ClimbAnim,origAnims.climb); s(a.swim and a.swim.Swim,origAnims.swim); s(a.swimidle and a.swimidle.SwimIdle,origAnims.swimidle); local hum=char:FindFirstChildOfClass("Humanoid"); if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end end end
local function startGoodAnim() local char=player.Character; if not char then return end; saveOrigAnims(char); applyGoodAnims(char); local hum=char:FindFirstChildOfClass("Humanoid"); if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end end; if goodAnimConn then goodAnimConn:Disconnect() end; goodAnimConn=RunService.Heartbeat:Connect(function() if not goodAnimEnabled then return end; local c=player.Character; if c then applyGoodAnims(c) end end) end
local function stopGoodAnim() if goodAnimConn then goodAnimConn:Disconnect(); goodAnimConn=nil end; local char=player.Character; if char then restoreOrigAnims(char) end end

-- ====================== MEDUSA COUNTER ======================
local MEDUSA_COOLDOWN=25; local medusaLastUsed=0; local medusaDebounce=false; local medusaAnchorConns={}
local function findMedusaTool() local char=player.Character; if not char then return nil end; for _,tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") then local tn=tool.Name:lower(); if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end end end; local bp=player:FindFirstChild("Backpack"); if bp then for _,tool in ipairs(bp:GetChildren()) do if tool:IsA("Tool") then local tn=tool.Name:lower(); if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end end end end; return nil end
local function useMedusaCounter() if medusaDebounce then return end; if tick()-medusaLastUsed<MEDUSA_COOLDOWN then return end; local char=player.Character; if not char then return end; medusaDebounce=true; local med=findMedusaTool(); if not med then medusaDebounce=false; return end; if med.Parent~=char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(med) end end; pcall(function() med:Activate() end); medusaLastUsed=tick(); medusaDebounce=false end
local function stopMedusaCounter() for _,c in pairs(medusaAnchorConns) do pcall(function() c:Disconnect() end) end; medusaAnchorConns={} end
local function setupMedusaCounter(char) stopMedusaCounter(); if not char then return end; local function onAnchorChanged(part) return part:GetPropertyChangedSignal("Anchored"):Connect(function() if medusaCounterEnabled and part.Anchored and part.Transparency==1 then useMedusaCounter() end end) end; for _,part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then table.insert(medusaAnchorConns,onAnchorChanged(part)) end end; table.insert(medusaAnchorConns,char.DescendantAdded:Connect(function(part) if part:IsA("BasePart") then table.insert(medusaAnchorConns,onAnchorChanged(part)) end end)) end

-- ====================== BRAINROT DEFENSE ======================
local wasRagdolled=false; local alreadyTP=false
local function doVortexTP(char) if alreadyTP then return end; alreadyTP=true; task.spawn(function() task.wait(0.15); local cc=player.Character; if not cc then alreadyTP=false; return end; for _,v in ipairs(cc:GetDescendants()) do if v:IsA("BasePart") then v.AssemblyLinearVelocity=Vector3.zero; v.AssemblyAngularVelocity=Vector3.zero end end; if brainrotDefenseSide=="left" then cc:PivotTo(CFrame.new(CHECKPOINT_A+Vector3.new(0,3,0))); task.wait(0.08); cc:PivotTo(CFrame.new(CHECKPOINT_L+Vector3.new(0,3,0))); task.wait(0.08); cc:PivotTo(CFrame.new(DEFENSE_LEFT_FINAL+Vector3.new(0,3,0))) else cc:PivotTo(CFrame.new(CHECKPOINT_A+Vector3.new(0,3,0))); task.wait(0.08); cc:PivotTo(CFrame.new(CHECKPOINT_R+Vector3.new(0,3,0))); task.wait(0.08); cc:PivotTo(CFrame.new(DEFENSE_RIGHT_FINAL+Vector3.new(0,3,0))) end; task.wait(1.5); alreadyTP=false end) end
local function checkRagdollState(c) local hum=c:FindFirstChildOfClass("Humanoid"); if not hum then return false end; local state=hum:GetState(); if state==Enum.HumanoidStateType.Physics or state==Enum.HumanoidStateType.FallingDown or state==Enum.HumanoidStateType.Ragdoll then return true end; local hrp=c:FindFirstChild("HumanoidRootPart"); if hrp then local mo=hrp:FindFirstChildOfClass("Motor6D"); if mo and not mo.Enabled then return true end end; return false end
local function startBrainrotDefense() if brainrotDefenseConn then return end; brainrotDefenseConn=RunService.Heartbeat:Connect(function() if not brainrotDefenseEnabled then return end; if batAimbotEnabled or aplOn or aprOn or autoLOn or autoROn then return end; local c=player.Character; if not c then return end; local ragNow=checkRagdollState(c); if ragNow and not wasRagdolled then doVortexTP(c) end; wasRagdolled=ragNow end); player.CharacterAdded:Connect(function() alreadyTP=false; wasRagdolled=false end) end
local function stopBrainrotDefense() if brainrotDefenseConn then brainrotDefenseConn:Disconnect(); brainrotDefenseConn=nil end end

-- Keybinds: MobAutoL and MobAutoR default to Unknown (unbound) to prevent random controller bleed
Keybinds={
    AutoLeft=Enum.KeyCode.Q, AutoRight=Enum.KeyCode.E,
    AutoSteal=Enum.KeyCode.V, BatAimbot=Enum.KeyCode.Z,
    AntiRagdoll=Enum.KeyCode.X, Unwalk=Enum.KeyCode.N,
    CarrySpd=Enum.KeyCode.F7, Drop=Enum.KeyCode.F3, TPDown=Enum.KeyCode.G,
    MobAutoL=Enum.KeyCode.Unknown, MobAutoR=Enum.KeyCode.Unknown
}

local aimbotHighlight=Instance.new("Highlight"); aimbotHighlight.Name="BloodHubAimbotESP"; aimbotHighlight.FillColor=Color3.fromRGB(255,0,50); aimbotHighlight.OutlineColor=Color3.fromRGB(255,255,255); aimbotHighlight.FillTransparency=0.5; aimbotHighlight.OutlineTransparency=0
pcall(function() aimbotHighlight.Parent=player:WaitForChild("PlayerGui") end)

-- ====================== SAVE / LOAD ======================
local function saveConfig()
    pcall(function()
        if not writefile then return end
        local data={NORMAL_SPEED=NORMAL_SPEED,SLOW_SPEED=SLOW_SPEED,STEAL_RADIUS=STEAL_RADIUS,STEAL_DURATION=STEAL_DURATION,GALAXY_GRAVITY=GALAXY_GRAVITY,GALAXY_HOP=GALAXY_HOP,SPIN_SPEED=SPIN_SPEED,fovValue=fovValue,AIMBOT_SPEED=AIMBOT_SPEED,BAT_ENGAGE_RANGE=BAT_ENGAGE_RANGE,infJumpEnabled=infJumpEnabled,espEnabled=espEnabled,antiRagdollEnabled=antiRagdollEnabled,unwalkEnabled=unwalkEnabled,spinBotEnabled=spinBotEnabled,slowDownEnabled=slowDownEnabled,galaxyEnabled=galaxyEnabled,optimizerEnabled=optimizerEnabled,autoStealEnabled=autoStealEnabled,brainrotDefenseEnabled=brainrotDefenseEnabled,brainrotDefenseSide=brainrotDefenseSide,batAimbotEnabled=batAimbotEnabled,autoSaveEnabled=autoSaveEnabled,desyncEnabled=desyncEnabled,medusaCounterEnabled=medusaCounterEnabled,goodAnimEnabled=goodAnimEnabled}
        for k in pairs(Keybinds) do
            local ok,name=pcall(function() return Keybinds[k].Name end)
            if ok and Keybinds[k]~=Enum.KeyCode.Unknown then data["KEY_"..k]=name end
        end
        writefile(CONFIG_KEY..".json",game:GetService("HttpService"):JSONEncode(data))
    end)
end
local savedData={}
local function loadConfig()
    pcall(function()
        if not (readfile and isfile and isfile(CONFIG_KEY..".json")) then return end
        local ok,data=pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(CONFIG_KEY..".json")) end)
        if not ok or not data then return end
        savedData=data
        if data.NORMAL_SPEED then NORMAL_SPEED=data.NORMAL_SPEED end; if data.SLOW_SPEED then SLOW_SPEED=data.SLOW_SPEED end; if data.STEAL_RADIUS then STEAL_RADIUS=data.STEAL_RADIUS end; if data.STEAL_DURATION then STEAL_DURATION=data.STEAL_DURATION end; if data.GALAXY_GRAVITY then GALAXY_GRAVITY=data.GALAXY_GRAVITY end; if data.GALAXY_HOP then GALAXY_HOP=data.GALAXY_HOP end; if data.SPIN_SPEED then SPIN_SPEED=data.SPIN_SPEED end; if data.fovValue then fovValue=data.fovValue end; if data.AIMBOT_SPEED then AIMBOT_SPEED=data.AIMBOT_SPEED end; if data.BAT_ENGAGE_RANGE then BAT_ENGAGE_RANGE=data.BAT_ENGAGE_RANGE end
        if data.infJumpEnabled~=nil then infJumpEnabled=data.infJumpEnabled end; if data.espEnabled~=nil then espEnabled=data.espEnabled end; if data.antiRagdollEnabled~=nil then antiRagdollEnabled=data.antiRagdollEnabled end; if data.unwalkEnabled~=nil then unwalkEnabled=data.unwalkEnabled end; if data.spinBotEnabled~=nil then spinBotEnabled=data.spinBotEnabled end; if data.slowDownEnabled~=nil then slowDownEnabled=data.slowDownEnabled end; if data.galaxyEnabled~=nil then galaxyEnabled=data.galaxyEnabled end; if data.optimizerEnabled~=nil then optimizerEnabled=data.optimizerEnabled end; if data.autoStealEnabled~=nil then autoStealEnabled=data.autoStealEnabled end; if data.brainrotDefenseEnabled~=nil then brainrotDefenseEnabled=data.brainrotDefenseEnabled end; if data.brainrotDefenseSide then brainrotDefenseSide=data.brainrotDefenseSide end; if data.batAimbotEnabled~=nil then batAimbotEnabled=data.batAimbotEnabled end; if data.autoSaveEnabled~=nil then autoSaveEnabled=data.autoSaveEnabled end; if data.desyncEnabled~=nil then desyncEnabled=data.desyncEnabled end; if data.medusaCounterEnabled~=nil then medusaCounterEnabled=data.medusaCounterEnabled end; if data.goodAnimEnabled~=nil then goodAnimEnabled=data.goodAnimEnabled end
        for k in pairs(Keybinds) do
            if data["KEY_"..k] then
                local kc=Enum.KeyCode[data["KEY_"..k]]
                if kc and kc~=Enum.KeyCode.Unknown then pcall(function() Keybinds[k]=kc end) end
            end
        end
    end)
end
loadConfig()
player.AncestryChanged:Connect(function() if not player.Parent and autoSaveEnabled then saveConfig() end end)
game:GetService("Players").PlayerRemoving:Connect(function(p) if p==player and autoSaveEnabled then saveConfig() end end)

-- ====================== TP DOWN ======================
local function doTPDown()
    task.spawn(function()
        pcall(function()
            local c=player.Character; if not c then return end
            local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local hum=c:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local rp=RaycastParams.new(); rp.FilterDescendantsInstances={c}; rp.FilterType=Enum.RaycastFilterType.Exclude
            local hit=workspace:Raycast(hrp.Position,Vector3.new(0,-600,0),rp)
            if hit then hrp.AssemblyLinearVelocity=Vector3.zero; hrp.AssemblyAngularVelocity=Vector3.zero; local hh=hum.HipHeight or 2; local hy=hrp.Size.Y/2; hrp.CFrame=CFrame.new(hit.Position.X,hit.Position.Y+hh+hy+0.1,hit.Position.Z); hrp.AssemblyLinearVelocity=Vector3.zero end
        end)
    end)
end

-- ====================== INF JUMP ======================
UserInputService.JumpRequest:Connect(function() if not infJumpEnabled then return end; local h=getHRP(); if not h then return end; h.AssemblyLinearVelocity=Vector3.new(h.AssemblyLinearVelocity.X,INF_JUMP_FORCE,h.AssemblyLinearVelocity.Z) end)
RunService.Heartbeat:Connect(function() if not infJumpEnabled then return end; local h=getHRP(); if not h then return end; if h.AssemblyLinearVelocity.Y<-CLAMP_FALL then h.AssemblyLinearVelocity=Vector3.new(h.AssemblyLinearVelocity.X,-CLAMP_FALL,h.AssemblyLinearVelocity.Z) end end)

-- ====================== DROP ======================
local _wfConns={}; local _wfActive=false
local function startWalkFling() _wfActive=true; table.insert(_wfConns,RunService.Stepped:Connect(function() if not _wfActive then return end; for _,p in ipairs(Players:GetPlayers()) do if p~=player and p.Character then for _,part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide=false end end end end end)); local co=coroutine.create(function() while _wfActive do RunService.Heartbeat:Wait(); local c=player.Character; local root=c and c:FindFirstChild("HumanoidRootPart"); if not root then RunService.Heartbeat:Wait(); continue end; local vel=root.Velocity; root.Velocity=vel*10000+Vector3.new(0,10000,0); RunService.RenderStepped:Wait(); if root and root.Parent then root.Velocity=vel end; RunService.Stepped:Wait(); if root and root.Parent then root.Velocity=vel+Vector3.new(0,0.1,0) end end end); coroutine.resume(co); table.insert(_wfConns,co) end
local function stopWalkFling() _wfActive=false; for _,c in ipairs(_wfConns) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() elseif typeof(c)=="thread" then pcall(task.cancel,c) end end; _wfConns={} end
local function doDrop() startWalkFling(); task.delay(0.4,stopWalkFling) end

-- ====================== ANTI RAGDOLL ======================
local function startAntiRagdoll()
    if #AntiRagdollConns>0 then return end
    local c=player.Character or player.CharacterAdded:Wait(); local humanoid=c:WaitForChild("Humanoid"); local root=c:WaitForChild("HumanoidRootPart"); local animator=humanoid:WaitForChild("Animator")
    local maxVelocity=40; local clampVelocity=25; local maxClamp=15; local lastVelocity=Vector3.new(0,0,0)
    local function IsRagdollState() local state=humanoid:GetState(); return state==Enum.HumanoidStateType.Physics or state==Enum.HumanoidStateType.Ragdoll or state==Enum.HumanoidStateType.FallingDown or state==Enum.HumanoidStateType.GettingUp end
    local function CleanRagdollEffects() for _,obj in pairs(c:GetDescendants()) do if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint") or (obj:IsA("Attachment") and (obj.Name=="A" or obj.Name=="B")) then obj:Destroy() elseif obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then obj:Destroy() elseif obj:IsA("Motor6D") then obj.Enabled=true end end; for _,track in pairs(animator:GetPlayingAnimationTracks()) do local animName=track.Animation and track.Animation.Name:lower() or ""; if animName:find("rag") or animName:find("fall") or animName:find("hurt") or animName:find("down") then track:Stop(0) end end end
    local function ReEnableControls() pcall(function() require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls():Enable() end) end
    table.insert(AntiRagdollConns,humanoid.StateChanged:Connect(function() if IsRagdollState() then humanoid:ChangeState(Enum.HumanoidStateType.Running); CleanRagdollEffects(); workspace.CurrentCamera.CameraSubject=humanoid; ReEnableControls() end end))
    table.insert(AntiRagdollConns,RunService.Heartbeat:Connect(function() if not antiRagdollEnabled then return end; if IsRagdollState() then CleanRagdollEffects(); local vel=root.AssemblyLinearVelocity; if (vel-lastVelocity).Magnitude>maxVelocity and vel.Magnitude>clampVelocity then root.AssemblyLinearVelocity=vel.Unit*math.min(vel.Magnitude,maxClamp) end; lastVelocity=vel end end))
    table.insert(AntiRagdollConns,c.DescendantAdded:Connect(function() if IsRagdollState() then CleanRagdollEffects() end end))
    table.insert(AntiRagdollConns,player.CharacterAdded:Connect(function(newChar) c=newChar; humanoid=newChar:WaitForChild("Humanoid"); root=newChar:WaitForChild("HumanoidRootPart"); animator=humanoid:WaitForChild("Animator"); lastVelocity=Vector3.new(0,0,0); ReEnableControls(); CleanRagdollEffects() end))
    ReEnableControls(); CleanRagdollEffects()
end
local function stopAntiRagdoll() for _,conn in pairs(AntiRagdollConns) do conn:Disconnect() end; AntiRagdollConns={} end

-- ====================== UNWALK ======================
local function startUnwalk() if not gChar then return end; local h2=gChar:FindFirstChildOfClass("Humanoid"); if not h2 then return end; local anim=h2:FindFirstChildOfClass("Animator"); if not anim then return end; for _,t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end; if unwalkConn then unwalkConn:Disconnect() end; unwalkConn=RunService.Heartbeat:Connect(function() if not unwalkEnabled then unwalkConn:Disconnect(); unwalkConn=nil; return end; local c=player.Character; if not c then return end; local hh=c:FindFirstChildOfClass("Humanoid"); if not hh then return end; local an=hh:FindFirstChildOfClass("Animator"); if not an then return end; for _,t in ipairs(an:GetPlayingAnimationTracks()) do t:Stop(0) end end) end
local function stopUnwalk() if unwalkConn then unwalkConn:Disconnect(); unwalkConn=nil end end

-- ====================== ESP ======================
local function createESP(plr) if plr==player or not plr.Character then return end; local c=plr.Character; local root=c:FindFirstChild("HumanoidRootPart"); if not root then return end; local head=c:FindFirstChild("Head"); if not head then return end; if c:FindFirstChild("BloodHubESP") then return end; local box=Instance.new("BoxHandleAdornment"); box.Name="BloodHubESP"; box.Adornee=root; box.Size=Vector3.new(4,6,2); box.Color3=Color3.fromRGB(255,0,50); box.Transparency=0.45; box.ZIndex=10; box.AlwaysOnTop=true; box.Parent=c; local bb=Instance.new("BillboardGui"); bb.Name="BloodHubESP_Name"; bb.Adornee=head; bb.Size=UDim2.new(0,200,0,45); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Parent=c; local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=plr.DisplayName; lbl.TextColor3=Color3.fromRGB(255,255,255); lbl.Font=Enum.Font.GothamBold; lbl.TextScaled=true; lbl.TextStrokeTransparency=0.5; lbl.TextStrokeColor3=Color3.fromRGB(255,0,50); lbl.Parent=bb end
local function removeESP(plr) if not plr.Character then return end; local b=plr.Character:FindFirstChild("BloodHubESP"); local n=plr.Character:FindFirstChild("BloodHubESP_Name"); if b then b:Destroy() end; if n then n:Destroy() end end
local function enableESP() for _,plr in ipairs(Players:GetPlayers()) do if plr~=player then if plr.Character then pcall(function() createESP(plr) end) end; table.insert(espConns,plr.CharacterAdded:Connect(function() task.wait(0.1); if espEnabled then pcall(function() createESP(plr) end) end end)) end end; table.insert(espConns,Players.PlayerAdded:Connect(function(plr) if plr==player then return end; table.insert(espConns,plr.CharacterAdded:Connect(function() task.wait(0.1); if espEnabled then pcall(function() createESP(plr) end) end end)) end)) end
local function disableESP() for _,plr in ipairs(Players:GetPlayers()) do pcall(function() removeESP(plr) end) end; for _,c in ipairs(espConns) do if c and c.Connected then c:Disconnect() end end; espConns={} end

-- ====================== OPTIMIZER ======================
local function enableOptimizer() pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01; Lighting.GlobalShadows=false; Lighting.Brightness=2; Lighting.FogEnd=9e9; for _,fx in ipairs(Lighting:GetChildren()) do if fx:IsA("PostEffect") then fx.Enabled=false end end end); pcall(function() for _,obj in ipairs(workspace:GetDescendants()) do pcall(function() if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then obj.Enabled=false; obj:Destroy() elseif obj:IsA("SelectionBox") then obj:Destroy() elseif obj:IsA("BasePart") then obj.CastShadow=false; obj.Material=Enum.Material.Plastic; for _,ch in ipairs(obj:GetChildren()) do if ch:IsA("Decal") or ch:IsA("Texture") or ch:IsA("SurfaceAppearance") then ch:Destroy() end end elseif obj:IsA("Sky") then obj:Destroy() end end) end end); pcall(function() for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and obj.Anchored and (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then xrayOrig[obj]=obj.LocalTransparencyModifier; obj.LocalTransparencyModifier=0.88 end end end) end
local function disableOptimizer() pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic; Lighting.GlobalShadows=true end); for part,val in pairs(xrayOrig) do if part and part.Parent then part.LocalTransparencyModifier=val end end; xrayOrig={} end

-- ====================== FOV ======================
local function applyFOV() if fovConn then fovConn:Disconnect() end; fovConn=RunService.RenderStepped:Connect(function() workspace.CurrentCamera.FieldOfView=fovValue end) end

-- ====================== GALAXY ======================
local function setupGalaxyForce() local h=getHRP(); if not h then return end; if galaxyVF then galaxyVF:Destroy() end; if galaxyAtt then galaxyAtt:Destroy() end; galaxyAtt=Instance.new("Attachment"); galaxyAtt.Parent=h; galaxyVF=Instance.new("VectorForce"); galaxyVF.Attachment0=galaxyAtt; galaxyVF.ApplyAtCenterOfMass=true; galaxyVF.RelativeTo=Enum.ActuatorRelativeTo.World; galaxyVF.Force=Vector3.zero; galaxyVF.Parent=h end
local function updateGalaxyForce() if not galaxyEnabled or not galaxyVF or not gChar then return end; local mass=0; for _,p in ipairs(gChar:GetDescendants()) do if p:IsA("BasePart") then mass=mass+p:GetMass() end end; local tg=DEFAULT_GRAVITY*(GALAXY_GRAVITY/100); galaxyVF.Force=Vector3.new(0,mass*(DEFAULT_GRAVITY-tg)*0.95,0) end
local function startGalaxy() galaxyEnabled=true; hopsEnabled=true; pcall(setupGalaxyForce) end
local function stopGalaxy() galaxyEnabled=false; hopsEnabled=false; if galaxyVF then galaxyVF:Destroy(); galaxyVF=nil end; if galaxyAtt then galaxyAtt:Destroy(); galaxyAtt=nil end end
local function doHop() local h=getHRP(); local hh=getHum(); if not h or not hh then return end; if tick()-lastHop<HOP_COOLDOWN then return end; lastHop=tick(); if hh.FloorMaterial==Enum.Material.Air then h.AssemblyLinearVelocity=Vector3.new(h.AssemblyLinearVelocity.X,GALAXY_HOP,h.AssemblyLinearVelocity.Z) end end

-- ====================== SPINBOT ======================
local function startSpin() local c=player.Character; if not c then return end; local root=c:FindFirstChild("HumanoidRootPart"); if not root then return end; if spinBAV then spinBAV:Destroy() end; spinBAV=Instance.new("BodyAngularVelocity"); spinBAV.Name="BloodHubSpinBAV"; spinBAV.MaxTorque=Vector3.new(0,math.huge,0); spinBAV.AngularVelocity=Vector3.new(0,SPIN_SPEED,0); spinBAV.Parent=root end
local function stopSpin() if spinBAV then spinBAV:Destroy(); spinBAV=nil end end

-- ====================== LOCK ======================
local function isTargetValid(targetChar)
    if not targetChar then return false end
    local hum=targetChar:FindFirstChildOfClass("Humanoid")
    local hrp=targetChar:FindFirstChild("HumanoidRootPart")
    local ff=targetChar:FindFirstChildOfClass("ForceField")
    return hum and hrp and hum.Health>0 and not ff
end

local function getBestTarget(myHRP)
    local shortest=math.huge; local bestChar=nil; local bestHRP=nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and isTargetValid(p.Character) then
            local tr=p.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local d=(tr.Position-myHRP.Position).Magnitude
                if d<shortest then shortest=d; bestHRP=tr; bestChar=p.Character end
            end
        end
    end
    return bestHRP, bestChar
end

local function findBatTool()
    local c=player.Character; if not c then return nil end
    local bp=player:FindFirstChildOfClass("Backpack")
    local SlapList={"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}
    for _,ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
    if bp then for _,ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    for _,name in ipairs(SlapList) do
        local t=c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
        if t then return t end
    end
end

local function startBatAimbot()
    if aimbotConnection then return end
    local c=player.Character; if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart")
    local hum=c:FindFirstChildOfClass("Humanoid")
    if not h or not hum then return end
    hum.AutoRotate=false
    local attachment=h:FindFirstChild("AimbotAttachment") or Instance.new("Attachment",h)
    attachment.Name="AimbotAttachment"
    local align=h:FindFirstChild("AimbotAlign") or Instance.new("AlignOrientation",h)
    align.Name="AimbotAlign"; align.Mode=Enum.OrientationAlignmentMode.OneAttachment
    align.Attachment0=attachment; align.MaxTorque=math.huge; align.Responsiveness=200
    batAimbotEnabled=true
    aimbotConnection=RunService.Heartbeat:Connect(function()
        if not batAimbotEnabled then return end
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local now=tick()
        local currentHRP=player.Character.HumanoidRootPart
        local currentHum=player.Character:FindFirstChildOfClass("Humanoid")
        local bat=findBatTool()
        if bat and bat.Parent~=player.Character then pcall(function() currentHum:EquipTool(bat) end) end
        local targetHRP,targetChar=getBestTarget(currentHRP)
        if targetHRP and targetChar then
            aimbotHighlight.Adornee=targetChar
            local targetVel=targetHRP.AssemblyLinearVelocity
            local speed=targetVel.Magnitude
            local predictTime=math.clamp(speed/150,0.05,0.2)
            local predictedPos=targetHRP.Position+(targetVel*predictTime)
            align.CFrame=CFrame.lookAt(currentHRP.Position,predictedPos)
            local chaseSpd=getTouchSpeed()
            local dirToTarget=predictedPos-currentHRP.Position
            local dist=dirToTarget.Magnitude
            local standPos=dist>0 and (predictedPos-(dirToTarget.Unit*MELEE_OFFSET)) or predictedPos
            local moveDir=standPos-currentHRP.Position
            local distToStand=moveDir.Magnitude
            if distToStand>1 then
                currentHRP.AssemblyLinearVelocity=moveDir.Unit*chaseSpd
            else
                currentHRP.AssemblyLinearVelocity=targetVel
            end
            if distToStand<=BAT_ENGAGE_RANGE then
                if bat and bat.Parent==player.Character and (now-lastBatSwing)>=BAT_SWING_COOLDOWN then
                    lastBatSwing=now
                    pcall(function() bat:Activate() end)
                end
            end
        else
            currentHRP.AssemblyLinearVelocity=Vector3.new(0,0,0)
            aimbotHighlight.Adornee=nil
        end
    end)
end

local function stopBatAimbot()
    batAimbotEnabled=false
    if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection=nil end
    local c=player.Character
    local h=c and c:FindFirstChild("HumanoidRootPart")
    local hum=c and c:FindFirstChildOfClass("Humanoid")
    if h then
        local att=h:FindFirstChild("AimbotAttachment"); if att then att:Destroy() end
        local al=h:FindFirstChild("AimbotAlign"); if al then al:Destroy() end
        h.AssemblyLinearVelocity=Vector3.new(0,0,0)
    end
    if hum then hum.AutoRotate=true end
    aimbotHighlight.Adornee=nil
end

-- ====================== AUTO L / AUTO R ======================
local function stopAutoL() autoLOn=false; if autoLConn then autoLConn:Disconnect(); autoLConn=nil end; autoLPhase=1; local hh=getHum(); if hh then hh:Move(Vector3.zero,false) end; local h=getHRP(); if h then h.AssemblyLinearVelocity=Vector3.new(0,h.AssemblyLinearVelocity.Y,0) end end
local function stopAutoR() autoROn=false; if autoRConn then autoRConn:Disconnect(); autoRConn=nil end; autoRPhase=1; local hh=getHum(); if hh then hh:Move(Vector3.zero,false) end; local h=getHRP(); if h then h.AssemblyLinearVelocity=Vector3.new(0,h.AssemblyLinearVelocity.Y,0) end end
local function startAutoL() if autoLConn then autoLConn:Disconnect() end; autoLPhase=1; local pts={FAP_L1,FAP_L2,FAP_L3,FAP_L4,FAP_L5}; autoLConn=RunService.Heartbeat:Connect(function() if not autoLOn or not gHrp or not gHum then return end; local ph=autoLPhase; local tgt=pts[ph]; local spd=ph>=3 and getCarrySpeed() or getAutoSpeed(); local flat=Vector3.new(tgt.X-gHrp.Position.X,0,tgt.Z-gHrp.Position.Z); if flat.Magnitude<1 then if ph==5 then gHum:Move(Vector3.zero,false); gHrp.AssemblyLinearVelocity=Vector3.zero; autoLOn=false; stopAutoL(); local info=mobBtnRefs["AUTO L"]; if info then info.btn.BackgroundColor3=Color3.fromRGB(8,8,8); info.bs.Color=Color3.fromRGB(40,40,50); info.bs.Transparency=0.2; info.state=false end; if toggleSetters["Auto Left"] then toggleSetters["Auto Left"](false) end; return elseif ph==2 then gHum:Move(Vector3.zero,false); gHrp.AssemblyLinearVelocity=Vector3.zero; task.wait(0.05); autoLPhase=3; return else autoLPhase=ph+1; return end end; local md=flat.Unit; gHum:Move(md,false); gHrp.AssemblyLinearVelocity=Vector3.new(md.X*spd,gHrp.AssemblyLinearVelocity.Y,md.Z*spd) end) end
local function startAutoR() if autoRConn then autoRConn:Disconnect() end; autoRPhase=1; local pts={FAP_R1,FAP_R2,FAP_R3,FAP_R4,FAP_R5}; autoRConn=RunService.Heartbeat:Connect(function() if not autoROn or not gHrp or not gHum then return end; local ph=autoRPhase; local tgt=pts[ph]; local spd=ph>=3 and getCarrySpeed() or getAutoSpeed(); local flat=Vector3.new(tgt.X-gHrp.Position.X,0,tgt.Z-gHrp.Position.Z); if flat.Magnitude<1 then if ph==5 then gHum:Move(Vector3.zero,false); gHrp.AssemblyLinearVelocity=Vector3.zero; autoROn=false; stopAutoR(); local info=mobBtnRefs["AUTO R"]; if info then info.btn.BackgroundColor3=Color3.fromRGB(8,8,8); info.bs.Color=Color3.fromRGB(40,40,50); info.bs.Transparency=0.2; info.state=false end; if toggleSetters["Auto Right"] then toggleSetters["Auto Right"](false) end; return elseif ph==2 then gHum:Move(Vector3.zero,false); gHrp.AssemblyLinearVelocity=Vector3.zero; task.wait(0.05); autoRPhase=3; return else autoRPhase=ph+1; return end end; local md=flat.Unit; gHum:Move(md,false); gHrp.AssemblyLinearVelocity=Vector3.new(md.X*spd,gHrp.AssemblyLinearVelocity.Y,md.Z*spd) end) end

-- ====================== PLAY L / PLAY R ======================
local function stopAutoPlayLeft() aplOn=false; if aplConn then aplConn:Disconnect(); aplConn=nil end; aplPhase=1; local hh=getHum(); if hh then hh:Move(Vector3.zero,false) end; local h=getHRP(); if h then h.AssemblyLinearVelocity=Vector3.new(0,h.AssemblyLinearVelocity.Y,0) end end
local function stopAutoPlayRight() aprOn=false; if aprConn then aprConn:Disconnect(); aprConn=nil end; aprPhase=1; local hh=getHum(); if hh then hh:Move(Vector3.zero,false) end; local h=getHRP(); if h then h.AssemblyLinearVelocity=Vector3.new(0,h.AssemblyLinearVelocity.Y,0) end end
local function startAutoPlayLeft() if aplConn then aplConn:Disconnect() end; aplPhase=1; aplConn=RunService.Heartbeat:Connect(function() if not aplOn or not gHrp or not gHum then return end; local targets={POS_L1,POS_L2}; local tp=targets[aplPhase]; local d=Vector3.new(tp.X-gHrp.Position.X,0,tp.Z-gHrp.Position.Z); if d.Magnitude<1 then if aplPhase==#targets then gHum:Move(Vector3.zero,false); gHrp.AssemblyLinearVelocity=Vector3.zero; aplOn=false; stopAutoPlayLeft(); local info=mobBtnRefs["PLAY L"]; if info then info.btn.BackgroundColor3=Color3.fromRGB(8,8,8); info.bs.Color=Color3.fromRGB(40,40,50); info.bs.Transparency=0.2; info.state=false end; if toggleSetters["Play Left"] then toggleSetters["Play Left"](false) end; return end; aplPhase=aplPhase+1 else local md=d.Unit; gHum:Move(md,false); local spd=getAutoSpeed(); gHrp.AssemblyLinearVelocity=Vector3.new(md.X*spd,gHrp.AssemblyLinearVelocity.Y,md.Z*spd) end end) end
local function startAutoPlayRight() if aprConn then aprConn:Disconnect() end; aprPhase=1; aprConn=RunService.Heartbeat:Connect(function() if not aprOn or not gHrp or not gHum then return end; local targets={POS_R1,POS_R2}; local tp=targets[aprPhase]; local d=Vector3.new(tp.X-gHrp.Position.X,0,tp.Z-gHrp.Position.Z); if d.Magnitude<1 then if aprPhase==#targets then gHum:Move(Vector3.zero,false); gHrp.AssemblyLinearVelocity=Vector3.zero; aprOn=false; stopAutoPlayRight(); local info=mobBtnRefs["PLAY R"]; if info then info.btn.BackgroundColor3=Color3.fromRGB(8,8,8); info.bs.Color=Color3.fromRGB(40,40,50); info.bs.Transparency=0.2; info.state=false end; if toggleSetters["Play Right"] then toggleSetters["Play Right"](false) end; return end; aprPhase=aprPhase+1 else local md=d.Unit; gHum:Move(md,false); local spd=getAutoSpeed(); gHrp.AssemblyLinearVelocity=Vector3.new(md.X*spd,gHrp.AssemblyLinearVelocity.Y,md.Z*spd) end end) end

-- ====================== AUTO STEAL ======================
local function isMyBase(plotName) local plots=workspace:FindFirstChild("Plots"); if not plots then return false end; local plot=plots:FindFirstChild(plotName); if not plot then return false end; local sign=plot:FindFirstChild("PlotSign"); if not sign then return false end; local yb=sign:FindFirstChild("YourBase"); return yb and yb:IsA("BillboardGui") and yb.Enabled==true end
local function scanPlot(plot) if not plot or not plot:IsA("Model") then return end; if isMyBase(plot.Name) then return end; local podiums=plot:FindFirstChild("AnimalPodiums"); if not podiums then return end; for _,pod in ipairs(podiums:GetChildren()) do if pod:IsA("Model") and pod:FindFirstChild("Base") then table.insert(animalCache,{plot=plot.Name,slot=pod.Name,worldPosition=pod:GetPivot().Position,uid=plot.Name.."_"..pod.Name}) end end end
local function findPromptForAnimal(ad) if not ad then return nil end; local cp=promptCache[ad.uid]; if cp and cp.Parent then return cp end; local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end; local plot=plots:FindFirstChild(ad.plot); if not plot then return nil end; local pods=plot:FindFirstChild("AnimalPodiums"); if not pods then return nil end; local pod=pods:FindFirstChild(ad.slot); if not pod then return nil end; local base=pod:FindFirstChild("Base"); if not base then return nil end; local sp=base:FindFirstChild("Spawn"); if not sp then return nil end; local att=sp:FindFirstChild("PromptAttachment"); if not att then return nil end; for _,p in ipairs(att:GetChildren()) do if p:IsA("ProximityPrompt") then promptCache[ad.uid]=p; return p end end end
local function buildCallbacks(prompt) if stealCache[prompt] then return end; local data={hold={},trigger={},ready=true}; pcall(function() if getconnections then for _,c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if type(c.Function)=="function" then table.insert(data.hold,c.Function) end end; for _,c in ipairs(getconnections(prompt.Triggered)) do if type(c.Function)=="function" then table.insert(data.trigger,c.Function) end end end end); if #data.hold>0 or #data.trigger>0 then stealCache[prompt]=data end end
local function execSteal(prompt) local data=stealCache[prompt]; if not data or not data.ready then return false end; data.ready=false; isStealing=true; stealStartTime=tick(); if ProgressLabel then ProgressLabel.Text="STEALING..." end; if progressConn then progressConn:Disconnect() end; progressConn=RunService.Heartbeat:Connect(function() if not isStealing then progressConn:Disconnect(); return end; local prog=math.clamp((tick()-stealStartTime)/STEAL_DURATION,0,1); if ProgressBarFill then ProgressBarFill.Size=UDim2.new(prog,0,1,0) end; if ProgressPctLabel then ProgressPctLabel.Text=math.floor(prog*100).."%" end end); task.spawn(function() for _,f in ipairs(data.hold) do task.spawn(f) end; task.wait(STEAL_DURATION); for _,f in ipairs(data.trigger) do task.spawn(f) end; if progressConn then progressConn:Disconnect() end; if ProgressLabel then ProgressLabel.Text="READY" end; if ProgressPctLabel then ProgressPctLabel.Text="" end; if ProgressBarFill then ProgressBarFill.Size=UDim2.new(0,0,1,0) end; data.ready=true; isStealing=false end); return true end
local function nearestAnimal() local h=getHRP(); if not h then return nil end; local best,bestD=nil,math.huge; for _,ad in ipairs(animalCache) do if not isMyBase(ad.plot) and ad.worldPosition then local d=(h.Position-ad.worldPosition).Magnitude; if d<bestD then bestD=d; best=ad end end end; return best end
local function startAutoSteal() if autoStealConn then return end; autoStealConn=RunService.Heartbeat:Connect(function() if not autoStealEnabled or isStealing then return end; local target=nearestAnimal(); if not target then return end; local h=getHRP(); if not h then return end; if (h.Position-target.worldPosition).Magnitude>STEAL_RADIUS then return end; local prompt=promptCache[target.uid]; if not prompt or not prompt.Parent then prompt=findPromptForAnimal(target) end; if prompt then buildCallbacks(prompt); execSteal(prompt) end end) end
local function stopAutoSteal() if autoStealConn then autoStealConn:Disconnect(); autoStealConn=nil end; isStealing=false; if progressConn then progressConn:Disconnect(); progressConn=nil end; if ProgressBarFill then ProgressBarFill.Size=UDim2.new(0,0,1,0) end; if ProgressLabel then ProgressLabel.Text="READY" end; if ProgressPctLabel then ProgressPctLabel.Text="" end end

task.spawn(function() task.wait(2); local plots=workspace:WaitForChild("Plots",10); if not plots then return end; for _,plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanPlot(plot) end end; plots.ChildAdded:Connect(function(plot) if plot:IsA("Model") then task.wait(0.5); scanPlot(plot) end end); task.spawn(function() while task.wait(5) do animalCache={}; for _,plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") then scanPlot(plot) end end end end) end)

-- ====================== HEARTBEAT ======================
RunService.Heartbeat:Connect(function()
    if not gChar or not gHum or not gHrp then return end
    if spinBotEnabled and spinBAV then spinBAV.AngularVelocity=Vector3.new(0,SPIN_SPEED,0) end
    if galaxyEnabled then updateGalaxyForce() end
    if galaxyEnabled and hopsEnabled and spaceHeld then doHop() end
    if not batAimbotEnabled and not aplOn and not aprOn and not autoLOn and not autoROn then
        local md=gHum.MoveDirection
        if md.Magnitude>0.1 then local spd=slowDownEnabled and getCarrySpeed() or NORMAL_SPEED; gHrp.AssemblyLinearVelocity=Vector3.new(md.X*spd,gHrp.AssemblyLinearVelocity.Y,md.Z*spd) end
    end
end)
UserInputService.InputBegan:Connect(function(input) if input.KeyCode==Enum.KeyCode.Space then spaceHeld=true end end)
UserInputService.InputEnded:Connect(function(input) if input.KeyCode==Enum.KeyCode.Space then spaceHeld=false end end)

local function setupChar(c)
    gChar=c; gHum=c:WaitForChild("Humanoid",5); gHrp=c:WaitForChild("HumanoidRootPart",5)
    if not gHum or not gHrp then return end
    task.wait(0.5)
    if galaxyEnabled then stopGalaxy(); startGalaxy() end
    if antiRagdollEnabled then stopAntiRagdoll(); startAntiRagdoll() end
    if spinBotEnabled then stopSpin(); startSpin() end
    if espEnabled then enableESP() end
    if batAimbotEnabled then stopBatAimbot(); startBatAimbot() end
    if unwalkEnabled then startUnwalk() end
    if brainrotDefenseEnabled then startBrainrotDefense() end
    if goodAnimEnabled then task.wait(0.3); startGoodAnim() end
    if medusaCounterEnabled then setupMedusaCounter(c) end
end
if player.Character then setupChar(player.Character) end
player.CharacterAdded:Connect(function(c) task.wait(0.5); setupChar(c) end)

-- ====================== MAIN GUI ======================
task.spawn(function()

    local ScreenGui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
    ScreenGui.Name="BloodHub_V1"; ScreenGui.ResetOnSpawn=false; ScreenGui.IgnoreGuiInset=true; ScreenGui.DisplayOrder=10

    local PBGui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
    PBGui.Name="BloodHub_ProgressBar"; PBGui.ResetOnSpawn=false; PBGui.IgnoreGuiInset=true; PBGui.DisplayOrder=5

    local toggleMenuBtn=Instance.new("TextButton",ScreenGui)
    toggleMenuBtn.Size=UDim2.new(0,34,0,34); toggleMenuBtn.Position=UDim2.new(1,-142,0,10)
    toggleMenuBtn.BackgroundColor3=Color3.fromRGB(18,18,22); toggleMenuBtn.Text="BH"
    toggleMenuBtn.TextColor3=Color3.fromRGB(255,20,55); toggleMenuBtn.Font=Enum.Font.GothamBlack
    toggleMenuBtn.TextSize=13; toggleMenuBtn.BackgroundTransparency=0.1; toggleMenuBtn.ZIndex=10
    Instance.new("UICorner",toggleMenuBtn).CornerRadius=UDim.new(0,9)
    local tStroke=Instance.new("UIStroke",toggleMenuBtn); tStroke.Thickness=1.5; tStroke.Color=Color3.fromRGB(255,0,50)

    local lockBtn=Instance.new("TextButton",ScreenGui)
    lockBtn.Size=UDim2.new(0,34,0,34); lockBtn.Position=UDim2.new(1,-180,0,10)
    lockBtn.BackgroundColor3=Color3.fromRGB(18,18,22); lockBtn.Text="🔓"
    lockBtn.TextColor3=Color3.fromRGB(200,200,200); lockBtn.Font=Enum.Font.GothamBold
    lockBtn.TextSize=18; lockBtn.BackgroundTransparency=0.1; lockBtn.ZIndex=10
    Instance.new("UICorner",lockBtn).CornerRadius=UDim.new(0,9)
    Instance.new("UIStroke",lockBtn).Color=Color3.fromRGB(60,60,70)
    local dragLocked=false
    lockBtn.MouseButton1Click:Connect(function()
        dragLocked=not dragLocked
        lockBtn.Text=dragLocked and "🔒" or "🔓"
        lockBtn.TextColor3=dragLocked and Color3.fromRGB(255,20,55) or Color3.fromRGB(200,200,200)
    end)

    local mainFrame=Instance.new("Frame",ScreenGui)
    mainFrame.Size=UDim2.new(0,178,0,370); mainFrame.Position=UDim2.new(0,10,0,55)
    mainFrame.BackgroundColor3=Color3.fromRGB(13,13,17); mainFrame.BackgroundTransparency=0; mainFrame.BorderSizePixel=0; mainFrame.Active=true
    Instance.new("UICorner",mainFrame).CornerRadius=UDim.new(0,14)
    local mfStroke=Instance.new("UIStroke",mainFrame); mfStroke.Thickness=1.5; mfStroke.Color=Color3.fromRGB(200,0,30)

    local leftDrag=Instance.new("Frame",mainFrame)
    leftDrag.Size=UDim2.new(0,6,1,-28); leftDrag.Position=UDim2.new(0,0,0,14)
    leftDrag.BackgroundColor3=Color3.fromRGB(20,3,3); leftDrag.BorderSizePixel=0; leftDrag.ZIndex=10; leftDrag.Active=true
    Instance.new("UICorner",leftDrag).CornerRadius=UDim.new(0,6)
    local stripPip=Instance.new("Frame",leftDrag)
    stripPip.Size=UDim2.new(0,2,0,18); stripPip.Position=UDim2.new(0.5,-1,0.5,-9)
    stripPip.BackgroundColor3=Color3.fromRGB(255,0,50); stripPip.BorderSizePixel=0; stripPip.ZIndex=11
    Instance.new("UICorner",stripPip).CornerRadius=UDim.new(1,0)

    local stripDragging=false; local stripDragStart=nil; local stripStartPos=nil
    leftDrag.InputBegan:Connect(function(inp)
        if dragLocked then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            stripDragging=true; stripDragStart=Vector2.new(inp.Position.X,inp.Position.Y); stripStartPos=Vector2.new(mainFrame.Position.X.Offset,mainFrame.Position.Y.Offset)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            stripDragging=false; stripDragStart=nil; stripStartPos=nil
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragLocked or not stripDragging or not stripDragStart then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            local dx=inp.Position.X-stripDragStart.X; local dy=inp.Position.Y-stripDragStart.Y
            mainFrame.Position=UDim2.new(0,stripStartPos.X+dx,0,stripStartPos.Y+dy)
        end
    end)

    local titleBar=Instance.new("Frame",mainFrame)
    titleBar.Size=UDim2.new(1,-6,0,20); titleBar.Position=UDim2.new(0,6,0,0)
    titleBar.BackgroundColor3=Color3.fromRGB(18,18,24); titleBar.BorderSizePixel=0; titleBar.ZIndex=3; titleBar.Active=true
    Instance.new("UICorner",titleBar).CornerRadius=UDim.new(0,14)
    local tbFix=Instance.new("Frame",titleBar); tbFix.Size=UDim2.new(0,14,0.6,0); tbFix.Position=UDim2.new(0,0,0.4,0); tbFix.BackgroundColor3=Color3.fromRGB(18,18,24); tbFix.BorderSizePixel=0; tbFix.ZIndex=3
    local tbFix2=Instance.new("Frame",titleBar); tbFix2.Size=UDim2.new(1,0,0.5,0); tbFix2.Position=UDim2.new(0,0,0.5,0); tbFix2.BackgroundColor3=Color3.fromRGB(18,18,24); tbFix2.BorderSizePixel=0; tbFix2.ZIndex=3

    local tbDragging=false; local tbDragStart=nil; local tbStartPos=nil
    titleBar.InputBegan:Connect(function(inp)
        if dragLocked then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            tbDragging=true; tbDragStart=Vector2.new(inp.Position.X,inp.Position.Y); tbStartPos=Vector2.new(mainFrame.Position.X.Offset,mainFrame.Position.Y.Offset)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            tbDragging=false; tbDragStart=nil; tbStartPos=nil
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragLocked or not tbDragging or not tbDragStart then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            local dx=inp.Position.X-tbDragStart.X; local dy=inp.Position.Y-tbDragStart.Y
            mainFrame.Position=UDim2.new(0,tbStartPos.X+dx,0,tbStartPos.Y+dy)
        end
    end)

    local titleLbl=Instance.new("TextLabel",titleBar); titleLbl.Size=UDim2.new(0,80,1,0); titleLbl.Position=UDim2.new(0,7,0,0); titleLbl.BackgroundTransparency=1; titleLbl.Text="BLOOD HUB"; titleLbl.Font=Enum.Font.LuckiestGuy; titleLbl.TextSize=11; titleLbl.TextColor3=Color3.fromRGB(255,20,55); titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.ZIndex=4
    local FPSLbl=Instance.new("TextLabel",titleBar); FPSLbl.Size=UDim2.new(0,44,1,0); FPSLbl.Position=UDim2.new(1,-62,0,0); FPSLbl.BackgroundTransparency=1; FPSLbl.Text="0 FPS"; FPSLbl.Font=Enum.Font.GothamBold; FPSLbl.TextSize=8; FPSLbl.TextColor3=Color3.fromRGB(255,0,50); FPSLbl.TextXAlignment=Enum.TextXAlignment.Right; FPSLbl.ZIndex=5
    local fc,lft=0,tick(); RunService.RenderStepped:Connect(function() fc=fc+1; local ct=tick(); if ct-lft>=1 then FPSLbl.Text=fc.." FPS"; fc=0; lft=ct end end)
    local minBtn=Instance.new("TextButton",titleBar); minBtn.Size=UDim2.new(0,15,0,12); minBtn.Position=UDim2.new(1,-18,0.5,-6); minBtn.BackgroundColor3=Color3.fromRGB(30,30,40); minBtn.Text="−"; minBtn.TextColor3=Color3.fromRGB(180,180,180); minBtn.Font=Enum.Font.GothamBold; minBtn.TextSize=10; minBtn.ZIndex=5; Instance.new("UICorner",minBtn).CornerRadius=UDim.new(0,4)
    local guiVisible=true; local function toggleVis() guiVisible=not guiVisible; mainFrame.Visible=guiVisible end
    minBtn.MouseButton1Click:Connect(toggleVis); toggleMenuBtn.MouseButton1Click:Connect(toggleVis)

    local sep=Instance.new("Frame",mainFrame); sep.Size=UDim2.new(1,-6,0,1); sep.Position=UDim2.new(0,6,0,20); sep.BackgroundColor3=Color3.fromRGB(130,0,15); sep.BorderSizePixel=0; sep.ZIndex=3

    local scroll=Instance.new("ScrollingFrame",mainFrame); scroll.Size=UDim2.new(1,-8,1,-24); scroll.Position=UDim2.new(0,7,0,22); scroll.BackgroundTransparency=1; scroll.ScrollBarThickness=2; scroll.ScrollBarImageColor3=Color3.fromRGB(255,0,50); scroll.BorderSizePixel=0; scroll.ZIndex=2; scroll.CanvasSize=UDim2.new(0,0,0,0)
    local ll=Instance.new("UIListLayout",scroll); ll.Padding=UDim.new(0,0); ll.SortOrder=Enum.SortOrder.LayoutOrder
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+8) end)

    local lo=0; local function nlo() lo=lo+1; return lo end

    local function makeSectionHeader(text) local h=Instance.new("Frame",scroll); h.Size=UDim2.new(1,0,0,16); h.BackgroundTransparency=1; h.LayoutOrder=nlo(); local l=Instance.new("TextLabel",h); l.Size=UDim2.new(1,-8,1,0); l.Position=UDim2.new(0,8,0,0); l.BackgroundTransparency=1; l.Text=text; l.Font=Enum.Font.GothamBlack; l.TextSize=8; l.TextColor3=Color3.fromRGB(255,20,55); l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=3 end
    local function makeToggleRow(label,defaultState,onToggle) local row=Instance.new("Frame",scroll); row.Size=UDim2.new(1,0,0,28); row.BackgroundColor3=Color3.fromRGB(18,18,24); row.BorderSizePixel=0; row.LayoutOrder=nlo(); row.ZIndex=2; local div=Instance.new("Frame",row); div.Size=UDim2.new(1,-6,0,1); div.Position=UDim2.new(0,3,1,-1); div.BackgroundColor3=Color3.fromRGB(30,30,40); div.BorderSizePixel=0; div.ZIndex=3; local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0.62,0,1,0); lbl.Position=UDim2.new(0,8,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.Font=Enum.Font.GothamSemibold; lbl.TextSize=10; lbl.TextColor3=Color3.fromRGB(215,215,215); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=3; local tBg=Instance.new("Frame",row); tBg.Size=UDim2.new(0,28,0,15); tBg.Position=UDim2.new(1,-32,0.5,-7); tBg.BackgroundColor3=defaultState and Color3.fromRGB(255,0,50) or Color3.fromRGB(45,45,58); tBg.ZIndex=3; Instance.new("UICorner",tBg).CornerRadius=UDim.new(1,0); local tCirc=Instance.new("Frame",tBg); tCirc.Size=UDim2.new(0,10,0,10); tCirc.Position=defaultState and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5); tCirc.BackgroundColor3=Color3.new(1,1,1); tCirc.ZIndex=4; Instance.new("UICorner",tCirc).CornerRadius=UDim.new(1,0); local click=Instance.new("TextButton",row); click.Size=UDim2.new(1,0,1,0); click.BackgroundTransparency=1; click.Text=""; click.ZIndex=5; local isOn=defaultState; local function setVis(state) isOn=state; tBg.BackgroundColor3=isOn and Color3.fromRGB(255,0,50) or Color3.fromRGB(45,45,58); tCirc.Position=isOn and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5) end; toggleSetters[label]=setVis; click.MouseButton1Click:Connect(function() isOn=not isOn; setVis(isOn); if onToggle then onToggle(isOn) end end); return setVis end
    local function makeValueRow(label,defaultVal,onChanged) local row=Instance.new("Frame",scroll); row.Size=UDim2.new(1,0,0,28); row.BackgroundColor3=Color3.fromRGB(18,18,24); row.BorderSizePixel=0; row.LayoutOrder=nlo(); row.ZIndex=2; local div=Instance.new("Frame",row); div.Size=UDim2.new(1,-6,0,1); div.Position=UDim2.new(0,3,1,-1); div.BackgroundColor3=Color3.fromRGB(30,30,40); div.BorderSizePixel=0; div.ZIndex=3; local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0.6,0,1,0); lbl.Position=UDim2.new(0,8,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.Font=Enum.Font.GothamSemibold; lbl.TextSize=10; lbl.TextColor3=Color3.fromRGB(215,215,215); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=3; local vb=Instance.new("TextBox",row); vb.Size=UDim2.new(0,44,0,16); vb.Position=UDim2.new(1,-48,0.5,-8); vb.BackgroundColor3=Color3.fromRGB(22,22,32); vb.Text=tostring(defaultVal); vb.TextColor3=Color3.fromRGB(200,160,255); vb.Font=Enum.Font.GothamBold; vb.TextSize=10; vb.ClearTextOnFocus=false; vb.ZIndex=4; Instance.new("UICorner",vb).CornerRadius=UDim.new(0,5); Instance.new("UIStroke",vb).Color=Color3.fromRGB(80,0,160); vb.FocusLost:Connect(function() local n=tonumber(vb.Text); if n then if onChanged then onChanged(n,vb) end else vb.Text=tostring(defaultVal) end end); return vb end
    local function makeActionBtn(text,cb) local row=Instance.new("Frame",scroll); row.Size=UDim2.new(1,0,0,28); row.BackgroundColor3=Color3.fromRGB(18,18,24); row.BorderSizePixel=0; row.LayoutOrder=nlo(); row.ZIndex=2; local div=Instance.new("Frame",row); div.Size=UDim2.new(1,-6,0,1); div.Position=UDim2.new(0,3,1,-1); div.BackgroundColor3=Color3.fromRGB(30,30,40); div.BorderSizePixel=0; div.ZIndex=3; local btn=Instance.new("TextButton",row); btn.Size=UDim2.new(1,-12,0,17); btn.Position=UDim2.new(0,6,0.5,-8); btn.BackgroundColor3=Color3.fromRGB(28,28,38); btn.Text=text; btn.TextColor3=Color3.fromRGB(215,215,215); btn.Font=Enum.Font.GothamBold; btn.TextSize=10; btn.ZIndex=3; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7); Instance.new("UIStroke",btn).Color=Color3.fromRGB(60,60,80); btn.MouseButton1Click:Connect(function() if cb then cb(btn) end end); return btn end
    local function makeKeybindRow(label,kbKey) local row=Instance.new("Frame",scroll); row.Size=UDim2.new(1,0,0,28); row.BackgroundColor3=Color3.fromRGB(18,18,24); row.BorderSizePixel=0; row.LayoutOrder=nlo(); row.ZIndex=2; local div=Instance.new("Frame",row); div.Size=UDim2.new(1,-6,0,1); div.Position=UDim2.new(0,3,1,-1); div.BackgroundColor3=Color3.fromRGB(30,30,40); div.BorderSizePixel=0; div.ZIndex=3; local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0.55,0,1,0); lbl.Position=UDim2.new(0,8,0,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.Font=Enum.Font.GothamSemibold; lbl.TextSize=9; lbl.TextColor3=Color3.fromRGB(200,200,200); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=3; local kbBtn=Instance.new("TextButton",row); kbBtn.Size=UDim2.new(0,60,0,16); kbBtn.Position=UDim2.new(1,-64,0.5,-8); kbBtn.BackgroundColor3=Color3.fromRGB(22,22,32); kbBtn.Text=(Keybinds[kbKey] and Keybinds[kbKey]~=Enum.KeyCode.Unknown) and Keybinds[kbKey].Name or "—"; kbBtn.TextColor3=Color3.fromRGB(255,255,255); kbBtn.Font=Enum.Font.GothamBold; kbBtn.TextSize=8; kbBtn.ZIndex=4; Instance.new("UICorner",kbBtn).CornerRadius=UDim.new(0,4); Instance.new("UIStroke",kbBtn).Color=Color3.fromRGB(80,0,160); local waiting=false; kbBtn.MouseButton1Click:Connect(function() if waiting then return end; waiting=true; kbBtn.Text="..."; local con; con=UserInputService.InputBegan:Connect(function(inp,gpe) if gpe then return end; if inp.KeyCode~=Enum.KeyCode.Unknown then Keybinds[kbKey]=inp.KeyCode; kbBtn.Text=inp.KeyCode.Name; waiting=false; con:Disconnect(); saveConfig() end end) end) end

    -- ── LAYOUT ──
    makeSectionHeader("MOVEMENT")
    makeToggleRow("Spin Bot",spinBotEnabled,function(s) spinBotEnabled=s; if s then startSpin() else stopSpin() end; saveConfig() end)
    makeValueRow("Spin Speed",SPIN_SPEED,function(v) SPIN_SPEED=math.clamp(v,1,200); if spinBAV then spinBAV.AngularVelocity=Vector3.new(0,SPIN_SPEED,0) end; saveConfig() end)
    makeToggleRow("Infinite Jump",infJumpEnabled,function(s) infJumpEnabled=s; saveConfig() end)
    makeToggleRow("Anti Ragdoll",antiRagdollEnabled,function(s) antiRagdollEnabled=s; if s then startAntiRagdoll() else stopAntiRagdoll() end; saveConfig() end)
    makeToggleRow("Unwalk",unwalkEnabled,function(s) unwalkEnabled=s; if s then startUnwalk() else stopUnwalk() end; saveConfig() end)
    makeToggleRow("Good Animation",goodAnimEnabled,function(s) goodAnimEnabled=s; if s then startGoodAnim() else stopGoodAnim() end; saveConfig() end)
    makeToggleRow("Carry SPD",slowDownEnabled,function(s) slowDownEnabled=s; saveConfig() end)
    local normalSpeedBox=makeValueRow("Normal Speed",NORMAL_SPEED,function(v) NORMAL_SPEED=math.clamp(v,1,300); saveConfig() end)
    local carrySpeedBox=makeValueRow("Carry SPD Value",SLOW_SPEED,function(v) SLOW_SPEED=math.clamp(v,1,300); saveConfig() end)
    makeToggleRow("Desync Mode",desyncEnabled,function(s)
        desyncEnabled=s
        if normalSpeedBox then normalSpeedBox.Text=s and tostring(DESYNC_NORMAL) or tostring(NORMAL_SPEED); normalSpeedBox.TextColor3=s and Color3.fromRGB(255,180,80) or Color3.fromRGB(200,160,255) end
        if carrySpeedBox then carrySpeedBox.Text=s and tostring(DESYNC_CARRY) or tostring(SLOW_SPEED); carrySpeedBox.TextColor3=s and Color3.fromRGB(255,180,80) or Color3.fromRGB(200,160,255) end
        saveConfig()
    end)

    makeSectionHeader("AUTOMATION")
    makeToggleRow("Lock",batAimbotEnabled,function(s)
        if s then
            if aplOn then stopAutoPlayLeft(); if toggleSetters["Play Left"] then toggleSetters["Play Left"](false) end end
            if aprOn then stopAutoPlayRight(); if toggleSetters["Play Right"] then toggleSetters["Play Right"](false) end end
            if autoLOn then stopAutoL(); if toggleSetters["Auto Left"] then toggleSetters["Auto Left"](false) end end
            if autoROn then stopAutoR(); if toggleSetters["Auto Right"] then toggleSetters["Auto Right"](false) end end
            startBatAimbot()
        else stopBatAimbot() end
        saveConfig()
    end)
    makeToggleRow("Auto Steal",autoStealEnabled,function(s) autoStealEnabled=s; if s then startAutoSteal() else stopAutoSteal() end; saveConfig() end)
    makeValueRow("Grab Time (s)",STEAL_DURATION,function(v) STEAL_DURATION=math.clamp(v,0.05,10); saveConfig() end)
    makeValueRow("Steal Radius",STEAL_RADIUS,function(v) STEAL_RADIUS=math.clamp(v,1,300); saveConfig() end)
    makeToggleRow("Auto Left",false,function(s) if s then if batAimbotEnabled then stopBatAimbot(); if toggleSetters["Lock"] then toggleSetters["Lock"](false) end end; if aprOn then stopAutoPlayRight(); if toggleSetters["Play Right"] then toggleSetters["Play Right"](false) end end; if autoROn then stopAutoR(); if toggleSetters["Auto Right"] then toggleSetters["Auto Right"](false) end end; if aplOn then stopAutoPlayLeft(); if toggleSetters["Play Left"] then toggleSetters["Play Left"](false) end end; autoLOn=true; startAutoL() else autoLOn=false; stopAutoL() end end)
    makeToggleRow("Auto Right",false,function(s) if s then if batAimbotEnabled then stopBatAimbot(); if toggleSetters["Lock"] then toggleSetters["Lock"](false) end end; if aplOn then stopAutoPlayLeft(); if toggleSetters["Play Left"] then toggleSetters["Play Left"](false) end end; if autoLOn then stopAutoL(); if toggleSetters["Auto Left"] then toggleSetters["Auto Left"](false) end end; if aprOn then stopAutoPlayRight(); if toggleSetters["Play Right"] then toggleSetters["Play Right"](false) end end; autoROn=true; startAutoR() else autoROn=false; stopAutoR() end end)
    makeToggleRow("Play Left",false,function(s) if s then if batAimbotEnabled then stopBatAimbot(); if toggleSetters["Lock"] then toggleSetters["Lock"](false) end end; if aprOn then stopAutoPlayRight(); if toggleSetters["Play Right"] then toggleSetters["Play Right"](false) end end; if autoLOn then stopAutoL(); if toggleSetters["Auto Left"] then toggleSetters["Auto Left"](false) end end; if autoROn then stopAutoR(); if toggleSetters["Auto Right"] then toggleSetters["Auto Right"](false) end end; aplOn=true; startAutoPlayLeft() else aplOn=false; stopAutoPlayLeft() end end)
    makeToggleRow("Play Right",false,function(s) if s then if batAimbotEnabled then stopBatAimbot(); if toggleSetters["Lock"] then toggleSetters["Lock"](false) end end; if aplOn then stopAutoPlayLeft(); if toggleSetters["Play Left"] then toggleSetters["Play Left"](false) end end; if autoLOn then stopAutoL(); if toggleSetters["Auto Left"] then toggleSetters["Auto Left"](false) end end; if autoROn then stopAutoR(); if toggleSetters["Auto Right"] then toggleSetters["Auto Right"](false) end end; aprOn=true; startAutoPlayRight() else aprOn=false; stopAutoPlayRight() end end)

    makeSectionHeader("DEFENSE")
    do
        local row=Instance.new("Frame",scroll); row.Size=UDim2.new(1,0,0,28); row.BackgroundColor3=Color3.fromRGB(18,18,24); row.BorderSizePixel=0; row.LayoutOrder=nlo(); row.ZIndex=2
        local div=Instance.new("Frame",row); div.Size=UDim2.new(1,-6,0,1); div.Position=UDim2.new(0,3,1,-1); div.BackgroundColor3=Color3.fromRGB(30,30,40); div.BorderSizePixel=0; div.ZIndex=3
        local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0,72,1,0); lbl.Position=UDim2.new(0,8,0,0); lbl.BackgroundTransparency=1; lbl.Text="Brainrot Def"; lbl.Font=Enum.Font.GothamSemibold; lbl.TextSize=9; lbl.TextColor3=Color3.fromRGB(215,215,215); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=3
        local sideBtn=Instance.new("TextButton",row); sideBtn.Size=UDim2.new(0,34,0,15); sideBtn.Position=UDim2.new(1,-72,0.5,-7); sideBtn.BackgroundColor3=Color3.fromRGB(30,10,60); sideBtn.Text=brainrotDefenseSide=="left" and "LEFT" or "RIGHT"; sideBtn.TextColor3=Color3.fromRGB(200,140,255); sideBtn.Font=Enum.Font.GothamBold; sideBtn.TextSize=7; sideBtn.BorderSizePixel=0; sideBtn.ZIndex=6; Instance.new("UICorner",sideBtn).CornerRadius=UDim.new(0,4); Instance.new("UIStroke",sideBtn).Color=Color3.fromRGB(220,0,30)
        sideBtn.MouseButton1Click:Connect(function() brainrotDefenseSide=brainrotDefenseSide=="left" and "right" or "left"; sideBtn.Text=brainrotDefenseSide=="left" and "LEFT" or "RIGHT"; saveConfig() end)
        local tBg=Instance.new("Frame",row); tBg.Size=UDim2.new(0,28,0,15); tBg.Position=UDim2.new(1,-32,0.5,-7); tBg.BackgroundColor3=brainrotDefenseEnabled and Color3.fromRGB(255,0,50) or Color3.fromRGB(45,45,58); tBg.ZIndex=3; Instance.new("UICorner",tBg).CornerRadius=UDim.new(1,0)
        local tCirc=Instance.new("Frame",tBg); tCirc.Size=UDim2.new(0,10,0,10); tCirc.Position=brainrotDefenseEnabled and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5); tCirc.BackgroundColor3=Color3.new(1,1,1); tCirc.ZIndex=4; Instance.new("UICorner",tCirc).CornerRadius=UDim.new(1,0)
        local isOn=brainrotDefenseEnabled; local function setVis(state) isOn=state; tBg.BackgroundColor3=isOn and Color3.fromRGB(255,0,50) or Color3.fromRGB(45,45,58); tCirc.Position=isOn and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5) end; toggleSetters["Brainrot Defense"]=setVis
        local click=Instance.new("TextButton",row); click.Size=UDim2.new(0,36,1,0); click.Position=UDim2.new(1,-38,0,0); click.BackgroundTransparency=1; click.Text=""; click.ZIndex=5
        click.MouseButton1Click:Connect(function() isOn=not isOn; setVis(isOn); brainrotDefenseEnabled=isOn; if isOn then startBrainrotDefense() else stopBrainrotDefense() end; saveConfig() end)
    end
    makeToggleRow("Medusa Counter",medusaCounterEnabled,function(s) medusaCounterEnabled=s; if s then setupMedusaCounter(player.Character) else stopMedusaCounter() end; saveConfig() end)

    makeSectionHeader("ACTIONS")
    makeActionBtn("DROP",function() task.spawn(doDrop) end)
    makeActionBtn("TP DOWN",function() task.spawn(doTPDown) end)

    makeSectionHeader("WORLD & VISUALS")
    makeToggleRow("Player ESP",espEnabled,function(s) espEnabled=s; if s then enableESP() else disableESP() end; saveConfig() end)
    makeToggleRow("Galaxy Mode",galaxyEnabled,function(s) galaxyEnabled=s; if s then startGalaxy() else stopGalaxy() end; saveConfig() end)
    makeValueRow("Gravity %",GALAXY_GRAVITY,function(v) GALAXY_GRAVITY=math.clamp(v,1,300); saveConfig() end)
    makeValueRow("Hop Power",GALAXY_HOP,function(v) GALAXY_HOP=math.clamp(v,1,200); saveConfig() end)
    makeToggleRow("Optimizer+XRay",optimizerEnabled,function(s) optimizerEnabled=s; if s then enableOptimizer() else disableOptimizer() end; saveConfig() end)
    makeValueRow("Field of View",fovValue,function(v) fovValue=math.clamp(v,10,120); applyFOV(); saveConfig() end)

    makeSectionHeader("SETTINGS")
    makeToggleRow("Auto Save Config",autoSaveEnabled,function(s) autoSaveEnabled=s; saveConfig() end)
    makeActionBtn("Save Config",function(btn) saveConfig(); btn.Text="Saved"; btn.TextColor3=Color3.fromRGB(80,220,120); task.delay(1.5,function() btn.Text="Save Config"; btn.TextColor3=Color3.fromRGB(215,215,215) end) end)

    makeSectionHeader("KEYBINDS")
    makeKeybindRow("Play Left","AutoLeft"); makeKeybindRow("Play Right","AutoRight"); makeKeybindRow("Lock","BatAimbot")
    makeKeybindRow("Auto Left","MobAutoL"); makeKeybindRow("Auto Right","MobAutoR")
    makeKeybindRow("Carry SPD","CarrySpd"); makeKeybindRow("Drop","Drop"); makeKeybindRow("TP Down","TPDown")
    makeKeybindRow("Auto Steal","AutoSteal"); makeKeybindRow("Anti Ragdoll","AntiRagdoll"); makeKeybindRow("Unwalk","Unwalk")

    -- ====================== PROGRESS BAR (draggable) ======================
    local PBC=Instance.new("Frame",PBGui)
    PBC.Size=UDim2.new(0,196,0,36); PBC.Position=UDim2.new(0.5,-98,1,-110)
    PBC.BackgroundColor3=Color3.fromRGB(8,8,12); PBC.BackgroundTransparency=0.1; PBC.BorderSizePixel=0; PBC.Active=true
    Instance.new("UICorner",PBC).CornerRadius=UDim.new(0,11)
    local pbs=Instance.new("UIStroke",PBC); pbs.Color=Color3.fromRGB(255,0,50); pbs.Thickness=1.5
    local bloodHubText=Instance.new("TextLabel",PBC); bloodHubText.Size=UDim2.new(0.38,0,0.55,0); bloodHubText.Position=UDim2.new(0.62,0,0,3); bloodHubText.BackgroundTransparency=1; bloodHubText.Text="BLOOD HUB"; bloodHubText.TextColor3=Color3.fromRGB(255,255,255); bloodHubText.Font=Enum.Font.GothamBlack; bloodHubText.TextSize=11; bloodHubText.TextXAlignment=Enum.TextXAlignment.Right; bloodHubText.ZIndex=3
    ProgressLabel=Instance.new("TextLabel",PBC); ProgressLabel.Size=UDim2.new(0.55,0,0.55,0); ProgressLabel.Position=UDim2.new(0,8,0,3); ProgressLabel.BackgroundTransparency=1; ProgressLabel.Text="READY"; ProgressLabel.TextColor3=Color3.fromRGB(220,220,220); ProgressLabel.Font=Enum.Font.GothamBold; ProgressLabel.TextSize=10; ProgressLabel.TextXAlignment=Enum.TextXAlignment.Left; ProgressLabel.ZIndex=3
    ProgressPctLabel=Instance.new("TextLabel",PBC); ProgressPctLabel.Size=UDim2.new(0,0,0,0); ProgressPctLabel.Visible=false
    local pt=Instance.new("Frame",PBC); pt.Size=UDim2.new(0.9,0,0,5); pt.Position=UDim2.new(0.05,0,1,-10); pt.BackgroundColor3=Color3.fromRGB(15,2,2); pt.BorderSizePixel=0; pt.ZIndex=2; Instance.new("UICorner",pt).CornerRadius=UDim.new(1,0)
    ProgressBarFill=Instance.new("Frame",pt); ProgressBarFill.Size=UDim2.new(0,0,1,0); ProgressBarFill.BackgroundColor3=Color3.fromRGB(255,0,50); ProgressBarFill.BorderSizePixel=0; ProgressBarFill.ZIndex=3; Instance.new("UICorner",ProgressBarFill).CornerRadius=UDim.new(1,0)
    -- drag logic for steal radius bar
    do
        local pbDragging=false; local pbDragStart=nil; local pbFrameStart=nil
        PBC.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                pbDragging=true
                pbDragStart=Vector2.new(inp.Position.X,inp.Position.Y)
                pbFrameStart=Vector2.new(PBC.Position.X.Offset,PBC.Position.Y.Offset)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                pbDragging=false; pbDragStart=nil; pbFrameStart=nil
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if not pbDragging or not pbDragStart then return end
            if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
                local dx=inp.Position.X-pbDragStart.X; local dy=inp.Position.Y-pbDragStart.Y
                if math.abs(dx)>2 or math.abs(dy)>2 then
                    PBC.Position=UDim2.new(PBC.Position.X.Scale,pbFrameStart.X+dx,PBC.Position.Y.Scale,pbFrameStart.Y+dy)
                end
            end
        end)
    end

    -- ====================== MOBILE PANEL (draggable, smooth) ======================
    local PURPLE_ON=Color3.fromRGB(200,0,25); local BLACK_OFF=Color3.fromRGB(8,8,8)
    local panelGui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui")); panelGui.Name="BloodHub_MobilePanel"; panelGui.ResetOnSpawn=false; panelGui.IgnoreGuiInset=true; panelGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; panelGui.DisplayOrder=8

    local panelFrame=Instance.new("Frame",panelGui); panelFrame.Name="MobilePanel"; panelFrame.Size=UDim2.new(0,120,0,232); panelFrame.Position=UDim2.new(1,-128,0.5,-116); panelFrame.BackgroundColor3=Color3.fromRGB(4,4,6); panelFrame.BackgroundTransparency=0.05; panelFrame.BorderSizePixel=0; panelFrame.Active=true; panelFrame.ZIndex=20
    Instance.new("UICorner",panelFrame).CornerRadius=UDim.new(0,14)
    local psk=Instance.new("UIStroke",panelFrame); psk.Color=Color3.fromRGB(90,5,5); psk.Thickness=1.2; psk.Transparency=0.3

    -- smooth drag: track finger/mouse separately from button clicks using a dedicated invisible drag zone
    local pDragging=false; local pDragStart=nil; local pFrameStart=nil
    -- we use UserInputService globally so touch doesn't get eaten by buttons
    local panelDragConn1=panelFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            -- only start drag if not hitting a child button (buttons have ZIndex 22, frame is 20)
            -- we check by seeing if the input hit the frame directly via position guard
            pDragging=true
            pDragStart=Vector2.new(inp.Position.X,inp.Position.Y)
            pFrameStart=Vector2.new(panelFrame.Position.X.Offset,panelFrame.Position.Y.Offset)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            pDragging=false; pDragStart=nil; pFrameStart=nil
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not pDragging or not pDragStart then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            local dx=inp.Position.X-pDragStart.X; local dy=inp.Position.Y-pDragStart.Y
            -- only move if significant drag distance, preventing accidental drags from button taps
            if math.abs(dx)>2 or math.abs(dy)>2 then
                panelFrame.Position=UDim2.new(panelFrame.Position.X.Scale,pFrameStart.X+dx,panelFrame.Position.Y.Scale,pFrameStart.Y+dy)
            end
        end
    end)

    local panelTitle=Instance.new("TextLabel",panelFrame); panelTitle.Size=UDim2.new(1,-4,0,12); panelTitle.Position=UDim2.new(0,2,0,2); panelTitle.BackgroundTransparency=1; panelTitle.Text="BLOOD HUB"; panelTitle.Font=Enum.Font.LuckiestGuy; panelTitle.TextSize=8; panelTitle.TextColor3=Color3.fromRGB(255,0,50); panelTitle.TextXAlignment=Enum.TextXAlignment.Center; panelTitle.ZIndex=26
    task.spawn(function() local t=0; while panelTitle and panelTitle.Parent do t=t+0.05; local p=(math.sin(t*2)+1)/2; panelTitle.TextColor3=Color3.fromRGB(255,math.floor(p*30),math.floor(p*30)); task.wait(0.05) end end)

    local btnGrid=Instance.new("Frame",panelFrame); btnGrid.Size=UDim2.new(1,-8,0,212); btnGrid.Position=UDim2.new(0,4,0,15); btnGrid.BackgroundTransparency=1; btnGrid.ZIndex=21
    local gl=Instance.new("UIGridLayout",btnGrid); gl.CellSize=UDim2.new(0.5,-3,0,50); gl.CellPadding=UDim2.new(0,5,0,4); gl.SortOrder=Enum.SortOrder.LayoutOrder; gl.FillDirectionMaxCells=2

    local function makePBtn(l1,l2,order)
        local btn=Instance.new("TextButton",btnGrid); btn.LayoutOrder=order; btn.Size=UDim2.new(0,1,0,1); btn.BackgroundColor3=BLACK_OFF; btn.BackgroundTransparency=0; btn.BorderSizePixel=0; btn.Text=""; btn.ZIndex=22
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
        local bs=Instance.new("UIStroke",btn); bs.Color=Color3.fromRGB(40,40,50); bs.Thickness=1; bs.Transparency=0.2
        local t1=Instance.new("TextLabel",btn); t1.Size=UDim2.new(1,0,0.52,0); t1.Position=UDim2.new(0,0,0.06,0); t1.BackgroundTransparency=1; t1.Text=l1; t1.TextColor3=Color3.fromRGB(255,255,255); t1.Font=Enum.Font.GothamBlack; t1.TextSize=10; t1.TextXAlignment=Enum.TextXAlignment.Center; t1.ZIndex=23
        local t2=Instance.new("TextLabel",btn); t2.Size=UDim2.new(1,0,0.44,0); t2.Position=UDim2.new(0,0,0.52,0); t2.BackgroundTransparency=1; t2.Text=l2; t2.TextColor3=Color3.fromRGB(255,255,255); t2.Font=Enum.Font.GothamBlack; t2.TextSize=10; t2.TextXAlignment=Enum.TextXAlignment.Center; t2.ZIndex=23
        -- stop drag from firing when a button is tapped
        btn.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                pDragging=false
            end
        end)
        return btn,bs
    end

    local function setPH(btn,bs,isOn) btn.BackgroundColor3=isOn and PURPLE_ON or BLACK_OFF; bs.Color=isOn and Color3.fromRGB(255,20,50) or Color3.fromRGB(40,40,50); bs.Transparency=isOn and 0 or 0.2 end

    local btnAAL,bsAAL=makePBtn("AUTO","L",1); local btnAAR,bsAAR=makePBtn("AUTO","R",2)
    local btnPL,bsPL=makePBtn("PLAY","L",3); local btnPR,bsPR=makePBtn("PLAY","R",4)
    local btnDR,bsDR=makePBtn("DROP","",5); local btnTP,bsTP=makePBtn("TP","DOWN",6)
    local btnLK,bsLK=makePBtn("LOCK","",7); local btnCS,bsCS=makePBtn("CARRY","SPD",8)

    local pState={AAL=false,AAR=false,PL=false,PR=false,LK=false,CS=slowDownEnabled}
    mobBtnRefs["AUTO L"]={btn=btnAAL,bs=bsAAL,state=false}; mobBtnRefs["AUTO R"]={btn=btnAAR,bs=bsAAR,state=false}
    mobBtnRefs["PLAY L"]={btn=btnPL,bs=bsPL,state=false}; mobBtnRefs["PLAY R"]={btn=btnPR,bs=bsPR,state=false}
    if pState.CS then setPH(btnCS,bsCS,true) end

    local function mutualOff(keep)
        local map={AAL={btnAAL,bsAAL},AAR={btnAAR,bsAAR},PL={btnPL,bsPL},PR={btnPR,bsPR},LK={btnLK,bsLK}}
        for k,v in pairs(map) do if k~=keep and pState[k] then pState[k]=false; setPH(v[1],v[2],false); if k=="AAL" then autoLOn=false; stopAutoL(); if toggleSetters["Auto Left"] then toggleSetters["Auto Left"](false) end elseif k=="AAR" then autoROn=false; stopAutoR(); if toggleSetters["Auto Right"] then toggleSetters["Auto Right"](false) end elseif k=="PL" then aplOn=false; stopAutoPlayLeft(); if toggleSetters["Play Left"] then toggleSetters["Play Left"](false) end elseif k=="PR" then aprOn=false; stopAutoPlayRight(); if toggleSetters["Play Right"] then toggleSetters["Play Right"](false) end elseif k=="LK" then stopBatAimbot(); if toggleSetters["Lock"] then toggleSetters["Lock"](false) end end end end
    end

    btnAAL.MouseButton1Click:Connect(function() local ns=not pState.AAL; if ns then mutualOff("AAL") end; pState.AAL=ns; setPH(btnAAL,bsAAL,ns); mobBtnRefs["AUTO L"].state=ns; if toggleSetters["Auto Left"] then toggleSetters["Auto Left"](ns) end; if ns then autoLOn=true; startAutoL() else autoLOn=false; stopAutoL() end end)
    btnAAR.MouseButton1Click:Connect(function() local ns=not pState.AAR; if ns then mutualOff("AAR") end; pState.AAR=ns; setPH(btnAAR,bsAAR,ns); mobBtnRefs["AUTO R"].state=ns; if toggleSetters["Auto Right"] then toggleSetters["Auto Right"](ns) end; if ns then autoROn=true; startAutoR() else autoROn=false; stopAutoR() end end)
    btnPL.MouseButton1Click:Connect(function() local ns=not pState.PL; if ns then mutualOff("PL") end; pState.PL=ns; setPH(btnPL,bsPL,ns); mobBtnRefs["PLAY L"].state=ns; if toggleSetters["Play Left"] then toggleSetters["Play Left"](ns) end; if ns then aplOn=true; startAutoPlayLeft() else aplOn=false; stopAutoPlayLeft() end end)
    btnPR.MouseButton1Click:Connect(function() local ns=not pState.PR; if ns then mutualOff("PR") end; pState.PR=ns; setPH(btnPR,bsPR,ns); mobBtnRefs["PLAY R"].state=ns; if toggleSetters["Play Right"] then toggleSetters["Play Right"](ns) end; if ns then aprOn=true; startAutoPlayRight() else aprOn=false; stopAutoPlayRight() end end)
    btnDR.MouseButton1Click:Connect(function() setPH(btnDR,bsDR,true); task.delay(0.35,function() setPH(btnDR,bsDR,false) end); task.spawn(doDrop) end)
    btnTP.MouseButton1Click:Connect(function() setPH(btnTP,bsTP,true); task.delay(0.35,function() setPH(btnTP,bsTP,false) end); task.spawn(doTPDown) end)
    btnLK.MouseButton1Click:Connect(function() local ns=not pState.LK; if ns then mutualOff("LK") end; pState.LK=ns; setPH(btnLK,bsLK,ns); if toggleSetters["Lock"] then toggleSetters["Lock"](ns) end; if ns then startBatAimbot() else stopBatAimbot() end end)
    btnCS.MouseButton1Click:Connect(function() local ns=not pState.CS; pState.CS=ns; setPH(btnCS,bsCS,ns); slowDownEnabled=ns; if toggleSetters["Carry SPD"] then toggleSetters["Carry SPD"](ns) end end)

    -- ====================== KEYBIND INPUT ======================
    -- Only fires for non-Unknown keycodes, preventing unbound keys from triggering anything
    UserInputService.InputBegan:Connect(function(input,processed)
        if processed then return end
        local kc=input.KeyCode
        if kc==Enum.KeyCode.Unknown then return end  -- hard guard: Unknown never triggers anything
        if kc==Keybinds.AutoLeft then
            local ns=not pState.PL; if ns then mutualOff("PL") end; pState.PL=ns; setPH(btnPL,bsPL,ns); if toggleSetters["Play Left"] then toggleSetters["Play Left"](ns) end; if ns then aplOn=true; startAutoPlayLeft() else aplOn=false; stopAutoPlayLeft() end
        elseif kc==Keybinds.AutoRight then
            local ns=not pState.PR; if ns then mutualOff("PR") end; pState.PR=ns; setPH(btnPR,bsPR,ns); if toggleSetters["Play Right"] then toggleSetters["Play Right"](ns) end; if ns then aprOn=true; startAutoPlayRight() else aprOn=false; stopAutoPlayRight() end
        elseif kc==Keybinds.MobAutoL and Keybinds.MobAutoL~=Enum.KeyCode.Unknown then
            local ns=not pState.AAL; if ns then mutualOff("AAL") end; pState.AAL=ns; setPH(btnAAL,bsAAL,ns); mobBtnRefs["AUTO L"].state=ns; if toggleSetters["Auto Left"] then toggleSetters["Auto Left"](ns) end; if ns then autoLOn=true; startAutoL() else autoLOn=false; stopAutoL() end
        elseif kc==Keybinds.MobAutoR and Keybinds.MobAutoR~=Enum.KeyCode.Unknown then
            local ns=not pState.AAR; if ns then mutualOff("AAR") end; pState.AAR=ns; setPH(btnAAR,bsAAR,ns); mobBtnRefs["AUTO R"].state=ns; if toggleSetters["Auto Right"] then toggleSetters["Auto Right"](ns) end; if ns then autoROn=true; startAutoR() else autoROn=false; stopAutoR() end
        elseif kc==Keybinds.BatAimbot then
            local ns=not pState.LK; if ns then mutualOff("LK") end; pState.LK=ns; setPH(btnLK,bsLK,ns); if toggleSetters["Lock"] then toggleSetters["Lock"](ns) end; if ns then startBatAimbot() else stopBatAimbot() end
        elseif kc==Keybinds.CarrySpd then
            local ns=not pState.CS; pState.CS=ns; setPH(btnCS,bsCS,ns); slowDownEnabled=ns; if toggleSetters["Carry SPD"] then toggleSetters["Carry SPD"](ns) end
        elseif kc==Keybinds.Drop then task.spawn(doDrop)
        elseif kc==Keybinds.TPDown then task.spawn(doTPDown)
        elseif kc==Keybinds.AutoSteal then autoStealEnabled=not autoStealEnabled; if autoStealEnabled then startAutoSteal() else stopAutoSteal() end; if toggleSetters["Auto Steal"] then toggleSetters["Auto Steal"](autoStealEnabled) end; saveConfig()
        elseif kc==Keybinds.AntiRagdoll then antiRagdollEnabled=not antiRagdollEnabled; if antiRagdollEnabled then startAntiRagdoll() else stopAntiRagdoll() end; if toggleSetters["Anti Ragdoll"] then toggleSetters["Anti Ragdoll"](antiRagdollEnabled) end; saveConfig()
        elseif kc==Keybinds.Unwalk then unwalkEnabled=not unwalkEnabled; if unwalkEnabled then startUnwalk() else stopUnwalk() end; if toggleSetters["Unwalk"] then toggleSetters["Unwalk"](unwalkEnabled) end; saveConfig() end
    end)

    if espEnabled then enableESP() end
    applyFOV()
    if brainrotDefenseEnabled then startBrainrotDefense() end
    if spinBotEnabled then startSpin() end
    if antiRagdollEnabled then startAntiRagdoll() end
    if unwalkEnabled then startUnwalk() end
    if batAimbotEnabled then startBatAimbot() end
    if autoStealEnabled then startAutoSteal() end
    if galaxyEnabled then startGalaxy() end
    if optimizerEnabled then enableOptimizer() end
    if goodAnimEnabled then task.spawn(startGoodAnim) end
    if medusaCounterEnabled then task.spawn(function() task.wait(1); setupMedusaCounter(player.Character) end) end

    print("Blood Hub loaded.")
end)
