-- From ServerScriptService.ChatAndCommands
local Spam = {}
local originalmax = {}
local Blacklist = {{" ",true},{"/e ",false},{"/help",true},{"",true},{"/nickname ",false},{"/removenick",true},{"/",false}} --format = blacklisting, whole message blacklisting
local PermissionLevels = {["Disabled"] = {}, ["Creator"] = {}, ["Admin"] = {}, ["Mod"] = {}, UTMMKitCreators = {76355774,81898264}} --harmless little rank! please keep!!!
local Commands = {
	["example"] = {["Description"] = "Example command", ["PermissionLevel"] = "Mod", ["Arguments"] = 0, ["Logs"] = "No",
	["Function"] = function(plr,msg)
		print("Example executed by "..plr.Name)
	end},
}
local c = game.Lighting.Battles:GetChildren()
for i=1,#c do
	table.insert(originalmax,{c[i].Name,c[i].MaxPlayers})
end

function CheckPermissionLevel(plr,level)
	for i=1,#level do
		if level[i] == plr.UserId then
			return true
			
		end
	end
	return false
end

function SpamProof(plr)
	local returnable = true
	for i=1,#Spam do
		if Spam[i] and Spam[i][1] and Spam[i][2] and Spam[i][3] and Spam[i][1] == plr and Spam[i][2] > 10 and os.time() - Spam[i][3] <= 20 then
			returnable = false
		elseif Spam[i] and Spam[i][1] == plr and Spam[i][2] > 10 and os.time() - Spam[i][3] > 20 then
			table.remove(Spam,i)
		end 
	end
	return returnable
end

