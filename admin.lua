-- admin.lua
-- For testing in your own Roblox Studio game

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flying = false
local noclip = false
local flySpeed = 60
local viewingPlayer = nil

local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(char)
	character = char
	root = char:WaitForChild("HumanoidRootPart")
	humanoid = char:WaitForChild("Humanoid")
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AdminGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, 430)
frame.Position = UDim2.fromOffset(30, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "ADMIN PANEL"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Dragging
local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

title.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Buttons
local function makeButton(text, y)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 38)
	button.Position = UDim2.fromOffset(10, y)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 17
	button.Text = text
	button.Font = Enum.Font.SourceSans
	button.Parent = frame
	return button
end

local flyButton = makeButton("Fly: OFF", 55)
local noclipButton = makeButton("Noclip: OFF", 100)
local stopViewButton = makeButton("Stop Viewing", 145)

-- Player list
local playerTitle = Instance.new("TextLabel")
playerTitle.Size = UDim2.new(1, -20, 0, 25)
playerTitle.Position = UDim2.fromOffset(10, 190)
playerTitle.BackgroundTransparency = 1
playerTitle.Text = "PLAYER LIST"
playerTitle.TextColor3 = Color3.new(1, 1, 1)
playerTitle.TextSize = 17
playerTitle.TextXAlignment = Enum.TextXAlignment.Left
playerTitle.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 0, 220)
list.Position = UDim2.fromOffset(10, 215)
list.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = list

-- View player
local function viewPlayer(target)
	if not target then return end

	local targetCharacter = target.Character
	if not targetCharacter then return end

	local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")

	if targetHumanoid then
		camera.CameraSubject = targetHumanoid
		viewingPlayer = target
	end
end

stopViewButton.MouseButton1Click:Connect(function()
	local myHumanoid = character and character:FindFirstChildOfClass("Humanoid")

	if myHumanoid then
		camera.CameraSubject = myHumanoid
	end

	viewingPlayer = nil
end)

-- Refresh player list
local function refreshPlayers()
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, target in ipairs(Players:GetPlayers()) do
		local button = Instance.new("TextButton")

		button.Size = UDim2.new(1, -10, 0, 35)
		button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		button.TextColor3 = Color3.new(1, 1, 1)
		button.TextSize = 16
		button.Text = target.Name
		button.Parent = list

		button.MouseButton1Click:Connect(function()
			viewPlayer(target)
		end)
	end

	task.wait()
	list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 5)
end

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

refreshPlayers()

-- Fly
flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	flyButton.Text = "Fly: " .. (flying and "ON" or "OFF")

	if not flying and root then
		root.AssemblyLinearVelocity = Vector3.zero
	end
end)

RunService.RenderStepped:Connect(function()
	if not flying or not root then
		return
	end

	local direction = Vector3.zero

	if UIS:IsKeyDown(Enum.KeyCode.W) then
		direction += camera.CFrame.LookVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.S) then
		direction -= camera.CFrame.LookVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.A) then
		direction -= camera.CFrame.RightVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.D) then
		direction += camera.CFrame.RightVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.Space) then
		direction += Vector3.yAxis
	end

	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
		direction -= Vector3.yAxis
	end

	if direction.Magnitude > 0 then
		root.AssemblyLinearVelocity = direction.Unit * flySpeed
	else
		root.AssemblyLinearVelocity = Vector3.zero
	end
end)

-- Noclip
noclipButton.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipButton.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
	if not character then return end

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not noclip
		end
	end
end)
