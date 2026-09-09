-- ADMIN GUI
-- For your own Roblox Studio game

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Remove old GUI
local old = player.PlayerGui:FindFirstChild("AnimatedAdmin")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "AnimatedAdmin"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- Main window
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 420)
main.Position = UDim2.new(0, 25, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 45)
title.Position = UDim2.fromOffset(15, 5)
title.BackgroundTransparency = 1
title.Text = "⚡ ADMIN PANEL"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

-- Close
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(38, 38)
close.Position = UDim2.new(1, -45, 0, 8)
close.Text = "×"
close.TextSize = 28
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
close.BorderSizePixel = 0
close.Parent = main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = close

-- Reopen button
local reopen = Instance.new("TextButton")
reopen.Size = UDim2.fromOffset(120, 42)
reopen.Position = UDim2.fromOffset(20, 20)
reopen.Text = "OPEN ADMIN"
reopen.TextSize = 14
reopen.Font = Enum.Font.GothamBold
reopen.TextColor3 = Color3.new(1, 1, 1)
reopen.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
reopen.Visible = false
reopen.Parent = gui

local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(0, 10)
reopenCorner.Parent = reopen

-- Button creator
local function makeButton(text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -30, 0, 42)
	b.Position = UDim2.fromOffset(15, y)
	b.Text = text
	b.TextSize = 15
	b.Font = Enum.Font.GothamBold
	b.TextColor3 = Color3.new(1, 1, 1)
	b.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	b.Parent = main

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 9)
	c.Parent = b

	-- Hover animation
	b.MouseEnter:Connect(function()
		TweenService:Create(
			b,
			TweenInfo.new(0.15),
			{BackgroundColor3 = Color3.fromRGB(65, 65, 80)}
		):Play()
	end)

	b.MouseLeave:Connect(function()
		TweenService:Create(
			b,
			TweenInfo.new(0.15),
			{BackgroundColor3 = Color3.fromRGB(45, 45, 55)}
		):Play()
	end)

	-- Click animation
	b.MouseButton1Down:Connect(function()
		TweenService:Create(
			b,
			TweenInfo.new(0.08),
			{Size = UDim2.new(1, -38, 0, 38)}
		):Play()
	end)

	b.MouseButton1Up:Connect(function()
		TweenService:Create(
			b,
			TweenInfo.new(0.08),
			{Size = UDim2.new(1, -30, 0, 42)}
		):Play()
	end)

	return b
end

-- Noclip
local noclip = false
local noclipButton = makeButton("Noclip: OFF", 60)

noclipButton.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipButton.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
	if not noclip then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.CanCollide = false
		end
	end
end)

-- Fly
local flying = false
local flySpeed = 50

local flyButton = makeButton("Fly: OFF", 112)

local bodyVelocity
local bodyGyro

flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	flyButton.Text = "Fly: " .. (flying and "ON" or "OFF")

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if flying and root then
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = root

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		bodyGyro.P = 10000
		bodyGyro.Parent = root
	else
		if bodyVelocity then
			bodyVelocity:Destroy()
			bodyVelocity = nil
		end

		if bodyGyro then
			bodyGyro:Destroy()
			bodyGyro = nil
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not flying then
		return
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not root or not humanoid or not bodyVelocity then
		return
	end

	local camera = workspace.CurrentCamera
	bodyVelocity.Velocity = humanoid.MoveDirection * flySpeed

	if bodyGyro then
		bodyGyro.CFrame = camera.CFrame
	end
end)

-- ESP
local esp = false
local espButton = makeButton("ESP: OFF", 164)

local function addESP(plr)
	if plr == player then return end

	local character = plr.Character
	if not character then return end

	if character:FindFirstChild("AdminESP") then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "AdminESP"
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0
	highlight.Parent = character
end

local function removeESP(plr)
	if plr.Character then
		local h = plr.Character:FindFirstChild("AdminESP")

		if h then
			h:Destroy()
		end
	end
end

espButton.MouseButton1Click:Connect(function()
	esp = not esp
	espButton.Text = "ESP: " .. (esp and "ON" or "OFF")

	for _, plr in ipairs(Players:GetPlayers()) do
		if esp then
			addESP(plr)
		else
			removeESP(plr)
		end
	end
end)

-- View player
local viewButton = makeButton("View Player", 216)

viewButton.MouseButton1Click:Connect(function()
	local others = {}

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			table.insert(others, plr)
		end
	end

	if #others > 0 then
		local target = others[math.random(1, #others)]
		local humanoid = target.Character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			workspace.CurrentCamera.CameraSubject = humanoid
		end
	end
end)

-- Reset camera
local resetView = makeButton("Reset View", 268)

resetView.MouseButton1Click:Connect(function()
	local character = player.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			workspace.CurrentCamera.CameraSubject = humanoid
		end
	end
end)

-- Player count
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -30, 0, 35)
info.Position = UDim2.fromOffset(15, 325)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(190, 190, 190)
info.TextSize = 14
info.Font = Enum.Font.Gotham
info.Text = "Players: " .. #Players:GetPlayers()
info.Parent = main

Players.PlayerAdded:Connect(function()
	info.Text = "Players: " .. #Players:GetPlayers()
end)

Players.PlayerRemoving:Connect(function()
	info.Text = "Players: " .. #Players:GetPlayers()
end)

-- Dragging
local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPosition = main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Smooth close
close.MouseButton1Click:Connect(function()
	local tween = TweenService:Create(
		main,
		TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{
			Size = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1
		}
	)

	tween:Play()
	tween.Completed:Wait()

	main.Visible = false
	main.Size = UDim2.fromOffset(320, 420)
	main.BackgroundTransparency = 0
	reopen.Visible = true
end)

-- Smooth reopen
reopen.MouseButton1Click:Connect(function()
	reopen.Visible = false
	main.Visible = true
	main.Size = UDim2.fromOffset(0, 0)

	TweenService:Create(
		main,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = UDim2.fromOffset(320, 420)}
	):Play()
end)

print("Animated Admin loaded!")
