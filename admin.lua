local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character
local Humanoid
local Root

local function UpdateCharacter()
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
end

UpdateCharacter()

local NoclipEnabled = false
local FlyEnabled = false
local ESPEnabled = false
local SitEnabled = false

local SelectedPlayer = nil

local NoclipConnection
local FlyConnection
local SitThread

local OriginalCollision = {}
local ESPObjects = {}

--------------------------------------------------
-- GUI
--------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "AdminGui"
Gui.ResetOnSpawn = false
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0,140,0,40)
OpenButton.Position = UDim2.new(0.5,-70,0,15)
OpenButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
OpenButton.TextColor3 = Color3.new(1,1,1)
OpenButton.Text = "OPEN ADMIN"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 14
OpenButton.Visible = false
OpenButton.Parent = Gui

Instance.new("UICorner",OpenButton).CornerRadius = UDim.new(0,10)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,360,0,625)
Main.Position = UDim2.new(0.5,-180,0.5,-312)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-55,0,45)
Title.Position = UDim2.new(0,15,0,5)
Title.BackgroundTransparency = 1
Title.Text = "ADMIN PANEL"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,35,0,35)
Close.Position = UDim2.new(1,-45,0,8)
Close.BackgroundColor3 = Color3.fromRGB(150,45,45)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 16
Close.Parent = Main

Instance.new("UICorner",Close).CornerRadius = UDim.new(0,9)

--------------------------------------------------
-- BUTTON CREATOR
--------------------------------------------------

local function CreateButton(text,y)

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1,-30,0,40)
	Button.Position = UDim2.new(0,15,0,y)
	Button.BackgroundColor3 = Color3.fromRGB(35,35,35)
	Button.TextColor3 = Color3.new(1,1,1)
	Button.Text = text
	Button.Font = Enum.Font.GothamBold
	Button.TextSize = 14
	Button.AutoButtonColor = false
	Button.Parent = Main

	Instance.new("UICorner",Button).CornerRadius = UDim.new(0,9)

	Button.MouseEnter:Connect(function()
		Button.BackgroundColor3 = Color3.fromRGB(50,50,50)
	end)

	Button.MouseLeave:Connect(function()
		Button.BackgroundColor3 = Color3.fromRGB(35,35,35)
	end)

	return Button
end

--------------------------------------------------
-- BUTTONS
--------------------------------------------------

local NoclipButton = CreateButton("Noclip: OFF",55)
local FlyButton = CreateButton("Fly: OFF",100)
local ESPButton = CreateButton("ESP: OFF",145)
local ViewButton = CreateButton("View Selected",190)
local ResetViewButton = CreateButton("Reset View",235)

--------------------------------------------------
-- PLAYER LIST
--------------------------------------------------

local PlayerTitle = Instance.new("TextLabel")
PlayerTitle.Size = UDim2.new(1,-30,0,30)
PlayerTitle.Position = UDim2.new(0,15,0,280)
PlayerTitle.BackgroundTransparency = 1
PlayerTitle.Text = "PLAYER LIST"
PlayerTitle.TextColor3 = Color3.new(1,1,1)
PlayerTitle.Font = Enum.Font.GothamBold
PlayerTitle.TextSize = 15
PlayerTitle.TextXAlignment = Enum.TextXAlignment.Left
PlayerTitle.Parent = Main

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1,-30,0,215)
PlayerList.Position = UDim2.new(0,15,0,315)
PlayerList.BackgroundColor3 = Color3.fromRGB(15,15,15)
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 5
PlayerList.Parent = Main

Instance.new("UICorner",PlayerList).CornerRadius = UDim.new(0,9)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,5)
Layout.Parent = PlayerList

local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Size = UDim2.new(1,-30,0,30)
SelectedLabel.Position = UDim2.new(0,15,0,540)
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.Text = "Selected: None"
SelectedLabel.TextColor3 = Color3.fromRGB(200,200,200)
SelectedLabel.Font = Enum.Font.Gotham
SelectedLabel.TextSize = 13
SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedLabel.Parent = Main

local SitButton = CreateButton("Sit to Player: OFF",575)

--------------------------------------------------
-- REFRESH PLAYER LIST
--------------------------------------------------

