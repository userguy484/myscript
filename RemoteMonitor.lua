-- RemoteMonitor.luaa
-- ONE SCRIPT - creates its own GUI
-- For your own Roblox Studio game

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--------------------------------------------------
-- GUI
--------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "RemoteMonitor"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(400, 450)
Main.Position = UDim2.new(0, 20, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

--------------------------------------------------
-- TITLE
--------------------------------------------------

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.fromOffset(12, 5)
Title.BackgroundTransparency = 1
Title.Text = "REMOTE MONITOR"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--------------------------------------------------
-- CLOSE
--------------------------------------------------

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(30, 30)
Close.Position = UDim2.new(1, -40, 0, 8)
Close.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 12
Close.Parent = Main

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

--------------------------------------------------
-- POSITION
--------------------------------------------------

local Position = Instance.new("TextLabel")
Position.Size = UDim2.new(1, -24, 0, 65)
Position.Position = UDim2.fromOffset(12, 48)
Position.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Position.TextColor3 = Color3.new(1,1,1)
Position.Font = Enum.Font.Code
Position.TextSize = 14
Position.TextXAlignment = Enum.TextXAlignment.Left
Position.TextYAlignment = Enum.TextYAlignment.Center
Position.Text = "POSITION\nX: 0    Y: 0    Z: 0"
Position.Parent = Main

Instance.new("UICorner", Position).CornerRadius = UDim.new(0, 7)

--------------------------------------------------
-- STATUS
--------------------------------------------------

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -24, 0, 25)
Status.Position = UDim2.fromOffset(12, 120)
Status.BackgroundTransparency = 1
Status.Text = "● MONITORING"
Status.TextColor3 = Color3.fromRGB(80, 255, 80)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

--------------------------------------------------
-- REMOTE LIST
--------------------------------------------------

local ListTitle = Instance.new("TextLabel")
ListTitle.Size = UDim2.new(1, -24, 0, 25)
ListTitle.Position = UDim2.fromOffset(12, 145)
ListTitle.BackgroundTransparency = 1
ListTitle.Text = "ACTIVE REMOTE EVENTS"
ListTitle.TextColor3 = Color3.new(1,1,1)
ListTitle.Font = Enum.Font.GothamBold
ListTitle.TextSize = 12
ListTitle.TextXAlignment = Enum.TextXAlignment.Left
ListTitle.Parent = Main

local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -24, 0, 235)
List.Position = UDim2.fromOffset(12, 170)
List.BackgroundColor3 = Color3.fromRGB(10,10,10)
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.CanvasSize = UDim2.new(0,0,0,0)
List.Parent = Main

Instance.new("UICorner", List).CornerRadius = UDim.new(0, 7)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 3)
Layout.Parent = List

--------------------------------------------------
-- CLEAR
--------------------------------------------------

local Clear = Instance.new("TextButton")
Clear.Size = UDim2.fromOffset(90, 30)
Clear.Position = UDim2.new(1, -102, 1, -38)
Clear.BackgroundColor3 = Color3.fromRGB(45,45,45)
Clear.Text = "CLEAR"
Clear.TextColor3 = Color3.new(1,1,1)
Clear.Font = Enum.Font.GothamBold
Clear.TextSize = 11
Clear.Parent = Main

Instance.new("UICorner", Clear).CornerRadius = UDim.new(0, 6)

Clear.MouseButton1Click:Connect(function()

	for _,v in ipairs(List:GetChildren()) do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end

	List.CanvasSize = UDim2.new(0,0,0,0)
end)

--------------------------------------------------
-- ADD REMOTE
--------------------------------------------------

local function AddRemote(Name)

	local Entry = Instance.new("TextLabel")

	Entry.Size = UDim2.new(1, -8, 0, 45)
	Entry.BackgroundColor3 = Color3.fromRGB(28,28,28)
	Entry.TextColor3 = Color3.new(1,1,1)
	Entry.Font = Enum.Font.Code
	Entry.TextSize = 11
	Entry.TextXAlignment = Enum.TextXAlignment.Left
	Entry.TextYAlignment = Enum.TextYAlignment.Center

	Entry.Text =
		"[" .. os.date("%H:%M:%S") .. "]  "
		.. tostring(Name)

	Entry.Parent = List

	Instance.new("UICorner", Entry).CornerRadius = UDim.new(0,5)

	task.wait()

	List.CanvasSize = UDim2.new(
		0,
		0,
		0,
		Layout.AbsoluteContentSize.Y + 10
	)

	List.CanvasPosition = Vector2.new(0, math.huge)

	-- Keep last 100
	local Entries = {}

	for _,v in ipairs(List:GetChildren()) do
		if v:IsA("TextLabel") then
			table.insert(Entries,v)
		end
	end

	if #Entries > 100 then
		Entries[1]:Destroy()
	end
end

--------------------------------------------------
-- FIND REMOTES
--------------------------------------------------

local function ScanRemotes()

	for _,Object in ipairs(ReplicatedStorage:GetDescendants()) do

		if Object:IsA("RemoteEvent") then

			-- Show that the remote exists
			AddRemote("FOUND: " .. Object:GetFullName())

		end

	end

end

ScanRemotes()

--------------------------------------------------
-- NEW REMOTE DETECTION
--------------------------------------------------

ReplicatedStorage.DescendantAdded:Connect(function(Object)

	if Object:IsA("RemoteEvent") then

		AddRemote("NEW: " .. Object:GetFullName())

	end

end)

--------------------------------------------------
-- POSITION
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	local Character = Player.Character

	if not Character then
		return
	end

	local Root = Character:FindFirstChild("HumanoidRootPart")

	if not Root then
		return
	end

	local P = Root.Position

	Position.Text = string.format(
		"POSITION\nX: %.0f    Y: %.0f    Z: %.0f",
		P.X,
		P.Y,
		P.Z
	)

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

UserInputService.InputEnded:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = false
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
