local MODE = MODE

hook.Add("WeaponsInv Loadout", "Manhunt_WeaponsInvLoadout", function(ply)
	if not IsValid(ply) then return end
	if CurrentRound() ~= MODE then return end
	if not MODE:IsHunter(ply) then return end
	if not hg or not hg.weaponInv or not hg.weaponInv.CreateLimit then return end

	hg.weaponInv.CreateLimit(ply, 1, 1)
	hg.weaponInv.CreateLimit(ply, 2, 2)
	hg.weaponInv.CreateLimit(ply, 3, 2)
	hg.weaponInv.CreateLimit(ply, 4, 1)
	hg.weaponInv.CreateLimit(ply, 5, 1)
	hg.weaponInv.CreateLimit(ply, 6, 2)

	return true
end)

function MODE:CanLaunch()
	return true
end

function MODE:OverrideBalance()
	return true
end

local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

function MODE:GetTeamSpawn()
	local hunters = zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_T"))
	local others = zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_CT"))

	if not hunters or not next(hunters) then
		hunters = {zb:GetRandomSpawn()}
	end

	if not others or not next(others) then
		others = {zb:GetRandomSpawn()}
	end

	return hunters, others
end

function MODE:IsHunter(ply)
	return IsValid(ply) and (ply.ManhuntRole == "leo" or ply.ManhuntRole == "daniel")
end

function MODE:IsOpponent(ply)
	return IsValid(ply) and (ply.ManhuntRole == "watchdog" or ply.ManhuntRole == "militia")
end

function MODE:GiveHunterLoadout(ply)
	if not IsValid(ply) then return end

	ply:StripWeapons()
	ply:RemoveAllAmmo()

	ply:SetSuppressPickupNotices(true)
	ply.noSound = true

	if ply.organism then
		ply.organism.allowholster = true
	end

	ply:Give("weapon_hands_sh")
	ply:Give("weapon_sogknife")

	local hatchetData = weapons.GetStored("weapon_hatchet")
	local oldHatchetInvCategory = hatchetData and hatchetData.weaponInvCategory
	if hatchetData then
		hatchetData.weaponInvCategory = false
	end

	local sledgeData = weapons.GetStored("weapon_hg_sledgehammer")
	local oldSledgeInvCategory = sledgeData and sledgeData.weaponInvCategory
	if sledgeData then
		sledgeData.weaponInvCategory = false
	end

	ply:Give("weapon_hatchet")
	ply:Give("weapon_hg_sledgehammer")

	if hatchetData then
		hatchetData.weaponInvCategory = oldHatchetInvCategory
	end
	if sledgeData then
		sledgeData.weaponInvCategory = oldSledgeInvCategory
	end

	ply:Give("weapon_hg_bottle")
	ply:Give("weapon_brick")
	ply:Give("weapon_hg_smokenade_tpik")
	ply:Give("weapon_hg_jam")
	ply:Give("weapon_ducttape")
	ply:AllowFlashlight(false)
	do
		local inv = ply:GetNetVar("Inventory") or ply.inventory or {}
		inv.Weapons = inv.Weapons or {}
		inv.Weapons["hg_flashlight"] = true
		ply.inventory = inv
		ply:SetNetVar("Inventory", inv)
		ply:SetNetVar("flashlight", false)
	end

	local makarov = ply:Give("weapon_makarov")
	if IsValid(makarov) then
		makarov:SetClip1(3)
		local ammoType = makarov:GetPrimaryAmmoType()
		if ammoType and ammoType >= 0 then
			local reserve = ply:GetAmmoCount(ammoType)
			if reserve > 0 then
				ply:RemoveAmmo(reserve, ammoType)
			end
		end
	end

	local maxhp = math.max(ply:GetMaxHealth(), 100)
	local hp = math.floor(maxhp * (MODE.DurabilityMul or 2.5))
	ply:SetMaxHealth(hp)
	ply:SetHealth(hp)

	if ply.organism and ply.organism.stamina then
		local stamina = ply.organism.stamina
		ply.ManhuntBaseStaminaRange = ply.ManhuntBaseStaminaRange or stamina.range or stamina.max

		local mul = MODE.StaminaMul or 3
		if ply.ManhuntBaseStaminaRange then
			stamina.range = ply.ManhuntBaseStaminaRange * mul
			stamina.max = stamina.range
			stamina[1] = stamina.max
		end
	end

	timer.Simple(0, function()
		if not IsValid(ply) then return end
		ply:SelectWeapon("weapon_hands_sh")
		ply.noSound = false
		ply:SetSuppressPickupNotices(false)
	end)
