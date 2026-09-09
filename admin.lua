--// ANIMATED ADMIN GUI
--// No character animation / no fling

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove old GUI
local old = PlayerGui:FindFirstChild("AnimatedAdmin")
if old then
	old:Destroy()
end

--// GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "AnimatedAdmin"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(340, 500)
Main.Position = UDim2.new(0, 20, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,12)
Corner.Parent = Main

--// Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-55,0,45)
Title.Position = UDim2.fromOffset(15,5)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ADMIN PANEL"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--// Close
local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(38,38)
Close.Position = UDim2.new(1,-45,0,8)
Close.Text = "×"
Close.TextSize = 28
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(180,50,50)
Close.BorderSizePixel = 0
Close.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0,10)
CloseCorner.Parent = Close

--// Reopen
local Reopen = Instance.new("TextButton")
Reopen.Size = UDim2.fromOffset(120,42)
Reopen.Position = UDim2.fromOffset(20,20)
Reopen.Text = "OPEN ADMIN"
Reopen.TextSize = 14
Reopen.Font = Enum.Font.GothamBold
Reopen.TextColor3 = Color3.new(1,1,1)
Reopen.BackgroundColor3 = Color3.fromRGB(45,45,55)
Reopen.Visible = false
Reopen.Parent = Gui

local ReopenCorner = Instance.new("UICorner")
ReopenCorner.CornerRadius = UDim.new(0,10)
ReopenCorner.Parent = Reopen

--// Button creator
local function CreateButton(text, y)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1,-30,0,40)
	Button.Position = UDim2.fromOffset(15,y)
	Button.Text = text
	Button.TextSize = 14
	Button.Font = Enum.Font.GothamBold
	Button.TextColor3 = Color3.new(1,1,1)
	Button.BackgroundColor3 = Color3.fromRGB(45,45,55)
	Button.BorderSizePixel = 0
	Button.AutoButtonColor = false
	Button.Parent = Main

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,9)
	c.Parent = Button

	Button.MouseEnter:Connect(function()
		TweenService:Create(
			Button,
			TweenInfo.new(.12),
			{BackgroundColor3 = Color3.fromRGB(70,70,85)}
		):Play()
	end)

	Button.MouseLeave:Connect(function()
		TweenService:Create(
			Button,
			TweenInfo.new(.12),
			{BackgroundColor3 = Color3.fromRGB(45,45,55)}
		):Play()
	end)

	return Button
end

--// Noclip
local Noclip = false
local NoclipButton = CreateButton("Noclip: OFF",55)

NoclipButton.MouseButton1Click:Connect(function()
	Noclip = not Noclip
	NoclipButton.Text = "Noclip: "..(Noclip and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
	if not Noclip then return end

	local Character = LocalPlayer.Character
	if not Character then return end

	for _,v in ipairs(Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end)

--// FLY
local Flying = false
local FlySpeed = 60
local FlyConnection

local FlyButton = CreateButton("Fly: OFF",105)

local function StopFly()
	Flying = false
	FlyButton.Text = "Fly: OFF"

	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

	local Character = LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")

	if Root then
		Root.AssemblyLinearVelocity = Vector3.zero
	end
end

local function StartFly()
	if Flying then return end

	local Character = LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")

	if not Root then return end

	Flying = true
	FlyButton.Text = "Fly: ON"

	FlyConnection = RunService.RenderStepped:Connect(function()
		if not Flying then return end

		Character = LocalPlayer.Character
		Root = Character and Character:FindFirstChild("HumanoidRootPart")

		if not Character or not Root then
			StopFly()
			return
		end

		local Camera = workspace.CurrentCamera
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")

		if not Humanoid then return end

		local Direction = Vector3.zero

		-- WASD movement
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

		-- Up / down
		if UIS:IsKeyDown(Enum.KeyCode.Space) then
			Direction += Vector3.new(0,1,0)
		end

		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
			Direction -= Vector3.new(0,1,0)
		end

		if Direction.Magnitude > 0 then
			Direction = Direction.Unit * FlySpeed
		end

		Root.AssemblyLinearVelocity = Direction
	end)
end

FlyButton.MouseButton1Click:Connect(function()
	if Flying then
		StopFly()
	else
		StartFly()
	end
end)

--// ESP
local ESP = false
local ESPButton = CreateButton("ESP: OFF",155)

local function AddESP(plr)
	if plr == LocalPlayer then return end
	if not plr.Character then return end

	if plr.Character:FindFirstChild("AdminESP") then
		return
	end

	local Highlight = Instance.new("Highlight")
	Highlight.Name = "AdminESP"
	Highlight.FillTransparency = .65
	Highlight.OutlineTransparency = 0
	Highlight.Parent = plr.Character
end

local function RemoveESP(plr)
	if plr.Character then
		local Highlight = plr.Character:FindFirstChild("AdminESP")
		if Highlight then
			Highlight:Destroy()
		end
	end
end

ESPButton.MouseButton1Click:Connect(function()
	ESP = not ESP
	ESPButton.Text = "ESP: "..(ESP and "ON" or "OFF")

	for _,plr in ipairs(Players:GetPlayers()) do
		if ESP then
			AddESP(plr)
		else
			RemoveESP(plr)
		end
	end
end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(1)

		if ESP then
			AddESP(plr)
		end
	end)
end)

--// Reset camera
local ResetView = CreateButton("Reset View",205)

ResetView.MouseButton1Click:Connect(function()
	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		workspace.CurrentCamera.CameraSubject = Humanoid
	end
end)

--// PLAYER LIST
local PlayerTitle = Instance.new("TextLabel")
PlayerTitle.Size = UDim2.new(1,-30,0,30)
PlayerTitle.Position = UDim2.fromOffset(15,250)
PlayerTitle.BackgroundTransparency = 1
PlayerTitle.Text = "PLAYER LIST"
PlayerTitle.TextColor3 = Color3.new(1,1,1)
PlayerTitle.TextSize = 16
PlayerTitle.Font = Enum.Font.GothamBold
PlayerTitle.TextXAlignment = Enum.TextXAlignment.Left
PlayerTitle.Parent = Main

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1,-30,0,170)
PlayerList.Position = UDim2.fromOffset(15,285)
PlayerList.BackgroundColor3 = Color3.fromRGB(18,18,22)
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 5
PlayerList.CanvasSize = UDim2.new(0,0,0,0)
PlayerList.Parent = Main

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0,8)
ListCorner.Parent = PlayerList

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,5)
Layout.Parent = PlayerList

