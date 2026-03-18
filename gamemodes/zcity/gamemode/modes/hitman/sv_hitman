local MODE = MODE

MODE.LootTable = {
	{65, {
		{15,"weapon_smallconsumable"},
		{12,"weapon_bigconsumable"},
		{8,"weapon_tourniquet"},
		{8,"weapon_bandage_sh"},
		{7,"weapon_ducttape"},
		{6,"weapon_painkillers"},
		{5,"weapon_bloodbag"},
		{4,"hg_flashlight"},
		{1,"weapon_matches"},
	}},
	{35, {
		{1,"weapon_hammer"},
		{1,"weapon_brick"},
		{1,"weapon_pocketknife"},
		{0.32,"weapon_bat"},
		{0.3,"weapon_leadpipe"},
		{0.15,"weapon_hg_extinguisher"},
		{0.14,"weapon_hg_crowbar"},
		{0.12,"weapon_hatchet"},
		{0.10,"weapon_hg_axe"},
		{0.09,"weapon_hg_sledgehammer"},
		{0.07,"weapon_hg_machete"},
	}},
}

util.AddNetworkString("HITMAN_RoundStart")
util.AddNetworkString("HITMAN_TargetsUpdate")

MODE.HitmanOutcomeAnnounced = false

function MODE:GetTargetsCountForPlayers(player_count)
	if player_count >= 20 then return 8 end
	if player_count >= 16 then return 6 end
	if player_count >= 12 then return 4 end
	if player_count >= 6 then return 2 end
	if player_count >= 4 then return 1 end
	return 0
end

function MODE:GetHitman()
	for _, ply in player.Iterator() do
		if ply.isTraitor and ply.MainTraitor and ply:Team() ~= TEAM_SPECTATOR then
			return ply
		end
	end

	for _, ply in player.Iterator() do
		if ply.isTraitor and ply:Team() ~= TEAM_SPECTATOR then
			return ply
		end
	end
end

