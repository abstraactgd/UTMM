-- From ServerScriptService.PlayerStuff
Positions = {}
local Modules = game.ReplicatedStorage.Modules
local Settings = require(Modules.Settings)
local FormatNumber = require(Modules.FormatNumber)
local TickToDate = require(Modules.TickToDate)
game.Lighting.TimeToDate.Event:Connect(TickToDate)


local DSS = game:GetService("DataStoreService")
local DataStore = DSS:GetDataStore("DataStore")

local DefaultData = {
	Gold = 0,
	LOVE = 1,
	EXP = 0,
	Resets = 0,
	TrueResets = 0,
	Settings = {
		Weapon = "Stick",
		SOUL = "Basic",
		Armor = "Bandage",
		InvitesDisabled = false,
		ArmorDesignDisabled = false,
		DamageCounter = true,
		MuteMusic = false,
		NotifyMessages = true,
		Skins = {},
		TextEdit = {
			Voice = 360449521,
			Font = "Arcade",
			Color = {1,1,1},
		},
	},
	Weapons = {"Stick"}, --What weapons does the player have at beginning. 
	Armors = {"Bandage"}, --Armors,
	SOULs = {"Basic"}, -- and SOULs
	Skins = {}, --Format: WeaponName = true (for example: CharcoalStick = true)
	BossChart = {}, 
	Food = {}, --Format: FoodName = number (for example: MonsterCandy = 1)
	SOULFragments = {},
}


