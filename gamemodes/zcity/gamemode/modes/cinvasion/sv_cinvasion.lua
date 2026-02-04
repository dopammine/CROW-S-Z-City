MODE.name = "cinvasion"
MODE.PrintName = "Combine Invasion"

MODE.ForBigMaps = false
MODE.LootSpawn = true
MODE.ROUND_TIME = 240

MODE.Chance = 0.05

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1, true--returning true so guilt bans
end

function shuffle(tbl)
	local len = #tbl
	for i = len, 2, -1 do
	  local j = math.random(i)
	  tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

function MODE:AssignTeams()
	local players = player.GetAll()
	local numPlayers = #players
	local numCOMBINE = 1

	if numPlayers == 2 then
		numCOMBINE = 1
	elseif numPlayers == 3 then
		numCOMBINE = 1
	elseif numPlayers == 4 then
		numCOMBINE = 1
	elseif numPlayers == 5 then
		numCOMBINE = 2
	elseif numPlayers == 6 then
		numCOMBINE = 2
	elseif numPlayers == 7 then
		numCOMBINE = 3
	elseif numPlayers >= 8 then --return of the great elseif table
		numCOMBINE = 4
	end

	shuffle(players)

	for i = 1, numCOMBINE do
		if IsValid(players[i]) then 
			players[i]:SetTeam(0)
		end
	end

	for i = numCOMBINE + 1, numPlayers do
		if IsValid(players[i]) then 
			players[i]:SetTeam(1)
		end
	end
end

util.AddNetworkString("cinvasion_start")
function MODE:Intermission()
	game.CleanUpMap()
    
    self:AssignTeams()
	
	for k, ply in ipairs(player.GetAll()) do
		if ply:Team() == TEAM_SPECTATOR or ply:Team() == 0 then ply:KillSilent() continue end
		ply:SetupTeam(ply:Team())
	end

	net.Start("cinvasion_start")
	net.Broadcast()

end

function MODE:CheckAlivePlayers()
	local combinePlayers = {}
	local bystanderPlayers = {}

	for _, ply in ipairs(team.GetPlayers(0)) do
		if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
			table.insert(combinePlayers, ply)
		end
	end

	for _, ply in ipairs(team.GetPlayers(1)) do
		if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
			table.insert(bystanderPlayers, ply)
			end
	end

	return {combinePlayers, bystanderPlayers}
end





function MODE:ShouldRoundEnd()
	if zb.ROUND_START + 91 > CurTime() then return end
	local aliveTeams = self:CheckAlivePlayers()
	local endround, winner = zb:CheckWinner(aliveTeams)
	return endround
end



function MODE:RoundStart()
    
end

local tblweps = {
	[0] = { 
		{"weapon_osipr", {} }, 
		{"weapon_spas12", {} },
		{"weapon_mp7", {"holo14"} },
	},
	[1] = { 
		{"weapon_revolver357", {} },
		{"weapon_hk_usp", {} },
		{"weapon_doublebarrel", {} },
		{"weapon_pm9", {"silencer_pistol", "pm9_magwell", "microt2", "afg_grip", "xps3", "grip_pm9"} },
		{"weapon_px4beretta", {"silencer_pistol"} },
		{"weapon_ruger", {} },
		{"weapon_svd", {"svd_barrel", "svd_scope", "svd_mount"} },
		{"weapon_vpo136", {} },
	}
}

local tblotheritems = {
	[0] = { 
		"weapon_medkit_sh", 
		"weapon_tourniquet",
        "weapon_hg_stunstick",
		"weapon_hg_hl2nade_tpik"
	},
	[1] = { 
		"weapon_bigconsumable", 
		"weapon_bandage_sh",
		"weapon_painkillers",
		"weapon_ducttape",
		"weapon_hammer"

	}
}