end

function MODE:GiveWatchdogLoadout(ply)
	if not IsValid(ply) then return end

	ply:SetPlayerClass("swat")

	ply:StripWeapons()
	ply:RemoveAllAmmo()

	ply:SetSuppressPickupNotices(true)
	ply.noSound = true

	if ply.organism then
		ply.organism.allowholster = true
	end

	ply:Give("weapon_hands_sh")
	local wep = table.Random({"weapon_bat", "weapon_hg_shovel", "weapon_hg_tonfa"})
	ply:Give(wep)
	ply:AllowFlashlight(false)
	do
		local inv = ply:GetNetVar("Inventory") or ply.inventory or {}
		inv.Weapons = inv.Weapons or {}
		inv.Weapons["hg_flashlight"] = true
		ply.inventory = inv
		ply:SetNetVar("Inventory", inv)
		ply:SetNetVar("flashlight", false)
	end

	timer.Simple(0, function()
		if not IsValid(ply) then return end
		ply:SelectWeapon("weapon_hands_sh")
		ply.noSound = false
		ply:SetSuppressPickupNotices(false)
	end)
end

function MODE:GiveMilitiaLoadout(ply)
	if not IsValid(ply) then return end

	ply:SetPlayerClass("nationalguard")

	ply:StripWeapons()
	ply:RemoveAllAmmo()

	ply:SetSuppressPickupNotices(true)
	ply.noSound = true

	if ply.organism then
		ply.organism.allowholster = true
	end

	ply:Give("weapon_hands_sh")
	ply:Give("weapon_hg_tonfa")
	ply:AllowFlashlight(false)
	do
		local inv = ply:GetNetVar("Inventory") or ply.inventory or {}
		inv.Weapons = inv.Weapons or {}
		inv.Weapons["hg_flashlight"] = true
		ply.inventory = inv
		ply:SetNetVar("Inventory", inv)
		ply:SetNetVar("flashlight", false)
	end

	local primary = table.Random({"weapon_ar15", "weapon_m590a1", "weapon_revolver357"})
	local gun = ply:Give(primary)
	if IsValid(gun) then
		ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)
	end

	timer.Simple(0, function()
		if not IsValid(ply) then return end
		ply:SelectWeapon("weapon_hands_sh")
		ply.noSound = false
		ply:SetSuppressPickupNotices(false)
	end)
end

function MODE:GetPlayerTraceToOther(ply, aim_vector, dist)
	local trace = hg.eyeTrace(ply, dist, nil, aim_vector)

	if not trace then
		return nil
	end

	local aim_ent = trace.Entity
	local other_ply = nil

	if IsValid(aim_ent) then
		if aim_ent:IsPlayer() then
			other_ply = aim_ent
		elseif aim_ent:IsRagdoll() and IsValid(aim_ent.ply) then
			other_ply = aim_ent.ply
		end
	end

	return aim_ent, other_ply, trace
end

function MODE:GetPlayerTraceToOtherVictim(ply, victim, dist)
	if not IsValid(victim) then return end

	local ragdoll = victim.FakeRagdoll or victim:GetNWEntity("RagdollDeath", victim.FakeRagdoll)
	if not IsValid(ragdoll) then
		ragdoll = victim
	end

	local bone_id = ragdoll:LookupBone("ValveBiped.Bip01_Spine2")
	if not bone_id then return end

	local bone_matrix = ragdoll:GetBoneMatrix(bone_id)
	if not bone_matrix then return end

	local pos = bone_matrix:GetTranslation()
	local ply_offset_normal = pos - ply:GetShootPos()
	local ply_aim_normal = ply:GetAimVector()

	ply_offset_normal:Normalize()
	ply_aim_normal:Normalize()

	local ang_diff = -(math.deg(math.acos(ply_aim_normal:DotProduct(-ply_offset_normal))) - 180)
	if ang_diff < 80 then
		local aim_ent, other_ply, trace = MODE:GetPlayerTraceToOther(ply, ply_offset_normal, dist)
		if IsValid(aim_ent) then
			return aim_ent, other_ply, trace
		end
	end

	return MODE:GetPlayerTraceToOther(ply, nil, dist)
end

