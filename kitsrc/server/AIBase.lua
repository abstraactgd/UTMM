-- From ServerScriptService.Modules.AIBase
local FormatNumber = require(game.ReplicatedStorage.Modules.FormatNumber)

return function(Character, Info)
	
	if Character:FindFirstChild("Damage") then
		Character.Damage.OnServerEvent:Connect(function(Player, Name)
			if Info.DamageInfo and Info.DamageInfo[Name] then
				if typeof(Info.DamageInfo[Name]) == "number" then
					Player.Character.Humanoid:TakeDamage(Info.DamageInfo[Name])
				elseif typeof(Info.DamageInfo[Name]) == "function" then
					Info.DamageInfo[Name](Player)
				end
			end
		end)
	else
		warn("Add a remote event called Damage to",Character,"for damaging!")
	end

	local CurrentAOIndex = 0
	
	local enemytag = Instance.new("ObjectValue")
	enemytag.Name = "_enemytag"
	enemytag.Parent = Character
	Character.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	Character.Humanoid.NameDisplayDistance = 0
	local stats = game.Lighting.Stats:Clone()
	stats.MonsterName.Text = Info.MonsterName
	stats.Parent = Character.Head
	local order = 1
	Character.Humanoid.Died:Connect(function()
		if Info.DeathEffect then
			Info.DeathEffect()
		end
	end)
	
	local function UpdateHP()
		stats.HP.Text.Text = "HP "..FormatNumber(Character.Humanoid.Health).."/"..FormatNumber(Character.Humanoid.MaxHealth)
		stats.HP.Bar.Size = UDim2.new(Character.Humanoid.Health/Character.Humanoid.MaxHealth,0,1,0)
	end
	UpdateHP()
	Character.Humanoid.Changed:Connect(UpdateHP)
	

	local target = nil 
	local function FindTarget()
		local dist = Info.RangeofVision
		local found = nil
		local c = workspace:GetChildren()
		for i=1,#c do
			if c[i]:FindFirstChild("HumanoidRootPart") and c[i]:FindFirstChild("Humanoid") and c[i].Humanoid.Health > 0  and c[i]:FindFirstChild("_enemytag") == nil and c[i] ~= Character and (Character.HumanoidRootPart.Position - c[i].HumanoidRootPart.Position).Magnitude <= dist then
				dist = (Character.HumanoidRootPart.Position - c[i].HumanoidRootPart.Position).Magnitude
				found = c[i]
			end
		end
		target = found
	end

	local function Move()
		local path = game:GetService("PathfindingService"):FindPathAsync(Character.HumanoidRootPart.Position,target.HumanoidRootPart.Position)
		local wp = path:GetWaypoints()
		if #wp >= 4 then
			Character.Humanoid.WalkToPoint = wp[4].Position
			if wp[4].Action == Enum.PathWaypointAction.Jump then
				Character.Humanoid.Jump = true
			end
		elseif #wp >= 3 then
			Character.Humanoid.WalkToPoint = wp[3].Position
			if wp[3].Action == Enum.PathWaypointAction.Jump then
				Character.Humanoid.Jump = true
			end
		elseif #wp >= 2 then
			Character.Humanoid.WalkToPoint = wp[2].Position
			if wp[2].Action == Enum.PathWaypointAction.Jump then
				Character.Humanoid.Jump = true
			end
		elseif #wp >= 1 then
			Character.Humanoid.WalkToPoint = wp[1].Position
			if wp[1].Action == Enum.PathWaypointAction.Jump then
				Character.Humanoid.Jump = true
			end
		else
			Character.Humanoid.WalkToPoint = target.HumanoidRootPart.Position
		end
	end
	
	local function GetAttackOrder()
		if Info.AttackOrders == nil then return Info.AttackOrder end
		local Return, Index = Info.AttackOrder, CurrentAOIndex
		for i, Order in ipairs(Info.AttackOrders) do
			if Order.Condition and (typeof(Order.Condition) == "number" and Character.Humanoid.Health <= Order.Condition or typeof(Order.Condition) == "function" and Order.Condition()) then
				Return = Order
				Index = i
			end
		end
		return Return, Index
	end
	
	local speed = Character.Humanoid.WalkSpeed
	while Character and (Character:FindFirstChildOfClass("Humanoid") == nil or Character:FindFirstChildOfClass("Humanoid").Health > 0) do
		task.wait()
		FindTarget()
		local plrs = {}
		local c = Character.Players:GetChildren()
		for i=1,#c do
			table.insert(plrs,c[i].Value)
		end
		local NewOrder, NOIndex = GetAttackOrder()
		if NOIndex ~= CurrentAOIndex then
			Info.AttackOrder = NewOrder.Order or Info.AttackOrder
			Info.Hitspeed = NewOrder.Hitspeed or Info.Hitspeed
			CurrentAOIndex = NOIndex
			order = 1
		end
		if target and target.Parent and target:FindFirstChild("HumanoidRootPart") then
			if (Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude > Info.AttackActivationRange then
				Move() 
				Character.Humanoid.WalkSpeed = speed
			else 
				Character.Humanoid.WalkSpeed = 0.05
				Character.Humanoid.WalkToPoint = target.HumanoidRootPart.Position
				if Character:FindFirstChild("_attacktag") == nil then
					local block = Instance.new("ObjectValue")
					block.Name = "_attacktag"
					block.Parent = Character
					game.Debris:AddItem(block,Info.Hitspeed)
					if not Info.AttackOrderRandom and target and target.Parent and target:FindFirstChild("HumanoidRootPart") then
						if order <= #Info.AttackOrder and target and target.Parent and target:FindFirstChild("HumanoidRootPart") then
							if string.sub(Info.AttackOrder[order],1,6) == "SERVER" then
								local attack = require(Character.Attacks:FindFirstChild(Info.AttackOrder[order]))
								attack(target)	
							else
								for i=1,#plrs do
									game.Lighting.AttackOnClient:FireClient(plrs[i],Character.Attacks:FindFirstChild(Info.AttackOrder[order]),target,Character)
								end	
							end				
							order = order + 1
						elseif target then
							order = 1 
							if string.sub(Info.AttackOrder[order],1,6) == "SERVER" then
								local attack = require(Character.Attacks:FindFirstChild(Info.AttackOrder[order]))
								attack(target)	
							else
								for i=1,#plrs do
									game.Lighting.AttackOnClient:FireClient(plrs[i],Character.Attacks:FindFirstChild(Info.AttackOrder[order]),target,Character)
								end	
							end				
						end
					elseif target and target.Parent and target:FindFirstChild("HumanoidRootPart") then
						if string.sub(Info.AttackOrder[order],1,6) == "SERVER" then
							local attack = require(Character.Attacks:FindFirstChild(Info.AttackOrder[order]))
							attack(target)	
						else
							for i=1,#plrs do
								game.Lighting.AttackOnClient:FireClient(plrs[i],Character.Attacks:FindFirstChild(Info.AttackOrder[order]),target,Character)
							end	
						end				
					end
				end
			end
		end
	end
end