function LoadPlrData(plr)
	task.wait(0.5)
	if plr:FindFirstChild("_dogcheck") == nil then
		local Data = DataStore:GetAsync("Player"..plr.UserId)
		
		if not Data then
			local CheckData = DSS:GetDataStore("DataStore"..plr.UserId)
			local LOVE = CheckData:GetAsync("LOVE")
			if LOVE then
				Data = CheckData
				local ConvertTag = Instance.new("ObjectValue")
				ConvertTag.Name = "_converting"
				ConvertTag.Parent = plr

				local BossChart = Data:GetAsync("BossChartData")
				local Used = Data:GetAsync("UsedData")
				local Weapons = Data:GetAsync("WeaponsData")
				local Armors = Data:GetAsync("ArmorData")
				local Food = Data:GetAsync("FoodData")
				local Frag = Data:GetAsync("SOULFragmentsData")
				local SOULs = Data:GetAsync("SOULsData")
				local SkinsData = Data:GetAsync("SkinsData")
				local Gold = Data:GetAsync("Gold")
				local EXP = Data:GetAsync("XP")
				local Resets = Data:GetAsync("Resets")
				local TrueResets = Data:GetAsync("TrueResets")
				local BanInfo = Data:GetAsync("BanInfo")

				local Table = {
					Gold = Gold or 0,
					LOVE = LOVE or 1,
					EXP = EXP or 0,
					Resets = Resets or 0,
					TrueResets = TrueResets or 0,
					Settings = {
						Weapon = Used[1] or DefaultData.Settings.Weapon,
						Armor = Used[2] or DefaultData.Settings.Armor,
						SOUL = Used[3] or DefaultData.Settings.SOUL,
						InvitesDisabled = Used[4] == "true",
						ArmorDesignDisabled = Used[5] == "true",
						DamageCounter = Used[6] == "true",
						MuteMusic = DefaultData.Settings.MuteMusic,
						NotifyMessages = DefaultData.Settings.NotifyMessages,
						Skins = {},
						TextEdit = {
							Voice = tonumber(Used[7]) or DefaultData.Settings.Voice,
							Font = Used[8] or DefaultData.Settings.Font,
							Color = {tonumber(Used[10]) or 1, tonumber(Used[11]) or 1, tonumber(Used[12]) or 1},
						}
					},
					Weapons = {},
					Armors = {},
					SOULs = {},
					Skins = {},
					BossChart = {},
					Food = {},
					SOULFragments = {},
				}

				local Match = "(.*)_true$"
				for _, Weapon in Weapons do
					local Name = Weapon:match(Match)
					if Name then
						table.insert(Table.Weapons, Name)
					end
				end
				for _, Armor in Armors do
					local Name = Armor:match(Match)
					if Name then
						table.insert(Table.Armors, Name)
					end
				end
				for _, SOUL in SOULs do
					local Name = SOUL:match(Match)
					if Name then
						table.insert(Table.SOULs, Name)
					end
				end
				for _, Skin in SkinsData[1] do
					local Name = Skin:match(Match)
					if Name then
						table.insert(Table.Skins, Name)
					end
				end

				for _, Info in BossChart do
					Table.BossChart[Info[1]] = {
						LOVE = Info[2],
						Resets = Info[3],
						TimesFought = Info[4],
						TimesFoughtMulti = Info[5],
						Date = Info[6]
					}
				end

				for _, Weapon in game.Lighting.Weapons:GetChildren() do
					Weapon = Weapon.Name
					for _, Skin in SkinsData[2] do
						Skin = Skin:match(Weapon.."_(.*)")
						if Skin then
							Table.Settings.Skins[Weapon] = Skin
						end
					end
				end

				for _, Item in game.Lighting.Food:GetChildren() do
					Item = Item.Name
					for _, Amount in Food do
						Amount = Amount:match(Item.."_(%d*)")
						if Amount then
							Table.Food[Item] = tonumber(Amount)
						end
					end
				end

				for _, Fragment in game.Lighting.SOULs:GetChildren() do
					Fragment = Fragment.Name
					for _, Amount in Frag do
						Amount = Amount:match(Fragment.."_(%d*)")
						if Amount then
							Table.SOULFragments[Fragment] = tonumber(Amount)
						end
					end
				end

				if BanInfo then
					Table.BanInfo = {
						Cause = BanInfo[1],
						Date = BanInfo[2],
						Reason = BanInfo[3],
						BanGiver = BanInfo[4],
						Position = BanInfo[5],
						Battle = BanInfo[6],
					}
				end
				DataStore:SetAsync("Player"..plr.UserId, Table)
				ConvertTag:Destroy()
				LoadPlrData(plr)
				return
			else
				Data = DefaultData
			end
		end

		if Data.BanInfo == nil then

			local SoulFragments = Instance.new("Folder")
			local Souls = Instance.new("Folder")
			local UsedWeapon = Instance.new("ObjectValue")
			local weapons = Instance.new("Folder")

			local DisableInvite = Instance.new("BoolValue")
			DisableInvite.Name = "InvitationsDisabled"

			local Skins = Instance.new("Folder")
			Skins.Name = "Skins"

			local ArmorDesign = Instance.new("BoolValue")
			ArmorDesign.Name = "ArmorDesignDisabled"

			local DamageCounter = Instance.new("BoolValue")
			DamageCounter.Name = "DamageCounterDisabled"

			weapons.Name = "Weapons"
			UsedWeapon.Name = "Weapon"
			SoulFragments.Name = "SoulFragments"

			local Voice = Instance.new("NumberValue")
			Voice.Name = "Voice"
			Voice.Value = Data.Settings.Voice or 0

			local Font = Instance.new("StringValue")
			Font.Name = "Font"
			Font.Value = "Arcade"
			local SelectedArmor = Instance.new("ObjectValue")
			SelectedArmor.Name = "EquippedArmor"
			Souls.Name = "SOULs"
			local ArmorF = Instance.new("Folder")
			ArmorF.Name = "Armor"
			local foods = Instance.new("Folder")
			foods.Name = "Food"
			local SelectedSoul = Instance.new("ObjectValue")
			SelectedSoul.Name = "SelectedSOUL"
			local SoulFragments = Instance.new("Folder")
			SoulFragments.Name = "SoulFragments"

			local BossChartF = Instance.new("Folder")
			BossChartF.Name = "BossChart"

			local TextColor = Instance.new("Color3Value")
			TextColor.Name = "TextColor"
			TextColor.Value = Color3.new(1,1,1)
			local MuteMusic = Instance.new("BoolValue")
			MuteMusic.Name = "MuteMusic"

			local NotifyMessages = Instance.new("BoolValue")
			NotifyMessages.Name = "NotifyMessages"
			NotifyMessages.Value = Data.Settings.NotifyMessages
			
			for Battle, Info in Data.BossChart do
				local folder = Instance.new("Folder")
				folder.Name = Battle 
				local LOVEB = Instance.new("NumberValue")
				LOVEB.Name = "LOVE"
				LOVEB.Value = Info.LOVE
				LOVEB.Parent = folder
				local ResetsB = Instance.new("NumberValue")
				ResetsB.Name = "Resets"
				ResetsB.Value = Info.Resets
				ResetsB.Parent = folder
				local Fought = Instance.new("NumberValue")
				Fought.Name = "TimesFought"
				Fought.Value = Info.TimesFought
				Fought.Parent = folder
				local FoughtMulti = Instance.new("NumberValue")
				FoughtMulti.Name = "TimesFoughtMulti"
				FoughtMulti.Value = Info.TimesFoughtMulti
				FoughtMulti.Parent = folder
				local Date = Instance.new("StringValue")
				Date.Name = "Date"
				Date.Value = Info.Date
				Date.Parent = folder
				folder.Parent = BossChartF
			end

			local c = game.Lighting.Battles:GetChildren()
			for i=1,#c do
				if BossChartF:FindFirstChild(c[i].Name) == nil then
					local folder = Instance.new("Folder")
					folder.Name = c[i].Name --String, name
					local LOVEB = Instance.new("NumberValue")
					LOVEB.Name = "LOVE"
					LOVEB.Value = 1
					LOVEB.Parent = folder
					local ResetsB = Instance.new("NumberValue")
					ResetsB.Name = "Resets"
					ResetsB.Value = 0
					ResetsB.Parent = folder
					local Fought = Instance.new("NumberValue")
					Fought.Name = "TimesFought"
					Fought.Value = 0
					Fought.Parent = folder
					local FoughtMulti = Instance.new("NumberValue")
					FoughtMulti.Name = "TimesFoughtMulti"
					FoughtMulti.Value = 0
					FoughtMulti.Parent = folder
					local Date = Instance.new("StringValue")
					Date.Name = "Date"
					Date.Value = "Never"
					Date.Parent = folder
					folder.Parent = BossChartF
				end
			end
			plr.Gold.Value = Data.Gold
			plr.LOVE.Value = Data.LOVE
			plr.XP.Value = Data.EXP
			plr.Resets.Value = Data.Resets
			plr.TrueResets.Value = Data.TrueResets
			UsedWeapon.Value = game.Lighting.Weapons:FindFirstChild(Data.Settings.Weapon or DefaultData.Settings.Weapon)
			SelectedArmor.Value = game.Lighting.Armor:FindFirstChild(Data.Settings.Armor or DefaultData.Settings.Armor)
			SelectedSoul.Value = game.Lighting.SOULs:FindFirstChild(Data.Settings.SOUL or DefaultData.Settings.SOUL)
			DisableInvite.Value = Data.Settings.InvitesDisabled
			ArmorDesign.Value = Data.Settings.ArmorDesignDisabled
			DamageCounter.Value = Data.Settings.DamageCounter
			Voice.Value = Data.Settings.TextEdit.Voice
			Font.Value = Data.Settings.TextEdit.Font
			MuteMusic.Value = Data.Settings.MuteMusic
			TextColor.Value = Color3.new(unpack(Data.Settings.TextEdit.Color))

			NotifyMessages.Parent = plr
			TextColor.Parent = plr
			Font.Parent = plr
			Voice.Parent = plr
			DamageCounter.Parent = plr
			ArmorDesign.Parent = plr
			DisableInvite.Parent = plr
			UsedWeapon.Parent = plr
			SelectedArmor.Parent = plr
			SelectedSoul.Parent = plr
			MuteMusic.Parent = plr
			
			for _, Weapon in Data.Weapons do
				if game.Lighting.Weapons:FindFirstChild(Weapon) == nil then
					warn("Deleted",Weapon,"from",plr.Name,"(weapon no longer exists)")
					continue
				end
				local Value = Instance.new("BoolValue")
				Value.Value = true
				Value.Name = Weapon
				Value.Parent = weapons
				local Skin = Instance.new("ObjectValue")
				Skin.Name = "Skin"
				if Data.Settings.Skins[Weapon] then
					Skin.Value = game.Lighting.Skins:FindFirstChild(Data.Settings.Skins[Weapon])
				end
				if Skin.Value == nil then
					Skin.Value = game.Lighting.Weapons:FindFirstChild(Weapon)
				end
				Skin.Parent = Value
			end
			
			for _, Weapon in game.Lighting.Weapons:GetChildren() do
				if table.find(Data.Weapons, Weapon.Name) == nil then
					local Value = Instance.new("BoolValue")
					Value.Value = false
					Value.Name = Weapon.Name
					Value.Parent = weapons
					local Skin = Instance.new("ObjectValue")
					Skin.Name = "Skin"
					if Data.Settings.Skins[Weapon.Name] then
						Skin.Value = game.Lighting.Skins:FindFirstChild(Data.Settings.Skins[Weapon.Name])
					end
					if Skin.Value == nil then
						Skin.Value = game.Lighting.Weapons:FindFirstChild(Weapon.Name)
					end
					Skin.Parent = Value
				end
			end

			for _, Armor in Data.Armors do
				if game.Lighting.Armor:FindFirstChild(Armor) == nil then
					warn("Deleted",Armor,"from",plr.Name,"(armor no longer exists)")
					continue
				end
				local Value = Instance.new("BoolValue")
				Value.Value = true
				Value.Name = Armor
				Value.Parent = ArmorF
			end
			
			for _, Armor in game.Lighting.Armor:GetChildren() do
				if table.find(Data.Armors, Armor.Name) == nil then
					local Value = Instance.new("BoolValue")
					Value.Value = false
					Value.Name = Armor.Name
					Value.Parent = ArmorF
				end
			end
			
			for _, SOUL in Data.SOULs do
				if game.Lighting.SOULs:FindFirstChild(SOUL) == nil then
					warn("Deleted",SOUL,"from",plr.Name,"(soul no longer exists)")
					continue
				end
				local Value = Instance.new("BoolValue")
				Value.Value = true
				Value.Name = SOUL
				Value.Parent = Souls
			end
			
			for _, SOUL in game.Lighting.SOULs:GetChildren() do
				if table.find(Data.SOULs, SOUL.Name) == nil then
					local Value = Instance.new("BoolValue")
					Value.Value = false
					Value.Name = SOUL.Name
					Value.Parent = Souls
				end
			end
		
			for _, Skin in Data.Skins do
				if game.Lighting.Skins:FindFirstChild(Skin) == nil then
					warn("Deleted",Skin,"from",plr.Name,"(skin no longer exists)")
					continue
				end
				local Value = Instance.new("BoolValue")
				Value.Value = true
				Value.Name = Skin
				Value.Parent = Skins
			end
			
			for _, Skin in game.Lighting.Skins:GetChildren() do
				if table.find(Data.Skins, Skin.Name) == nil then
					local Value = Instance.new("BoolValue")
					Value.Value = false
					Value.Name = Skin.Name
					Value.Parent = Skins
				end
			end
			
			for Food, Amount in Data.Food do
				if game.Lighting.Food:FindFirstChild(Food) == nil then
					warn("Deleted",Food,"from",plr.Name,"(food no longer exists)")
					continue
				end
				local Value = Instance.new("NumberValue")
				Value.Value = Amount
				Value.Name = Food
				Value.Parent = foods
			end
			for _, Food in game.Lighting.Food:GetChildren() do
				if Data.Food[Food.Name] == nil then
					local Value = Instance.new("NumberValue")
					Value.Value = 0
					Value.Name = Food.Name
					Value.Parent = foods
				end
			end
			
			for Fragment, Amount in Data.SOULFragments do
				if game.Lighting.SOULs:FindFirstChild(Fragment) == nil then
					warn("Deleted",Fragment,"fragment from",plr.Name,"(soul no longer exists)")
					continue
				end
				local Value = Instance.new("NumberValue")
				Value.Value = Amount
				Value.Name = Fragment
				Value.Parent = SoulFragments
			end
			for _, Fragment in game.Lighting.SOULs:GetChildren() do
				if Data.SOULFragments[Fragment.Name] == nil then
					local Value = Instance.new("NumberValue")
					Value.Value = 0
					Value.Name = Fragment.Name
					Value.Parent = SoulFragments
				end
			end
			
			weapons.Parent = plr
			Skins.Parent = plr
			ArmorF.Parent = plr
			Souls.Parent = plr
			foods.Parent = plr
			BossChartF.Parent = plr
			SoulFragments.Parent = plr
			
			local CanChat = game.Chat:CanUserChatAsync(plr.UserId)
			if CanChat == false then
				game.Lighting.DisableChat:FireClient(plr)
			end

			local loadeddata = Instance.new("ObjectValue")
			loadeddata.Name = "_loadeddata"
			loadeddata.Parent = plr
			game.Lighting.DataLoaden:FireClient(plr)
			
			local t1= weapons:FindFirstChild(UsedWeapon.Value.Name).Skin.Value.Tool:FindFirstChildOfClass("Tool"):Clone()
			local p1 = Instance.new("ObjectValue")
			p1.Name = "Player"
			p1.Value = plr
			p1.Parent = t1
			local i1 = Instance.new("ObjectValue")
			i1.Name = "BaseWeapon"
			i1.Value = UsedWeapon.Value
			i1.Parent = t1
			t1.Parent = plr.StarterGear
			plr:LoadCharacter()
		else
			plr:LoadCharacter()
			game.Lighting.Assets.Despacito2:Clone().Parent = plr.PlayerGui
			task.wait(.5)
			plr.Character:Destroy()
			task.wait(9.5)
			plr:Kick("You have been banned for: "..Data.BanInfo.Reason)
		end
	end
