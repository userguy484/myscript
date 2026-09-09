local SitButton = CreateButton("Sit to Player", 575)

SitButton.MouseButton1Click:Connect(function()

	if not SelectedPlayer then
		SitButton.Text = "Select A Player!"

		task.delay(1, function()
			if SitButton then
				SitButton.Text = "Sit to Player"
			end
		end)

		return
	end

	local targetCharacter = SelectedPlayer.Character
	if not targetCharacter then return end

	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	if not Root or not Humanoid then return end

	-- Move your character beside the selected player
	Root.CFrame =
		targetRoot.CFrame
		* CFrame.new(0, 0, -2.5)

	-- Sit
	Humanoid.Sit = true

	SitButton.Text = "Sitting!"

	task.delay(1, function()
		if SitButton then
			SitButton.Text = "Sit to Player"
		end
	end)
end)
