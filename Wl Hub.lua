-- [[ WL HUB V3 FULL: ROBLOX VERSION ]] --
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- 1. MAIN UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "WLHubMain"
Main.Size = UDim2.new(0, 180, 0, 150)
Main.Position = UDim2.new(0.1, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- Biar bisa digeser kayak di PC

-- 2. DUAL NEON BORDERS (RE-IMPLEMENTED)
local LeftNeon = Instance.new("Frame", Main)
LeftNeon.Size = UDim2.new(0, 4, 1, 0)
LeftNeon.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- MERAH NEON KIRI
LeftNeon.BorderSizePixel = 0

local RightNeon = Instance.new("Frame", Main)
RightNeon.Size = UDim2.new(0, 4, 1, 0)
RightNeon.Position = UDim2.new(1, -4, 0, 0)
RightNeon.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- HIJAU NEON KANAN
RightNeon.BorderSizePixel = 0

-- 3. HEADER & MINIMIZE BUTTON
local Header = Instance.new("TextLabel", Main)
Header.Text = "  WL Hub"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Font = Enum.Font.SourceSansBold

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Text = "[-]"
MinBtn.Size = UDim2.new(0, 30, 1, 0)
MinBtn.Position = UDim2.new(1, -30, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- 4. CONTENT AREA
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1

local GrabBtn = Instance.new("TextButton", Content)
GrabBtn.Text = "START AUTO GRAB"
GrabBtn.Size = UDim2.new(0.8, 0, 0, 35)
GrabBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
GrabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
GrabBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
GrabBtn.Font = Enum.Font.SourceSansBold

local LeaveBtn = Instance.new("TextButton", Content)
LeaveBtn.Text = "LEAVE SERVER"
LeaveBtn.Size = UDim2.new(0.8, 0, 0, 35)
LeaveBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
LeaveBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LeaveBtn.TextColor3 = Color3.fromRGB(0, 255, 255)

-- 5. LOGIC MINIMIZE
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    Main.Size = minimized and UDim2.new(0, 180, 0, 30) or UDim2.new(0, 180, 0, 150)
    MinBtn.Text = minimized and "[+]" or "[-]"
end)

-- 6. LOGIC AUTO GRAB
local active = false
GrabBtn.MouseButton1Click:Connect(function()
    active = not active
    GrabBtn.Text = active and "GRABBING..." or "START AUTO GRAB"
    GrabBtn.TextColor3 = active and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    
    task.spawn(function()
        while active do
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("TouchTransmitter") then
                    firetouchinterest(hrp, v.Parent, 0)
                    firetouchinterest(hrp, v.Parent, 1)
                end
            end
            task.wait(0.1)
        end
    end)
end)

LeaveBtn.MouseButton1Click:Connect(function()
    game:Shutdown()
end)