end




function GenerateValue()
	local value = Vector3.new(math.random(1,500)*200,10000,math.random(1,500)*200)
	for i=1,#Positions do
		if value == Positions[i] then
			for i=1,#Positions do
				if value == Positions[i] then
					local value = Vector3.new(math.random(1,500)*200,10000,math.random(1,500)*200)
				end
			end
		end
	end
	return value
end
game.Players.PlayerAdded:Connect(function(plr)
	local data = game:GetService("DataStoreService"):GetDataStore("DataStore"..plr.UserId)
	local LOVE = Instance.new("NumberValue")
	LOVE.Name = "LOVE"
	LOVE.Value = 1
	local gold = Instance.new("NumberValue")
	gold.Name = "Gold"
	local XP = Instance.new("NumberValue")
	local resets = Instance.new("NumberValue")
	resets.Name = "Resets"
	local trueresets = Instance.new("NumberValue")
	trueresets.Name = "TrueResets"
	game.Debris:AddItem(plr.Character,3)
	XP.Name = "XP"
	LOVE.Parent = plr
	XP.Parent = plr
	resets.Parent = plr
	gold.Parent = plr
	trueresets.Parent = plr
	local pos = Instance.new("Vector3Value")
	pos.Name = "Pos"
	table.insert(Positions,1,pos.Value)
	pos.Parent = plr
	plr.ChildAdded:Connect(function(c)
		if c.Name == "_nickname" then
			if plr.Character then
				plr.Character.Head.RobotName.Text = plr["_nickname"].Value
				plr.Character.Head.RobotName.TextColor3 = Color3.new(1,1,1)
			end
			c.Changed:Connect(function()
				if plr.Character then
					plr.Character.Head.RobotName.Text = plr["_nickname"].Value
					plr.Character.Head.RobotName.TextColor3 = Color3.new(1,1,1)
				end
			end)
		end
	end)
	plr.ChildRemoved:Connect(function()
		if plr:FindFirstChild("_nickname") == nil then
			if plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Head:FindFirstChild("StatsHuman") then
				plr.Character.Head.StatsHuman.RobotName.Text = plr.DisplayName
				if plr:FindFirstChild("Badge") then
					plr.Character.Head.StatsHuman.RobotName.TextColor3 = plr.Badge.BadgeColor.Value
				end
			end
		end
	end)
	plr:LoadCharacter()
	plr.CharacterAdded:Connect(function(char)
		if plr:FindFirstChild("_loadeddata") == nil then return end
		local SelectedArmor = plr.EquippedArmor
		local SelectedSoul = plr.SelectedSOUL
		local value = GenerateValue()
		pos.Value = value
		repeat task.wait() until plr.Character:FindFirstChild("Humanoid")
		char.Humanoid.WalkSpeed = 50
		local stats = game.Lighting.StatsHuman:Clone()
		if plr:FindFirstChild("Badge") then
			stats.RobotName.TextColor3 = plr.Badge.BadgeColor.Value
		end
		if plr:FindFirstChild("_nickname") == nil then
			stats.RobotName.Text = plr.DisplayName
		else
			stats.RobotName.Text = plr["_nickname"].Value
			stats.RobotName.TextColor3 = Color3.new(1,1,1)
		end
		stats.HP.Text.Text = "HP "..char.Humanoid.Health.."/"..char.Humanoid.MaxHealth
		stats.HP.Bar.Size = UDim2.new(char.Humanoid.Health/char.Humanoid.MaxHealth,0,1,0)
		stats.PlayerToHideFrom = plr
		stats.Parent = char.Head
		local function Yes()
			if stats:FindFirstChild("HP") and char:FindFirstChild("Humanoid") then
				stats.HP.Text.Text = "HP "..FormatNumber(char.Humanoid.Health).."/"..FormatNumber(char.Humanoid.MaxHealth)
				stats.HP.Bar.Size = UDim2.new(char.Humanoid.Health/char.Humanoid.MaxHealth,0,1,0)
			end
			if char:FindFirstChild("KR") then
				if char.KR.Value > 0 then
					stats.HP.Text.TextColor3 = Color3.new(1,0,1)
				else
					stats.HP.Text.TextColor3 = Color3.new(1,1,1)
				end
				stats.HP.Bar.KR.Size = UDim2.new(char.KR.Value/char.Humanoid.Health,0,1,0)
				stats.HP.Bar.KR.Position = UDim2.new(1-char.KR.Value/char.Humanoid.Health,0,0,0)
			else
				stats.HP.Text.TextColor3 = Color3.new(1,1,1)
			end
		end
		char.Humanoid.Changed:Connect(Yes)
		char:WaitForChild("KR").Changed:Connect(Yes)
		if plr.LOVE.Value < 20 then
			plr.Character.Humanoid.MaxHealth = (20 + (4*(plr.LOVE.Value-1))) + SelectedArmor.Value.HPBonus.Value
			plr.Character.Humanoid.Health = (20 + (4*(plr.LOVE.Value-1))) + SelectedArmor.Value.HPBonus.Value
		elseif plr.LOVE.Value >= 20 then
			plr.Character.Humanoid.MaxHealth = (100 + (5*(plr.LOVE.Value-20))) + SelectedArmor.Value.HPBonus.Value
			plr.Character.Humanoid.Health = (100 + (5*(plr.LOVE.Value-20))) + SelectedArmor.Value.HPBonus.Value
		end
		local c = SelectedArmor.Value.Design:GetChildren()
		for i=1,#c do
			local clone = c[i]:Clone()
			if (clone:IsA("Model") or clone:IsA("Accessory")) then
				local f = clone:GetChildren()
				for i2=1,#f do
					if f[i2]:IsA("BasePart") then
						local Transparency = Instance.new("NumberValue")
						Transparency.Name = "_transparency"
						Transparency.Value = f[i2].Transparency
						Transparency.Parent = f[i2]
						if plr.ArmorDesignDisabled.Value then
							f[i2].Transparency = 1
						end
					end
				end
			end
			clone.Parent = char
		end
		if plr.Backpack:FindFirstChild("AttackTool") then
			if plr.Backpack.AttackTool:FindFirstChild("DamageIncrease") then
				plr.Backpack.AttackTool.DamageIncrease.Value = 0
			end
		elseif plr.Character:FindFirstChild("AttackTool") then
			if plr.Character.AttackTool:FindFirstChild("DamageIncrease") then
				plr.Character.AttackTool.DamageIncrease.Value = 0
			end
		end

		plr.Character.Humanoid.Died:Connect(function()
			if plr.Character:FindFirstChild("HumanoidRootPart") then
				task.wait()
				local deathpos = char.HumanoidRootPart.Position
				char:ClearAllChildren()
				local soul
				if plr.SelectedSOUL.Value:FindFirstChild("Soul") == nil then 
					soul = game.Lighting.Assets.Soul:Clone()
				else
					soul = plr.SelectedSOUL.Value.Soul:Clone()
				end
				soul.Color = SelectedSoul.Value.Color.Value
				soul.Position = deathpos
				soul.Name = plr.Name.."Soul"
				soul.Parent = workspace
				local bsoul 
				if plr.SelectedSOUL.Value:FindFirstChild("BrokenSoul") == nil then 
					bsoul = game.Lighting.Assets.BrokenSoul:Clone()
				else
					bsoul = plr.SelectedSOUL.Value.BrokenSoul:Clone()
				end
				bsoul.Color = SelectedSoul.Value.Color.Value
				bsoul.Position = deathpos
				bsoul.Name = plr.Name.."BrokenSoul"
				bsoul.Parent = workspace
				bsoul.Transparency = 1
				if plr.SelectedSOUL:FindFirstChild("BrokenSoul") == nil then
					bsoul.ParticleEmitter.Color = ColorSequence.new(bsoul.Color)
				end
				task.wait(1)
				soul:Destroy()
				bsoul.Crack:Play()
				bsoul.Transparency = 0
				task.wait(1)
				bsoul.Transparency = 1
				bsoul.ParticleEmitter.Enabled = true 
				bsoul.Break:Play()
				task.wait(1)
				bsoul:Destroy()
				plr:LoadCharacter()
			else
				task.wait(3)
				plr:LoadCharacter()
			end
		end)
		if plr:FindFirstChild("_loadeddata") then
			SelectedSoul.Value.Effect:Clone().Parent = char
		end
	end)
	if not data:GetAsync("Played") then
		LoadPlrData(plr)
	end
	XP.Changed:Connect(function()
		local SetXP = XP.Value
		local SetLOVE = LOVE.Value
		for i = 1, 500 do
			local Next = Settings.NextEXP(SetLOVE)
			if SetXP >= Next and SetLOVE < Settings.MaxLOVE then
				SetXP -= Next
				SetLOVE += 1
			else
				break
			end
		end
		if XP.Value ~= SetXP then
			XP.Value = SetXP
		end
		if LOVE.Value ~= SetLOVE then
			LOVE.Value = SetLOVE
		end
	end)
end)
game.Players.PlayerRemoving:Connect(function(plr)
	if plr:FindFirstChild("_loadeddata") then
		game.Lighting.Save:Fire(plr)
	end
end)

