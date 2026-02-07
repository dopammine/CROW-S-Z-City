local MODE = MODE

MODE.name = "genocide"
MODE.PrintName = "Genocide"
MODE.Description = "Collect weapons and kill until only one survives."
MODE.Chance = 0.03

MODE.LootSpawn = true
MODE.GuiltDisabled = true
MODE.ForBigMaps = false

MODE.LootTable = {
	{50, {
		{9, "*ammo*"},

		{6, "ent_armor_vest3"},
		{5, "ent_armor_vest4"},
		{5, "ent_armor_helmet1"},

		{5, "weapon_akm"},
		{5, "weapon_ak74"},
		{5, "weapon_ak74u"},
		{5, "weapon_m4a1"},
		{5, "weapon_hk416"},

		{5, "weapon_saiga12"},
		{5, "weapon_spas12"},

		{5, "weapon_m98b"},
		{5, "weapon_sr25"},
		{5, "weapon_svd"},
		{5, "weapon_ptrd"},
	}},
}

util.AddNetworkString("genocide_start")
util.AddNetworkString("genocide_end")

function MODE:CanLaunch()
    return true
end

function MODE:Intermission()
	game.CleanUpMap()

	local poses = {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then
			continue
		end

		ply:SetupTeam(0)
		table.insert(poses, ply:GetPos())
	end

	local centerpoint = Vector(0, 0, 0)
	for _, pos in ipairs(poses) do
		centerpoint:Add(pos)
	end
	if #poses > 0 then
		centerpoint:Div(#poses)
	end

	zonepoint = centerpoint

	local points = zb.GetMapPoints("RandomSpawns") or {}
	if not points or not next(points) then
		points = zb.GetMapPoints("Spawnpoint") or {}
	end

	for _, v in ipairs(points) do
		if math.random(3) == 1 then continue end

		local mdl
		if math.random(2) == 1 then
			mdl = "models/props_junk/wood_crate001a.mdl"
		else
			mdl = "models/props_junk/wood_crate002a.mdl"
		end

		local box = ents.Create("prop_physics")
		if not IsValid(box) then continue end
		box:SetModel(mdl)
		box:SetPos(v.pos)
		box:SetAngles(v.ang or angle_zero)
		box:Spawn()
	end

	net.Start("genocide_start")
		net.WriteVector(zonepoint)
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

function MODE:RoundStart()
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end

		ply:StripWeapons()
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true

		local hands = ply:Give("weapon_hands_sh")
		if IsValid(hands) then
			ply:SelectWeapon(hands)
		end

		local inv = ply:GetNetVar("Inventory") or {}
		inv["Weapons"] = inv["Weapons"] or {}
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory", inv)

		timer.Simple(0.1, function()
			if not IsValid(ply) then return end
			ply.noSound = false
			ply:SetSuppressPickupNotices(false)
		end)
	end
end

function MODE:RoundThink()
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints("Spawnpoint")), zb.TranslatePointsToVectors(zb.GetMapPoints("Spawnpoint"))
end

function MODE:CanSpawn()
end

function MODE:EndRound()
	local winner = zb:CheckAlive(true)[1]

	timer.Simple(2, function()
		net.Start("genocide_end")
			net.WriteEntity(IsValid(winner) and winner:Alive() and winner or NULL)
		net.Broadcast()

		if IsValid(winner) then
			winner:GiveExp(math.random(200, 250))
			winner:GiveSkill(math.Rand(0.3, 0.4))
		end
	end)
end
