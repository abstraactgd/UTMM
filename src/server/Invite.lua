-- From ServerScriptService.Invite
game.Lighting.Invite.OnServerEvent:Connect(function(plr,invited,battle)
	if plr.Character:FindFirstChild("_battle") == nil then
	local goers = {plr}	
	for i=1,#invited do
		local invite = invited[i].Character:FindFirstChild("_battle") == nil and invited[i].LOVE.Value >= battle.Battle.Value.LOVE.Value and invited[i].Resets.Value >= battle.Battle.Value.Resets.Value
		invited[i].Character.Humanoid.WalkSpeed = 0
		local c = invited[i].Character:GetChildren()
		if invite  then
		game.Lighting.Invite:FireClient(invited[i],plr,battle.Battle.Value.BattleName.Value)
		game.Lighting.BattleInvitations.OnServerEvent:Connect(function(plr2,leader,text)
			local can = true			
			for b=1,#goers do
				if goers[b] == plr2 then
					can = false 
				end
			end
			if text == "Accept" and can == true and plr2.Character and leader == plr then
						local c = invited[i].Character:GetChildren()
		for i2=1,#c do 
			if string.sub(c[i2].Name,1,7) == "_battle" then
				invite = false
			end
		end
		if invite == true then
			table.insert(goers,#goers+1,plr2)
		end
			elseif invited[i].Character then
				invited[i].Character.Humanoid.WalkSpeed = 50
			end
		end)
		end
		
	end
	if #invited > 0 then
	task.wait(5)
	for i=1,#invited do
		invited[i].Character.Humanoid.WalkSpeed = 50
	end
	battle.Party:Fire(goers)
	else
	battle.Party:Fire(goers)
	end
	end
end)
