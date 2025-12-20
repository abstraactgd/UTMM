-- From ServerScriptService.Modules.BattlePads
local TickToDate = require(game.ReplicatedStorage.Modules.TickToDate)
return function(BattlePad)

	debounce = false
	local pb = {}

	function SendPlayersToBattle(plrs,battle)
		local antidup = false
		for i=1,#pb do
			if pb[i] == plrs[1] then
				antidup = true
			end
		end
		if antidup == false then
			table.insert(pb,#pb+1,plrs[1])
			local map = Instance.new("Model") --Move the map
			local deadplayers = {}
			local stuff = game.ServerStorage.BattleMaps:FindFirstChild(battle.Name):Clone()
			stuff.Name = "Stuff"
			stuff.Parent = map
			if stuff:FindFirstChild("Root") then
				map.PrimaryPart = stuff.Root
				map:SetPrimaryPartCFrame(CFrame.new(plrs[1].Pos.Value))
				local spawnpoint = stuff.PlayerSpawn
				local enemies = {}
				local originalplayeramount = #plrs
				local c = stuff:GetChildren()--Used to clean them too
				for i=1,#c do
					if c[i]:FindFirstChild("AI") then
						table.insert(enemies,1,c[i])
						local playerfolder = Instance.new("Folder")
						playerfolder.Name = "Players"
						for i2=1,#plrs do
							local val = Instance.new("ObjectValue")
							val.Name = plrs[i2].Name
							val.Value = plrs[i2]
							val.Parent = playerfolder
							plrs[i2].Character.Humanoid.Died:Connect(function()
								task.wait(3)						
								val:Destroy()
							end)
						end
						playerfolder.Parent = c[i]
					end
				end
				stuff.Parent = workspace

				local c = stuff:GetChildren()--Used to clean them too
				local enemiesleft = #enemies
				for i=1,#enemies do
					enemies[i].Humanoid.Died:Connect(function()
						enemiesleft = enemiesleft -1
						if enemiesleft == 0  then
							if battle.LinkedBattle.Value == nil then
								for i2=1,#pb do
									if pb[i2] == plrs[1] then
										table.remove(pb,i2)
									end
								end
								local goldamount = 0
								local xpamount = 0
								if battle.Share.Value then
									goldamount = battle.Gold.Value / originalplayeramount
									xpamount = battle.XP.Value / originalplayeramount 
								else
									goldamount = battle.Gold.Value
									xpamount = battle.XP.Value  
								end
								for i3=1,#plrs do
									local dead = false
									for i2=1,#deadplayers do
										if deadplayers[i2] == plrs[i3] then
											dead = true
										end
									end
									if dead == false then
										plrs[i3].Gold.Value = plrs[i3].Gold.Value + (goldamount * (1 + plrs[i3].Resets.Value))
										plrs[i3].XP.Value = plrs[i3].XP.Value + math.floor(xpamount * (1 + (plrs[i3].TrueResets.Value * 0.1)))
										game.Lighting.Save:Fire(plrs[i3])
										if originalplayeramount == 1 then
											plrs[i3].BossChart:FindFirstChild(battle.Name).TimesFought.Value = plrs[i3].BossChart:FindFirstChild(battle.Name).TimesFought.Value + 1
										else
											plrs[i3].BossChart:FindFirstChild(battle.Name).TimesFoughtMulti.Value = plrs[i3].BossChart:FindFirstChild(battle.Name).TimesFoughtMulti.Value + 1
										end
										if plrs[i3].BossChart:FindFirstChild(battle.Name).Date.Value == "Never" then
											plrs[i3].BossChart:FindFirstChild(battle.Name).Date.Value = TickToDate(os.time())
											plrs[i3].BossChart:FindFirstChild(battle.Name).Resets.Value = plrs[i3].Resets.Value
											plrs[i3].BossChart:FindFirstChild(battle.Name).LOVE.Value = plrs[i3].LOVE.Value
										end
										if originalplayeramount == 1 or battle.Share.Value == false then
											if battle.RewardWeapon.Value then
												if battle.RewardWeapon.Value.Parent.Name == "Weapons" then
													plrs[i3].Weapons:FindFirstChild(battle.RewardWeapon.Value.Name).Value = true
												elseif battle.RewardWeapon.Value.Parent.Name == "Armor" then
													plrs[i3].Armor:FindFirstChild(battle.RewardWeapon.Value.Name).Value = true
												elseif battle.RewardWeapon.Value.Parent.Name == "SOULs" then
													plrs[i3].SOULs:FindFirstChild(battle.RewardWeapon.Value.Name).Value = true
												end
											end

										end
										if originalplayeramount == 1 and battle.FragmentChance.Value > 0 then
											local chance = math.random(1,100)
											if chance <= battle.FragmentChance.Value and battle.SoulFragment.Value then
												plrs[i3].SoulFragments:FindFirstChild(battle.SoulFragment.Value.Name).Value = plrs[i3].SoulFragments:FindFirstChild(battle.SoulFragment.Value.Name).Value + 1
											end
										end
									end
								end
								task.wait(3)
								for i=1,#c do
									c[i]:Destroy()
								end
								for i3=1,#plrs do
									local dead = false
									for i2=1,#deadplayers do
										if deadplayers[i2] == plrs[i3] then
											dead = true
										end
									end
									if dead == false then
										plrs[i3]:LoadCharacter()
									end
								end
							else
								task.wait(1)
								for i2=1,#pb do
									if pb[i2] == plrs[1] then
										table.remove(pb,i2)
									end
								end
								for i=1,#c do
									c[i]:Destroy()
								end
								local goers = {}
								for i2=1,#plrs do
									local dead = false
									for i3=1,#deadplayers do
										if deadplayers[i3] == plrs[i2] then
											dead = true
										end
									end
									if dead == false then
										table.insert(goers,#goers+1,plrs[i2])
									end
								end
								SendPlayersToBattle(goers,battle.LinkedBattle.Value)
							end

						end
					end)
					for _, v in pairs(enemies[i]:GetDescendants()) do
						if v:IsA("BasePart") and v.Anchored == false then
							local Set = true						
							for _, v in pairs(v:GetJoints()) do
								if v:IsA("BasePart") and v.Anchored == true then
									Set = false
								end
							end
							if Set == true then
								pcall(function()
									v:SetNetworkOwner(nil)
								end)
							end
						end
					end
				end
				local LoadedTable = {}
				for i=1,#plrs do
					local tag = Instance.new("ObjectValue")
					tag.Name = "_battle"
					tag.Value = battle
					local stufftag = Instance.new("ObjectValue")
					stufftag.Name = "BattleStuff"
					stufftag.Value = stuff
					stufftag.Parent = tag
					tag.Parent = plrs[i].Character
					plrs[i].Character.Humanoid.WalkSpeed = 20
					game.Lighting.Music:FireClient(plrs[i],battle.Music)
					plrs[i].Character:SetPrimaryPartCFrame(spawnpoint.CFrame)
					plrs[i].Character.HumanoidRootPart.Anchored = true
					if battle.DisableWeapons.Value == true then
						if plrs[i].Backpack:FindFirstChild("AttackTool") then
							plrs[i].Backpack.AttackTool:Destroy()
						elseif plrs[i].Character:FindFirstChild("AttackTool") then
							plrs[i].Character.AttackTool:Destroy()
						end
					end
					local f = plrs[i].Food:GetChildren()
					if plrs[i].Character:FindFirstChild("_foodgiven") == nil and battle.DisableFood.Value == false then
						for a=1,#f do
							local foodname = f[a].Name
							for rv0rmv0=1,f[a].Value do
								local food = game.Lighting.Food:FindFirstChild(foodname).Tool:FindFirstChildOfClass("Tool"):Clone()
								if food:FindFirstChild("Decrease") then
									food.Decrease.Value = plrs[i].Food:FindFirstChild(foodname)
								end
								food.Parent = plrs[i].Backpack
							end
						end
						local foodgiven = Instance.new("ObjectValue")
						foodgiven.Name = "_foodgiven"
						foodgiven.Parent = plrs[i].Character
					end
					game.Players.PlayerRemoving:Connect(function(rmpl)
						if rmpl == plrs[i] then
							table.remove(plrs,i)
							for i2=1,#pb do
								if pb[i2] == rmpl then
									table.remove(pb,i2)
								end
							end
							for a=1,#deadplayers do
								if deadplayers[a] == plrs[i] then
									table.remove(deadplayers,a)
								end
							end
						end
					end)
					plrs[i].Character.Humanoid.Died:Connect(function()
						table.insert(deadplayers,1,plrs[i])
						for i2=1,#pb do
							if pb[i2] == plrs[i] then
								table.remove(pb,i2)
							end
						end

						if #deadplayers >= #plrs then
							task.wait(3)
							for i=1,#c do
								c[i]:Destroy()
							end
						end
					end)

					pcall(coroutine.wrap(function()
						local Loaded = game.Lighting.LoadMap:InvokeClient(plrs[i], stuff)
						if Loaded then
							LoadedTable[plrs[i] ] = true
						end
					end))
				end
				repeat
					task.wait()
					local Break = true
					for _, Player in pairs(plrs) do
						if LoadedTable[Player] ~= true then
							Break = false
						end
					end
					if Break == true then
						break
					end
				until nil
				for _, Player in pairs(plrs) do
					if Player.Character and table.find(deadplayers, Player) == nil then
						Player.Character.HumanoidRootPart.Anchored = false
					end
				end
			else
				warn("Battle couldn't be loaded")
				map:Destroy()
			end	
		end
	end
	BattlePad.Touched:Connect(function(h)
		if debounce == false then
			local plr = game.Players:GetPlayerFromCharacter(h.Parent)
			if plr and plr.Character and plr.Character.Humanoid.Health > 0 and plr.Character.Humanoid.WalkSpeed > 0 and plr.Resets.Value >= BattlePad.Battle.Value.Resets.Value and plr.LOVE.Value >= BattlePad.Battle.Value.LOVE.Value and plr.Character:FindFirstChild("_battle"..plr.Name..BattlePad.Battle.Value.Name) == nil then
				local tag = Instance.new("ObjectValue")
				tag.Name = "_battle"..plr.Name..BattlePad.Battle.Value.Name
				tag.Parent = plr.Character
				debounce = true
				plr.Character.Humanoid.WalkSpeed = 0
				game.Lighting.BattleInvitations:FireClient(plr,BattlePad)
				local went = false 
				BattlePad.Party.Event:Connect(function(goers)
					if went == false then
						plr.Character.Humanoid.WalkSpeed = 20
						SendPlayersToBattle(goers,BattlePad.Battle.Value)
						went = true
					end
				end)
				task.wait(3)
				debounce = false
			end
		end
	end)
end
