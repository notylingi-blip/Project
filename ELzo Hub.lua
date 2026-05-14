-- ELzo Hub
-- LocalScript > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================================
-- CONFIG AUTO SAVE
-- ============================================================
local CONFIG_FILE = "ELzoHubConfig.json"
local _isfile   = isfile   or function() return false end
local _readfile = readfile  or function() return nil end
local _writefile = writefile or function() end

local defaultConfig = {
    mainPos    = {X=120, Y=10},
    panelPos   = {X=440, Y=10},
    tpStud     = 20,
    keybinds   = {tpUp="E", tpDown="F", drop="H", aimbot="G"},
    panelLocked = false,
    normalSpeed  = 16,
    stealSpeed   = 30,
    aimbotSpeed  = 80,
    laggerSpeed  = 12,
}

local cfg = {}
local function loadConfig()
    local ok, data = pcall(function()
        if _isfile(CONFIG_FILE) then
            return HttpService:JSONDecode(_readfile(CONFIG_FILE))
        end
    end)
    local src = (ok and data) or {}
    for k, v in pairs(defaultConfig) do
        cfg[k] = src[k] ~= nil and src[k] or v
    end
end

local function saveConfig()
    pcall(function() _writefile(CONFIG_FILE, HttpService:JSONEncode(cfg)) end)
end

loadConfig()

-- ============================================================
-- STATE
-- ============================================================
local State = {
    infJumpEnabled     = false,
    antiRagdollEnabled = false,
    batAimbotToggled   = false,
    dropEnabled        = false,
    espEnabled         = false,
    laggerEnabled      = false,
    stealSpeedEnabled  = false,
    antiLagEnabled     = false,
    tpStud             = cfg.tpStud,
    normalSpeed        = cfg.normalSpeed,
    stealSpeed         = cfg.stealSpeed,
    aimbotSpeed        = cfg.aimbotSpeed,
    laggerSpeed        = cfg.laggerSpeed,
    lastMoveDir        = Vector3.new(0,0,0),
}

