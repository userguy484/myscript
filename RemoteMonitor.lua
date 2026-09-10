-- CoolGuy Creation
-- Fling / Fly / Noclip
-- For your own Roblox Studio game

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Character
local Humanoid
local Root

local function GetCharacter()
	Character = Player.Character or Player.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
end

GetCharacter()

--------------------------------------------------
-- GUI
--------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "CoolGuy Creation"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(300, 230)
Main.Position = UDim2.new(0, 20, 0.5, -115)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-50,0,40)
Title.Position = UDim2.fromOffset(12,0)
Title.BackgroundTransparency = 1
Title.Text = "CoolGuy Creation"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(30,30)
Close.Position = UDim2.new(1,-40,0,5)
Close.BackgroundColor3 = Color3.fromRGB(150,45,45)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.Font = Enum.Font.GothamBold
Close.Parent = Main

Instance.new("UICorner", Close).CornerRadius = UDim.new(0,6)

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

--------------------------------------------------
-- BUTTON CREATOR
--------------------------------------------------

local function Button(Text, Y)
	local B = Instance.new("TextButton")
	B.Size = UDim2.new(1,-24,0,42)
	B.Position = UDim2.fromOffset(12,Y)
	B.BackgroundColor3 = Color3.fromRGB(40,40,40)
	B.Text = Text
	B.TextColor3 = Color3.new(1,1,1)
	B.Font = Enum.Font.GothamBold
	B.TextSize = 13
	B.Parent = Main

	Instance.new("UICorner", B).CornerRadius = UDim.new(0,7)

	return B
end

local FlyButton = Button("Fly: OFF",45)
local NoclipButton = Button("Noclip: OFF",93)
local FlingButton = Button("Fling",141)

--------------------------------------------------
-- NOCLIP
--------------------------------------------------

local Noclip = false

RunService.Stepped:Connect(function()

	if not Character then return end

	for _,Part in ipairs(Character:GetDescendants()) do
		if Part:IsA("BasePart") then
			Part.CanCollide = not Noclip
		end
	end

end)

NoclipButton.MouseButton1Click:Connect(function()

	Noclip = not Noclip

	if Noclip then
		NoclipButton.Text = "Noclip: ON"
	else
		NoclipButton.Text = "Noclip: OFF"
	end

end)

--------------------------------------------------
-- FLY
--------------------------------------------------

local Fly = false
local FlySpeed = 60

local FlyVelocity
local FlyConnection

FlyButton.MouseButton1Click:Connect(function()

	Fly = not Fly

	if Fly then

		FlyButton.Text = "Fly: ON"

		FlyVelocity = Instance.new("BodyVelocity")
		FlyVelocity.MaxForce = Vector3.new(1e9,1e9,1e9)
		FlyVelocity.Velocity = Vector3.zero
		FlyVelocity.Parent = Root

		FlyConnection = RunService.RenderStepped:Connect(function()

			if not Fly or not Root then return end

			local Camera = workspace.CurrentCamera
			local Direction = Vector3.zero

			if UIS:IsKeyDown(Enum.KeyCode.W) then
				Direction += Camera.CFrame.LookVector
			end

			if UIS:IsKeyDown(Enum.KeyCode.S) then
				Direction -= Camera.CFrame.LookVector
			end

			if UIS:IsKeyDown(Enum.KeyCode.A) then
				Direction -= Camera.CFrame.RightVector
			end

			if UIS:IsKeyDown(Enum.KeyCode.D) then
				Direction += Camera.CFrame.RightVector
			end

			if UIS:IsKeyDown(Enum.KeyCode.Space) then
				Direction += Vector3.yAxis
			end

			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
				Direction -= Vector3.yAxis
			end

			if Direction.Magnitude > 0 then
				Direction = Direction.Unit * FlySpeed
			end

			FlyVelocity.Velocity = Direction

		end)

	else

		FlyButton.Text = "Fly: OFF"

		if FlyConnection then
			FlyConnection:Disconnect()
			FlyConnection = nil
		end

		if FlyVelocity then
			FlyVelocity:Destroy()
			FlyVelocity = nil
		end

		if Root then
			Root.AssemblyLinearVelocity = Vector3.zero
		end

	end

end)

--------------------------------------------------
-- PHYSICS FLING
--------------------------------------------------

FlingButton.MouseButton1Click:Connect(function()

	if not Root then
		return
	end

	-- Short physics burst upward/forward.
	Root.AssemblyLinearVelocity =
		Root.CFrame.LookVector * 120
		+ Vector3.new(0,150,0)

	Root.AssemblyAngularVelocity =
		Vector3.new(0,80,0)

	FlingButton.Text = "FLING!"

	task.delay(0.5,function()
		if FlingButton.Parent then
			FlingButton.Text = "Fling"
		end
	end)

end)

--------------------------------------------------
-- RESPAWN
--------------------------------------------------

Player.CharacterAdded:Connect(function()

	task.wait(0.5)

	GetCharacter()

	Fly = false
	Noclip = false

	FlyButton.Text = "Fly: OFF"
	NoclipButton.Text = "Noclip: OFF"

	if FlyVelocity then
		FlyVelocity:Destroy()
		FlyVelocity = nil
	end

	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

end)

--------------------------------------------------
-- DRAG
--------------------------------------------------

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = true
		DragStart = Input.Position
		StartPosition = Main.Position
	end

end)

UIS.InputEnded:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = false
	end

end)

UIS.InputChanged:Connect(function(Input)

	if not Dragging then return end
	if Input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

	local Delta = Input.Position - DragStart

	Main.Position = UDim2.new(
		StartPosition.X.Scale,
		StartPosition.X.Offset + Delta.X,
		StartPosition.Y.Scale,
		StartPosition.Y.Offset + Delta.Y
	)

end)

print("CoolGuy Creation loaded")