game.Lighting.Buy.OnServerEvent:Connect(function(plr,purchase,purchasetype)
	if purchase then
		if purchasetype == "Weapon" then
			if plr.Gold.Value >= purchase.Cost.Value and plr.Weapons:FindFirstChild(purchase.Name).Value == false and purchase.Onsale.Value then
				plr.Gold.Value = plr.Gold.Value - purchase.Cost.Value
				plr.Weapons:FindFirstChild(purchase.Name).Value = true
			end
		elseif purchasetype == "Food"  then
			local foodamount = 0
			local food = plr.Food:GetChildren()
			for i=1,#food do
				foodamount = foodamount + food[i].Value
			end
			if plr.Gold.Value >= purchase.Cost.Value and foodamount < 8 and purchase.Onsale.Value == true and plr.Food:FindFirstChild(purchase.Name).Value < purchase.Max.Value then
				plr.Gold.Value = plr.Gold.Value - purchase.Cost.Value
				plr.Food:FindFirstChild(purchase.Name).Value = plr.Food:FindFirstChild(purchase.Name).Value + 1
			end
		elseif purchasetype == "SOUL" then
			if plr.Gold.Value  >= purchase.Cost.Value and plr.SoulFragments:FindFirstChild(purchase.Name).Value >= purchase.Fragments.Value and purchase.Onsale.Value == true  then
				plr.Gold.Value = plr.Gold.Value - purchase.Cost.Value
				plr.SoulFragments:FindFirstChild(purchase.Name).Value = plr.SoulFragments:FindFirstChild(purchase.Name).Value - purchase.Fragments.Value
				plr.SOULs:FindFirstChild(purchase.Name).Value = true
			end
		elseif purchasetype == "Armor" then
			if plr.Gold.Value >= purchase.Cost.Value and plr.Armor:FindFirstChild(purchase.Name).Value == false and purchase.Onsale.Value == true then
				plr.Gold.Value = plr.Gold.Value - purchase.Cost.Value
				plr.Armor:FindFirstChild(purchase.Name).Value = true
			end
		end
	end
end)
game.Lighting.UseSoul.OnServerEvent:Connect(function(plr,soul)
	local battling = false
	local c = plr.Character:GetChildren()
	for i=1,#c do
		if string.sub(c[i].Name,1,7) == "_battle" then
			battling = true
		end
	end
	if plr.SOULs:FindFirstChild(soul.Name).Value == true and battling == false then
		plr.SelectedSOUL.Value = soul
		plr.Character.Effect:Destroy()
		plr.Character.Humanoid.WalkSpeed = 50
		plr.Character.Humanoid.JumpPower = 50
		soul.Effect:Clone().Parent = plr.Character
	end
end)