local MOVE_KEYS = {
    [Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,
    [Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,
    [Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,
    [Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true,
}

local Conns = {antiRag=nil, aimbot=nil, speedLoop=nil}

-- ============================================================
-- HELPER: get humanoid & hrp
-- ============================================================
local function getCharParts()
    local c = LP.Character
    if not c then return nil, nil end
    return c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
-- SPEED BILLBOARD (tulisan speed di atas kepala)
-- ============================================================
local speedBillboard = nil

local function setupSpeedBillboard()
    local c = LP.Character
    if not c then return end
    local head = c:FindFirstChild("Head")
    if not head then return end
    if head:FindFirstChild("ELzoBB") then head:FindFirstChild("ELzoBB"):Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ELzoBB"
    bb.Size = UDim2.new(0, 100, 0, 28)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = false
    bb.Parent = head
    local lbl = Instance.new("TextLabel", bb)
    lbl.Name = "SpeedLbl"
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "0.0"
    lbl.TextColor3 = Color3.fromRGB(220, 180, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.TextStrokeTransparency = 0.1
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
    speedBillboard = bb
end

-- ============================================================
-- SPEED LOOP (dari unknown RenderStepped logic)
-- ============================================================
local function startSpeedLoop()
    if Conns.speedLoop then return end
    Conns.speedLoop = RunService.RenderStepped:Connect(function()
        local hum, hrp = getCharParts()
        if not hum or not hrp then return end

        -- Update speed billboard
        pcall(function()
            local head = LP.Character and LP.Character:FindFirstChild("Head")
            if head then
                local bb = head:FindFirstChild("ELzoBB")
                local lbl = bb and bb:FindFirstChild("SpeedLbl")
                if lbl then
                    local hspd = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z).Magnitude
                    lbl.Text = string.format("%.1f", hspd)
                end
            end
        end)

        -- Bat aimbot speed - dihandle di startBatAimbot, skip di sini
        if State.batAimbotToggled then return end

        local md = hum.MoveDirection
        local spd
        if State.laggerEnabled then
            spd = State.laggerSpeed
        elseif State.stealSpeedEnabled then
            spd = State.stealSpeed
        else
            return -- normal speed: biarkan engine yang handle
        end

        if md.Magnitude > 0 then
            State.lastMoveDir = md
            hrp.Velocity = Vector3.new(md.X * spd, hrp.Velocity.Y, md.Z * spd)
        elseif State.antiRagdollEnabled and State.lastMoveDir.Magnitude > 0 then
            local anyHeld = false
            for key in pairs(MOVE_KEYS) do
                if UserInputService:IsKeyDown(key) then anyHeld = true; break end
            end
            if anyHeld then
                hrp.Velocity = Vector3.new(State.lastMoveDir.X * spd, hrp.Velocity.Y, State.lastMoveDir.Z * spd)
            end
        end
    end)
end

local function stopSpeedLoop()
    if Conns.speedLoop then Conns.speedLoop:Disconnect(); Conns.speedLoop = nil end
end

-- ============================================================
-- ANTI LAG (dari unknown applyFPSBoost)
-- ============================================================
local antiLagDescConn = nil

local function applyAntiLag()
    pcall(function() setfpscap(999999999) end)
    local function pO(v)
        pcall(function()
            if v:IsA("MeshPart") then
                v.CastShadow = false
                v.RenderFidelity = Enum.RenderFidelity.Performance
            elseif v:IsA("BasePart") then
                v.CastShadow = false
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("SpecialMesh") then
                v.TextureId = ""
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke")
                or v:IsA("Sparkles") or v:IsA("ParticleEmitter")
                or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            elseif v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then
                v:Destroy()
            end
        end)
    end
    for _, v in pairs(workspace:GetDescendants()) do pO(v) end
    pcall(function()
        local L = game:GetService("Lighting")
        for _, v in pairs(L:GetDescendants()) do
            pcall(function()
                if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect")
                    or v:IsA("BlurEffect") or v:IsA("SunRaysEffect")
                    or v:IsA("DepthOfFieldEffect") or v:IsA("Clouds")
                    or v:IsA("PostEffect") or v:IsA("ColorCorrectionEffect") then
                    v:Destroy()
                end
            end)
        end
        pcall(function() sethiddenproperty(game:GetService("Lighting"), "Technology", Enum.Technology.Legacy) end)
        local L2 = game:GetService("Lighting")
        L2.GlobalShadows = false
        L2.FogEnd = 9e9
        L2.Brightness = 0
        local ter = workspace:FindFirstChildOfClass("Terrain")
        if ter then
            ter.WaterReflectance = 0
            ter.WaterWaveSize = 0
            ter.WaterWaveSpeed = 0
        end
    end)
    if antiLagDescConn then antiLagDescConn:Disconnect() end
    antiLagDescConn = workspace.DescendantAdded:Connect(function(v)
        if State.antiLagEnabled then task.spawn(pO, v) end
    end)
end

-- ============================================================
-- ESP
-- ============================================================
local espHighlights = {}
local espConnections = {}
local ESP_COLOR = Color3.fromRGB(180, 0, 255)

local function createHighlight(character)
    local h = Instance.new("Highlight")
    h.Name = "ELzo_ESP"
    h.Adornee = character
    h.FillColor = ESP_COLOR
    h.FillTransparency = 0.35
    h.OutlineColor = ESP_COLOR
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = game:GetService("CoreGui")
    return h
end

local function attachESP(player)
    if player == LP then return end
    local function apply(character)
        if espHighlights[player] then espHighlights[player]:Destroy() end
        espHighlights[player] = createHighlight(character)
    end
    if player.Character then apply(player.Character) end
    local c = player.CharacterAdded:Connect(apply)
    table.insert(espConnections, c)
end

local function enableESP()
    if State.espEnabled then return end
    State.espEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do attachESP(p) end
    table.insert(espConnections, Players.PlayerAdded:Connect(attachESP))
    table.insert(espConnections, Players.PlayerRemoving:Connect(function(p)
        if espHighlights[p] then espHighlights[p]:Destroy(); espHighlights[p] = nil end
    end))
end

local function disableESP()
    if not State.espEnabled then return end
    State.espEnabled = false
    for _, h in pairs(espHighlights) do pcall(function() h:Destroy() end) end
    for _, c in ipairs(espConnections) do pcall(function() c:Disconnect() end) end
    espHighlights = {}
    espConnections = {}
end

-- ============================================================
-- INFINITE JUMP
-- ============================================================
UserInputService.JumpRequest:Connect(function()
    if not State.infJumpEnabled then return end
    local _, hrp = getCharParts()
    if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, 55, hrp.Velocity.Z) end
end)

-- ============================================================
-- ANTI RAGDOLL
-- ============================================================
local function startAntiRagdoll()
    if Conns.antiRag then return end
    Conns.antiRag = RunService.Heartbeat:Connect(function()
        if not State.antiRagdollEnabled then return end
        local hum, root = getCharParts()
        if not hum or not root then return end
        if hum.Health <= 0 then return end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Dead then return end
        if st == Enum.HumanoidStateType.Physics
            or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            pcall(function() workspace.CurrentCamera.CameraSubject = hum end)
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        end
        local c = LP.Character
        if c then
            for _, obj in ipairs(c:GetDescendants()) do
                pcall(function()
                    if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled = true end
                end)
            end
        end
    end)
end

local function stopAntiRagdoll()
    if Conns.antiRag then Conns.antiRag:Disconnect(); Conns.antiRag = nil end
end

-- ============================================================
-- TP DOWN / TP UP
-- ============================================================
local function doTpDown()
    pcall(function()
        local _, root = getCharParts()
        if not root then return end
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {LP.Character}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local res = workspace:Raycast(root.Position, Vector3.new(0,-1000,0), rp)
        if res then
            root.CFrame = CFrame.new(res.Position + Vector3.new(0, root.Size.Y/2+0.5, 0))
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function doTpUp()
    pcall(function()
        local _, root = getCharParts()
        if not root then return end
        root.CFrame = root.CFrame + Vector3.new(0, State.tpStud, 0)
        root.AssemblyLinearVelocity = Vector3.zero
    end)
end

-- ============================================================
-- DROP
-- ============================================================
local _dropConns = {}
local DROP_AUTO_OFF = 0.5

local function stopDropBrainrot()
    State.dropEnabled = false
    for _, c in ipairs(_dropConns) do pcall(function() c:Disconnect() end) end
    _dropConns = {}
end

local function runDropBrainrot()
    if State.dropEnabled then return end
    State.dropEnabled = true
    task.spawn(function()
        local colConn = RunService.Stepped:Connect(function()
            if not State.dropEnabled then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
        table.insert(_dropConns, colConn)
        task.spawn(function()
            while State.dropEnabled do
                RunService.Heartbeat:Wait()
                local _, root = getCharParts()
                if not root then continue end
                local vel = root.Velocity
                root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                RunService.RenderStepped:Wait()
                if root and root.Parent then root.Velocity = vel end
                RunService.Stepped:Wait()
                if root and root.Parent then root.Velocity = vel + Vector3.new(0, 0.1, 0) end
            end
        end)
        task.wait(DROP_AUTO_OFF)
        stopDropBrainrot()
    end)
end

-- ============================================================
-- BAT AIMBOT
-- ============================================================
local function getClosestPlayer()
    local _, root = getCharParts()
    if not root then return nil, math.huge end
    local closest, closestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local pr = p.Character:FindFirstChild("HumanoidRootPart")
            if pr then
                local d = (pr.Position - root.Position).Magnitude
                if d < closestDist then closestDist = d; closest = p end
            end
        end
    end
    return closest, closestDist
end

local function startBatAimbot()
    if Conns.aimbot then return end
    Conns.aimbot = RunService.Heartbeat:Connect(function()
        if not State.batAimbotToggled then return end
        local _, root = getCharParts()
        if not root then return end
        local target = getClosestPlayer()
        if target and target.Character then
            local tr = target.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local fp = tr.Position + tr.CFrame.LookVector * 1.5
                local dir = (fp - root.Position).Unit
                local spd = State.aimbotSpeed
                root.AssemblyLinearVelocity = Vector3.new(dir.X*spd, dir.Y*spd, dir.Z*spd)
            end
        else
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function stopBatAimbot()
    if Conns.aimbot then Conns.aimbot:Disconnect(); Conns.aimbot = nil end
    local _, root = getCharParts()
    if root then root.AssemblyLinearVelocity = Vector3.zero end
end

-- ============================================================
-- GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ELzoHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

local MainScale = Instance.new("UIScale")
MainScale.Scale = 1

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,100,0,30)
ToggleBtn.Position = UDim2.new(0,10,0,10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(55,0,100)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "ELzo Hub"
ToggleBtn.TextColor3 = Color3.fromRGB(220,180,255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.ZIndex = 10
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner",ToggleBtn).CornerRadius = UDim.new(0,8)
local _s = Instance.new("UIStroke",ToggleBtn)
_s.Color = Color3.fromRGB(160,70,255); _s.Thickness = 1.5

-- Main Holder
local MainHolder = Instance.new("Frame")
MainHolder.Size = UDim2.new(0,300,0,620)
MainHolder.Position = UDim2.new(0,cfg.mainPos.X,0,cfg.mainPos.Y)
MainHolder.BackgroundTransparency = 1
MainHolder.Visible = false
MainHolder.Parent = ScreenGui
MainScale.Parent = MainHolder

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1,0,1,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10,0,25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = MainHolder
Instance.new("UICorner",MainFrame).CornerRadius = UDim.new(0,12)
local _mfs = Instance.new("UIStroke",MainFrame)
_mfs.Color = Color3.fromRGB(140,60,255); _mfs.Thickness = 2
local _mfg = Instance.new("UIGradient",MainFrame)
_mfg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(15,0,40)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(28,0,65)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(10,0,30)),
})
_mfg.Rotation = 135

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40,0,80)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner",TitleBar).CornerRadius = UDim.new(0,12)
local _tg = Instance.new("UIGradient",TitleBar)
_tg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(80,0,160)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(30,0,80)),
})
_tg.Rotation = 90

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1,-50,1,0)
TitleLbl.Position = UDim2.new(0,12,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "ELzo Hub"
TitleLbl.TextColor3 = Color3.fromRGB(220,170,255)
TitleLbl.TextSize = 16
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,26,0,26)
CloseBtn.Position = UDim2.new(1,-34,0,7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(100,0,160)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,200,255)
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner",CloseBtn).CornerRadius = UDim.new(0,6)

