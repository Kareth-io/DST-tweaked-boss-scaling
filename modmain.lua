-- This keeps this code from being evaluated client side.
-- It is especially important since the client doesn't have access to certain components like 'lootdropper' and will cause tracebacks.
if not (GLOBAL.TheNet:GetIsServer() or GLOBAL.TheNet:IsDedicated()) then 
	return
end

-- Gross hash table thing
modimport "bosses.lua"

NumPlayer = 1
local SetSharedLootTable = GLOBAL.SetSharedLootTable


function ScaleLootTable(inst) 


	local new_loot = {}
	local scale_items = loot_bosses[inst.prefab]
	local maximum_drop = NumPlayer

	-- To ensure people playing solo don't have to 50/50 their boss drops.
	local minimum_drop = NumPlayer / 2
	if minimum_drop <= 1 then
		minimum_drop = 1
	end


	

	for _,item in pairs(scale_items) do
		if item['count'] == 'scale' then
			for i=1,maximum_drop do
				if i <= minimum_drop then
					chance = 1.00
				else
					chance = .40
				end
			new_loot[#new_loot+1] = {item["name"] ,  chance}
			end
		else
			-- Non scaled items processed here
			chance = item['chance']
			for i=1,item['count'] do
				new_loot[#new_loot+1] = {item["name"] ,  chance}
			end
		end
	end

	
	SetSharedLootTable(inst, new_loot)
	if(inst.components.lootdropper) then
		inst.components.lootdropper:SetChanceLootTable(inst)
	end
end

for boss,items in pairs(loot_bosses) do
	AddPrefabPostInit(boss, ScaleLootTable)
end

-- Method to update the number of players the mod has detected
local function UpdateLoot(world,player)
	NumPlayer = #GLOBAL.AllPlayers
    if NumPlayer == nil or NumPlayer==0 then
		return
    end
end


-- Run previous method on player join/leave
AddPrefabPostInit("world", function(world)
    world:ListenForEvent("ms_playerspawn", UpdateLoot)
    world:ListenForEvent("ms_playerleft", UpdateLoot)
end)	