game.Lighting.EquipArmor.OnServerEvent:Connect(function(plr,armor)
	local battling = false
	local c = plr.Character:GetChildren()
	for i=1,#c do
		if string.sub(c[i].Name,1,7) == "_battle" then
			battling = true
		end
	end
	if plr.Armor:FindFirstChild(armor.Name).Value == true and battling == false then
		plr.EquippedArmor.Value = armor
		local HP = Settings.MaxHP(plr.LOVE.Value, armor)
		assert(HP, "Settings.MaxHP returns an invalid value!")
		plr.Character.Humanoid.MaxHealth = HP
		plr.Character.Humanoid.Health = HP
		local c = plr.Character:GetChildren()
		for i=1,#c do
			if c[i].Name == "ArmorDesign" then
				c[i]:Destroy()
			end
		end
		local c = armor.Design:GetChildren()
		for i=1,#c do
			local clone = c[i]:Clone()
			if (clone:IsA("Model") or clone:IsA("Accessory"))then
				local f = clone:GetChildren()
				for i2=1,#f do
					if f[i2]:IsA("BasePart") then
						local Transparency = Instance.new("NumberValue")
						Transparency.Name = "_transparency"
						Transparency.Value = f[i2].Transparency
						Transparency.Parent = f[i2]
						if plr.ArmorDesignDisabled.Value then
							f[i2].Transparency = 1
						end
					end
				end
			end
			clone.Parent = plr.Character
		end
		if plr.Backpack:FindFirstChild("AttackTool") then
			if plr.Backpack.AttackTool:FindFirstChild("DamageIncrease") then
				plr.Backpack.AttackTool.DamageIncrease.Value = 0
			end
		elseif plr.Character:FindFirstChild("AttackTool") then
			if plr.Character.AttackTool:FindFirstChild("DamageIncrease") then
				plr.Character.AttackTool.DamageIncrease.Value = 0
			end
		end
	end
end)