function MODE:SendTargets()
	local hitman = self:GetHitman()
	if not IsValid(hitman) then return end

	local targets = {}
	local target_hints = {}
	
	for ply in pairs(self.TargetPlayers or {}) do
		if IsValid(ply) then
			targets[#targets + 1] = ply
			
			-- Generate a random hint for each target
			local hint_type = math.random(1, 2) -- 1: Name initial, 2: Clothing/Appearance (simplified for now as actual skin/hat might be complex to get reliably)
			local hint_text = ""
			
			if hint_type == 1 then
				local name = ply:Nick()
				hint_text = "Target's name starts with: " .. string.sub(name, 1, 1)
			else
				-- If you have a specific system for hats/skin color, you'd check it here.
				-- For example, if hg.GetAppearance exists:
				local app = ply:GetNetVar("Appearance")
				if app and app.playerColor then
					local c = app.playerColor
					hint_text = string.format("Target has shirt color roughly: RGB(%d,%d,%d)", c.x*255, c.y*255, c.z*255)
				else
					local pmodel = string.lower(ply:GetModel() or "")
					if string.find(pmodel, "female") then
						hint_text = "Target is Female."
					elseif string.find(pmodel, "male") then
						hint_text = "Target is Male."
					else
						hint_text = "Target's name starts with: " .. string.sub(ply:Nick(), 1, 1) -- Fallback
					end
				end
			end
			
			target_hints[#target_hints + 1] = hint_text
		end
	end

	net.Start("HITMAN_TargetsUpdate")
		net.WriteUInt(#targets, 6)
		for i, ply in ipairs(targets) do
			net.WriteEntity(ply)
			net.WriteString(target_hints[i] or "Unknown Target")
		end
		net.WriteUInt(self.TargetsRemaining or 0, 6)
		net.WriteUInt(self.TargetsInitial or 0, 6)
	net.Send(hitman)
end

function MODE:ReplaceTarget()
	local hitman = self:GetHitman()
	if not IsValid(hitman) then return end

	local candidates = {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if ply == hitman then continue end
		if not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end
		if self.TargetPlayers and self.TargetPlayers[ply] then continue end
		candidates[#candidates + 1] = ply
	end

	if #candidates < 1 then return end

	local new_target = table.Random(candidates)
	self.TargetPlayers[new_target] = true
end

function MODE:AssignTargets()
	self.TargetPlayers = {}
	self.TargetsRemaining = 0
	self.TargetsInitial = 0
	self.TargetsCompleted = false

	local hitman = self:GetHitman()
	if not IsValid(hitman) then return end

	local player_count = 0
	local candidates = {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		player_count = player_count + 1

		if ply == hitman then continue end
		if not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end
		candidates[#candidates + 1] = ply
	end

	local target_count = math.min(self:GetTargetsCountForPlayers(player_count), #candidates)
	self.TargetsRemaining = target_count
	self.TargetsInitial = target_count

	for i = 1, target_count do
		local pick = table.remove(candidates, math.random(#candidates))
		self.TargetPlayers[pick] = true
	end

	self:SendTargets()
end

local function resolveKiller(inflictor, attacker)
	if IsValid(attacker) then
		if attacker:IsPlayer() then return attacker end
		if attacker:IsRagdoll() and hg and hg.RagdollOwner then
			local owner = hg.RagdollOwner(attacker)
			if IsValid(owner) and owner:IsPlayer() then return owner end
		end
		if attacker.GetOwner then
			local owner = attacker:GetOwner()
			if IsValid(owner) and owner:IsPlayer() then return owner end
		end
		if attacker.GetCreator then
			local creator = attacker:GetCreator()
			if IsValid(creator) and creator:IsPlayer() then return creator end
		end
		if attacker.GetNWEntity then
			local nw = attacker:GetNWEntity("Owner")
			if IsValid(nw) and nw:IsPlayer() then return nw end
			local th = attacker:GetNWEntity("Thrower")
			if IsValid(th) and th:IsPlayer() then return th end
			local at = attacker:GetNWEntity("Attacker")
			if IsValid(at) and at:IsPlayer() then return at end
		end
	end
	if IsValid(inflictor) then
		if inflictor:IsPlayer() then return inflictor end
		if inflictor.GetOwner then
			local owner = inflictor:GetOwner()
			if IsValid(owner) and owner:IsPlayer() then return owner end
		end
		if inflictor.GetCreator then
			local creator = inflictor:GetCreator()
			if IsValid(creator) and creator:IsPlayer() then return creator end
		end
		if inflictor.GetNWEntity then
			local nw = inflictor:GetNWEntity("Owner")
			if IsValid(nw) and nw:IsPlayer() then return nw end
			local th = inflictor:GetNWEntity("Thrower")
			if IsValid(th) and th:IsPlayer() then return th end
			local at = inflictor:GetNWEntity("Attacker")
			if IsValid(at) and at:IsPlayer() then return at end
		end
	end
end

local function isHitmanPlayer(ply)
	return IsValid(ply) and ply:IsPlayer() and ply.isTraitor == true
end

hook.Add("EntityTakeDamage", "Hitman_LastAttackerTag", function(ent, dmginfo)
	local mode = CurrentRound()
	if not mode or mode.name ~= "hitman" then return end

	local victim = ent
	if ent:IsRagdoll() and hg and hg.RagdollOwner then
		local owner = hg.RagdollOwner(ent)
		if IsValid(owner) then victim = owner end
	end
	if not (IsValid(victim) and victim:IsPlayer()) then return end
	if not (mode.TargetPlayers and mode.TargetPlayers[victim]) then return end

	local atk = resolveKiller(dmginfo:GetInflictor(), dmginfo:GetAttacker())
	if isHitmanPlayer(atk) then
		victim.HitmanLastAttacker = atk
		victim.HitmanLastAttackTime = CurTime()
	end
end)

hook.Add("HomigradDamage", "Hitman_LastAttackerTag_HG", function(ply, dmginfo)
	local mode = CurrentRound()
	if not mode or mode.name ~= "hitman" then return end
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not (mode.TargetPlayers and mode.TargetPlayers[ply]) then return end

	local atk = resolveKiller(dmginfo:GetInflictor(), dmginfo:GetAttacker())
	if isHitmanPlayer(atk) then
		ply.HitmanLastAttacker = atk
		ply.HitmanLastAttackTime = CurTime()
	end
end)

function MODE:CheckAlivePlayers()
	local hitman = self:GetHitman()
	if self.TargetsCompleted and IsValid(hitman) and hitman:Alive() then
		return {
			[0] = {},
			[1] = {hitman}
		}
	end

	local AlivePlyTbl = {
		[0] = {},
		[1] = {}
	}

	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		if (not ply.isTraitor) and ply.organism and ply.organism.incapacitated then continue end

		if ply.isTraitor and not ply:GetNetVar("handcuffed", false) then
			AlivePlyTbl[1][#AlivePlyTbl[1] + 1] = ply
		else
			AlivePlyTbl[0][#AlivePlyTbl[0] + 1] = ply
		end
	end

	return AlivePlyTbl
end

function MODE:ShouldRoundEnd()
	if self.TargetsCompleted then
		return true
	end

	local endround = zb:CheckWinner(self:CheckAlivePlayers())
	return endround
end

function MODE:Intermission()
	game.CleanUpMap()

	self.TargetPlayers = {}
	self.TargetsRemaining = 0
	self.TargetsInitial = 0
	self.TargetsCompleted = false
	self.HitmanOutcomeAnnounced = false

	local candidates = {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		ply:KillSilent()
		ply:SetupTeam(0)

		ply.isTraitor = false
		ply.isGunner = false
		ply.MainTraitor = false

		candidates[#candidates + 1] = ply
	end

	if #candidates < 2 then return end

	local hitman
	
	if not hitman then
		for _, ply in RandomPairs(candidates) do
			if math.random(100) <= (ply.Karma or 100) then
				hitman = ply
				break
			end
		end
	end
	
	hitman = hitman or table.Random(candidates)

	hitman.isTraitor = true
	hitman.MainTraitor = true

	local gunnerCandidates = {}
	for _, ply in ipairs(candidates) do
		if ply ~= hitman then
			gunnerCandidates[#gunnerCandidates + 1] = ply
		end
	end

	if #gunnerCandidates > 0 then
		local gunner = table.Random(gunnerCandidates)
		gunner.isGunner = true
	end
end

local function giveHitmanLoot(ply)
	local p22 = ply:Give("weapon_p22")
	hg.AddAttachmentForce(ply, p22, "supressor4")
	ply:Give("weapon_sogknife")
	ply:Give("weapon_hg_type59_tpik")
	ply:Give("weapon_walkie_talkie")
	ply:Give("weapon_adrenaline")
	ply:Give("weapon_hg_smokenade_tpik")
	ply:Give("weapon_traitor_ied")
	ply:Give("weapon_traitor_poison2")
	ply:Give("weapon_traitor_poison3")
	ply:Give("weapon_traitor_poison_consumable")
	ply.organism.recoilmul = 1
	ply.organism.stamina.range = 220

	local inv = ply:GetNetVar("Inventory") or {}
	inv["Weapons"] = inv["Weapons"] or {}
	inv["Weapons"]["hg_flashlight"] = true
	ply:SetNetVar("Inventory", inv)
end

local function giveGunnerLoot(ply)
	local gun = ply:Give((math.random(1, 2) > 1 and "weapon_remington870") or "weapon_kar98")
	ply.organism.recoilmul = 1.0
	if gun:GetClass() == "weapon_kar98" then
		hg.AddAttachmentForce(ply, gun, "optic12")
	end
	local inv = ply:GetNetVar("Inventory") or {}
	inv["Weapons"] = inv["Weapons"] or {}
	inv["Weapons"]["hg_sling"] = true
	ply:SetNetVar("Inventory", inv)

	ply:SetNetVar("CurPluv", "pluvboss")
end

function MODE:RoundStart()
	self.HitmanOutcomeAnnounced = false
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		ApplyAppearance(ply, nil, nil, nil, true)
		ply:Spawn()
		ply:GetRandomSpawn()

		if not ply:Alive() then continue end

		if ply.isTraitor then
			local farPos = Vector(0, 0, -30000)
			local targetSpawn = zb:GetRandomSpawn(ply)
			if targetSpawn then
				ply:SetPos(farPos)
			end
			giveHitmanLoot(ply)
			if targetSpawn then
				timer.Simple(0, function()
					if IsValid(ply) and ply:Alive() then
						ply:SetPos(targetSpawn)
					end
				end)
			end
		elseif ply.isGunner then
			giveGunnerLoot(ply)
		end

		local hands = ply:Give("weapon_hands_sh")
		ply:SetActiveWeapon(hands)

		net.Start("HITMAN_RoundStart")
			net.WriteBool(ply.isTraitor == true)
			net.WriteBool(ply.isGunner == true)
		net.Send(ply)
	end

	timer.Simple(0, function()
		if zb.ROUND_STATE ~= 1 then return end
		if not MODE or CurrentRound() ~= MODE then return end
		MODE:AssignTargets()
	end)
end

function MODE:EndRound()
	self.TargetPlayers = {}
	self.TargetsRemaining = 0
	self.TargetsInitial = 0
	-- Announce outcome if not already announced
	if not self.HitmanOutcomeAnnounced then
		if self.TargetsCompleted then
			PrintMessage(HUD_PRINTTALK, "The Hitman killed all their targets!")
		else
			PrintMessage(HUD_PRINTTALK, "The hitman has failed!")
		end
		self.HitmanOutcomeAnnounced = true
	end
	self.TargetsCompleted = false

	for _, ply in player.Iterator() do
		ply.isTraitor = false
		ply.isGunner = false
		ply.MainTraitor = false
	end
end

hook.Add("PlayerDeath", "Hitman_Targets", function(victim, inflictor, attacker)
	local mode = CurrentRound()
	if not mode or mode.name ~= "hitman" then return end
	-- If the hitman dies: immediate failure announcement
	local hitman = mode:GetHitman()
	if IsValid(hitman) and victim == hitman and not mode.HitmanOutcomeAnnounced then
		PrintMessage(HUD_PRINTTALK, "The hitman has failed!")
		mode.HitmanOutcomeAnnounced = true
		return
	end

	if not mode.TargetPlayers or not mode.TargetPlayers[victim] then return end

	local killer = resolveKiller(inflictor, attacker)
	if not isHitmanPlayer(killer) then
		if victim.HitmanLastAttacker and isHitmanPlayer(victim.HitmanLastAttacker) and (victim.HitmanLastAttackTime or 0) + 30 >= CurTime() then
			killer = victim.HitmanLastAttacker
		end
	end

	if IsValid(hitman) and IsValid(killer) and killer == hitman then
		mode.TargetsRemaining = math.max((mode.TargetsRemaining or 1) - 1, 0)
		mode.TargetPlayers[victim] = nil
	else
		mode:ReplaceTarget()
		mode.TargetPlayers[victim] = nil
	end

	timer.Simple(0, function()
		if CurrentRound() ~= mode then return end
		mode:SendTargets()
	end)

	if (mode.TargetsInitial or 0) > 0 and (mode.TargetsRemaining or 0) <= 0 and IsValid(hitman) and hitman:Alive() then
		mode.TargetsCompleted = true
		if not mode.HitmanOutcomeAnnounced then
			PrintMessage(HUD_PRINTTALK, "The Hitman killed all their targets!")
			mode.HitmanOutcomeAnnounced = true
		end
		zb:EndRound()
	end
end)

hook.Add("Player_Death", "Hitman_Targets_Compat", function(victim)
	local mode = CurrentRound()
	if not mode or mode.name ~= "hitman" then return end
	-- Fallback: ensure removed targets propagate to clients
	if mode.TargetPlayers and mode.TargetPlayers[victim] then
		mode.TargetPlayers[victim] = nil
		timer.Simple(0, function()
			if CurrentRound() ~= mode then return end
			mode:SendTargets()
		end)
	end
end)