-- Scroll Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,0,1,-44)
Content.Position = UDim2.new(0,0,0,44)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local CScroll = Instance.new("ScrollingFrame")
CScroll.Size = UDim2.new(1,0,1,0)
CScroll.BackgroundTransparency = 1
CScroll.BorderSizePixel = 0
CScroll.ScrollBarThickness = 3
CScroll.ScrollBarImageColor3 = Color3.fromRGB(120,50,220)
CScroll.CanvasSize = UDim2.new(0,0,0,0)
CScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CScroll.Parent = Content

local CList = Instance.new("UIListLayout")
CList.Padding = UDim.new(0,6)
CList.HorizontalAlignment = Enum.HorizontalAlignment.Center
CList.Parent = CScroll

local CPad = Instance.new("UIPadding")
CPad.PaddingTop = UDim.new(0,8)
CPad.PaddingLeft = UDim.new(0,10)
CPad.PaddingRight = UDim.new(0,10)
CPad.PaddingBottom = UDim.new(0,8)
CPad.Parent = CScroll

-- ========================
-- UI HELPERS
-- ========================
local function sectionLabel(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,15)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(180,120,255)
    l.TextSize = 10
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = CScroll
    return l
end

local toggleRefs = {}
local function createToggle(name, key, cb)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1,0,0,32)
    Row.BackgroundColor3 = Color3.fromRGB(28,0,58)
    Row.BorderSizePixel = 0
    Row.Parent = CScroll
    Instance.new("UICorner",Row).CornerRadius = UDim.new(0,7)
    local rs = Instance.new("UIStroke",Row)
    rs.Color = Color3.fromRGB(100,40,200); rs.Thickness = 1

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1,-54,1,0)
    Lbl.Position = UDim2.new(0,9,0,0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = name
    Lbl.TextColor3 = Color3.fromRGB(200,160,255)
    Lbl.TextSize = 12
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local SBG = Instance.new("Frame")
    SBG.Size = UDim2.new(0,38,0,19)
    SBG.Position = UDim2.new(1,-46,0.5,-9)
    SBG.BackgroundColor3 = Color3.fromRGB(60,60,80)
    SBG.BorderSizePixel = 0
    SBG.Parent = Row
    Instance.new("UICorner",SBG).CornerRadius = UDim.new(1,0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0,13,0,13)
    Knob.Position = UDim2.new(0,3,0.5,-6)
    Knob.BackgroundColor3 = Color3.fromRGB(160,100,255)
    Knob.BorderSizePixel = 0
    Knob.Parent = SBG
    Instance.new("UICorner",Knob).CornerRadius = UDim.new(1,0)

    local on = false
    local function setOn(val)
        on = val
        TweenService:Create(Knob,TweenInfo.new(0.18),{
            Position = on and UDim2.new(1,-16,0.5,-6) or UDim2.new(0,3,0.5,-6),
            BackgroundColor3 = on and Color3.fromRGB(230,190,255) or Color3.fromRGB(160,100,255),
        }):Play()
        TweenService:Create(SBG,TweenInfo.new(0.18),{
            BackgroundColor3 = on and Color3.fromRGB(110,0,210) or Color3.fromRGB(60,60,80),
        }):Play()
    end

    local function toggle()
        on = not on; setOn(on)
        if cb then cb(on) end
    end

    Row.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then toggle() end
    end)
    SBG.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then toggle() end
    end)

    if key then toggleRefs[key] = {setOn=setOn, getOn=function() return on end} end