game.Lighting.UseWeapon.OnServerEvent:Connect(function(plr,weapon)
	if typeof(weapon) ~= "Instance" or weapon:IsDescendantOf(game.Lighting.Weapons) == false then
		return
	end
	local battling = plr.Character:FindFirstChild("_battle") ~= nil
	if plr.Weapons:FindFirstChild(weapon.Name).Value == true and battling == false then
		plr.Weapon.Value = weapon
		if plr.Backpack:FindFirstChild("AttackTool") then
			plr.Backpack:FindFirstChild("AttackTool"):Destroy()
		elseif plr.Character:FindFirstChild("AttackTool") then
			plr.Character:FindFirstChild("AttackTool"):Destroy()
		end
		if plr.StarterGear:FindFirstChild("AttackTool")  then
			plr.StarterGear:FindFirstChild("AttackTool"):Destroy()
		end
		local t1= plr.Weapons:FindFirstChild(weapon.Name).Skin.Value.Tool:FindFirstChildOfClass("Tool"):Clone()
		local t2 = plr.Weapons:FindFirstChild(weapon.Name).Skin.Value.Tool:FindFirstChildOfClass("Tool"):Clone()
		local p1 = Instance.new("ObjectValue")
		p1.Name = "Player"
		p1.Value = plr
		p1.Parent = t1
		local p2 = Instance.new("ObjectValue")
		p2.Name = "Player"
		p2.Value = plr
		p2.Parent = t2
		local i1 = Instance.new("ObjectValue")
		i1.Name = "BaseWeapon"
		i1.Value = weapon
		i1.Parent = t1
		local i2 = Instance.new("ObjectValue")
		i2.Name = "BaseWeapon"
		i2.Value = weapon
		i2.Parent = t2
		t1.Parent = plr.Backpack
		t2.Parent = plr.StarterGear
	end
end)

