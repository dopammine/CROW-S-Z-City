util.AddNetworkString("hg_halal_zero")

local minHalal = 0
local maxHalal = 100
local eatPenalty = 12
local drinkPenalty = 8
local killPenalty = 20
local barrageDelay = 0.2
local barrageInterval = 0.35
local barrageCount = 8
local flyoverDuration = 13
local flyoverHeight = 4000
local flyoverSpeed = 2000

local function aprilFoolsEnabled()
	local cvar = GetConVar("hg_aprilfools")
	if cvar then
		return cvar:GetBool()
	end
	return GetGlobalBool("hg_aprilfools", false)
end

local function setHalal(ply, value)
	local v = math.Clamp(value, minHalal, maxHalal)
	ply:SetNWFloat("hg_halal", v)
	return v
end

local function isVoteExempt(attacker)
	if attacker.isTraitor or attacker.MainTraitor then return true end
	local _, modeKey = CurrentRound()
	if not modeKey then return false end
	local key = tostring(modeKey):lower()
	if key == "tdm" then return true end
	if key == "dm" or key == "sdm" or key == "superfighters" or key == "scugarena" or key == "hl2dm" then return true end
	return false
end

local function triggerNotHalal(ply)
	if ply.hg_halal_zero then return end
	ply.hg_halal_zero = true
	net.Start("hg_halal_zero")
	net.Send(ply)

	local function spawnFlyover(ply)
		if not IsValid(ply) then return end
		local ent = ents.Create("prop_dynamic")
		if not IsValid(ent) then return end
		ent:SetModel("models/gta5/vehicles/lazer/chassis.mdl")
		ent:SetSolid(SOLID_NONE)
		ent:SetMoveType(MOVETYPE_NOCLIP)
		ent:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		ent:Spawn()

		local yaw = math.random(0, 359)
		local dir = Angle(0, yaw, 0):Forward()
		local start = ply:GetPos() + Vector(0, 0, flyoverHeight) + dir * (-flyoverSpeed * flyoverDuration * 0.5)
		local ang = dir:Angle()
		ang:RotateAroundAxis(ang:Right(), -15)
		ent:SetPos(start)
		ent:SetAngles(ang)

		local id = ply:SteamID64() or ply:EntIndex()
		local timerName = "hg_halal_flyover_" .. id
		if timer.Exists(timerName) then timer.Remove(timerName) end
		local startTime = CurTime() + barrageDelay
		timer.Create(timerName, 0.05, math.ceil(flyoverDuration / 0.05), function()
			if not IsValid(ent) then timer.Remove(timerName) return end
			if not IsValid(ply) then ent:Remove() timer.Remove(timerName) return end
			local t = CurTime() - startTime
			if t < 0 then
				ent:SetPos(start)
				return
			end
			local progress = math.Clamp(t / flyoverDuration, 0, 1)
			local eased = progress * progress * (3 - 2 * progress)
			local pos = start + dir * (flyoverSpeed * flyoverDuration * eased)
			ent:SetPos(pos)
		end)
		timer.Simple(flyoverDuration, function()
			if IsValid(ent) then ent:Remove() end
		end)
	end

	spawnFlyover(ply)

	local function spawnBombAt(pos)
		local bomb = ents.Create("gb_bomb_sc100")
		if IsValid(bomb) then
			bomb:SetPos(pos + Vector(0, 0, 5000))
			bomb:SetAngles(Angle(90, 0, 0))
			bomb:Spawn()
			bomb:Activate()
			timer.Simple(barrageDelay, function()
				if not IsValid(bomb) then return end
				local phys = bomb:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(true)
					phys:Wake()
					phys:SetVelocity(Vector(0, 0, -2000))
				end
			end)
		else
			local exp = ents.Create("env_explosion")
			if not IsValid(exp) then return end
			exp:SetPos(pos)
			exp:SetKeyValue("iMagnitude", "120")
			exp:Spawn()
			exp:Fire("Explode")
		end
	end

	local id = ply:SteamID64() or ply:EntIndex()
	local timerName = "hg_halal_barrage_" .. id
	if timer.Exists(timerName) then timer.Remove(timerName) end
	timer.Simple(barrageDelay, function()
		if not IsValid(ply) then return end
		timer.Create(timerName, barrageInterval, barrageCount, function()
			if not IsValid(ply) then timer.Remove(timerName) return end
			local base = ply:GetPos()
			local offset = VectorRand() * 300
			offset.z = 0
			spawnBombAt(base + offset)
		end)
	end)
end

hook.Add("PlayerSpawn", "hg_halal_spawn", function(ply)
	if not IsValid(ply) then return end
	ply.hg_halal_zero = false
	setHalal(ply, maxHalal)
end)

hook.Add("HG_OnFoodEaten", "hg_halal_food", function(ply, isDrink)
	if not IsValid(ply) or not ply:Alive() then return end
	if not aprilFoolsEnabled() then return end
	local current = ply:GetNWFloat("hg_halal", maxHalal)
	local penalty = isDrink and drinkPenalty or eatPenalty
	local value = setHalal(ply, current - penalty)
	if value <= 0 then
		triggerNotHalal(ply)
	end
end)

hook.Add("PlayerDeath", "hg_halal_kill", function(victim, _, attacker)
	if not IsValid(attacker) or not attacker:IsPlayer() then return end
	if attacker == victim then return end
	if not aprilFoolsEnabled() then return end
	if isVoteExempt(attacker) then return end
	local current = attacker:GetNWFloat("hg_halal", maxHalal)
	local value = setHalal(attacker, current - killPenalty)
	if value <= 0 then
		triggerNotHalal(attacker)
	end
end)
