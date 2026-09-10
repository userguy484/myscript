-- RemoteMonitor.lua
-- LocalScript for your own Roblox Studio game

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local OWNER_ID = 11522003214

if LP.UserId ~= OWNER_ID then
	return
end

local fly = false
local noclip = false
local espOn = false
local hitboxOn = false
local speed = 60

local character
local humanoid
local root

local espObjects = {}
local hitboxObjects = {}

local function setupCharacter(c)
	character = c
	humanoid = c:WaitForChild("Humanoid")
	root = c:WaitForChild("HumanoidRootPart")
end

if LP.Character then
	setupCharacter(LP.Character)
end

LP.CharacterAdded:Connect(function(c)
	setupCharacter(c)
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteMonitor"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(155, 150)
frame.Position = UDim2.fromOffset(15, 100)
frame.BackgroundTransparency = 0.15
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "RemoteMonitor"
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = frame

local function makeButton(text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -10, 0, 27)
	b.Position = UDim2.fromOffset(5, y)
	b.Text = text
	b.TextScaled = true
	b.Parent = frame
	return b
end

local espButton = makeButton("ESP: OFF", 30)
local flyButton = makeButton("Fly: OFF", 60)
local noclipButton = makeButton("Noclip: OFF", 90)
local hitboxButton = makeButton("Hitbox: OFF", 120)

-- ESP
local function removeESP(p)
	if espObjects[p] then
		espObjects[p]:Destroy()
		espObjects[p] = nil
	end
end

local function addESP(p)
	if p == LP or not espOn then
		return
	end

	local c = p.Character
	if not c then
		return
	end

	removeESP(p)

	local h = Instance.new("Highlight")
	h.Name = "RemoteMonitorESP"
	h.Adornee = c
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = c

	espObjects[p] = h
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

local function watchPlayer(p)
	if p == LP then
		return
	end

	p.CharacterAdded:Connect(function()
		task.wait()
		if espOn then
			addESP(p)
		end
	end)

	if espOn then
		addESP(p)
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	watchPlayer(p)
end

Players.PlayerAdded:Connect(watchPlayer)

Players.PlayerRemoving:Connect(function(p)
	removeESP(p)

	if hitboxObjects[p] then
		hitboxObjects[p]:Destroy()
		hitboxObjects[p] = nil
	end
end)

espButton.MouseButton1Click:Connect(function()
	espOn = not espOn
	espButton.Text = "ESP: " .. (espOn and "ON" or "OFF")
	refreshESP()
end)

-- Fly
flyButton.MouseButton1Click:Connect(function()
	fly = not fly
	flyButton.Text = "Fly: " .. (fly and "ON" or "OFF")

	if not fly and root then
		root.AssemblyLinearVelocity = Vector3.zero
	end
end)

-- Noclip
noclipButton.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipButton.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

-- Hitbox visualization
local function removeHitbox(p)
	if hitboxObjects[p] then
		hitboxObjects[p]:Destroy()
		hitboxObjects[p] = nil
	end
end

local function addHitbox(p)
	if p == LP or not hitboxOn then
		return
	end

	local c = p.Character
	local r = c and c:FindFirstChild("HumanoidRootPart")

	if not r then
		return
	end

	removeHitbox(p)

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "HitboxDisplay"
	box.Adornee = r
	box.Size = r.Size
	box.AlwaysOnTop = true
	box.Transparency = 0.5
	box.ZIndex = 5
	box.Parent = r

	hitboxObjects[p] = box
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

hitboxButton.MouseButton1Click:Connect(function()
	hitboxOn = not hitboxOn
	hitboxButton.Text = "Hitbox: " .. (hitboxOn and "ON" or "OFF")
	refreshHitboxes()
end)

-- Main loop
RunService.RenderStepped:Connect(function()
	if character and humanoid and root then

		-- Noclip
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not noclip
			end
		end

		-- Camera-direction Fly
		if fly then
			local camera = workspace.CurrentCamera

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
				root.AssemblyLinearVelocity = direction.Unit * speed
			else
				root.AssemblyLinearVelocity = Vector3.zero
			end
		end
	end

	-- Keep hitbox displays updated
	if hitboxOn then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP then
				local c = p.Character
				local r = c and c:FindFirstChild("HumanoidRootPart")

				if r then
					local box = hitboxObjects[p]

					if not box or box.Adornee ~= r then
						addHitbox(p)
					end
				end
			end
		end
	end
end)

-- Draggable GUI
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

UIS.InputChanged:Connect(function(input)
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

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