game.Lighting.Sell.OnServerEvent:Connect(function(plr,food)
	local battling = false
	local c = plr.Character:GetChildren()
	for i=1,#c do
		if string.sub(c[i].Name,1,7) == "_battle" then
			battling = true
		end
	end
	if plr.Food:FindFirstChild(food.Name).Value > 0 and battling == false and food.Permanent.Value == false then
		plr.Food:FindFirstChild(food.Name).Value = plr.Food:FindFirstChild(food.Name).Value - 1
		plr.Gold.Value = plr.Gold.Value + (food.Cost.Value / 2)
	end
end)
game.Lighting.Reset.OnServerEvent:Connect(function(plr)
	task.wait(0.5)
	if plr.LOVE.Value == Settings.MaxLOVE and ((game.Lighting.FinalBosses:FindFirstChild(plr.Resets.Value)  and plr.BossChart:FindFirstChild(game.Lighting.FinalBosses:FindFirstChild(plr.Resets.Value).Value.Name).TimesFought.Value >= 1) or game.Lighting.FinalBosses:FindFirstChild(plr.Resets.Value) == nil  and plr.Gold.Value >= Settings.ResetPriceBase*(plr.Resets.Value+1)) and plr.Resets.Value < (Settings.MaxResets or math.huge) then
		plr.LOVE.Value = 1
		plr.Resets.Value += 1
		plr.Gold.Value = 0
		plr.XP.Value = 0
		plr.SelectedSOUL.Value = game.Lighting.Weapons:FindFirstChild(DefaultData.Settings.SOUL)
		plr.Weapon.Value = game.Lighting.Weapons:FindFirstChild(DefaultData.Settings.Weapon)
		plr.EquippedArmor.Value = game.Lighting.Weapons:FindFirstChild(DefaultData.Settings.Armor)
		plr.StarterGear:ClearAllChildren()
		plr.Backpack:ClearAllChildren()
		game.Lighting.Weapons.Stick.Tool.AttackTool:Clone().Parent = plr.StarterGear
		local c = plr.Food:GetChildren()
		for i=1,#c do
			if game.Lighting.Food:FindFirstChild(c[i].Name).Permanent.Value == false and game.Lighting.Food:FindFirstChild(c[i].Name).TruePermanent.Value == false then
				c[i].Value = 0
			end
		end
		local c = plr.SoulFragments:GetChildren()
		for i=1,#c do
			c[i].Value = 0
		end
		local c = plr.Weapons:GetChildren()
		for i=1,#c do
			if game.Lighting.Weapons:FindFirstChild(c[i].Name).Permanent.Value == false and game.Lighting.Weapons:FindFirstChild(c[i].Name).TruePermanent.Value == false then
				c[i].Value = false
			end
		end 
		local c = plr.Armor:GetChildren()
		for i=1,#c do
			if game.Lighting.Armor:FindFirstChild(c[i].Name).Permanent.Value == false and game.Lighting.Armor:FindFirstChild(c[i].Name).TruePermanent.Value == false then
				c[i].Value = false
			end
		end 
		local c = plr.SOULs:GetChildren()
		for i=1,#c do
			if game.Lighting.SOULs:FindFirstChild(c[i].Name).Permanent.Value == false and game.Lighting.SOULs:FindFirstChild(c[i].Name).TruePermanent.Value == false then
				if c[i].Value == true then
					c[i].Value = false
					plr.SoulFragments:FindFirstChild(c[i].Name).Value = game.Lighting.SOULs:FindFirstChild(c[i].Name).Fragments.Value
				else
					c[i].Value = false
				end
			end
		end
		plr:LoadCharacter()
	elseif plr.LOVE.Value == Settings.MaxLOVE and plr.Resets.Value == Settings.MaxResets and Settings.TrueResetsEnabled == true then
		plr.LOVE.Value = 1
		plr.Resets.Value = 0
		plr.TrueResets.Value = plr.TrueResets.Value + 1
		plr.Gold.Value = 0
		plr.XP.Value = 0
		plr.SelectedSOUL.Value = game.Lighting.Weapons:FindFirstChild(DefaultData.Settings.SOUL)
		plr.Weapon.Value = game.Lighting.Weapons:FindFirstChild(DefaultData.Settings.Weapon)
		plr.EquippedArmor.Value = game.Lighting.Weapons:FindFirstChild(DefaultData.Settings.Armor)
		plr.StarterGear:ClearAllChildren()
		plr.Backpack:ClearAllChildren()
		game.Lighting.Weapons.Stick.Tool.AttackTool:Clone().Parent = plr.StarterGear
		local c = plr.Food:GetChildren()
		for i=1,#c do
			if game.Lighting.Food:FindFirstChild(c[i].Name).TruePermanent.Value == false then
				c[i].Value = 0
			end
		end
		local c = plr.SoulFragments:GetChildren()
		for i=1,#c do
			c[i].Value = 0
		end
		local c = plr.Weapons:GetChildren()
		for i=1,#c do
			if game.Lighting.Weapons:FindFirstChild(c[i].Name).TruePermanent.Value == false then
				c[i].Value = false
			end
		end 
		local c = plr.Armor:GetChildren()
		for i=1,#c do
			if game.Lighting.Armor:FindFirstChild(c[i].Name).TruePermanent.Value == false then
				c[i].Value = false
			end
		end 
		local c = plr.SOULs:GetChildren()
		for i=1,#c do
			if game.Lighting.SOULs:FindFirstChild(c[i].Name).TruePermanent.Value == false then
				if c[i].Value == true then
					c[i].Value = false
					plr.SoulFragments:FindFirstChild(c[i].Name).Value = game.Lighting.SOULs:FindFirstChild(c[i].Name).Fragments.Value
				else
					c[i].Value = false
				end
			end
		end
		plr:LoadCharacter()	
	end
end)



