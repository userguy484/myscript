-- RemoteMonitor.lua
-- Admin panel: ESP + Fly + Noclip

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local espEnabled = false
local flyEnabled = false
local noclipEnabled = false
local flySpeed = 60

local character
local humanoid
local root

local function updateCharacter()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")
end

updateCharacter()

player.CharacterAdded:Connect(function()
	task.wait()
	updateCharacter()
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteMonitor"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(190, 165)
frame.Position = UDim2.fromOffset(20, 100)
frame.BackgroundTransparency = 0.15
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "RemoteMonitor"
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = frame

local function makeButton(text, y)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 35)
	button.Position = UDim2.fromOffset(10, y)
	button.Text = text
	button.TextScaled = true
	button.Parent = frame
	return button
end

local espButton = makeButton("ESP: OFF", 35)
local flyButton = makeButton("Fly: OFF", 75)
local noclipButton = makeButton("Noclip: OFF", 115)

-- ESP
local highlights = {}

local function removeESP(p)
	if highlights[p] then
		highlights[p]:Destroy()
		highlights[p] = nil
	end
end

local function addESP(p)
	if p == player or not espEnabled then
		return
	end

	local char = p.Character
	if not char then
		return
	end

	removeESP(p)

	local highlight = Instance.new("Highlight")
	highlight.Name = "RemoteMonitorESP"
	highlight.Adornee = char
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = char

	highlights[p] = highlight
end

local function refreshESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			if espEnabled then
				addESP(p)
			else
				removeESP(p)
			end
		end
	end
end

espButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
	refreshESP()
end)

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		task.wait(0.2)
		if espEnabled then
			addESP(p)
		end
	end)
end)

Players.PlayerRemoving:Connect(removeESP)

-- Fly
flyButton.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	flyButton.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")

	if not flyEnabled and root then
		root.AssemblyLinearVelocity = Vector3.zero
	end
end)

-- Noclip
noclipButton.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipButton.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
end)

-- Main loop
RunService.RenderStepped:Connect(function()
	if not character or not humanoid or not root then
		return
	end

	-- Noclip
	if noclipEnabled then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	else
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end

	-- Fly
	if flyEnabled then
		local moveDirection = humanoid.MoveDirection

		if moveDirection.Magnitude > 0 then
			root.AssemblyLinearVelocity = moveDirection.Unit * flySpeed
		else
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end
end)

-- Drag panel
local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPosition = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
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