game.Players.PlayerAdded:Connect(function(plr)
	repeat task.wait() until plr:FindFirstChild("_loadeddata")
	local LV = plr.LOVE.Value
	local Resets = plr.Resets.Value
	game.Lighting.SystemMessage:FireAllClients(plr.DisplayName.." joined the game",Enum.Font.Arcade,Color3.new(1,1,0),plr.NotifyMessages.Value)
	plr.LOVE.Changed:Connect(function()
		if plr.LOVE.Value > LV then
			game.Lighting.SystemMessage:FireAllClients(plr.DisplayName.." just gained a LOVE!",Enum.Font.Arcade,Color3.new(1,1,0),plr.NotifyMessages.Value)
		end
		LV = plr.LOVE.Value
	end)
	plr.Resets.Changed:Connect(function()
		if plr.Resets.Value > Resets then
			game.Lighting.SystemMessage:FireAllClients(plr.DisplayName.." just reset!",Enum.Font.Arcade,Color3.new(1,1,0),plr.NotifyMessages.Value)
		end
		Resets = plr.Resets.Value
	end)
end)
game.Players.PlayerRemoving:Connect(function(plr)
	game.Lighting.SystemMessage:FireAllClients(plr.DisplayName.." left the game",Enum.Font.Arcade,Color3.new(1,1,0),plr.NotifyMessages.Value)
end)
function CheckForBlacklist(msg)
	for i=1,#Blacklist do
		if (Blacklist[i][2] == true and msg == Blacklist[i][1]) or (Blacklist[i][2] == false and string.sub(msg,1,#Blacklist[i][1]) == Blacklist[i][1]) then
			return false
		end
	end
	return true
end

game.Lighting.Chat.OnServerEvent:Connect(function(plr,message,whisper)
	if CheckForBlacklist(message) and SpamProof(plr) then
		print("Got message from",plr.Name..", filtering it...")
		local Chat = Instance.new("Folder")
		Chat.Name = plr.Name
		local Player = Instance.new("ObjectValue")
		Player.Name = "Player"
		Player.Value = plr
		Player.Parent = Chat
		local Message = Instance.new("Folder")
		Message.Name = "Message"
		local filter = ""
		local result = nil
		for i=1,#message do
			if string.sub(message,i,i) ~= " " then
				filter = filter.."_"
			end
		end
		for i=1,10 do
		local success, errormessage = pcall(function() 
			print("Filtering message from",plr.Name.."...")
			if whisper == nil then
			result = game:GetService("TextService"):FilterStringAsync(message, plr.UserId, Enum.TextFilterContext.PublicChat)
			else
			result = game:GetService("TextService"):FilterStringAsync(message, plr.UserId, Enum.TextFilterContext.PrivateChat)
			end
		end)
		if not success then
			warn("Message filter failed from",plr.Name..": , original",message..", error message: ",errormessage)
		end
		if result then
			print("Filter finished from "..plr.Name)
			local plrs = game.Players:GetPlayers()
			for i=1,#plrs do
				local filterstring = Instance.new("StringValue")
				filterstring.Name = plrs[i].Name
				filterstring.Value = result:GetChatForUserAsync(plr.UserId)
				filterstring.Parent = Message
			end
			break
		end 
		end
		local CanTalkFolder = Instance.new("Folder")
		CanTalkFolder.Name = "CanTalk"
		local p = game.Players:GetPlayers()
		for i=1,#p do
			local cantalk =  game.Chat:CanUsersChatAsync(plr.UserId,p[i].UserId) == true
			local val = Instance.new("BoolValue")
			val.Name = p[i].Name
			val.Value = cantalk
			val.Parent = CanTalkFolder
		end
		CanTalkFolder.Parent = Chat
		local Whispering = Instance.new("BoolValue")
		Whispering.Name = "Whisper"
		Whispering.Value = whisper ~= nil 
		Whispering.Parent = Chat
		Message.Parent = Chat
		if whisper == nil then
		Chat.Parent = game.Chat.Messages
		else
			Chat.Parent = game.Chat.Whisper
			game.Lighting.Chat:FireClient(plr,Chat)
			game.Lighting.Chat:FireClient(whisper,Chat)
		end
		local foundspam = nil
		local foundspamloc = 0
		for i=1,#Spam do
			if Spam[i][1] == plr then
				foundspam = Spam[i]
				foundspamloc = i
			end
		end
		if foundspam == nil then
			local spam = {plr,1,os.time()}
			table.insert(Spam,#Spam+1,spam)
		else
			foundspam[2] = foundspam[2] + 1
			table.remove(Spam,foundspamloc)
			table.insert(Spam,foundspamloc,foundspam)
		end
	elseif not SpamProof(plr) then
		game.Lighting.SystemMessage:FireClient(plr,"You have sent too many messages in a short time. Please wait a bit.",Enum.Font.Arcade,Color3.new(1,1,1),true)
	end
	if string.sub(message,1,#"/nickname ") == "/nickname " and (plr.UserId == 76355774 or plr.UserId == 81898264) then
		if plr:FindFirstChild("_nickname") == nil then
			local nick = Instance.new("StringValue")
			nick.Name = "_nickname"
			nick.Parent = plr
		end
		    local nick = plr:FindFirstChild("_nickname")
			nick.Value = game.Chat:FilterStringAsync(string.sub(message,#"/nickname "+1),plr,plr)
	end
	if string.sub(message,1,3) == "/e " or string.sub(message,1,8) == "/emote " then
		local emotetext = ""
		if string.sub(message,1,3) == "/e "  then
			emotetext = string.sub(message,4)
		else
			emotetext = string.sub(message,9)
		end
		if game.Lighting.Emotes:FindFirstChild(emotetext) and game.Lighting.Emotes:FindFirstChild(emotetext).ResetUnlock.Value <= plr.Resets.Value then
			if plr.Character:FindFirstChild("Emote") == nil then
			local animation = Instance.new("Animation")
			animation.AnimationId = "rbxassetid://"..game.Lighting.Emotes:FindFirstChild(emotetext).Animation.Value
			animation.Name = "Emote"
			animation.Parent = plr.Character
			local anim = plr.Character.Humanoid.Animator:LoadAnimation(animation)
			anim:Play()
			plr.Character.Humanoid.Changed:Connect(function()
				if plr.Character.Humanoid.Jump == true or plr.Character.Humanoid.MoveDirection ~= Vector3.new(0,0,0) then
					anim:Stop()
					anim:Destroy()
					animation:Destroy() 
					return
				end
			end)
			end
		end
	end
	if message == "/removenick" then
		if plr:FindFirstChild("_nickname") then
			plr:FindFirstChild("_nickname"):Destroy()
		end
	end
	if message == "/help" then
		game.Lighting.SystemMessage:FireClient(plr,"List of commands: ",Enum.Font.Arcade,Color3.new(1,1,1),true)
		game.Lighting.SystemMessage:FireClient(plr,"/w username (direct message people)",Enum.Font.Arcade,Color3.new(1,1,1),true)
		game.Lighting.SystemMessage:FireClient(plr,"/help (yes you aren't using this command)",Enum.Font.Arcade,Color3.new(1,1,1),true)
		for i,v in pairs(Commands) do
			print("gay")
			if CheckPermissionLevel(plr, PermissionLevels[v["PermissionLevel"]]) ==  true then
				print("command help")
				game.Lighting.SystemMessage:FireClient(plr,"/"..tostring(i).." ("..v["Description"]..")",Enum.Font.Arcade,Color3.new(1,1,1),true)
			end
		end
		game.Lighting.SystemMessage:FireClient(plr,"Emotes: ",Enum.Font.Arcade,Color3.new(1,1,1),true)
		local c = game.Lighting.Emotes:GetChildren()
		for i=1,#c do
			if c[i].ResetUnlock.Value <= plr.Resets.Value then
		      game.Lighting.SystemMessage:FireClient(plr,"/e "..c[i].Name,Enum.Font.Arcade,Color3.new(1,1,1),true)
			end
		end
	end
	for i,v in pairs(Commands) do
		if string.sub(string.lower(message),1,#i+1) == "/"..i and CheckPermissionLevel(plr, PermissionLevels[v["PermissionLevel"]]) ==  true then
			v["Function"](plr,message)
		end
	end
end)




function LoadChat(msg,char,plrfrom)
	repeat task.wait(0.01) until char.Head:FindFirstChild("Chatties") == nil 
	local chat = game.Lighting.Chatty:Clone()
	if plrfrom.UserId == 81898264 or plrfrom.UserId == 76355774 then
		chat.Frame.Text.TextColor3 = Color3.new(0,1,1)
	end
	chat.Frame.BackgroundTransparency = 1
	chat.Parent = char.Head
	local chatties = 0
	for i=1,10 do
		task.wait(0.05)
		chat.Frame.BackgroundTransparency = chat.Frame.BackgroundTransparency - 0.1
	end
	if char:FindFirstChild("_loadvoice") then
		if char:FindFirstChild("_loadvoice").Value then
					local text = char:FindFirstChild("_loadvoice").Value:Clone()
		text.FromPlayer.Value = plrfrom
		text.Message.Value = msg
		text.Parent = chat.Frame.Text
		else
			local text = game.Lighting.Text.Player:Clone()
		text.FromPlayer.Value = plrfrom
		text.Message.Value = msg
		text.Parent = chat.Frame.Text
		end
	else
		local text = game.Lighting.Text.Player:Clone()
		text.FromPlayer.Value = plrfrom
		text.Message.Value = msg
		text.Parent = chat.Frame.Text
	end
end

game.Players.PlayerAdded:Connect(function(plr)
	if CheckPermissionLevel(plr,PermissionLevels["Creator"]) then
		local badgefolder = Instance.new("Folder")
		badgefolder.Name = "Badge"
		local badgename = Instance.new("StringValue")
		badgename.Name = "BadgeName"
		badgename.Value = "A creator of the game"
		badgename.Parent = badgefolder
		local badgecolor = Instance.new("Color3Value")
		badgecolor.Value = Color3.fromRGB(0,255,255)
		badgecolor.Name = "BadgeColor"
		badgecolor.Parent = badgefolder
		badgefolder.Parent = plr
	elseif CheckPermissionLevel(plr,PermissionLevels["Admin"]) then
		local badgefolder = Instance.new("Folder")
		badgefolder.Name = "Badge"
		local badgename = Instance.new("StringValue")
		badgename.Name = "BadgeName"
		badgename.Value = "An administrator of the game"
		badgename.Parent = badgefolder
		local badgecolor = Instance.new("Color3Value")
		badgecolor.Value = Color3.fromRGB(131,31,24)
		badgecolor.Name = "BadgeColor"
		badgecolor.Parent = badgefolder
		badgefolder.Parent = plr
	elseif CheckPermissionLevel(plr,PermissionLevels["Mod"]) then
		local badgefolder = Instance.new("Folder")
		badgefolder.Name = "Badge"
		local badgename = Instance.new("StringValue")
		badgename.Name = "BadgeName"
		badgename.Value = "A moderator of the game"
		badgename.Parent = badgefolder
		local badgecolor = Instance.new("Color3Value")
		badgecolor.Value = Color3.fromRGB(26,255,0)
		badgecolor.Name = "BadgeColor"
		badgecolor.Parent = badgefolder
		badgefolder.Parent = plr
	elseif CheckPermissionLevel(plr,PermissionLevels["UTMMKitCreators"]) then
		local badgefolder = Instance.new("Folder")
		badgefolder.Name = "Badge"
		local badgename = Instance.new("StringValue")
		badgename.Name = "BadgeName"
		badgename.Value = "Creator of the UT MM kit"
		badgename.Parent = badgefolder
		local badgecolor = Instance.new("Color3Value")
		badgecolor.Value = Color3.fromRGB(155,0,255)
		badgecolor.Name = "BadgeColor"
		badgecolor.Parent = badgefolder
		badgefolder.Parent = plr
	end
	plr.Chatted:Connect(function(msg)
		if CheckForBlacklist(msg) then
		local char = plr.Character
		LoadChat(msg,char,plr)
		end
	end)
end)