game.Lighting.EquipSkin.OnServerEvent:Connect(function(plr,skin)
	local battling = plr.Character:FindFirstChild("_battle") ~= nil
	if battling == false and (skin.Parent == game.Lighting.Skins and plr.Skins:FindFirstChild(skin.Name).Value == true or skin.Parent == game.Lighting.Weapons and plr.Weapons:FindFirstChild(skin.Name).Value == true) then
		if skin.Parent == game.Lighting.Skins and skin.SkinOf.Value == plr.Weapon.Value or skin.Parent == game.Lighting.Weapons then
			if plr.Backpack:FindFirstChild("AttackTool") then
				plr.Backpack.AttackTool:Destroy()
			end
			if plr.Character:FindFirstChild("AttackTool") then
				plr.Character.AttackTool:Destroy()
			end
			if plr.StarterGear:FindFirstChild("AttackTool") then
				plr.StarterGear.AttackTool:Destroy()
			end
			local t1= skin.Tool:FindFirstChildOfClass("Tool"):Clone()
			local t2 = skin.Tool:FindFirstChildOfClass("Tool"):Clone()
			local p1 = Instance.new("ObjectValue")
			p1.Name = "Player"
			p1.Value = plr
			p1.Parent = t1
			local p2 = Instance.new("ObjectValue")
			p2.Name = "Player"
			p2.Value = plr
			p2.Parent = t2
			local i1 = Instance.new("ObjectValue")
			i1.Name = "BaseWeapon"
			i1.Parent = t1
			local i2 = Instance.new("ObjectValue")
			i2.Name = "BaseWeapon"
			i2.Parent = t2
			if skin.Parent == game.Lighting.Skins then
				i1.Value = skin.SkinOf.Value
				i2.Value = skin.SkinOf.Value
			else
				i1.Value = skin
				i2.Value = skin
			end
			t1.Parent = plr.Backpack
			t2.Parent = plr.StarterGear
		end
		if skin.Parent == game.Lighting.Skins then
			plr.Weapons:FindFirstChild(skin.SkinOf.Value.Name).Skin.Value = skin
		else
			plr.Weapons:FindFirstChild(skin.Name).Skin.Value = skin
		end
	end
end)


game.Lighting.Save.Event:Connect(function(plr, BanInfo)
	if plr:FindFirstChild("_loadeddata") then
		local Data = {
			Gold = plr.Gold.Value,
			EXP = plr.XP.Value,
			LOVE = plr.LOVE.Value,
			Resets = plr.Resets.Value,
			TrueResets = plr.TrueResets.Value,
			Settings = {
				Weapon = plr.Weapon.Value.Name,
				Armor = plr.EquippedArmor.Value.Name,
				SOUL = plr.SelectedSOUL.Value.Name,
				InvitesDisabled = plr.InvitationsDisabled.Value,
				ArmorDesignDisabled = plr.ArmorDesignDisabled.Value,
				DamageCounter = plr.DamageCounterDisabled.Value,
				MuteMusic = plr.MuteMusic.Value,
				NotifyMessages = plr.NotifyMessages.Value,
				Skins = {},
				TextEdit = {
					Voice = plr.Voice.Value,
					Font = plr.Font.Value,
					Color = {plr.TextColor.Value.R, plr.TextColor.Value.G, plr.TextColor.Value.B}
				}
			},
			Weapons = {unpack(DefaultData.Weapons)},
			Armors = {unpack(DefaultData.Armors)},
			SOULs = {unpack(DefaultData.SOULs)},
			SOULFragments = {},
			Food = {},
			BossChart = {},
			Skins = {},
			BanInfo = BanInfo
		}
		for _, Weapon in plr.Weapons:GetChildren() do
			if Weapon.Value == true and table.find(Data.Weapons, Weapon.Name) == nil then
				table.insert(Data.Weapons, Weapon.Name)
			end
			Data.Settings.Skins[Weapon.Name] = Weapon.Skin.Value.Name
		end
		for _, Armor in plr.Armor:GetChildren() do
			if Armor.Value == true and table.find(Data.Armors, Armor.Name) == nil then
				table.insert(Data.Armors, Armor.Name)
			end
		end
		for _, SOUL in plr.SOULs:GetChildren() do
			if SOUL.Value == true and table.find(Data.SOULs, SOUL.Name) == nil then
				table.insert(Data.SOULs, SOUL.Name)
			end
		end
		for _, Skin in plr.Skins:GetChildren() do
			if Skin.Value == true and table.find(Data.Skins, Skin.Name) == nil then
				table.insert(Data.Skins, Skin.Name)
			end
		end
		for _, Food in plr.Food:GetChildren() do
			Data.Food[Food.Name] = Food.Value
		end
		for _, Fragment in plr.SoulFragments:GetChildren() do
			Data.SOULFragments[Fragment.Name] = Fragment.Value
		end
		for _, BossChart in plr.BossChart:GetChildren() do
			Data.BossChart[BossChart.Name] = {
				LOVE = BossChart.LOVE.Value,
				Resets = BossChart.Resets.Value,
				TimesFought = BossChart.TimesFought.Value,
				TimesFoughtMulti = BossChart.TimesFoughtMulti.Value,
				Date = BossChart.Date.Value,
			}
		end
		DataStore:SetAsync("Player"..plr.UserId, Data)
		game.Lighting.Saved:FireClient(plr)
		print("Saved data for "..plr.Name)
		if BanInfo then
			plr:Kick("You've been banned for: "..BanInfo.Reason)
		end
	end
end)
game.Lighting.CancelBattle.OnServerEvent:Connect(function(plr)
	local battling = false
	local c = plr.Character:GetChildren()
	for i=1,#c do
		if string.sub(c[i].Name,1,7) == "_battle" then
			battling = true
		end
	end
	if battling == true and plr.Character.Humanoid.WalkSpeed == 0 then
		for i=1,#c do
			if string.sub(c[i].Name,1,7) == "_battle" then
				c[i]:Destroy()
			end
		end
		plr.Character.Humanoid.WalkSpeed = 50
	end
end)

game.Lighting.EquipTool.OnServerEvent:Connect(function(plr,tool)
	if tool.Parent == plr.Backpack then
		plr.Character.Humanoid:EquipTool(tool)
	elseif tool.Parent == plr.Character then
		tool.Parent = plr.Backpack
	end
end)

game.Lighting.MuteMusic.OnServerEvent:Connect(function(Player, Muted)
	Player.MuteMusic.Value = Muted == true
end)
