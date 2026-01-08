--[[
    Análise Educacional: Estrutura de GUI e Lógica de Câmera
    Este script demonstra como criar botões, frames arrastáveis e 
    manipulação básica de CFrame.
]]

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

-- 1. VARIÁVEIS DE CONTROLE (Estado do Script)
local aimEnabled = false
local espEnabled = false
local showFov = true
local fovSize = 100
local minimized = false

-- 2. INTERFACE DO CÍRCULO (Visualização de área)
local fovGui = Instance.new("ScreenGui", player.PlayerGui)
fovGui.Name = "Sistema_FOV"

local fovCircle = Instance.new("Frame", fovGui)
fovCircle.Size = UDim2.new(0, fovSize * 2, 0, fovSize * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 0.9
fovCircle.Visible = false

local uiCorner = Instance.new("UICorner", fovCircle)
uiCorner.CornerRadius = UDim.new(1, 0) -- Torna o Frame um círculo

-- 3. INTERFACE DE CONTROLE (Menu Principal)
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.ResetOnSpawn = false

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 180, 0, 260)
frame.Position = UDim2.new(0.5, -90, 0.4, -130)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.Active = true -- Necessário para permitir arrastar

-- 4. LÓGICA DE ARRASTAR (Draggable Logic)
local dragging, dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

userInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- 5. COMPONENTES E BOTÕES (Exemplo de um botão)
local container = Instance.new("Frame", frame)
container.Size = UDim2.new(1, 0, 1, -30)
container.Position = UDim2.new(0, 0, 0, 30)
container.BackgroundTransparency = 1

local aimBtn = Instance.new("TextButton", container)
aimBtn.Size = UDim2.new(0.9, 0, 0, 30)
aimBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
aimBtn.Text = "Toggle Feature"

-- 6. LÓGICA DE CÁLCULO (Encontrar alvo mais próximo do centro)
local function getTarget()
    local target = nil
    local dist = math.huge
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
            -- Converte a posição 3D do mundo para 2D na tela do jogador
            local pos, vis = camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if magnitude <= fovSize and magnitude < dist then
                    target = v.Character.Head
                    dist = magnitude
                end
            end
        end
    end
    return target
end

-- 7. LOOP DE RENDERIZAÇÃO (Executa a cada frame)
runService.RenderStepped:Connect(function()
    if aimEnabled then
        local target = getTarget()
        if target then
            -- Suaviza o movimento da câmera em direção ao alvo usando Lerp
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Position), 0.15)
        end
    end
end)