end

-- Speed input row dengan +/-
local function createSpeedInput(labelText, stateKey, cfgKey, minV, maxV)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1,0,0,32)
    Row.BackgroundColor3 = Color3.fromRGB(28,0,58)
    Row.BorderSizePixel = 0
    Row.Parent = CScroll
    Instance.new("UICorner",Row).CornerRadius = UDim.new(0,7)
    local rs = Instance.new("UIStroke",Row)
    rs.Color = Color3.fromRGB(100,40,200); rs.Thickness = 1

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.48,0,1,0)
    Lbl.Position = UDim2.new(0,9,0,0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = labelText
    Lbl.TextColor3 = Color3.fromRGB(200,160,255)
    Lbl.TextSize = 11
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local BtnM = Instance.new("TextButton")
    BtnM.Size = UDim2.new(0,20,0,20)
    BtnM.Position = UDim2.new(0.5,2,0.5,-10)
    BtnM.BackgroundColor3 = Color3.fromRGB(55,0,105)
    BtnM.Text = "-"
    BtnM.TextColor3 = Color3.fromRGB(220,180,255)
    BtnM.TextSize = 14
    BtnM.Font = Enum.Font.GothamBold
    BtnM.BorderSizePixel = 0
    BtnM.Parent = Row
    Instance.new("UICorner",BtnM).CornerRadius = UDim.new(0,5)

    local ValLbl = Instance.new("TextLabel")
    ValLbl.Size = UDim2.new(0,32,1,0)
    ValLbl.Position = UDim2.new(0.5,24,0,0)
    ValLbl.BackgroundTransparency = 1
    ValLbl.Text = tostring(State[stateKey])
    ValLbl.TextColor3 = Color3.fromRGB(255,230,255)
    ValLbl.TextSize = 12
    ValLbl.Font = Enum.Font.GothamBold
    ValLbl.TextXAlignment = Enum.TextXAlignment.Center
    ValLbl.Parent = Row

    local BtnP = Instance.new("TextButton")
    BtnP.Size = UDim2.new(0,20,0,20)
    BtnP.Position = UDim2.new(0.5,58,0.5,-10)
    BtnP.BackgroundColor3 = Color3.fromRGB(55,0,105)
    BtnP.Text = "+"
    BtnP.TextColor3 = Color3.fromRGB(220,180,255)
    BtnP.TextSize = 14
    BtnP.Font = Enum.Font.GothamBold
    BtnP.BorderSizePixel = 0
    BtnP.Parent = Row
    Instance.new("UICorner",BtnP).CornerRadius = UDim.new(0,5)

    BtnM.MouseButton1Click:Connect(function()
        State[stateKey] = math.max(minV, State[stateKey]-1)
        ValLbl.Text = tostring(State[stateKey])
        cfg[cfgKey] = State[stateKey]; saveConfig()
    end)
    BtnP.MouseButton1Click:Connect(function()
        State[stateKey] = math.min(maxV, State[stateKey]+1)
        ValLbl.Text = tostring(State[stateKey])
        cfg[cfgKey] = State[stateKey]; saveConfig()
    end)
end

-- Scale slider
local function createScaleSlider()
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1,0,0,44)
    Row.BackgroundColor3 = Color3.fromRGB(28,0,58)
    Row.BorderSizePixel = 0
    Row.Parent = CScroll
    Instance.new("UICorner",Row).CornerRadius = UDim.new(0,7)
    local rs = Instance.new("UIStroke",Row)
    rs.Color = Color3.fromRGB(100,40,200); rs.Thickness = 1

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1,-10,0,18)
    Lbl.Position = UDim2.new(0,9,0,2)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "UI Scale: 1.0"
    Lbl.TextColor3 = Color3.fromRGB(200,160,255)
    Lbl.TextSize = 11
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1,-18,0,5)
    Track.Position = UDim2.new(0,9,0,28)
    Track.BackgroundColor3 = Color3.fromRGB(50,0,100)
    Track.BorderSizePixel = 0
    Track.Parent = Row
    Instance.new("UICorner",Track).CornerRadius = UDim.new(1,0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0.33,0,1,0)
    Fill.BackgroundColor3 = Color3.fromRGB(140,60,255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner",Fill).CornerRadius = UDim.new(1,0)

    local Handle = Instance.new("TextButton")
    Handle.Size = UDim2.new(0,14,0,14)
    Handle.Position = UDim2.new(0.33,-7,0.5,-7)
    Handle.BackgroundColor3 = Color3.fromRGB(200,140,255)
    Handle.Text = ""
    Handle.BorderSizePixel = 0
    Handle.Parent = Track
    Instance.new("UICorner",Handle).CornerRadius = UDim.new(1,0)

    local sliding = false
    Handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1)
            Fill.Size = UDim2.new(rel,0,1,0)
            Handle.Position = UDim2.new(rel,-7,0.5,-7)
            MainScale.Scale = 0.5 + rel*1.5
            Lbl.Text = string.format("UI Scale: %.1f", MainScale.Scale)
        end
    end)