local function RefreshPlayers()

	for _,child in ipairs(PlayerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _,player in ipairs(Players:GetPlayers()) do

		if player ~= LocalPlayer then

			local Button = Instance.new("TextButton")
			Button.Size = UDim2.new(1,-10,0,32)
			Button.BackgroundColor3 = Color3.fromRGB(30,30,30)
			Button.TextColor3 = Color3.new(1,1,1)
			Button.Text = player.DisplayName.."  @"..player.Name
			Button.Font = Enum.Font.Gotham
			Button.TextSize = 12
			Button.AutoButtonColor = false
			Button.Parent = PlayerList

			Instance.new("UICorner",Button).CornerRadius = UDim.new(0,7)

			Button.MouseButton1Click:Connect(function()

				SelectedPlayer = player
				SelectedLabel.Text = "Selected: "..player.Name

				for _,b in ipairs(PlayerList:GetChildren()) do
					if b:IsA("TextButton") then
						b.BackgroundColor3 = Color3.fromRGB(30,30,30)
					end
				end

				Button.BackgroundColor3 = Color3.fromRGB(55,90,150)
			end)
		end
	end

	PlayerList.CanvasSize = UDim2.new(
		0,
		0,
		0,
		Layout.AbsoluteContentSize.Y + 10
	)
end

RefreshPlayers()

Players.PlayerAdded:Connect(RefreshPlayers)

Players.PlayerRemoving:Connect(function(player)

	if SelectedPlayer == player then
		SelectedPlayer = nil
		SelectedLabel.Text = "Selected: None"

		if SitEnabled then
			SitEnabled = false
			SitButton.Text = "Sit to Player: OFF"
		end
	end

	RefreshPlayers()
end)

--------------------------------------------------
-- NOCLIP
--------------------------------------------------

local function SetNoclip(enabled)

	NoclipEnabled = enabled

	if NoclipConnection then
		NoclipConnection:Disconnect()
		NoclipConnection = nil
	end

	if not enabled then

		for part,value in pairs(OriginalCollision) do
			if part and part.Parent then
				part.CanCollide = value
			end
		end

		OriginalCollision = {}
		NoclipButton.Text = "Noclip: OFF"

		return
	end

	NoclipButton.Text = "Noclip: ON"

	NoclipConnection = RunService.Stepped:Connect(function()

		if not Character then return end

		for _,part in ipairs(Character:GetDescendants()) do

			if part:IsA("BasePart") then

				if OriginalCollision[part] == nil then
					OriginalCollision[part] = part.CanCollide
				end

				part.CanCollide = false
			end
		end
	end)
end

NoclipButton.MouseButton1Click:Connect(function()
	SetNoclip(not NoclipEnabled)
end)

--------------------------------------------------
-- FLY
--------------------------------------------------

local Keys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	Ctrl = false
}

UserInputService.InputBegan:Connect(function(input,processed)

	if processed then return end

	if input.KeyCode == Enum.KeyCode.W then Keys.W = true end
	if input.KeyCode == Enum.KeyCode.A then Keys.A = true end
	if input.KeyCode == Enum.KeyCode.S then Keys.S = true end
	if input.KeyCode == Enum.KeyCode.D then Keys.D = true end
	if input.KeyCode == Enum.KeyCode.Space then Keys.Space = true end
	if input.KeyCode == Enum.KeyCode.LeftControl then Keys.Ctrl = true end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.KeyCode == Enum.KeyCode.W then Keys.W = false end
	if input.KeyCode == Enum.KeyCode.A then Keys.A = false end
	if input.KeyCode == Enum.KeyCode.S then Keys.S = false end
	if input.KeyCode == Enum.KeyCode.D then Keys.D = false end
	if input.KeyCode == Enum.KeyCode.Space then Keys.Space = false end
	if input.KeyCode == Enum.KeyCode.LeftControl then Keys.Ctrl = false end
end)

local function SetFly(enabled)

	FlyEnabled = enabled

	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

	if Humanoid then
		Humanoid.PlatformStand = false
	end

	if not enabled then
		FlyButton.Text = "Fly: OFF"
		return
	end

	FlyButton.Text = "Fly: ON"

	Humanoid.PlatformStand = true

	FlyConnection = RunService.RenderStepped:Connect(function()

		if not Root or not Root.Parent then return end

		local cf = Camera.CFrame
		local direction = Vector3.zero

		if Keys.W then direction += cf.LookVector end
		if Keys.S then direction -= cf.LookVector end
		if Keys.D then direction += cf.RightVector end
		if Keys.A then direction -= cf.RightVector end
		if Keys.Space then direction += Vector3.yAxis end
		if Keys.Ctrl then direction -= Vector3.yAxis end

		if direction.Magnitude > 0 then
			direction = direction.Unit * 70
		end

		Root.AssemblyLinearVelocity = direction
	end)
end

