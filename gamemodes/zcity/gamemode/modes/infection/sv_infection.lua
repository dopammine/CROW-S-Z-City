local MODE = MODE

function MODE:CanLaunch()
	return false
end

function MODE:OverrideBalance()
	return true
end

local function infectionShuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_T")), zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_CT"))
end

function MODE:Intermission()
	game.CleanUpMap()

	self.wave = 0
	self.phase = "idle"
	self.phaseEnd = nil
	self.roundOver = nil
	self.BuyUntil = nil
	self.buymenu = false

	local candidates = {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then
			ply.InfectionRole = nil
			continue
		end
		candidates[#candidates + 1] = ply
	end

	infectionShuffle(candidates)

	local total = #candidates
	local zombieCount = 0
	if total >= 2 then
		zombieCount = math.max(1, math.floor(total / 4))
	end

	for i, ply in ipairs(candidates) do
		local isZombie = i <= zombieCount
		ply.InfectionRole = isZombie and "zombie" or "human"
		ply:SetPlayerClass()
		ply:SetupTeam(isZombie and self.ZombiesTeam or self.HumansTeam)
		ply:SetNWInt("TDM_Money", 0)
	end
end

function MODE:GiveEquipment()
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		ply:StripWeapons()
		ply:RemoveAllAmmo()

		if ply.InfectionRole == "zombie" then
			ply:SetPlayerClass("headcrabzombie")
			ply:Give("weapon_hands_sh")
		else
			ply:SetPlayerClass("default")
			local glock = ply:Give("weapon_glock17")
			ply:Give("weapon_melee")
			ply:Give("weapon_hands_sh")
			if IsValid(glock) then
				ply:GiveAmmo(glock:GetMaxClip1() * 3, glock:GetPrimaryAmmoType(), true)
			end
		end
	end
end

function MODE:RoundStart()
	self:StartPrep()
end

function MODE:ShouldRoundEnd()
	if self.roundOver then return true end
end

function MODE:EndRound()
	self.roundOver = true
	timer.Remove("HG_Infection_Prep")
	timer.Remove("HG_Infection_Wave")

	if self.winText then
		PrintMessage(HUD_PRINTTALK, self.winText)
	end
end

function MODE:StartPrep()
	timer.Remove("HG_Infection_Prep")
	timer.Remove("HG_Infection_Wave")

	self.phase = "prep"
	self.BuyUntil = CurTime() + self.PrepDuration
	self.phaseEnd = self.BuyUntil
	self.buymenu = true

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		if ply.InfectionRole == "zombie" then
			if ply:Alive() then ply:KillSilent() end
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SetTeam(TEAM_SPECTATOR)
		else
			if not ply:Alive() then ply:Spawn() end
			ply:SetTeam(self.HumansTeam)
			ply:SetNWInt("TDM_Money", ply:GetNWInt("TDM_Money", 0) + self.PrepMoney)
			self:GiveHumanLoadout(ply)
		end
	end

	timer.Create("HG_Infection_Prep", self.PrepDuration, 1, function()
		if CurrentRound() ~= MODE then return end
		MODE:StartWave()
	end)
end

function MODE:StartWave()
	timer.Remove("HG_Infection_Prep")
	timer.Remove("HG_Infection_Wave")

	self.wave = (self.wave or 0) + 1
	self.phase = "wave"
	self.buymenu = false
	self.BuyUntil = nil

	self.phaseEnd = CurTime() + self.WaveDuration

	for _, ply in player.Iterator() do
		if ply.InfectionRole == "zombie" then
			ply:UnSpectate()
			ply:SetupTeam(self.ZombiesTeam)
			if not ply:Alive() then ply:Spawn() end
			ply:SetPlayerClass("headcrabzombie")
			ply:StripWeapons()
			ply:RemoveAllAmmo()
			ply:Give("weapon_hands_sh")
		elseif ply.InfectionRole == "human" then
			ply:SetTeam(self.HumansTeam)
			if not ply:Alive() then ply:Spawn() end
			self:GiveHumanLoadout(ply)
		end
	end

	timer.Create("HG_Infection_Wave", self.WaveDuration, 1, function()
		if CurrentRound() ~= MODE then return end
		MODE:WaveEnd()
	end)
end

function MODE:WaveEnd()
	if self.wave >= self.WavesTotal then
		local humansAlive = 0
		for _, ply in player.Iterator() do
			if ply.InfectionRole == "human" and ply:Team() ~= TEAM_SPECTATOR and ply:Alive() then
				humansAlive = humansAlive + 1
			end
		end

		self.winner = humansAlive > 0 and "humans" or "zombies"
		self.winText = humansAlive > 0 and "Humans Win" or "Zombies Win"
		self.roundOver = true
		return
	end

	self:StartPrep()
end

function MODE:RoundThink()
	if self.roundOver then return end

	local humans = 0
	for _, ply in player.Iterator() do
		if ply.InfectionRole == "human" and ply:Team() ~= TEAM_SPECTATOR and ply:Alive() then
			humans = humans + 1
		end
	end

	if humans <= 0 then
		self.winner = "zombies"
		self.winText = "Zombies Win"
		self.roundOver = true
	end
end

function MODE:GiveHumanLoadout(ply)
	if not IsValid(ply) then return end
	if ply.InfectionRole ~= "human" then return end

	local glock = ply:GetWeapon("weapon_glock17")
	local gaveGlock = false
	if not IsValid(glock) then
		glock = ply:Give("weapon_glock17")
		gaveGlock = true
	end

	if not ply:HasWeapon("weapon_melee") then
		ply:Give("weapon_melee")
	end
	if not ply:HasWeapon("weapon_hands_sh") then
		ply:Give("weapon_hands_sh")
	end

	if gaveGlock and IsValid(glock) then
		ply:GiveAmmo(glock:GetMaxClip1() * 3, glock:GetPrimaryAmmoType(), true)
	end
end

local function toPly(ent)
	if not IsValid(ent) then return end
	if hg and hg.RagdollOwner then
		return hg.RagdollOwner(ent) or ent
	end
	return ent
end

function MODE:PlayerDeath(victim, inflictor, attacker)
	if CurrentRound() ~= MODE then return end
	if self.phase ~= "wave" then return end
	if not IsValid(victim) or not victim:IsPlayer() then return end
	if victim.InfectionRole ~= "human" then return end

	victim.InfectionRole = "zombie"
	victim.InfectionPendingZombie = true
	victim:SetNWInt("TDM_Money", 0)

	if hg and hg.organism and hg.organism.module and hg.organism.module.virus and hg.organism.module.virus.InfectPlayer then
		hg.organism.module.virus.InfectPlayer(victim)
	end
end

function MODE:EntityTakeDamage(ent, dmgInfo)
	if CurrentRound() ~= MODE then return end
	if not IsValid(ent) or not ent:IsPlayer() then return end
	if ent.InfectionRole ~= "zombie" then return end

	if dmgInfo:IsDamageType(DMG_BULLET) or dmgInfo:IsDamageType(DMG_BUCKSHOT) then
		dmgInfo:ScaleDamage(0.55)
	elseif dmgInfo:IsDamageType(DMG_SLASH) then
		dmgInfo:ScaleDamage(0.7)
	end
end

function MODE:ShowSpare1(ply)
	if CurrentRound() ~= MODE then return end
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
	if ply.InfectionRole ~= "human" then return end
	if not self.buymenu or not self.BuyUntil or CurTime() > self.BuyUntil then return end

	net.Start("tdm_open_buymenu")
	net.WriteFloat(self.BuyUntil)
	net.Send(ply)
end

function MODE:PlayerUse(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if ply.InfectionRole == "zombie" then return false end
end

function MODE:PlayerCanPickupWeapon(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if ply.InfectionRole == "zombie" then return false end
end

function MODE:AllowPlayerPickup(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if ply.InfectionRole == "zombie" then return false end
end

function MODE:ZB_InventoryChecked(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if ply.InfectionRole == "zombie" then return false end
end

function MODE:ZB_InventoryOpened(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if ply.InfectionRole == "zombie" then return false end
end
