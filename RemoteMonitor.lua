-- RemoteMonitor.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local fly = false
local noclip = false
local speed = 60
local char, hum, root

local function setupChar(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	root = c:WaitForChild("HumanoidRootPart")
end

setupChar(LP.Character or LP.CharacterAdded:Wait())

LP.CharacterAdded:Connect(function(c)
	setupChar(c)
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteMonitor"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(140, 120)
frame.Position = UDim2.fromOffset(15, 100)
frame.BackgroundTransparency = 0.15
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,25)
title.Text = "Admin"
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = frame

local function button(text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,-10,0,27)
	b.Position = UDim2.fromOffset(5,y)
	b.Text = text
	b.TextScaled = true
	b.Parent = frame
	return b
end

local espBtn = button("ESP: OFF",30)
local flyBtn = button("Fly: OFF",60)
local noclipBtn = button("Noclip: OFF",90)

-- ESP
local esp = {}

local function removeESP(p)
	if esp[p] then
		esp[p]:Destroy()
		esp[p] = nil
	end
end

local function addESP(p)
	if p == LP or not fly then
		return
	end

	local c = p.Character
	if not c then return end

	removeESP(p)

	local h = Instance.new("Highlight")
	h.Name = "ESP"
	h.Adornee = c
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = c

	esp[p] = h
end

local espOn = false

local function refreshESP()
	for _,p in ipairs(Players:GetPlayers()) do
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
	espBtn.Text = "ESP: "..(espOn and "ON" or "OFF")
	refreshESP()
end)

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		task.wait(.2)
		if espOn then addESP(p) end
	end)
end)

Players.PlayerRemoving:Connect(removeESP)

for _,p in ipairs(Players:GetPlayers()) do
	if p ~= LP then
		p.CharacterAdded:Connect(function()
			task.wait(.2)
			if espOn then addESP(p) end
		end)
	end
end

-- Fly stays enabled through respawn
flyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	flyBtn.Text = "Fly: "..(fly and "ON" or "OFF")
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = "Noclip: "..(noclip and "ON" or "OFF")
end)

RunService.RenderStepped:Connect(function()
	if not char or not hum or not root then return end

	if noclip then
		for _,v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end

	if fly then
		local move = hum.MoveDirection

		if move.Magnitude > 0 then
			root.AssemblyLinearVelocity = move.Unit * speed
		else
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end
end)
