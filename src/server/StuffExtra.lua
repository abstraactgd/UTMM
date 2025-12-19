-- From ServerScriptService.StuffExtra
--Since roblox is annoying, this script had to be created.
local c = game.Lighting.Weapons:GetChildren()
for i=1,#c do
	if c[i].Tool:FindFirstChildOfClass("Tool") then
	c[i].Tool:FindFirstChildOfClass("Tool").CanBeDropped = false
	end
end

local c = game.Lighting.Food:GetChildren()
for i=1,#c do
	if c[i].Tool:FindFirstChildOfClass("Tool") then
	c[i].Tool:FindFirstChildOfClass("Tool").CanBeDropped = false
	end
end


local c = game.Lighting.Skins:GetChildren()
for i=1,#c do
	if c[i].Tool:FindFirstChildOfClass("Tool") then
	c[i].Tool:FindFirstChildOfClass("Tool").CanBeDropped = false
	end
end


----------------------------------
if tonumber(game.PrivateServerOwnerId) > 0 then
local c = game.Lighting.Battles:GetChildren()
for i=1,#c do
	if c[i].MaxPlayers.Value > 1 then
		c[i].MaxPlayers.Value = game.Players.MaxPlayers
	end
end
end

local c = game.Lighting.AreaUnlockables:GetChildren()
for i=1,#c do
	local f = c[i].Locked:GetChildren()
	for i2=1,#f do
		if f[i2]:FindFirstChild("RequirePart") then
			f[i2].RequirePart.SurfaceGui.TextLabel.Text = "You need to beat "..c[i].BeatBoss.Value.BattleName.Value.." to go into "..c[i].Name
		end
	end
end

workspace.ChildAdded:Connect(function(c)
	if c:IsA("Tool") then
		c[i]:Destroy()
	end
end)



game.Lighting.Spectate.OnServerEvent:Connect(function(plr,sel)
	if sel and sel ~= plr and sel.Character:FindFirstChild("_battle") and plr.Character:FindFirstChild("_battle") == nil then
		local spectateplr = Instance.new("ObjectValue")
		spectateplr.Name = "_spectating"
		spectateplr.Value = sel
		spectateplr.Parent = plr.Character
	end
end)
