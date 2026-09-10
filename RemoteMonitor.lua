-- RemoteMonitor.lua
-- Touch knockback for your own Roblox experience

local Players = game:GetService("Players")

local OWNER_USER_ID = 11522003214
local KNOCKBACK = 120
local UP_FORCE = 60
local COOLDOWN = 1

local lastHit = {}

local function setupCharacter(player, character)
	if player.UserId ~= OWNER_USER_ID then
		return
	end

	local root = character:WaitForChild("HumanoidRootPart")

	root.Touched:Connect(function(hit)
		local otherCharacter = hit:FindFirstAncestorOfClass("Model")
		if not otherCharacter or otherCharacter == character then
			return
		end

		local otherPlayer = Players:GetPlayerFromCharacter(otherCharacter)
		local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")

		if not otherPlayer or not otherRoot then
			return
		end

		if lastHit[otherPlayer] and os.clock() - lastHit[otherPlayer] < COOLDOWN then
			return
		end

		lastHit[otherPlayer] = os.clock()

		local direction = otherRoot.Position - root.Position

		if direction.Magnitude < 0.1 then
			direction = Vector3.new(0, 0, 1)
		end

		direction = direction.Unit

		otherRoot:ApplyImpulse(
			(direction * KNOCKBACK + Vector3.new(0, UP_FORCE, 0))
			* otherRoot.AssemblyMass
		)
	end)
end

local function setupPlayer(player)
	if player.UserId ~= OWNER_USER_ID then
		return
	end

	player.CharacterAdded:Connect(function(character)
		setupCharacter(player, character)
	end)

	if player.Character then
		setupCharacter(player, player.Character)
	end
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end
