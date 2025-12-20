-- From ServerScriptService.Settings
game.Lighting.ToggleInv.OnServerEvent:Connect(function(plr)
	plr.InvitationsDisabled.Value = not plr.InvitationsDisabled.Value
end)
game.Lighting.SpeechEdit.OnServerEvent:Connect(function(plr,voice,font,color)
	if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(plr.UserId,5236753) then --Keep it as is.
		if tonumber(voice) == nil or not game:GetService("MarketplaceService"):GetProductInfo(tonumber(voice),Enum.InfoType.Asset).AssetTypeId == Enum.AssetType.Audio then
			plr.Voice.Value = 360449521
		else
			plr.Voice.Value = voice
		end
		if font == nil or typeof(font) ~= "string" then
			plr.Font.Value = "Arcade"
		else
			plr.Font.Value = font
		end
		plr.TextColor.Value = color
	else
		game.Lighting.Assets.Despacito2:Clone().Parent = plr.PlayerGui
		game.Lighting.ExploitBot:Fire(plr,"Trying to change speech without game pass")
	end
end)
game.Lighting.ArmorDesign.OnServerEvent:Connect(function(plr)
	plr.ArmorDesignDisabled.Value = not plr.ArmorDesignDisabled.Value
	if plr.ArmorDesignDisabled.Value == true then
		local c = plr.Character:GetChildren()
		for i=1,#c do
			if (c[i]:IsA("Model") or c[i]:IsA("Accessory"))and c[i].Name == "ArmorDesign" then
				local f = c[i]:GetChildren()
				for i2=1,#f do
					if f[i2]:IsA("BasePart") then
						f[i2].Transparency = 1
					end
				end
			end
		end
	else
				local c = plr.Character:GetChildren()
		for i=1,#c do
			if (c[i]:IsA("Model") or c[i]:IsA("Accessory"))  and c[i].Name == "ArmorDesign" then
				local f = c[i]:GetChildren()
				for i2=1,#f do
					if f[i2]:IsA("BasePart") then
						f[i2].Transparency = f[i2]["_transparency"].Value
					end
				end
			end
		end

	end
end)



game.Lighting.ToggleDamageCounter.OnServerEvent:Connect(function(plr)
	plr.DamageCounterDisabled.Value = not plr.DamageCounterDisabled.Value
end)
