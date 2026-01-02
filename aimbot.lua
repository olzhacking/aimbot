-- coder: olz
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

local aimEnabled = false
local espEnabled = false
local showFov = true
local fovSize = 100
local minimized = false

-- --- INTERFACE DO CÍRCULO FOV ---
local fovGui = Instance.new("ScreenGui", player.PlayerGui)
fovGui.Name = "olz_fov_system"

local fovCircle = Instance.new("Frame", fovGui)
fovCircle.Size = UDim2.new(0, fovSize * 2, 0, fovSize * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundColor3 = Color3.fromHex("770000")
fovCircle.BackgroundTransparency = 0.9
fovCircle.Visible = false

local uiCorner = Instance.new("UICorner", fovCircle)
uiCorner.CornerRadius = UDim.new(1, 0)
local uiStroke = Instance.new("UIStroke", fovCircle)
uiStroke.Thickness = 1
uiStroke.Color = Color3.fromHex("770000")

-- --- INTERFACE DE CONTROLE ---
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "olz_combat_hub"
sg.ResetOnSpawn = false

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 180, 0, 260)
frame.Position = UDim2.new(0.8, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromHex("770000")
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(0.7, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "coder: olz"
title.Font = Enum.Font.Code
title.TextSize = 16

local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.BackgroundColor3 = Color3.fromHex("770000")
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1, 1, 1)

local container = Instance.new("Frame", frame)
container.Size = UDim2.new(1, 0, 1, -30)
container.Position = UDim2.new(0, 0, 0, 30)
container.BackgroundTransparency = 1

local aimBtn = Instance.new("TextButton", container)
aimBtn.Size = UDim2.new(0.9, 0, 0, 30)
aimBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
aimBtn.BackgroundColor3 = Color3.fromHex("770000")
aimBtn.Text = "aimbot: off"
aimBtn.TextColor3 = Color3.new(1, 1, 1)

local espBtn = Instance.new("TextButton", container)
espBtn.Size = UDim2.new(0.9, 0, 0, 30)
espBtn.Position = UDim2.new(0.05, 0, 0.20, 0)
espBtn.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
espBtn.Text = "esp: off"
espBtn.TextColor3 = Color3.new(1, 1, 1)

local fovVisibleBtn = Instance.new("TextButton", container)
fovVisibleBtn.Size = UDim2.new(0.9, 0, 0, 30)
fovVisibleBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
fovVisibleBtn.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
fovVisibleBtn.Text = "ver fov: on"
fovVisibleBtn.TextColor3 = Color3.new(1, 1, 1)

local fovLabel = Instance.new("TextLabel", container)
fovLabel.Size = UDim2.new(1, 0, 0, 20)
fovLabel.Position = UDim2.new(0, 0, 0.55, 0)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "fov size: " .. fovSize
fovLabel.TextColor3 = Color3.new(1, 1, 1)

local addFov = Instance.new("TextButton", container)
addFov.Size = UDim2.new(0.4, 0, 0, 30)
addFov.Position = UDim2.new(0.05, 0, 0.7, 0)
addFov.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
addFov.Text = "fov +"
addFov.TextColor3 = Color3.new(1, 1, 1)

local subFov = Instance.new("TextButton", container)
subFov.Size = UDim2.new(0.4, 0, 0, 30)
subFov.Position = UDim2.new(0.55, 0, 0.7, 0)
subFov.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
subFov.Text = "fov -"
subFov.TextColor3 = Color3.new(1, 1, 1)

-- --- LÓGICA DE BOTÕES ---
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	frame:TweenSize(minimized and UDim2.new(0, 180, 0, 30) or UDim2.new(0, 180, 0, 260))
	container.Visible = not minimized
	minBtn.Text = minimized and "+" or "-"
end)

aimBtn.MouseButton1Click:Connect(function()
	aimEnabled = not aimEnabled
	aimBtn.Text = aimEnabled and "aimbot: on" or "aimbot: off"
	fovCircle.Visible = aimEnabled and showFov
end)

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espBtn.Text = espEnabled and "esp: on" or "esp: off"
	if not espEnabled then
		for _, v in pairs(game.Players:GetPlayers()) do
			if v.Character and v.Character:FindFirstChild("olz_esp") then v.Character.olz_esp:Destroy() end
		end
	end
end)

fovVisibleBtn.MouseButton1Click:Connect(function()
	showFov = not showFov
	fovVisibleBtn.Text = showFov and "ver fov: on" or "ver fov: off"
	fovCircle.Visible = aimEnabled and showFov
end)

addFov.MouseButton1Click:Connect(function()
	fovSize = fovSize + 10
	fovLabel.Text = "fov size: " .. fovSize
	fovCircle.Size = UDim2.new(0, fovSize * 2, 0, fovSize * 2)
end)

subFov.MouseButton1Click:Connect(function()
	fovSize = math.max(10, fovSize - 10)
	fovLabel.Text = "fov size: " .. fovSize
	fovCircle.Size = UDim2.new(0, fovSize * 2, 0, fovSize * 2)
end)

-- --- CÁLCULO DE ALVO E RENDER ---
local function getTarget()
	local target = nil
	local dist = math.huge
	local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

	for _, v in pairs(game.Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
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

runService.RenderStepped:Connect(function()
	title.TextColor3 = Color3.fromHSV(tick() % 3 / 3, 1, 1) -- RGB
	
	if aimEnabled then
		local target = getTarget()
		if target then
			camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Position), 0.15)
		end
	end

	if espEnabled then
		for _, v in pairs(game.Players:GetPlayers()) do
			if v ~= player and v.Character and not v.Character:FindFirstChild("olz_esp") then
				local h = Instance.new("Highlight", v.Character)
				h.Name = "olz_esp"
				h.FillColor = Color3.fromHex("770000")
				h.FillTransparency = 0.5
			end
		end
	end
end)
