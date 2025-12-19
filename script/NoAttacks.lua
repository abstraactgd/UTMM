--[[
Exploit overview:

Some attacks are executed on the client to reduce load on the server. Of course, if attacks happen on the client, and we control the client, we control the attacks.
They're handled by a lone LocalScript called Handler in StarterGui.
]]

local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
local function removeClientAttackHandler()
	local handler = playerGui:WaitForChild("Handler", 3)
	if not handler then return end
	handler.Enabled = false
	task.delay(0, function()
		handler:Destroy()
	end) -- can't destroy an instance immediately after it's added
	-- so just wait a frame i guess
end
removeClientAttackHandler()
playerGui.ChildAdded:Connect(function(child)
	if child.Name == "Handler" then
		removeClientAttackHandler()
	end
end)
