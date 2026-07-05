--////////////////////////////////////////////////////////////
-- MAIN GUI + DRAG + TOGGLE + NOTIFICATION + NO ERROR
--////////////////////////////////////////////////////////////

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--========================================================
-- GUI DRAG FUNCTION
--========================================================
local function makeDraggable(frame)
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

--========================================================
-- CREATE GUI
--========================================================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "StickGui"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 150, 0, 80)
main.Position = UDim2.new(0, 20, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true

makeDraggable(main)

local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(1, -10, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0, 5)
toggleBtn.Text = "Start / Stop"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.new(1,1,1)

local label = Instance.new("TextLabel", main)
label.Size = UDim2.new(1, -10, 0, 20)
label.Position = UDim2.new(0, 5, 0, 40)
label.BackgroundTransparency = 1
label.Text = "Made by Diler - Spin Close"
label.TextColor3 = Color3.new(1,1,1)

local collapseBtn = Instance.new("TextButton", gui)
collapseBtn.Size = UDim2.new(0, 35, 0, 35)
collapseBtn.Position = UDim2.new(0, 20, 0, 100)
collapseBtn.Text = "-"
collapseBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
collapseBtn.TextColor3 = Color3.new(1,1,1)

local collapsed = false
collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    main.Visible = not collapsed
    collapseBtn.Text = collapsed and "+" or "-"
end)

--========================================================
-- STICK SPIN SYSTEM (Mượt, an toàn)
--========================================================
local stick = false
local spinSpeed = 45
local radius = 3.5

local function getClosest()
    local closest, dist = nil, math.huge
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p \~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
            if d < dist then
                dist = d
                closest = p
            end
        end
    end
    return closest
end

toggleBtn.MouseButton1Click:Connect(function()
    stick = not stick
end)

RunService.Heartbeat:Connect(function()
    if not stick then return end
    
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local target = getClosest()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = target.Character.HumanoidRootPart.Position
        local angle = tick() * spinSpeed
        
        local offset = Vector3.new(math.cos(angle) * radius, 1.5, math.sin(angle) * radius)
        
        hrp.CFrame = CFrame.new(targetPos + offset, targetPos + Vector3.new(0,1,0)) * CFrame.Angles(math.rad(-90), 0, 0)
    end
end)

--========================================================
-- NOTIFICATION (giữ nguyên)
--========================================================
StarterGui:SetCore("SendNotification", {Title = "Save Notification", Text = "Notfication Death Counter", Duration = 3})

local function notify(msg)
    StarterGui:SetCore("SendNotification", {Title = "⚠ Skill Alert", Text = msg, Duration = 3})
end

local function setupPlayer(plr)
    if plr == player then return end
    plr.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(function(child)
            if child.Name == "Ultimate" then
                notify(plr.Name .. " Him has turn on ULTIMATE Saitama!")
            end
            if child.Name == "CounterDeath" then
                notify(plr.Name .. " Him has turn on COUNTER DEATH!")
            end
        end)
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    setupPlayer(plr)
end
Players.PlayerAdded:Connect(setupPlayer)

print("✅ Spin Close Mode loaded mượt! Nhấn toggle để bật.")