end

local function createActionBtn(name, cb)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,0,0,30)
    Btn.BackgroundColor3 = Color3.fromRGB(55,0,110)
    Btn.BorderSizePixel = 0
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(220,180,255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = CScroll
    Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,7)
    local bs = Instance.new("UIStroke",Btn)
    bs.Color = Color3.fromRGB(160,70,255); bs.Thickness = 1.5
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(90,0,170)}):Play()
        task.delay(0.1,function() TweenService:Create(Btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(55,0,110)}):Play() end)
        if cb then cb() end
    end)
    return Btn
end

-- Keybind row
local keybindRowRefs = {}
local listeningFor = nil

local KeybindMap = {
    tpUp   = Enum.KeyCode[cfg.keybinds.tpUp]   or Enum.KeyCode.E,
    tpDown = Enum.KeyCode[cfg.keybinds.tpDown] or Enum.KeyCode.F,
    drop   = Enum.KeyCode[cfg.keybinds.drop]   or Enum.KeyCode.H,
    aimbot = Enum.KeyCode[cfg.keybinds.aimbot] or Enum.KeyCode.G,
}

local function createKeybindRow(label, keyName)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1,0,0,32)
    Row.BackgroundColor3 = Color3.fromRGB(28,0,58)
    Row.BorderSizePixel = 0
    Row.Parent = CScroll
    Instance.new("UICorner",Row).CornerRadius = UDim.new(0,7)
    local rs = Instance.new("UIStroke",Row)
    rs.Color = Color3.fromRGB(100,40,200); rs.Thickness = 1

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.5,0,1,0)
    Lbl.Position = UDim2.new(0,9,0,0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(200,160,255)
    Lbl.TextSize = 11
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local KeyBtn = Instance.new("TextButton")
    KeyBtn.Size = UDim2.new(0,68,0,21)
    KeyBtn.Position = UDim2.new(1,-76,0.5,-10)
    KeyBtn.BackgroundColor3 = Color3.fromRGB(50,0,100)
    KeyBtn.Text = cfg.keybinds[keyName] or "None"
    KeyBtn.TextColor3 = Color3.fromRGB(220,180,255)
    KeyBtn.TextSize = 11
    KeyBtn.Font = Enum.Font.GothamBold
    KeyBtn.BorderSizePixel = 0
    KeyBtn.Parent = Row
    Instance.new("UICorner",KeyBtn).CornerRadius = UDim.new(0,5)
    local kbs = Instance.new("UIStroke",KeyBtn)
    kbs.Color = Color3.fromRGB(120,50,220); kbs.Thickness = 1

    keybindRowRefs[keyName] = KeyBtn
    KeyBtn.MouseButton1Click:Connect(function()
        if listeningFor then
            keybindRowRefs[listeningFor].Text = cfg.keybinds[listeningFor] or "None"
            keybindRowRefs[listeningFor].BackgroundColor3 = Color3.fromRGB(50,0,100)
        end
        listeningFor = keyName
        KeyBtn.Text = "..."
        KeyBtn.BackgroundColor3 = Color3.fromRGB(100,0,180)
    end)
end

-- ========================
-- BUILD MAIN UI
-- ========================
sectionLabel("  PLAYER")
createToggle("Anti Ragdoll","antiRagdoll",function(s)
    State.antiRagdollEnabled = s
    if s then startAntiRagdoll() else stopAntiRagdoll() end
end)
createToggle("Infinite Jump","infJump",function(s)
    State.infJumpEnabled = s
end)

sectionLabel("  VISUALS")
createToggle("ESP (Neon Purple)","esp",function(s)
    if s then enableESP() else disableESP() end
end)

sectionLabel("  SPEED SETTINGS")
createSpeedInput("Normal Speed",  "normalSpeed",  "normalSpeed",  1, 70)
createSpeedInput("Steal Speed",   "stealSpeed",   "stealSpeed",   1, 70)
createSpeedInput("Aimbot Speed",  "aimbotSpeed",  "aimbotSpeed",  1, 70)
createSpeedInput("Lagger Speed",  "laggerSpeed",  "laggerSpeed",  1, 70)

sectionLabel("  TELEPORT SETTINGS")
createSpeedInput("TP Up Stud", "tpStud", "tpStud", 1, 200)

sectionLabel("  SETTINGS")
createToggle("Anti Lag","antiLag",function(s)
    State.antiLagEnabled = s
    if s then pcall(applyAntiLag) end
end)
createScaleSlider()

sectionLabel("  PANEL")
local OpenPanelBtn  = createActionBtn("Open ELzo Panel",nil)
local ClosePanelBtn = createActionBtn("Close ELzo Panel",nil)
ClosePanelBtn.BackgroundColor3 = Color3.fromRGB(70,0,40)
ClosePanelBtn.Visible = false
local LockPanelBtn = createActionBtn("Lock Panel: OFF",nil)
LockPanelBtn.Visible = false

sectionLabel("  KEYBINDS")
createKeybindRow("TP Up",       "tpUp")
createKeybindRow("TP Down",     "tpDown")
createKeybindRow("Drop",        "drop")
createKeybindRow("Bat Aimbot",  "aimbot")

-- ========================
-- PANEL ELZO
-- ========================
local PanelFrame = Instance.new("Frame")
PanelFrame.Name = "PanelELzo"
PanelFrame.Size = UDim2.new(0,140,0,330)
PanelFrame.Position = UDim2.new(0,cfg.panelPos.X,0,cfg.panelPos.Y)
PanelFrame.BackgroundColor3 = Color3.fromRGB(10,0,25)
PanelFrame.BorderSizePixel = 0
PanelFrame.ClipsDescendants = true
PanelFrame.Visible = false
PanelFrame.Parent = ScreenGui
Instance.new("UICorner",PanelFrame).CornerRadius = UDim.new(0,10)
local _pfs = Instance.new("UIStroke",PanelFrame)
_pfs.Color = Color3.fromRGB(140,60,255); _pfs.Thickness = 2
local _pfg = Instance.new("UIGradient",PanelFrame)
_pfg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(15,0,40)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(28,0,65)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(10,0,30)),
})
_pfg.Rotation = 135

