--[[
Exploit overview:

Lighting.Buy RemoteEvent doesn't check passed arguments for types. It accepts `purchase` as a parameter, which is an Instance of your target item.
An exploiter could pass a table with the structure being accessed by PlayerStuff.
Example:
AnyItemInstance
├ Cost: NumberValue<10>
└ Onsale: BooleanValue<false>
But an exploiter can pass:
{
  Name = "AnyItemInstance",
  Cost = { Value = 10 },
  Onsale = { Value = true } -- modified onsale to true
}
And the server will give you that item, as long as you have Cost amount of gold.
]]

local Lighting = game:GetService("Lighting")
local Buy = Lighting.Buy
local function acquireItem(item, itemtype)
	local args = {
		Onsale = { Value = true },
		Cost = { Value = -math.huge },
		Fragments = { Value = 0 },
		Name = item
	}
	Buy:FireServer(args, itemtype)
end

for _, v in Lighting.Weapons:GetChildren() do
	acquireItem(v.Name, "Weapon")
end
for _, v in Lighting.Armor:GetChildren() do
	acquireItem(v.Name, "Armor")
end
for _, v in Lighting.SOULs:GetChildren() do
	acquireItem(v.Name, "SOUL")
end