function MODE:CanPlayerBreakOtherNeck(ply, aim_ent)
	if not IsValid(ply) or not IsValid(aim_ent) then return false end

	if aim_ent:IsRagdoll() then
		local bone_id = aim_ent:LookupBone("ValveBiped.Bip01_Head1")
		if not bone_id then return false end

		local bone_matrix = aim_ent:GetBoneMatrix(bone_id)
		if not bone_matrix then return false end

		local pos, ang = bone_matrix:GetTranslation(), bone_matrix:GetAngles()
		local other_normal = -ang:Right()
		local ply_normal = pos - ply:GetShootPos()
		local dist_z = math.abs(pos.z - ply:GetShootPos().z)

		if dist_z >= 50 then return false end

		ply_normal:Normalize()
		local ang_diff = -(math.deg(math.acos(ply_normal:DotProduct(other_normal))) - 180)
		return ang_diff < 100
	elseif aim_ent:IsPlayer() then
		local other_angle = aim_ent:EyeAngles()[2]
		local ply_angle = (aim_ent:GetPos() - ply:GetPos()):Angle()[2]
		local ang_diff = math.abs(math.AngleDifference(other_angle, ply_angle))
		return ang_diff < 100
	end

	return false
end

function MODE:BreakOtherNeck(ply, other_ply, aim_ent)
	if not IsValid(ply) or not IsValid(other_ply) or not IsValid(aim_ent) then return end
	if not other_ply:Alive() then return end

	other_ply:Kill()
	other_ply:ViewPunch(Angle(0, 0, -10))

	if aim_ent.organism then
		aim_ent.organism.spine3 = 1
	end

	aim_ent:EmitSound("neck_snap_01.wav", 60, 100, 1, CHAN_AUTO)

	timer.Simple(0.1, function()
		local ent = other_ply:GetNWEntity("RagdollDeath")
		if not IsValid(ent) then return end

		local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
		local spineBone = ent:LookupBone("ValveBiped.Bip01_Spine2")
		if not headBone or not spineBone then return end

		ent:RemoveInternalConstraint(ent:TranslateBoneToPhysBone(headBone))

		local spine = ent:TranslateBoneToPhysBone(spineBone)
		local head = ent:TranslateBoneToPhysBone(headBone)

		local pspine = ent:GetPhysicsObjectNum(spine)
		local phead = ent:GetPhysicsObjectNum(head)
		if not IsValid(pspine) or not IsValid(phead) then return end

		local lpos = WorldToLocal(
			phead:GetPos() + phead:GetAngles():Forward() * -2 + phead:GetAngles():Up() * -1.5,
			angle_zero,
			pspine:GetPos(),
			pspine:GetAngles()
		)

		phead:SetPos(pspine:GetPos() + pspine:GetAngles():Forward() * 12.9 + pspine:GetAngles():Right() * -1)
		constraint.AdvBallsocket(ent, ent, spine, head, lpos, nil, 0, 0, -55, -90, -50, 55, 35, 50, 0, 0, 0, 0, 0)
	end)
end

function MODE:StartBreakingOtherNeck(ply, other_ply)
	ply.Ability_NeckBreak = {
		Victim = other_ply,
		Progress = 0,
	}
	other_ply.BeingVictimOfNeckBreak = true

	other_ply:ViewPunch(Angle(0, -10, -10))

	net.Start("HMCD_BeingVictimOfNeckBreak")
		net.WriteBool(true)
	net.Send(other_ply)

	net.Start("HMCD_BreakingOtherNeck")
		net.WriteBool(true)
		net.WriteEntity(ply)
		net.WriteEntity(other_ply)
	net.SendPVS(ply:GetShootPos())
end

function MODE:StopBreakingOtherNeck(ply)
	if ply.Ability_NeckBreak and IsValid(ply.Ability_NeckBreak.Victim) then
		ply.Ability_NeckBreak.Victim.BeingVictimOfNeckBreak = false

		net.Start("HMCD_BeingVictimOfNeckBreak")
			net.WriteBool(false)
		net.Send(ply.Ability_NeckBreak.Victim)

		net.Start("HMCD_BreakingOtherNeck")
			net.WriteBool(false)
			net.WriteEntity(ply)
		net.SendPVS(ply:GetShootPos())
	end

	ply.Ability_NeckBreak = nil
end

function MODE:ContinueBreakingOtherNeck(ply)
	local break_data = ply.Ability_NeckBreak
	if not break_data then return end

	local victim = break_data.Victim
	local aim_ent, other_ply = MODE:GetPlayerTraceToOtherVictim(ply, victim, 85)
	if not IsValid(aim_ent) or (not aim_ent:IsPlayer() and not aim_ent:IsRagdoll()) then
		return MODE:StopBreakingOtherNeck(ply)
	end

	if not (IsValid(victim) and victim:Alive() and MODE:CanPlayerBreakOtherNeck(ply, aim_ent) and other_ply == victim) then
		return MODE:StopBreakingOtherNeck(ply)
	end

	break_data.Progress = break_data.Progress + FrameTime() * 300
	if break_data.Progress >= 100 then
		MODE:BreakOtherNeck(ply, break_data.Victim, aim_ent)
		MODE:StopBreakingOtherNeck(ply)
	end