local PTitleBar = Instance.new("Frame")
PTitleBar.Size = UDim2.new(1,0,0,36)
PTitleBar.BackgroundColor3 = Color3.fromRGB(40,0,80)
PTitleBar.BorderSizePixel = 0
PTitleBar.Parent = PanelFrame
Instance.new("UICorner",PTitleBar).CornerRadius = UDim.new(0,10)
local _ptg = Instance.new("UIGradient",PTitleBar)
_ptg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(80,0,160)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(30,0,80)),
})
_ptg.Rotation = 90

local PTitleLbl = Instance.new("TextLabel")
PTitleLbl.Size = UDim2.new(1,-8,1,0)
PTitleLbl.Position = UDim2.new(0,10,0,0)
PTitleLbl.BackgroundTransparency = 1
PTitleLbl.Text = "Panel ELzo"
PTitleLbl.TextColor3 = Color3.fromRGB(220,170,255)
PTitleLbl.TextSize = 13
PTitleLbl.Font = Enum.Font.GothamBold
PTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
PTitleLbl.Parent = PTitleBar

local PContent = Instance.new("Frame")
PContent.Size = UDim2.new(1,0,1,-40)
PContent.Position = UDim2.new(0,0,0,40)
PContent.BackgroundTransparency = 1
PContent.Parent = PanelFrame

local PCList = Instance.new("UIListLayout")
PCList.Padding = UDim.new(0,6)
PCList.HorizontalAlignment = Enum.HorizontalAlignment.Center
PCList.Parent = PContent

local PCPad = Instance.new("UIPadding")
PCPad.PaddingTop = UDim.new(0,7)
PCPad.PaddingLeft = UDim.new(0,7)
PCPad.PaddingRight = UDim.new(0,7)
PCPad.Parent = PContent

