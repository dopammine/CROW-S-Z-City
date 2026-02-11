local MODE = MODE

MODE.name = "hideseek"
MODE.PrintName = "Hide and Seek"
MODE.HidingTime = MODE.HidingTime or 40
MODE.ROUND_TIME = MODE.ROUND_TIME or 600
MODE.randomSpawns = true
MODE.OverrideSpawn = true
MODE.LootSpawn = false
MODE.ForBigMaps = false
MODE.Chance = 0.03

local seekerRoleColor = Color(220, 60, 60)
local hiderRoleColor = Color(60, 140, 230)

util.AddNetworkString("hideseek_start")
util.AddNetworkString("hideseek_roundend")

local function Shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

function MODE:CanLaunch()
	return true
end

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1, true
end

function MODE:PickSeekerCount(count)
	if count <= 3 then return 1 end
	if count <= 6 then return 2 end
	if count <= 9 then return 3 end
	return math.max(1, math.floor(count / 4))
end

function MODE:Intermission()
	game.CleanUpMap()

	self.saved = self.saved or {}
	self.saved.Winner = nil

	local players = {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		table.insert(players, ply)
		ply.hs_seeker = false
		ply:SetNWBool("HS_Seeker", false)
	end

	if #players == 0 then return end

	Shuffle(players)

	local seekerCount = self:PickSeekerCount(#players)
	for i, ply in ipairs(players) do
		local isSeeker = i <= seekerCount
		ply.hs_seeker = isSeeker
		ply:SetNWBool("HS_Seeker", isSeeker)
		ply:SetTeam(isSeeker and 0 or 1)
		zb.GiveRole(ply, isSeeker and "Seeker" or "Hider", isSeeker and seekerRoleColor or hiderRoleColor)
		ply:SetupTeam(ply:Team())
		if not isSeeker then
			ply:Spawn()
		else
			if ply:Alive() then
				ply:KillSilent()
			end
		end
	end

	net.Start("hideseek_start")
		net.WriteFloat(self.HidingTime or 40)
	net.Broadcast()
end

function MODE:CanSpawn(ply)
	if ply and ply.hs_seeker and GetGlobalBool("ZB_HS_HidingPhase", false) then
		return false
	end
	return true
end

function MODE:RoundStart()
	local hideEnd = CurTime() + (self.HidingTime or 40)
	SetGlobalFloat("ZB_HS_HideEnd", hideEnd)
	SetGlobalBool("ZB_HS_HidingPhase", true)

	timer.Remove("HS_HidePhaseEnd")
	timer.Create("HS_HidePhaseEnd", self.HidingTime or 40, 1, function()
		SetGlobalBool("ZB_HS_HidingPhase", false)
		for _, ply in player.Iterator() do
			if not ply.hs_seeker then continue end
			if not ply:Alive() then
				ply:Spawn()
			end
			EquipSeeker(ply)
		end
	end)

	for _, ply in player.Iterator() do
		if ply.hs_seeker and ply:Alive() then
			ply:KillSilent()
		end
	end
end

local function FinishEquip(ply)
	timer.Simple(0.1, function()
		if IsValid(ply) then
			ply.noSound = false
			ply:SetSuppressPickupNotices(false)
		end
	end)
end

function EquipSeeker(ply)
	if not IsValid(ply) then return end
	ply:SetSuppressPickupNotices(true)
	ply.noSound = true
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	hg.AddArmor(ply, {"vest3", "helmet1"})
	local ruger = ply:Give("weapon_ruger")
	if IsValid(ruger) and ruger.GetMaxClip1 then
		ply:GiveAmmo(ruger:GetMaxClip1() * 3, ruger:GetPrimaryAmmoType(), true)
	end
	local glock = ply:Give("weapon_glock17")
	if IsValid(glock) and glock.GetMaxClip1 then
		ply:GiveAmmo(glock:GetMaxClip1() * 3, glock:GetPrimaryAmmoType(), true)
	end
	ply:Give("weapon_hands_sh")
	ply:SelectWeapon("weapon_hands_sh")
	FinishEquip(ply)
end

function EquipHider(ply)
	if not IsValid(ply) then return end
	ply:SetSuppressPickupNotices(true)
	ply.noSound = true
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:Give("weapon_ducttape")
	ply:Give("weapon_hands_sh")
	ply:SelectWeapon("weapon_hands_sh")
	FinishEquip(ply)
end

function MODE:GiveEquipment()
	timer.Simple(0.1, function()
		local hiding = GetGlobalBool("ZB_HS_HidingPhase", false)
		for _, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR then continue end
			if not ply:Alive() then continue end
			if ply.hs_seeker then
				if hiding then continue end
				EquipSeeker(ply)
			else
				EquipHider(ply)
			end
		end
	end)
end

function MODE:CheckAlive()
	local seekers = 0
	local hiders = 0
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end
		if ply.hs_seeker then
			seekers = seekers + 1
		else
			hiders = hiders + 1
		end
	end
	return seekers, hiders
end

function MODE:ShouldRoundEnd()
	if GetGlobalBool("ZB_HS_HidingPhase", false) then
		return nil
	end
	local seekers, hiders = self:CheckAlive()
	if hiders == 0 then
		self.saved.Winner = 0
		return true
	end
	if seekers == 0 then
		self.saved.Winner = 1
		return true
	end
	return nil
end

function MODE:EndRound()
	timer.Remove("HS_HidePhaseEnd")
	SetGlobalBool("ZB_HS_HidingPhase", false)

	local winner = self.saved and self.saved.Winner
	if winner == nil then
		local timeUp = (zb.ROUND_START or 0) + (self.ROUND_TIME or 600) <= CurTime()
		if timeUp then
			winner = 2
		else
			local seekers, hiders = self:CheckAlive()
			winner = hiders > 0 and 1 or 0
		end
	end

	timer.Simple(1, function()
		net.Start("hideseek_roundend")
			net.WriteUInt(winner or 2, 2)
		net.Broadcast()
	end)
end
