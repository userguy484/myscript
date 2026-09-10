-- RemoteMonitor.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local fly = false
local noclip = false
local espOn = false
local hitboxOn = false
local speed = 60

local char, hum, root
local esp = {}
local hitboxes = {}

local function setupCharacter(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	root = c:WaitForChild("HumanoidRootPart")
end

setupCharacter(LP.Character or LP.CharacterAdded:Wait())

LP.CharacterAdded:Connect(function(c)
	setupCharacter(c)
	task.wait(0.1)
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteMonitor"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(150, 155)
frame.Position = UDim2.fromOffset(15, 100)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "RemoteMonitor"
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = frame

local function button(text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -10, 0, 27)
	b.Position = UDim2.fromOffset(5, y)
	b.Text = text
	b.TextScaled = true
	b.Parent = frame
	return b
end

local espBtn = button("ESP: OFF", 30)
local flyBtn = button("Fly: OFF", 60)
local noclipBtn = button("Noclip: OFF", 90)
local hitboxBtn = button("Hitbox: OFF", 120)

-- ESP
local function removeESP(p)
	if esp[p] then
		esp[p]:Destroy()
		esp[p] = nil
	end
end

local function addESP(p)
	if p == LP or not espOn then return end

	local c = p.Character
	if not c then return end

	removeESP(p)

	local h = Instance.new("Highlight")
	h.Name = "RemoteMonitorESP"
	h.Adornee = c
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = c

	esp[p] = h
end

local function refreshESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			if espOn then
				addESP(p)
			else
				removeESP(p)
			end
		end
	end
end

espBtn.MouseButton1Click:Connect(function()
	espOn = not espOn
	espBtn.Text = "ESP: " .. (espOn and "ON" or "OFF")
	refreshESP()
end)

local function watchPlayer(p)
	if p == LP then return end

	p.CharacterAdded:Connect(function()
		task.wait()
		if espOn then
			addESP(p)
		end
	end)

	if p.Character and espOn then
		addESP(p)
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	watchPlayer(p)
end

Players.PlayerAdded:Connect(watchPlayer)

Players.PlayerRemoving:Connect(function(p)
	removeESP(p)
	if hitboxes[p] then
		hitboxes[p]:Destroy()
		hitboxes[p] = nil
	end
end)

-- Fly
flyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	flyBtn.Text = "Fly: " .. (fly and "ON" or "OFF")
end)

-- Noclip
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

-- Hitbox visualization
local function removeHitbox(p)
	if hitboxes[p] then
		hitboxes[p]:Destroy()
		hitboxes[p] = nil
	end
end

local function addHitbox(p)
	if p == LP or not hitboxOn then return end

	local c = p.Character
	if not c then return end

	local rootPart = c:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	removeHitbox(p)

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "HitboxDisplay"
	box.Adornee = rootPart
	box.Size = rootPart.Size
	box.AlwaysOnTop = true
	box.Transparency = 0.5
	box.ZIndex = 5
	box.Parent = rootPart

	hitboxes[p] = box
end

local function refreshHitboxes()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			if hitboxOn then
				addHitbox(p)
			else
				removeHitbox(p)
			end
		end
	end
end

hitboxBtn.MouseButton1Click:Connect(function()
	hitboxOn = not hitboxOn
	hitboxBtn.Text = "Hitbox: " .. (hitboxOn and "ON" or "OFF")
	refreshHitboxes()
end)

-- Continuous updates
RunService.RenderStepped:Connect(function()
	if char and hum and root then
		if noclip then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		else
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end

		if fly then
			local move = hum.MoveDirection
			local vertical = 0

			if UIS:IsKeyDown(Enum.KeyCode.Space) then
				vertical = speed
			elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
				vertical = -speed
			end

			root.AssemblyLinearVelocity =
				Vector3.new(move.X * speed, vertical, move.Z * speed)
		end
	end

	-- Recreate hitbox displays if characters change
	if hitboxOn then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP then
				local c = p.Character
				local r = c and c:FindFirstChild("HumanoidRootPart")

				if r and (not hitboxes[p] or hitboxes[p].Adornee ~= r) then
					addHitbox(p)
				end
			end
		end
	end
end)

-- Draggable panel
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

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
