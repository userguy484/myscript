-- admin.lua
-- Fly + Noclip + Self Fling
-- For your own Roblox Studio game

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local flying = false
local noclip = false
local speed = 60

local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
	character = char
	root = char:WaitForChild("HumanoidRootPart")
end)

local gui = Instance.new("ScreenGui")
gui.Name = "AdminGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(190, 180)
frame.Position = UDim2.fromOffset(20, 100)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Parent = gui

local function button(text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, 40)
	b.Position = UDim2.fromOffset(10, y)
	b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextSize = 18
	b.Text = text
	b.Parent = frame
	return b
end

local flyButton = button("Fly: OFF", 10)
local noclipButton = button("Noclip: OFF", 55)
local flingButton = button("Self Fling", 100)

-- Fly
flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	flyButton.Text = "Fly: " .. (flying and "ON" or "OFF")

	if not flying and root then
		root.AssemblyLinearVelocity = Vector3.zero
	end
end)

RunService.RenderStepped:Connect(function()
	if not flying or not root then return end

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

	root.AssemblyLinearVelocity =
		direction.Magnitude > 0 and direction.Unit * speed or Vector3.zero
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

-- Self fling
flingButton.MouseButton1Click:Connect(function()
	if root then
		root.AssemblyLinearVelocity =
			root.CFrame.LookVector * 250 +
			Vector3.new(0, 100, 0)
	end
end)