local panelBtnRefs = {}
local function createPanelBtn(name, key, cb)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,0,0,46)
    Btn.BackgroundColor3 = Color3.fromRGB(32,0,68)
    Btn.BorderSizePixel = 0
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(185,140,255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.TextWrapped = true
    Btn.Parent = PContent
    Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,7)
    local bs = Instance.new("UIStroke",Btn)
    bs.Color = Color3.fromRGB(100,40,200); bs.Thickness = 1.5

    local on = false
    local function setOn(val)
        on = val
        TweenService:Create(Btn,TweenInfo.new(0.15),{
            BackgroundColor3 = on and Color3.fromRGB(90,0,180) or Color3.fromRGB(32,0,68),
            TextColor3 = on and Color3.fromRGB(255,230,255) or Color3.fromRGB(185,140,255),
        }):Play()
    end

    Btn.MouseButton1Click:Connect(function()
        on = not on; setOn(on)
        if cb then cb(on) end
    end)

    if key then panelBtnRefs[key] = {setOn=setOn, getOn=function() return on end} end
end

-- Bat Aimbot
createPanelBtn("Bat Aimbot","aimbot",function(s)
    State.batAimbotToggled = s
    if s then pcall(startBatAimbot) else stopBatAimbot() end
end)

-- Drop (auto off 0.5 detik)
createPanelBtn("Drop","drop",function(s)
    if s then
        runDropBrainrot()
        task.delay(DROP_AUTO_OFF,function()
            if panelBtnRefs.drop then panelBtnRefs.drop.setOn(false) end
        end)
    end
end)

-- TP Up
createPanelBtn("TP Up","tpUp",function(s)
    if s then
        doTpUp()
        task.delay(0.1,function()
            if panelBtnRefs.tpUp then panelBtnRefs.tpUp.setOn(false) end
        end)
    end
end)

-- TP Down
createPanelBtn("TP Down","tpDown",function(s)
    if s then
        doTpDown()
        task.delay(0.1,function()
            if panelBtnRefs.tpDown then panelBtnRefs.tpDown.setOn(false) end
        end)
    end
end)

-- Speed Lagger (aktif = speed 12, off = kembali normal, mutex dengan Steal Speed)
createPanelBtn("Speed Lagger","speedLagger",function(s)
    State.laggerEnabled = s
    if s then
        -- matiin steal speed kalau nyala
        if State.stealSpeedEnabled then
            State.stealSpeedEnabled = false
            if panelBtnRefs.stealSpeed then panelBtnRefs.stealSpeed.setOn(false) end
        end
        startSpeedLoop()
    else
        if not State.stealSpeedEnabled then stopSpeedLoop() end
    end
end)

-- Steal Speed (aktif = pakai stealSpeed, mutex dengan Speed Lagger)
createPanelBtn("Steal Speed","stealSpeed",function(s)
    State.stealSpeedEnabled = s
    if s then
        -- matiin speed lagger kalau nyala
        if State.laggerEnabled then
            State.laggerEnabled = false
            if panelBtnRefs.speedLagger then panelBtnRefs.speedLagger.setOn(false) end
        end
        startSpeedLoop()
    else
        if not State.laggerEnabled then stopSpeedLoop() end
    end
end)

-- ========================
-- BINTANG KELAP KELIP
-- ========================
local function spawnStar(parent)
    local Star = Instance.new("Frame")
    local sz = math.random(2,5)
    Star.Size = UDim2.new(0,sz,0,sz)
    Star.Position = UDim2.new(math.random(3,97)/100,0,math.random(3,97)/100,0)
    Star.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Star.BorderSizePixel = 0
    Star.BackgroundTransparency = math.random(0,4)/10
    Star.ZIndex = 2
    Star.Parent = parent
    Instance.new("UICorner",Star).CornerRadius = UDim.new(1,0)
    task.spawn(function()
        while Star and Star.Parent do
            local t = math.random(3,12)/10
            TweenService:Create(Star,TweenInfo.new(t,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
                BackgroundTransparency = math.random(0,8)/10,
                Size = UDim2.new(0,math.random(1,6),0,math.random(1,6)),
            }):Play()
            task.wait(t)
        end
    end)
end

for i=1,28 do spawnStar(MainFrame) end
for i=1,14 do spawnStar(PanelFrame) end

-- ========================
-- DRAG
-- ========================
local drag1,ds1,dp1 = false,nil,nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag1=true; ds1=i.Position; dp1=MainHolder.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                drag1=false
                cfg.mainPos={X=MainHolder.Position.X.Offset,Y=MainHolder.Position.Y.Offset}
                saveConfig()
            end
        end)
    end
end)

local drag2,ds2,dp2 = false,nil,nil
local panelLocked = cfg.panelLocked or false

PTitleBar.InputBegan:Connect(function(i)
    if panelLocked then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag2=true; ds2=i.Position; dp2=PanelFrame.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                drag2=false
                cfg.panelPos={X=PanelFrame.Position.X.Offset,Y=PanelFrame.Position.Y.Offset}
                saveConfig()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        if drag1 and ds1 then
            local d = i.Position-ds1
            MainHolder.Position = UDim2.new(dp1.X.Scale,dp1.X.Offset+d.X,dp1.Y.Scale,dp1.Y.Offset+d.Y)
        end
        if drag2 and ds2 and not panelLocked then
            local d = i.Position-ds2
            PanelFrame.Position = UDim2.new(dp2.X.Scale,dp2.X.Offset+d.X,dp2.Y.Scale,dp2.Y.Offset+d.Y)
        end
    end
end)