FlyButton.MouseButton1Click:Connect(function()
	SetFly(not FlyEnabled)
end)

--------------------------------------------------
-- ESP
--------------------------------------------------

local function RemoveESP()

	for _,objects in pairs(ESPObjects) do
		for _,object in ipairs(objects) do
			if object and object.Parent then
				object:Destroy()
			end
		end
	end

	ESPObjects = {}
end

local function AddESP(player)

	if player == LocalPlayer then return end
	if ESPObjects[player] then return end

	local character = player.Character
	if not character then return end

	local Highlight = Instance.new("Highlight")
	Highlight.Name = "AdminESP"
	Highlight.FillTransparency = 0.7
	Highlight.OutlineTransparency = 0
	Highlight.Parent = character

	ESPObjects[player] = {Highlight}
end

local function SetESP(enabled)

	ESPEnabled = enabled

	if not enabled then
		ESPButton.Text = "ESP: OFF"
		RemoveESP()
		return
	end

	ESPButton.Text = "ESP: ON"

	for _,player in ipairs(Players:GetPlayers()) do
		AddESP(player)
	end
end

ESPButton.MouseButton1Click:Connect(function()
	SetESP(not ESPEnabled)
end)

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function()

		task.wait(1)

		if ESPEnabled then
			AddESP(player)
		end
	end)
end)

--------------------------------------------------
-- VIEW
--------------------------------------------------

ViewButton.MouseButton1Click:Connect(function()

	if not SelectedPlayer then

		ViewButton.Text = "Select A Player!"

		task.delay(1,function()
			ViewButton.Text = "View Selected"
		end)

		return
	end

	local character = SelectedPlayer.Character
	if not character then return end

	local targetHumanoid = character:FindFirstChildOfClass("Humanoid")
	if not targetHumanoid then return end

	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = targetHumanoid
end)

ResetViewButton.MouseButton1Click:Connect(function()

	if Humanoid then
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = Humanoid
	end
end)

--------------------------------------------------
-- SIT TO PLAYER
-- TELEPORT EVERY SECOND
--------------------------------------------------

local function TeleportToSelected()

	if not SitEnabled then return end
	if not SelectedPlayer then return end
	if not Root or not Root.Parent then return end
	if not Humanoid or not Humanoid.Parent then return end

	local targetCharacter = SelectedPlayer.Character
	if not targetCharacter then return end

	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	Root.CFrame = targetRoot.CFrame * CFrame.new(0,0,-2.5)

	Root.AssemblyLinearVelocity = Vector3.zero
	Root.AssemblyAngularVelocity = Vector3.zero

	Humanoid.Sit = true
end

local function StopSit()

	SitEnabled = false

	SitButton.Text = "Sit to Player: OFF"
end

local function StartSit()

	if not SelectedPlayer then

		SitButton.Text = "Select A Player!"

		task.delay(1,function()
			if not SitEnabled then
				SitButton.Text = "Sit to Player: OFF"
			end
		end)

		return
	end

	SitEnabled = true
	SitButton.Text = "Sit to Player: ON"

	-- Immediate teleport
	TeleportToSelected()

	-- Teleport again every second
	SitThread = task.spawn(function()

		while SitEnabled do

			task.wait(1)

			if SitEnabled then
				TeleportToSelected()
			end
		end
	end)
end

SitButton.MouseButton1Click:Connect(function()

	if SitEnabled then
		StopSit()
	else
		StartSit()
	end
end)

--------------------------------------------------
-- CLOSE / OPEN
--------------------------------------------------

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
	OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
	OpenButton.Visible = false
	Main.Visible = true
end)

--------------------------------------------------
-- DRAG
--------------------------------------------------

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		Dragging = true
		DragStart = input.Position
		StartPosition = Main.Position

		input.Changed:Connect(function()

			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not Dragging then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

	local Delta = input.Position - DragStart

	Main.Position = UDim2.new(
		StartPosition.X.Scale,
		StartPosition.X.Offset + Delta.X,
		StartPosition.Y.Scale,
		StartPosition.Y.Offset + Delta.Y
	)
end)

--------------------------------------------------
-- RESPAWN
--------------------------------------------------

LocalPlayer.CharacterAdded:Connect(function()

	SitEnabled = false
	SitButton.Text = "Sit to Player: OFF"

	task.wait(0.5)

	UpdateCharacter()

	if NoclipEnabled then
		SetNoclip(true)
	end

	if ESPEnabled then

		for _,player in ipairs(Players:GetPlayers()) do
			AddESP(player)
		end
	end
end)

print("ADMIN GUI LOADED")
