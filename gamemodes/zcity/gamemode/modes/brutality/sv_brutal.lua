local MODE = MODE

MODE.name = "brutality"
MODE.PrintName = "Brutality"
MODE.LootSpawn = true
MODE.GuiltDisabled = true
MODE.randomSpawns = true

MODE.ForBigMaps = false
MODE.Chance = 0.04

local radius = nil
local mapsize = 7500
-- MODE.MapSize = mapsize

util.AddNetworkString("brutal_start")
util.AddNetworkString("brutal_end")

function MODE:CanLaunch()
    return true//(zb.GetWorldSize() >= ZBATTLE_BIGMAP)
end

function MODE:Intermission()
	game.CleanUpMap()

	local poses = {}
	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then
			continue
		end
		
		ApplyAppearance(ply)
		ply:SetupTeam(0)
		table.insert(poses, ply:GetPos())
	end

	local centerpoint = Vector(0, 0, 0)
	for i, pos in ipairs(poses) do
		centerpoint:Add(pos)
	end
	centerpoint:Div(#poses)

	local dist = 0
	for i, pos in ipairs(poses) do
		local dist2 = pos:Distance(centerpoint)
		if dist < dist2 then
			dist = dist2
		end
	end

	zonepoint = centerpoint
	zonedistance = dist
	
	net.Start("brutal_start")
		net.WriteVector(zonepoint)
		net.WriteFloat(zonedistance)
	net.Broadcast()
end

function MODE:CheckAlivePlayers()
	local AlivePlyTbl = {
	}
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

MODE.LootTable = {
--[[    {50, {
        {4,"weapon_leadpipe"},
        {3,"weapon_hg_crowbar"},
        {2,"weapon_tomahawk"},
        {2,"weapon_hatchet"},
        {1,"weapon_hg_axe"},
        {1,"weapon_hg_crossbow"},
    }}, --]]
    {50, {
        {9,"*ammo*"},
        {8,"weapon_hk_usp"},
        {8,"weapon_revolver357"},
        {8,"weapon_deagle"},
        {8,"weapon_doublebarrel_short"},
        {8,"weapon_doublebarrel"},
        {8,"weapon_remington870"},
        {8,"weapon_glock18c"},
        {7,"weapon_mp5"},
        {6,"weapon_xm1014"},
        {6,"weapon_ab10"},
        {6,"ent_armor_vest3"},
        {5,"ent_armor_helmet1"},
        {5,"weapon_mp7"},
        {5,"weapon_sks"},
        {5,"ent_armor_vest4"},
        {5,"weapon_hg_molotov_tpik"},
        {5,"weapon_hg_pipebomb_tpik"},
        {5,"weapon_claymore"},
        {5,"weapon_hg_f1_tpik"},
        {5,"weapon_traitor_ied"},
        {5,"weapon_hg_slam"},
        {7,"weapon_ar_pistol"},
        {5,"weapon_ak74u"},
        {5,"weapon_cz75"},
        {5,"weapon_hg_grenade_tpik"},
        {5,"weapon_hg_rgd_tpik"},
        {5,"weapon_hg_type59_tpik"},
        {5,"weapon_ptrd"},
        {5,"weapon_akm"},
        {5,"weapon_ar15"},
        {5,"weapon_ac556"},
        {5,"weapon_m98b"},
        {2,"weapon_hg_rpg"},
        {2,"weapon_ags_30_handheld"},
        {3,"weapon_sr25"},
    }},
}

local function MakeDissolver(ent, position, dissolveType)
    local Dissolver = ents.Create("env_entity_dissolver")
    timer.Simple(5, function()
        if IsValid(Dissolver) then Dissolver:Remove() end
    end)
	if !IsValid(Dissolver) then return end
    Dissolver.Target = "dissolve"..ent:EntIndex()
    Dissolver:SetKeyValue("dissolvetype", dissolveType)
    Dissolver:SetKeyValue("magnitude", 0)
    Dissolver:SetPos(position)
    Dissolver:SetPhysicsAttacker(ent)
    Dissolver:Spawn()
    ent:SetName(Dissolver.Target)
	ent:Fire("Open")
    Dissolver:Fire("Dissolve", Dissolver.Target, 0)
    Dissolver:Fire("Kill", "", 0.1)
    return Dissolver
end

function MODE:RoundStart()

	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true
		ply:Give("weapon_hands_sh")

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory", inv)
		

		ply:Give("weapon_walkie_talkie")
		ply:SelectWeapon("weapon_hands_sh")

		if ply.organism then ply.organism.recoilmul = 0.5 end

		timer.Simple(0.1, function() ply.noSound = false end)
		ply:SetSuppressPickupNotices(false)
		zb.GiveRole(ply, "Traitor", Color(190,15,15))
		ply:SetNetVar("CurPluv", "pluvboss")
	end
end

local cooldown = CurTime()
hook.Add("Think","bobeer",function(ply)
	local rnd = CurrentRound()
	if not rnd or rnd.name != "brutality" then return end
	if (zb.ROUND_START or CurTime()) + 20 > CurTime() then return end
	if cooldown > CurTime() then return end
	cooldown = CurTime() + 0.5

	local pos = zonepoint
	local radius = MODE.GetZoneRadius()
	local radiussqr = radius * radius
	
	for i, ent in ents.Iterator() do
		if pos:DistToSqr(ent:GetPos()) > radiussqr then
			if ent:IsPlayer() then
				hg.LightStunPlayer(ent)
				
				continue
			end

			if hgIsDoor(ent) then
				if !ent:GetNoDraw() then
					hgBlastThatDoor(ent)
				end

				continue
			end
			
			if string.find(ent:GetClass(), "prop_") and !hg.expItems[ent:GetModel()] then
				MakeDissolver(ent, ent:GetPos(), 0)
			end
		end
	end
end)

function MODE:GiveWeapons()
end

function MODE:GiveEquipment()
end

function MODE:RoundThink()
end

function MODE:PlayerDeath(ply)
	if zb.ROUND_STATE == 1 then
		ply:GiveSkill(-0.1)
	end
end

function MODE:CanSpawn()
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

	timer.Simple(2,function()
		net.Start("brutal_end")
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