-- SETTINGS
local TELE_DISTANCE = 3
local LOW_HP = 20
local SAFEZONE_POS = Vector3.new(0,50,0)
local TELE_COOLDOWN = 0.05
local ORBIT_HEIGHT = 0.5
local AIM_SPEED = 0.15
local FOV_RADIUS = 150

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0,200,0,210)
MainFrame.Position = UDim2.new(0.05,0,0.1,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(60,0,60)
MainFrame.Active = true
MainFrame.Draggable = true

-- ON/OFF
local Toggle = Instance.new("TextButton", MainFrame)
Toggle.Size = UDim2.new(0,150,0,50)
Toggle.Position = UDim2.new(0.5,-75,0,10)
Toggle.BackgroundColor3 = Color3.fromRGB(90,0,90)
Toggle.Text = "AUTO TELEPORT: OFF"
Toggle.TextColor3 = Color3.fromRGB(255,255,255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 18

-- Author
local AuthorLabel = Instance.new("TextLabel", MainFrame)
AuthorLabel.Size = UDim2.new(0,150,0,25)
AuthorLabel.Position = UDim2.new(0.5,-75,0,65)
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.Text = "Made by Diler"
AuthorLabel.TextColor3 = Color3.fromRGB(255,255,255)
AuthorLabel.Font = Enum.Font.GothamBold
AuthorLabel.TextSize = 16

-- Target input
local TargetBox = Instance.new("TextBox", MainFrame)
TargetBox.Size = UDim2.new(0,150,0,40)
TargetBox.Position = UDim2.new(0.5,-75,0,95)
TargetBox.PlaceholderText = "Tên mục tiêu..."
TargetBox.TextColor3 = Color3.fromRGB(255,255,255)
TargetBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
TargetBox.Font = Enum.Font.Gotham
TargetBox.TextSize = 16

-- ON/OFF variable
local enabled = false
Toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    Toggle.Text = enabled and "AUTO TELEPORT: ON" or "AUTO TELEPORT: OFF"
    Toggle.BackgroundColor3 = enabled and Color3.fromRGB(150,0,150) or Color3.fromRGB(90,0,90)
end)

-- Rainbow effect
local function rainbowEffect(character)
    spawn(function()
        local colors = {Color3.fromRGB(255,0,0), Color3.fromRGB(255,127,0), Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255), Color3.fromRGB(75,0,130), Color3.fromRGB(148,0,211)}
        for i = 1, 10 do
            local p = Instance.new("Part")
            p.Shape = "Ball"
            p.Size = Vector3.new(1,1,1)
            p.Material = Enum.Material.Neon
            p.Anchored = true
            p.CanCollide = false
            p.CFrame = character.HumanoidRootPart.CFrame
            p.Color = colors[i % #colors + 1]
            p.Parent = workspace
            game.Debris:AddItem(p,0.4)
            task.wait(0.03)
        end
    end)
end

-- FOV Circle
local FOV = Drawing.new("Circle")
FOV.Radius = FOV_RADIUS
FOV.Color = Color3.fromRGB(255,0,255)
FOV.Thickness = 2
FOV.Filled = false
FOV.Visible = true

-- Helper: target in FOV màn hình
local function inFOV(targetPos)
    local camera = workspace.CurrentCamera
    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
    if not onScreen then return false end
    local mouse = game.Players.LocalPlayer:GetMouse()
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
    return dist <= FOV_RADIUS
end

-- MAIN LOOP
spawn(function()
    local player = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera

    while task.wait(TELE_COOLDOWN) do
        if not enabled then
            FOV.Visible = false
            continue
        end
        FOV.Visible = true
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then continue end

        -- Safe zone
        if humanoid.Health / humanoid.MaxHealth * 100 <= LOW_HP then
            rainbowEffect(char)
            char.HumanoidRootPart.CFrame = CFrame.new(SAFEZONE_POS)
            continue
        end

        -- Target
        local targetName = TargetBox.Text
        if targetName == "" then continue end
        local targetPlayer = game.Players:FindFirstChild(targetName)
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then continue end
        local targetHRP = targetPlayer.Character.HumanoidRootPart

        -- Chỉ tele + aim nếu target trong FOV
        if not inFOV(targetHRP.Position) then continue end

        -- Tele ra sau lưng target mượt bằng CFrame
        local lookDir = targetHRP.CFrame.LookVector
        local targetPos = targetHRP.Position - lookDir * TELE_DISTANCE + Vector3.new(0, ORBIT_HEIGHT, 0)
        char.HumanoidRootPart.CFrame = CFrame.new(targetPos, targetHRP.Position)

        -- Rainbow
        rainbowEffect(char)

        -- Aim camera theo target
        local direction = (targetHRP.Position - camera.CFrame.Position).Unit
        camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction), AIM_SPEED)

        -- FOV vòng tròn quanh chuột
        local mouse = player:GetMouse()
        FOV.Position = Vector2.new(mouse.X, mouse.Y)
    end
end)