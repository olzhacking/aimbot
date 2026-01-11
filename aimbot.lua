--[[
    Aimbot/ESP Hub: olz
    Funcionalidades: Nick dinâmico (limpeza automática ao desligar)
]]

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local aimEnabled = false
local espEnabled = false
local showFov = true
local fovSize = 100

-- --- INTERFACE DO CÍRCULO FOV ---
local fovGui = Instance.new("ScreenGui", player.PlayerGui)
local fovCircle = Instance.new("Frame", fovGui)
fovCircle.Size = UDim2.new(0, fovSize * 2, 0, fovSize * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 0.9
fovCircle.Visible = false
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local uiStroke = Instance.new("UIStroke", fovCircle)
uiStroke.Thickness = 1
uiStroke.Color = Color3.fromHex("770000")

-- --- INTERFACE DE CONTROLE ---
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.ResetOnSpawn = false
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 180, 0, 260)
frame.Position = UDim2.new(0.5, -90, 0.4, -130)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.Active = true

-- LÓGICA ARRASTRÁVEL
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = frame.Position
    end
end)
userInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
userInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local container = Instance.new("Frame", frame)
container.Size = UDim2.new(1, 0, 1, -30); container.Position = UDim2.new(0,0,0,30); container.BackgroundTransparency = 1

-- --- FUNÇÃO PARA GERENCIAR NICK ---
local function manageNick(char, state)
    local nick = char:FindFirstChild("olz_name")
    if state and not nick then
        local head = char:FindFirstChild("Head")
        if head then
            local bb = Instance.new("BillboardGui", char)
            bb.Name = "olz_name"; bb.Adornee = head; bb.Size = UDim2.new(0,100,0,50); bb.StudsOffset = Vector3.new(0,2,0); bb.AlwaysOnTop = true
            local l = Instance.new("TextLabel", bb); l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(1,1,1); l.TextStrokeTransparency = 0
            l.Text = game.Players:GetPlayerFromCharacter(char).Name; l.Font = Enum.Font.Code; l.TextSize = 14
        end
    elseif not state and nick then
        nick:Destroy()
    end
end

-- --- BOTÕES COM LIMPEZA AO DESLIGAR ---
local aimBtn = Instance.new("TextButton", container)
aimBtn.Size = UDim2.new(0.9, 0, 0, 30); aimBtn.Position = UDim2.new(0.05,0,0.05,0); aimBtn.Text = "aimbot: off"
aimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    aimBtn.Text = aimEnabled and "aimbot: on" or "aimbot: off"
    fovCircle.Visible = aimEnabled and showFov
    
    -- Se desligar o aimbot E o esp estiver off, limpa os nomes
    if not aimEnabled and not espEnabled then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character then manageNick(v.Character, false) end
        end
    end
end)

local espBtn = Instance.new("TextButton", container)
espBtn.Size = UDim2.new(0.9, 0, 0, 30); espBtn.Position = UDim2.new(0.05,0,0.20,0); espBtn.Text = "esp: off"
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "esp: on" or "esp: off"
    
    if not espEnabled then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character then
                if v.Character:FindFirstChild("olz_esp") then v.Character.olz_esp:Destroy() end
                -- Se o aimbot também estiver desligado, limpa os nomes
                if not aimEnabled then manageNick(v.Character, false) end
            end
        end
    end
end)

-- --- LOOP PRINCIPAL ---
runService.RenderStepped:Connect(function()
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local closestTarget = nil
    local shortestDist = fovSize

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
            local pos, vis = camera:WorldToViewportPoint(v.Character.Head.Position)
            local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            
            -- Lógica: Só mostra o nome se (Aimbot estiver On E estiver no FOV) OU se (ESP estiver On)
            local shouldShowNick = (aimEnabled and vis and mag <= fovSize) or espEnabled
            
            manageNick(v.Character, shouldShowNick)

            if aimEnabled and vis and mag <= fovSize and mag < shortestDist then
                closestTarget = v.Character.Head
                shortestDist = mag
            end

            if espEnabled and not v.Character:FindFirstChild("olz_esp") then
                local h = Instance.new("Highlight", v.Character)
                h.Name = "olz_esp"; h.FillColor = Color3.fromHex("770000")
            end
        end
    end

    if aimEnabled and closestTarget then
        camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, closestTarget.Position), 0.15)
    end
end)