function MODE:CanLaunch()
	local points = zb.GetMapPoints( "HMCD_CRI_CT" )
	local points2 = zb.GetMapPoints( "HMCD_CRI_T" )
	local plramount = zb:CheckPlaying()
    return (#points > 3) and (#points2 > 0) and (#plramount > 5)
end

function MODE:GiveEquipment()
	timer.Simple(0.5,function()
		local combinePlayers = {} 

		for i, ply in ipairs(player.GetAll()) do
			if ply:Team() == TEAM_SPECTATOR then continue end

			if ply:Team() == 0 then
				timer.Create("COMBINESpawn"..ply:EntIndex(), 90, 1, function()
					ply:Spawn()
					ply:SetSuppressPickupNotices(true)
					ply.noSound = true

					ply:SetupTeam(ply:Team())

					ply:SetPlayerClass("Combine")
					ply:SetModel("models/player/combine_soldier.mdl")

					local inv = ply:GetNetVar("Inventory")
					inv["Weapons"]["hg_sling"] = true
					ply:SetNetVar("Inventory",inv)

					hg.AddArmor(ply, "cmb_armor") 
					hg.AddArmor(ply, "cmb_helmet") 

					zb.GiveRole(ply, "Combine", Color(0,150,150))

					table.insert(combinePlayers, ply) 

					local wep = tblweps[ply:Team()][math.random(#tblweps[ply:Team()])]
					local gun = ply:Give(wep[1])
					if IsValid(gun) and gun.GetMaxClip1 then
						hg.AddAttachmentForce(ply,gun,wep[2])
						ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)
					else
						print("WTH???")
					end

					for _, item in ipairs(tblotheritems[ply:Team()]) do
						ply:Give(item)
					end

					local hands = ply:Give("weapon_hands_sh")

					ply:SetSuppressPickupNotices(false)
					ply.noSound = false
				end)
			else
				ply:SetSuppressPickupNotices(true)
				ply.noSound = true

				ply:SetPlayerClass("bystander")

				local inv = ply:GetNetVar("Inventory")
				inv["Weapons"]["hg_sling"] = true
				ply:SetNetVar("Inventory",inv)

				zb.GiveRole(ply, "Bystander", Color(0,190,190))

				local wep = tblweps[ply:Team()][math.random(#tblweps[ply:Team()])]
				local gun = ply:Give(wep[1])
				if IsValid(gun) and gun.GetMaxClip1 then
					hg.AddAttachmentForce(ply,gun,wep[2])
					ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)
				else
					print("WTH???")
				end

				for _, item in ipairs(tblotheritems[ply:Team()]) do
					ply:Give(item)
				end

				local hands = ply:Give("weapon_hands_sh")

				ply:SetSuppressPickupNotices(false)
				ply.noSound = false
			end

			timer.Simple(0.5,function()
				ply.noSound = false
			end)

			ply:SetSuppressPickupNotices(false)
		end

		timer.Create("COMBINESpawn",91,1,function()
			if #combinePlayers > 0 then
				local ramPlayer = combinePlayers[math.random(#combinePlayers)]
				ramPlayer:Give("weapon_ram")
			end
		end)
	end)
end

function MODE:RoundThink()
end

function MODE:GetTeamSpawn()
	return {zb:GetRandomSpawn()}, {zb:GetRandomSpawn()}
end

function MODE:CanSpawn()
end

util.AddNetworkString("ci_roundend")
function MODE:EndRound()
	for k,ply in player.Iterator() do
		if timer.Exists("COMBINESpawn"..ply:EntIndex()) then
			timer.Remove("COMBINESpawn"..ply:EntIndex())
		end
	end
	if timer.Exists("COMBINESpawn") then
		timer.Remove("COMBINESpawn")
	end

	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())

	timer.Simple(2,function()
		net.Start("ci_roundend")
			net.WriteBool(winner)
		net.Broadcast()
	end)

	for k,ply in player.Iterator() do
		if ply:Team() == winner then
			ply:GiveExp(math.random(15,30))
			ply:GiveSkill(math.Rand(0.1,0.15))
		else
			ply:GiveSkill(-math.Rand(0.05,0.1))
		end
	end
end

function MODE:PlayerDeath(_,ply)
end