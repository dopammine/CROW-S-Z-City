local MODE = MODE

MODE.name = "sdm"
MODE.PrintName = "Spineless Deathmatch"
MODE.Description = "Deathmatch where fighters cannot stand up."
MODE.LootSpawn = false
MODE.GuiltDisabled = true
MODE.randomSpawns = true
MODE.ForBigMaps = false
MODE.Chance = 0.04

util.AddNetworkString("sdm_start")
util.AddNetworkString("sdm_end")

function MODE:CanLaunch()
	return true
end

function MODE:Intermission()
	game.CleanUpMap()

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then
			continue
		end

		ApplyAppearance(ply)
		ply:SetupTeam(0)
	end

	net.Start("sdm_start")
	net.Broadcast()
end

function MODE:CheckAlivePlayers()
	local AlivePlyTbl = {}
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end
		AlivePlyTbl[#AlivePlyTbl + 1] = ply
	end
	return AlivePlyTbl
end

function MODE:ShouldRoundEnd()
	return (#zb:CheckAlive(true) <= 1)
end

local loadouts = {
	{primary = "weapon_glock17", attachments = {{"supressor4"},{"holo16","laser3"},{"holo15","laser1"},""}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_cz75", attachments = {{"supressor4"},{"supressor4"},""}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_deagle", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_ar15", attachments = {{"holo1","grip1","supressor2"},{"holo5","grip3","supressor2"},{"laser4","grip2"},{"laser4","supressor2"}}, armor = {"vest4","helmet1"}, ammo = 3},
	{primary = "weapon_sr25", attachments = {{"holo1","laser2"},{"optic2"},{"holo8","supressor7"},{"holo5","supressor7"}}, armor = {"vest1","helmet1","nightvision1"}, ammo = 3},
	{primary = "weapon_ptrd", attachments = "", armor = {}, ammo = 12},
	{primary = "weapon_mp7", attachments = {{"holo1","supressor2"},{"holo5","supressor2"},{"laser4","supressor2"}}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_p90", attachments = {{"holo15","supressor4"},{"laser1","supressor4"},{"holo14","supressor4"}}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_doublebarrel_short", attachments = "", armor = {"vest3","helmet1","mask1"}, ammo = 6},
	{primary = "weapon_akm", attachments = {{"holo6","supressor1"},{"holo4","laser1"},{"supressor1"}}, armor = {"vest1","helmet1","nightvision1"}, ammo = 3},
	{primary = "weapon_remington870", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_m4a1", attachments = {{"holo1","grip1","supressor2"},{"holo5","grip3","supressor2"},{"laser4","grip2"},{"laser4","supressor2"}}, armor = {"vest1","helmet1"}, ammo = 3},
	{primary = "weapon_mac11", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_mp5", attachments = {{"supressor4"}}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_m590a1", attachments = "", armor = {"vest4","helmet1","mask1"}, ammo = 3},
	{primary = "weapon_draco", attachments = "", armor = {"vest1","helmet1"}, ammo = 3},
	{primary = "weapon_uzi", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_tmp", attachments = {{"optic8"},{"holo3"},{"holo4"}}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_xm1014", attachments = "", armor = {"vest3","helmet1","mask1"}, ammo = 3},
	{primary = "weapon_saiga12", attachments = "", armor = {"vest3","helmet1","mask1"}, ammo = 4},
	{primary = "weapon_svd", attachments = {{"holo13"},{"holo6"},{"holo2"}}, armor = {"vest1","helmet1"}, ammo = 3},
	{primary = "weapon_spas12", attachments = {{"supressor5"}}, armor = {"vest3","helmet1","mask1"}, ammo = 3},
	{primary = "weapon_hk416", attachments = {{"holo1","grip1","supressor2"},{"holo5","grip3","supressor2"},{"laser4","grip2"},{"laser4","supressor2"}}, armor = {"vest1","helmet1"}, ammo = 3},
	{primary = "weapon_akmwreked", attachments = "", armor = {"vest1","helmet1"}, ammo = 3},
	{primary = "weapon_hk_usp", attachments = {{"supressor3"}}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_glock18c", attachments = {{"mag1","holo16"}}, armor = {"vest3","helmet1"}, ammo = 4},
	{primary = "weapon_skorpion", attachments = "", armor = {"vest3","helmet1"}, ammo = 4},
	{primary = "weapon_tec9", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_sg552", attachments = {{"optic8"},{"holo3"},{"holo4"}}, armor = {"vest4","helmet1"}, ammo = 3},
	{primary = "weapon_vector", attachments = {{"supressor4","holo3"},{"holo4"},{"holo7"}}, armor = {"vest3","helmet1"}, ammo = 4},
	{primary = "weapon_revolver2", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_revolver357", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_pkm", attachments = "", armor = {"vest1","helmet1"}, ammo = 0},
	{primary = "weapon_ak74", attachments = {{"holo6"},{"holo4"},{"optic8"}}, armor = {"vest1","helmet1"}, ammo = 3},
	{primary = "weapon_ak74u", attachments = {{"holo6"},{"holo4"}}, armor = {"vest1","helmet1"}, ammo = 3},
	{primary = "weapon_winchester", attachments = "", armor = {"vest3","helmet1"}, ammo = 4},
	{primary = "weapon_sks", attachments = {{"optic8"},{"holo6"}}, armor = {"vest3","helmet1"}, ammo = 4},
	{primary = "weapon_ruger", attachments = "", armor = {"vest3","helmet1"}, ammo = 5},
	{primary = "weapon_mini14", attachments = {{"optic8"},{"holo6"}}, armor = {"vest3","helmet1"}, ammo = 4},
	{primary = "weapon_ac556", attachments = {{"holo6"},{"holo4"}}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_ar15", secondary = "weapon_cz75", attachments = {{"holo1","grip1"},{"holo5","grip3"}}, armor = {"vest3","helmet1"}, ammo = 3, ammo2 = 2},
	{primary = "weapon_akm", secondary = "weapon_px4beretta", attachments = {{"holo6"},{"holo4"}}, armor = {"vest3","helmet1"}, ammo = 3, ammo2 = 2},
	{primary = "weapon_m4a1", secondary = "weapon_p22", attachments = {{"holo1","grip1"},{"holo5","grip3"}}, armor = {"vest3","helmet1"}, ammo = 3, ammo2 = 2},
	{primary = "weapon_mp5", secondary = "weapon_revolver2", attachments = {{"supressor4"}}, armor = {"vest3","helmet1"}, ammo = 3, ammo2 = 2},
	{primary = "weapon_sks", secondary = "weapon_flintlock", attachments = "", armor = {"vest3","helmet1"}, ammo = 4, ammo2 = 3},
	{primary = "weapon_winchester", secondary = "weapon_cz75", attachments = "", armor = {"vest3","helmet1"}, ammo = 4, ammo2 = 2},
	{primary = "weapon_mini14", secondary = "weapon_px4beretta", attachments = {{"holo6"}}, armor = {"vest3","helmet1"}, ammo = 3, ammo2 = 2},
	{primary = "weapon_hg_bow", attachments = "", armor = {"helmet1"}, ammo = 25, melee = "weapon_pocketknife", noGrenade = true, medicine = {"weapon_bandage_sh"}, medicineCount = 1},
	{primary = "weapon_hg_bow", attachments = "", armor = {"helmet7"}, ammo = 25, melee = "weapon_pocketknife", noGrenade = true, medicine = {"weapon_bigbandage_sh"}, medicineCount = 1},
	{primary = "weapon_musket", secondary = "weapon_flintlock", attachments = "", armor = {"vest2","helmet1"}, ammo = 10, ammo2 = 6, melee = "weapon_pocketknife", randomMedicine = true},
	{primary = "weapon_musket", secondary = "weapon_flintlock", attachments = "", armor = {"vest3"}, ammo = 12, ammo2 = 8, melee = "weapon_pocketknife", randomMedicine = true},
}

local randomGrenades = {"weapon_hg_rgd_tpik", "weapon_hg_pipebomb_tpik", "weapon_hg_smokenade_tpik", "weapon_hg_flashbang_tpik"}
local randomMedicine = {"weapon_bandage_sh", "weapon_bigbandage_sh", "weapon_medkit_sh", "weapon_fentanyl", "weapon_morphine", "weapon_adrenaline", "weapon_tourniquet"}
local randomMelees = {"weapon_melee", "weapon_pocketknife"}

local function ForceFake(ply, delay)
	if not IsValid(ply) then return end
	timer.Simple(delay or 0, function()
		if not IsValid(ply) then return end
		if not ply:Alive() then return end
		if ply:Team() == TEAM_SPECTATOR then return end
		hg.Fake(ply, nil, true, true)
	end)
end

function MODE:RoundStart()
	local loadout = loadouts[math.random(#loadouts)]
	local selectedAttachments = istable(loadout.attachments) and table.Random(loadout.attachments) or loadout.attachments

	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true
		ply:Give("weapon_hands_sh")

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory", inv)

		local gun = ply:Give(loadout.primary)
		if IsValid(gun) then
			ply:GiveAmmo(gun:GetMaxClip1() * loadout.ammo, gun:GetPrimaryAmmoType(), true)
			hg.AddAttachmentForce(ply, gun, selectedAttachments)
		end

		if loadout.secondary then
			local pistol = ply:Give(loadout.secondary)
			if IsValid(pistol) then
				ply:GiveAmmo(pistol:GetMaxClip1() * (loadout.ammo2 or 2), pistol:GetPrimaryAmmoType(), true)
			end
		end

		hg.AddArmor(ply, loadout.armor)
		ply:Give(loadout.melee or randomMelees[math.random(#randomMelees)])

		if not loadout.noGrenade then
			local grenadeCount = math.random(1, 2)
			local usedGrenades = {}
			for i = 1, grenadeCount do
				local grenade = randomGrenades[math.random(#randomGrenades)]
				while usedGrenades[grenade] and i > 1 do
					grenade = randomGrenades[math.random(#randomGrenades)]
				end
				usedGrenades[grenade] = true
				ply:Give(grenade)
			end
		end

		if loadout.medicine then
			for i = 1, (loadout.medicineCount or 1) do
				ply:Give(loadout.medicine[math.random(#loadout.medicine)])
			end
		elseif loadout.randomMedicine then
			for i = 1, math.random(1, 2) do
				ply:Give(randomMedicine[math.random(#randomMedicine)])
			end
		else
			ply:Give("weapon_bandage_sh")
			ply:Give("weapon_tourniquet")
		end

		ply:Give("weapon_walkie_talkie")
		ply:SelectWeapon("weapon_hands_sh")

		if ply.organism then ply.organism.recoilmul = 0.5 end

		timer.Simple(0.1, function()
			if IsValid(ply) then
				ply.noSound = false
				ply:SetSuppressPickupNotices(false)
			end
		end)
		zb.GiveRole(ply, "Fighter", Color(190,15,15))
		ply:SetNetVar("CurPluv", "pluvboss")
		ForceFake(ply, 0.2)
	end
end

function MODE:GiveWeapons()
end

function MODE:GiveEquipment()
end

function MODE:EndRound()
	local playersharm = {}
	for ply, tbl in pairs(zb.HarmDone) do
		for attacker, harm in pairs(tbl) do
			playersharm[attacker] = (playersharm[attacker] or 0) + harm
		end
	end

	local most_violent_player
	local curharm = 0
	for ply, harm in pairs(playersharm) do
		if harm > curharm then
			most_violent_player = ply
			curharm = harm
		end
	end

	timer.Simple(2, function()
		net.Start("sdm_end")
		local ent = zb:CheckAlive(true)[1]

		if IsValid(ent) then
			ent:GiveExp(math.random(150,200))
			ent:GiveSkill(math.Rand(0.2,0.3))
		end

		if IsValid(most_violent_player) then
			most_violent_player:GiveExp(math.random(150,200))
			most_violent_player:GiveSkill(math.Rand(0.2,0.3))
		end

		net.WriteEntity(IsValid(ent) and ent:Alive() and ent or NULL)
		net.WriteEntity(IsValid(most_violent_player) and most_violent_player or NULL)
		net.Broadcast()
	end)
end

MODE["Player Spawn"] = function(self, ply)
	ForceFake(ply, 0)
end

MODE["Should Fake Up"] = function(self, ply)
	return false
end
