local MODE = MODE

MODE.name = "infection"
MODE.PrintName = "Infection"
MODE.Description = "Survive waves of zombies. Killed humans become zombies."

MODE.randomSpawns = false
MODE.LootSpawn = false
MODE.ForBigMaps = false
MODE.Chance = 0

MODE.start_time = 5
MODE.ROUND_TIME = 9000

MODE.HumansTeam = 0
MODE.ZombiesTeam = 1

MODE.WavesTotal = 5
MODE.WaveDuration = 90
MODE.PrepDuration = 30
MODE.PrepMoney = 1000

MODE.BuyTime = MODE.PrepDuration
MODE.buymenu = false
MODE.BuyItems = MODE.BuyItems or {}

local priority = 1
local function AddItemToBUY(ItemName, Type, ItemClass, Price, Category, Attachments, Amount)
	if not MODE.BuyItems[Category] then
		MODE.BuyItems[Category] = {}
		MODE.BuyItems[Category].Priority = priority
		priority = priority + 1
	end

	MODE.BuyItems[Category][ItemName] = {
		Type = Type,
		ItemClass = ItemClass,
		Price = Price,
		Category = Category,
		Attachments = Attachments,
		Amount = Amount,
	}
end

AddItemToBUY("9x19mm (30)", "Ammo", "ent_ammo_9x19mmparabellum", 75, "Ammo", {}, 30)
AddItemToBUY("12/70 Buckshot (20)", "Ammo", "ent_ammo_12/70gauge", 85, "Ammo", {}, 20)
AddItemToBUY("5.56x45mm (30)", "Ammo", "ent_ammo_5.56x45mm", 120, "Ammo", {}, 30)

AddItemToBUY("Bandage", "Weapon", "weapon_bandage_sh", 120, "Medical", {})
AddItemToBUY("Painkillers", "Weapon", "weapon_painkillers", 160, "Medical", {})
AddItemToBUY("Medkit", "Weapon", "weapon_medkit_sh", 450, "Medical", {})

AddItemToBUY("IIIA Vest", "Armor", "ent_armor_vest3", 450, "Armor", {})
AddItemToBUY("III Vest", "Armor", "ent_armor_vest4", 650, "Armor", {})
AddItemToBUY("ACH III Helmet", "Armor", "ent_armor_helmet1", 350, "Armor", {})

AddItemToBUY("HK-USP", "Weapon", "weapon_hk_usp", 500, "Pistols", {"supressor3", "supressor4"})
AddItemToBUY("Glock-17", "Weapon", "weapon_glock17", 550, "Pistols", {"supressor4", "holo16", "laser3", "laser1"})
AddItemToBUY("Deagle", "Weapon", "weapon_deagle", 900, "Pistols", {"supressor2", "holo15"})

AddItemToBUY("MP5", "Weapon", "weapon_mp5", 1800, "SMGs", {"holo1", "holo2", "laser1"})
AddItemToBUY("AKM", "Weapon", "weapon_akm", 2700, "Rifles", {"holo1", "holo2", "optic4", "laser2"})
AddItemToBUY("AR-15", "Weapon", "weapon_ar15", 2600, "Rifles", {"holo14", "optic6", "laser2"})
AddItemToBUY("M249", "Weapon", "weapon_m249", 5750, "Heavy", {"holo1","holo2","supressor2"})