-- ========================
-- PANEL OPEN/CLOSE/LOCK
-- ========================
local panelVis = false
local function setPanel(val)
    panelVis = val
    if val then
        PanelFrame.Visible = true
        PanelFrame.Size = UDim2.new(0,0,0,0)
        TweenService:Create(PanelFrame,TweenInfo.new(0.25,Enum.EasingStyle.Back),{
            Size=UDim2.new(0,140,0,330)
        }):Play()
        OpenPanelBtn.Visible = false
        ClosePanelBtn.Visible = true
        LockPanelBtn.Visible = true
    else
        TweenService:Create(PanelFrame,TweenInfo.new(0.18),{Size=UDim2.new(0,0,0,0)}):Play()
        task.delay(0.18,function() PanelFrame.Visible=false end)
        OpenPanelBtn.Visible = true
        ClosePanelBtn.Visible = false
        LockPanelBtn.Visible = false
        panelLocked = false
        LockPanelBtn.Text = "Lock Panel: OFF"
        LockPanelBtn.BackgroundColor3 = Color3.fromRGB(55,0,110)
        cfg.panelLocked = false
        saveConfig()
    end
end

OpenPanelBtn.MouseButton1Click:Connect(function() setPanel(true) end)
ClosePanelBtn.MouseButton1Click:Connect(function() setPanel(false) end)

LockPanelBtn.MouseButton1Click:Connect(function()
    panelLocked = not panelLocked
    LockPanelBtn.Text = panelLocked and "Lock Panel: ON" or "Lock Panel: OFF"
    TweenService:Create(LockPanelBtn,TweenInfo.new(0.15),{
        BackgroundColor3 = panelLocked and Color3.fromRGB(120,0,45) or Color3.fromRGB(55,0,110),
    }):Play()
    cfg.panelLocked = panelLocked; saveConfig()
end)

-- ========================
-- MAIN SHOW/HIDE
-- ========================
local mainVis = false
local function setMain(val)
    mainVis = val
    if val then
        MainHolder.Visible = true
        MainFrame.Size = UDim2.new(0,0,0,0)
        TweenService:Create(MainFrame,TweenInfo.new(0.28,Enum.EasingStyle.Back),{
            Size=UDim2.new(1,0,1,0)
        }):Play()
    else
        TweenService:Create(MainFrame,TweenInfo.new(0.18),{Size=UDim2.new(0,0,0,0)}):Play()
        task.delay(0.18,function() MainHolder.Visible=false end)
    end
end

ToggleBtn.MouseButton1Click:Connect(function() setMain(not mainVis) end)
CloseBtn.MouseButton1Click:Connect(function() setMain(false) end)

-- ========================
-- KEYBIND INPUT
-- ========================
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local kc = inp.KeyCode
    if kc == Enum.KeyCode.Unknown then return end

    if listeningFor then
        local keyName = kc.Name
        KeybindMap[listeningFor] = kc
        cfg.keybinds[listeningFor] = keyName
        if keybindRowRefs[listeningFor] then
            keybindRowRefs[listeningFor].Text = keyName
            keybindRowRefs[listeningFor].BackgroundColor3 = Color3.fromRGB(50,0,100)
        end
        listeningFor = nil
        saveConfig()
        return
    end

    if kc == Enum.KeyCode.RightShift then setMain(not mainVis); return end

    if kc == KeybindMap.tpUp then
        doTpUp()
    elseif kc == KeybindMap.tpDown then
        doTpDown()
    elseif kc == KeybindMap.drop then
        runDropBrainrot()
        if panelBtnRefs.drop then
            panelBtnRefs.drop.setOn(true)
            task.delay(DROP_AUTO_OFF,function()
                if panelBtnRefs.drop then panelBtnRefs.drop.setOn(false) end
            end)
        end
    elseif kc == KeybindMap.aimbot then
        State.batAimbotToggled = not State.batAimbotToggled
        if State.batAimbotToggled then pcall(startBatAimbot) else stopBatAimbot() end
        if panelBtnRefs.aimbot then panelBtnRefs.aimbot.setOn(State.batAimbotToggled) end
    end
end)

-- ========================
-- AUTO SAVE tiap 10 detik
-- ========================
task.spawn(function()
    while true do
        task.wait(10)
        if MainHolder.Visible then
            cfg.mainPos={X=MainHolder.Position.X.Offset,Y=MainHolder.Position.Y.Offset}
        end
        if PanelFrame.Visible then
            cfg.panelPos={X=PanelFrame.Position.X.Offset,Y=PanelFrame.Position.Y.Offset}
        end
        saveConfig()
    end
end)

-- ========================
-- RESPAWN HANDLER
-- ========================
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    setupSpeedBillboard()
    if State.antiRagdollEnabled then stopAntiRagdoll(); task.wait(0.3); startAntiRagdoll() end
    if State.batAimbotToggled then stopBatAimbot(); task.wait(0.2); pcall(startBatAimbot) end
    if State.laggerEnabled or State.stealSpeedEnabled then stopSpeedLoop(); task.wait(0.1); startSpeedLoop() end
    if State.espEnabled then task.wait(0.3); disableESP(); enableESP() end
end)

-- Init billboard dan speed loop
task.spawn(function()
    task.wait(1)
    setupSpeedBillboard()
    startSpeedLoop()
end)

print("ELzo Hub loaded! RightShift = toggle UI")
