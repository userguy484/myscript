-- RemoteMonitor.luaa
-- RemoteEvent monitor for your own Roblox Studio game

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- GUI
--------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "RemoteMonitor"
Gui.ResetOnSpawn = false
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 430)
Main.Position = UDim2.new(0, 20, 0.5, -215)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

--------------------------------------------------
-- TITLE
--------------------------------------------------

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.new(0, 12, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "REMOTE MONITOR"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -38, 0, 8)
Close.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 12
Close.Parent = Main

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

--------------------------------------------------
-- POSITION
--------------------------------------------------

local PositionBox = Instance.new("TextLabel")
PositionBox.Size = UDim2.new(1, -24, 0, 60)
PositionBox.Position = UDim2.new(0, 12, 0, 48)
PositionBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PositionBox.TextColor3 = Color3.new(1, 1, 1)
PositionBox.Font = Enum.Font.Code
PositionBox.TextSize = 13
PositionBox.TextXAlignment = Enum.TextXAlignment.Left
PositionBox.TextYAlignment = Enum.TextYAlignment.Center
PositionBox.Text = "Position\nX: 0    Y: 0    Z: 0"
PositionBox.Parent = Main

Instance.new("UICorner", PositionBox).CornerRadius = UDim.new(0, 7)

--------------------------------------------------
-- STATUS
--------------------------------------------------

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -24, 0, 25)
Status.Position = UDim2.new(0, 12, 0, 115)
Status.BackgroundTransparency = 1
Status.Text = "● Monitoring RemoteEvents"
Status.TextColor3 = Color3.fromRGB(100, 255, 100)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

--------------------------------------------------
-- LOG TITLE
--------------------------------------------------

local LogTitle = Instance.new("TextLabel")
LogTitle.Size = UDim2.new(1, -24, 0, 25)
LogTitle.Position = UDim2.new(0, 12, 0, 140)
LogTitle.BackgroundTransparency = 1
LogTitle.Text = "RECENT ACTIVE REMOTES"
LogTitle.TextColor3 = Color3.new(1, 1, 1)
LogTitle.Font = Enum.Font.GothamBold
LogTitle.TextSize = 12
LogTitle.TextXAlignment = Enum.TextXAlignment.Left
LogTitle.Parent = Main

--------------------------------------------------
-- LOG LIST
--------------------------------------------------

local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -24, 0, 230)
List.Position = UDim2.new(0, 12, 0, 165)
List.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.CanvasSize = UDim2.new(0, 0, 0, 0)
List.Parent = Main

Instance.new("UICorner", List).CornerRadius = UDim.new(0, 7)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 3)
Layout.Parent = List

--------------------------------------------------
-- CLEAR
--------------------------------------------------

local Clear = Instance.new("TextButton")
Clear.Size = UDim2.new(0, 90, 0, 28)
Clear.Position = UDim2.new(1, -102, 1, -35)
Clear.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Clear.Text = "CLEAR"
Clear.TextColor3 = Color3.new(1, 1, 1)
Clear.Font = Enum.Font.GothamBold
Clear.TextSize = 11
Clear.Parent = Main

Instance.new("UICorner", Clear).CornerRadius = UDim.new(0, 6)

--------------------------------------------------
-- ADD LOG
--------------------------------------------------

local function AddLog(RemoteName, PlayerName, Position)

	local Entry = Instance.new("TextLabel")

	Entry.Size = UDim2.new(1, -8, 0, 55)
	Entry.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	Entry.TextColor3 = Color3.new(1, 1, 1)
	Entry.Font = Enum.Font.Code
	Entry.TextSize = 11
	Entry.TextXAlignment = Enum.TextXAlignment.Left
	Entry.TextYAlignment = Enum.TextYAlignment.Center

	local PositionText = "Unknown"

	if Position then
		PositionText = string.format(
			"X: %.0f  Y: %.0f  Z: %.0f",
			Position.X,
			Position.Y,
			Position.Z
		)
	end

	Entry.Text =
		"[" .. os.date("%H:%M:%S") .. "] "
		.. tostring(RemoteName)
		.. "\nPlayer: "
		.. tostring(PlayerName)
		.. "\n"
		.. PositionText

	Entry.Parent = List

	Instance.new("UICorner", Entry).CornerRadius = UDim.new(0, 5)

	List.CanvasSize = UDim2.new(
		0,
		0,
		0,
		Layout.AbsoluteContentSize.Y + 8
	)

	List.CanvasPosition = Vector2.new(0, math.huge)

	-- Keep only the newest 100 entries
	local Entries = {}

	for _, Child in ipairs(List:GetChildren()) do
		if Child:IsA("TextLabel") then
			table.insert(Entries, Child)
		end
	end

	if #Entries > 100 then
		Entries[1]:Destroy()
	end
end

--------------------------------------------------
-- POSITION UPDATE
--------------------------------------------------

local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()

	local Character = LocalPlayer.Character

	if not Character then
		return
	end

	local Root = Character:FindFirstChild("HumanoidRootPart")

	if not Root then
		return
	end

	local P = Root.Position

	PositionBox.Text = string.format(
		"Position\nX: %.0f    Y: %.0f    Z: %.0f",
		P.X,
		P.Y,
		P.Z
	)
end)

--------------------------------------------------
-- MANUAL GAME LOGGING
--------------------------------------------------
-- From another script in YOUR game you can use:
--
-- _G.RemoteMonitorLog("MyRemote")
--
--------------------------------------------------

_G.RemoteMonitorLog = function(RemoteName)

	local Character = LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")

	AddLog(
		RemoteName,
		LocalPlayer.Name,
		Root and Root.Position
	)
end

--------------------------------------------------
-- CLEAR
--------------------------------------------------

Clear.MouseButton1Click:Connect(function()

	for _, Child in ipairs(List:GetChildren()) do
		if Child:IsA("TextLabel") then
			Child:Destroy()
		end
	end

	List.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

--------------------------------------------------
-- CLOSE
--------------------------------------------------

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

--------------------------------------------------
-- DRAG
--------------------------------------------------

local UserInputService = game:GetService("UserInputService")

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1 then

		Dragging = true
		DragStart = Input.Position
		StartPosition = Main.Position

		Input.Changed:Connect(function()

			if Input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end

		end)
	end
end)

UserInputService.InputChanged:Connect(function(Input)

	if not Dragging then
		return
	end

	if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local Delta = Input.Position - DragStart

	Main.Position = UDim2.new(
		StartPosition.X.Scale,
		StartPosition.X.Offset + Delta.X,
		StartPosition.Y.Scale,
		StartPosition.Y.Offset + Delta.Y
	)
end)

print("REMOTE MONITOR LOADED")