local function RefreshPlayers()
	for _,v in ipairs(PlayerList:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	local Count = 0

	for _,plr in ipairs(Players:GetPlayers()) do
		Count += 1

		local Button = Instance.new("TextButton")
		Button.Size = UDim2.new(1,-10,0,32)
		Button.Text = plr.Name
		Button.TextSize = 13
		Button.Font = Enum.Font.Gotham
		Button.TextColor3 = Color3.new(1,1,1)
		Button.BackgroundColor3 = Color3.fromRGB(40,40,48)
		Button.BorderSizePixel = 0
		Button.AutoButtonColor = false
		Button.Parent = PlayerList

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0,7)
		c.Parent = Button

		Button.MouseEnter:Connect(function()
			TweenService:Create(
				Button,
				TweenInfo.new(.1),
				{BackgroundColor3 = Color3.fromRGB(65,65,75)}
			):Play()
		end)

		Button.MouseLeave:Connect(function()
			TweenService:Create(
				Button,
				TweenInfo.new(.1),
				{BackgroundColor3 = Color3.fromRGB(40,40,48)}
			):Play()
		end)

		Button.MouseButton1Click:Connect(function()
			if plr.Character then
				local Humanoid = plr.Character:FindFirstChildOfClass("Humanoid")

				if Humanoid then
					workspace.CurrentCamera.CameraSubject = Humanoid
				end
			end
		end)
	end

	PlayerList.CanvasSize = UDim2.fromOffset(0,Count * 37)
end

Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)

RefreshPlayers()

--// Drag GUI
local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = true
		DragStart = input.Position
		StartPosition = Main.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local Delta = input.Position - DragStart

		Main.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = false
	end
end)

--// Close animation
Close.MouseButton1Click:Connect(function()
	local Tween = TweenService:Create(
		Main,
		TweenInfo.new(.25,Enum.EasingStyle.Back,Enum.EasingDirection.In),
		{
			Size = UDim2.fromOffset(0,0),
			BackgroundTransparency = 1
		}
	)

	Tween:Play()
	Tween.Completed:Wait()

	Main.Visible = false
	Main.Size = UDim2.fromOffset(340,500)
	Main.BackgroundTransparency = 0
	Reopen.Visible = true
end)

--// Reopen animation
Reopen.MouseButton1Click:Connect(function()
	Reopen.Visible = false
	Main.Visible = true
	Main.Size = UDim2.fromOffset(0,0)

	TweenService:Create(
		Main,
		TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
		{Size = UDim2.fromOffset(340,500)}
	):Play()
end)

print("ADMIN GUI LOADED")