end

function MODE:PlayerPostThink(ply)
	if CurrentRound() ~= MODE then return end
	if not IsValid(ply) or not ply:Alive() then return end
	if not MODE:IsHunter(ply) then return end
	if ply.organism and ply.organism.otrub then return end

	if ply:KeyDown(IN_WALK) then
		if ply:KeyPressed(IN_USE) then
			local aim_ent, other_ply = MODE:GetPlayerTraceToOther(ply, nil, 85)
			if IsValid(aim_ent) and IsValid(other_ply) and MODE:IsOpponent(other_ply) and MODE:CanPlayerBreakOtherNeck(ply, aim_ent) then
				MODE:StartBreakingOtherNeck(ply, other_ply)
			end
		elseif ply:KeyDown(IN_USE) and ply.Ability_NeckBreak then
			MODE:ContinueBreakingOtherNeck(ply)
		end

		if ply:KeyReleased(IN_USE) then
			MODE:StopBreakingOtherNeck(ply)
		end
	else
		if ply.Ability_NeckBreak then
			MODE:StopBreakingOtherNeck(ply)
		end
	end
end

function MODE:Intermission()
	game.CleanUpMap()

	self.MilitiaArrived = false
	self.WatchdogsReleased = false
	self.WatchdogsReleaseAt = nil
	self.MilitiaArriveAt = nil
	self.ManhuntForceEndAt = nil

	timer.Remove("ZB_Manhunt_ForceEnd")

	for _, ply in player.Iterator() do
		ply.ManhuntRole = nil
		ply.ManhuntDeadBeforeMilitia = nil
		ply:SetNWBool("Manhunt_Blind", false)
		ply:SetNWString("PlayerRole", "")
	end

	local players = {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then
			continue
		end
		players[#players + 1] = ply
	end

	if #players <= 0 then return end

	shuffle(players)

	local leo = players[1]
	local daniel = (#players > 27) and players[2] or nil

	self.HasDaniel = IsValid(daniel)
	SetGlobalBool("Manhunt_HasDaniel", self.HasDaniel)

	for _, ply in ipairs(players) do
		if ply == leo then
			ply.ManhuntRole = "leo"
			ply:SetNWString("PlayerRole", "Leo Kasper")
			ply:SetupTeam(self.HuntersTeam)
			ply:Freeze(false)
		elseif self.HasDaniel and ply == daniel then
			ply.ManhuntRole = "daniel"
			ply:SetNWString("PlayerRole", "Daniel Lamb")
			ply:SetupTeam(self.HuntersTeam)
			ply:Freeze(false)
		else
			ply.ManhuntRole = "watchdog"
			ply:SetNWString("PlayerRole", "Watchdogs")
			ply:SetNWBool("Manhunt_Blind", true)
			ply:SetTeam(self.OpponentsTeam)
			if ply:Alive() then
				ply:KillSilent()
			end
		end
	end
end

function MODE:GiveEquipment()
	timer.Simple(0.1, function()
		if CurrentRound() ~= MODE then return end

		for _, ply in player.Iterator() do
			if MODE:IsHunter(ply) then
				MODE:GiveHunterLoadout(ply)
				ply:SetNWBool("Manhunt_Blind", false)
				ply:Freeze(false)
			elseif ply.ManhuntRole == "watchdog" then
				ply:SetNWBool("Manhunt_Blind", true)
				if ply:Alive() then
					ply:KillSilent()
				end

				timer.Remove("Manhunt_WatchdogSpawn" .. ply:EntIndex())
				timer.Create("Manhunt_WatchdogSpawn" .. ply:EntIndex(), (self.HideTime or 15), 1, function()
					if not IsValid(ply) then return end
					if CurrentRound() ~= MODE then return end
					if zb.ROUND_STATE ~= 1 then return end
					if ply.ManhuntRole ~= "watchdog" then return end

					ply:SetNWBool("Manhunt_Blind", false)
					ply:Spawn()
					timer.Simple(0, function()
						if not IsValid(ply) then return end
						if CurrentRound() ~= MODE then return end
						if ply.ManhuntRole ~= "watchdog" then return end
						ply:SetupTeam(self.OpponentsTeam)
						MODE:GiveWatchdogLoadout(ply)
					end)
				end)
			end
		end
	end)
end

function MODE:RoundStart()
	self.MilitiaArriveAt = CurTime() + (self.MilitiaTime or 150)
	self.MilitiaArrived = false
	self.WatchdogsReleased = false
	self.ManhuntForceEndAt = nil

	timer.Remove("ZB_Manhunt_WatchdogsReleased")
	timer.Create("ZB_Manhunt_WatchdogsReleased", (self.HideTime or 15), 1, function()
		if CurrentRound() ~= MODE then return end
		if zb.ROUND_STATE ~= 1 then return end
		self.WatchdogsReleased = true
	end)

	timer.Create("ZB_Manhunt_MilitiaArrive", 0.25, 0, function()
		if CurrentRound() ~= MODE then return timer.Remove("ZB_Manhunt_MilitiaArrive") end
		if zb.ROUND_STATE ~= 1 then return end
		if self.MilitiaArrived then return timer.Remove("ZB_Manhunt_MilitiaArrive") end
		if CurTime() < (self.MilitiaArriveAt or 0) then return end

		self.MilitiaArrived = true
		self.ManhuntForceEndAt = CurTime() + 90

		timer.Remove("ZB_Manhunt_ForceEnd")
		timer.Create("ZB_Manhunt_ForceEnd", 90, 1, function()
			if CurrentRound() ~= MODE then return end
			if zb.ROUND_STATE ~= 1 then return end
			zb:EndRound()
		end)

		for _, ply in player.Iterator() do
			if not ply.ManhuntDeadBeforeMilitia then continue end
			ply.ManhuntDeadBeforeMilitia = nil
			ply.ManhuntRole = "militia"
			ply:SetNWString("PlayerRole", "Project Militia")

			if ply:Team() == TEAM_SPECTATOR then
				ply:SetTeam(self.OpponentsTeam)
			end

			ply:SetNWBool("Manhunt_Blind", false)
			ply:Freeze(false)
			ply:Spawn()
			timer.Simple(0, function()
				if not IsValid(ply) then return end
				if CurrentRound() ~= MODE then return end
				ply:SetupTeam(self.OpponentsTeam)
				MODE:GiveMilitiaLoadout(ply)
			end)
		end
	end)
end

function MODE:PlayerDeath(victim, inflictor, attacker)
	if CurrentRound() ~= MODE then return end
	if zb.ROUND_STATE ~= 1 then return end
	if not IsValid(victim) or not victim:IsPlayer() then return end
	if victim.ManhuntRole ~= "watchdog" then return end
	if self.MilitiaArrived then return end
	if not self.WatchdogsReleased then return end

	victim.ManhuntDeadBeforeMilitia = true
end

function MODE:EntityTakeDamage(ent, dmgInfo)
	if CurrentRound() ~= MODE then return end
	if zb.ROUND_STATE ~= 1 then return end

	if IsValid(ent) and ent:IsPlayer() and MODE:IsHunter(ent) then
		dmgInfo:ScaleDamage(1 / (MODE.DurabilityMul or 2.5))
	end

	local attacker = dmgInfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() and MODE:IsHunter(attacker) then
		dmgInfo:ScaleDamage(MODE.StrengthMul or 2.5)
	end
end

function MODE:CheckAlivePlayers()
	local hunters = {}
	local opponents = {}

	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end

		if MODE:IsHunter(ply) then
			hunters[#hunters + 1] = ply
		elseif MODE:IsOpponent(ply) or ply.ManhuntRole == "watchdog" then
			opponents[#opponents + 1] = ply
		end
	end

	return {hunters, opponents}
end

function MODE:ShouldRoundEnd()
	if zb.ROUND_START and CurTime() < (zb.ROUND_START + (self.HideTime or 15) + 1) then
		return false
	end

	if self.ManhuntForceEndAt and CurTime() >= self.ManhuntForceEndAt then
		return true
	end
	local aliveTeams = self:CheckAlivePlayers()
	return zb:CheckWinner(aliveTeams)
end

function MODE:EndRound()
	timer.Remove("ZB_Manhunt_WatchdogsReleased")
	timer.Remove("ZB_Manhunt_ForceEnd")
	timer.Remove("ZB_Manhunt_MilitiaArrive")

	for _, ply in player.Iterator() do
		timer.Remove("Manhunt_WatchdogSpawn" .. ply:EntIndex())
		ply.ManhuntBaseStaminaRange = nil
		ply:SetNWBool("Manhunt_Blind", false)
		ply:Freeze(false)
	end
end
