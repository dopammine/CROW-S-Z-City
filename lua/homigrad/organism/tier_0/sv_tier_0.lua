hg.organism = hg.organism or {}
--local Organism = hg.organism
hg.organism.list = hg.organism.list or {}
local hook_Run = hook.Run
function hg.organism.Add(ent)
	ent.organism = {
		owner = ent
	}

	local org = ent.organism
	org.owner = ent
	hg.organism.list[ent] = org
	return org
end

function hg.organism.Clear(org)
	hook_Run("Org Clear", org)//.owner.organism_internal)
	if IsValid(org.owner) then org.owner.fullsend = true end
	hg.send_organism(org)
end

function hg.organism.Remove(ent)
	local org = hg.organism.list[ent]
	if org then org.owner = nil end
	hg.organism.list[ent] = nil
end

hook.Add("PlayerInitialSpawn", "homigrad-organism", function(ply) hg.organism.Add(ply) end)
hook.Add("Player Spawn", "homigrad-organism", function(ply) hg.organism.Clear(ply.organism) end)
hook.Add("PlayerDisconnected", "homigrad-organism", function(ply) hg.organism.Remove(ply) end)
hook.Add("PostPlayerDeath", "homigrad-organism", function(ply)
	local ragdoll = ply:GetNWEntity("RagdollDeath")
	
	if not IsValid(ragdoll) then ragdoll = ply.FakeRagdoll end

	if IsValid(ragdoll) then
		local newOrg = hg.organism.Add(ragdoll)
		table.Merge(newOrg, ply.organism)

		hook.Run("RagdollDeath", ply, ragdoll)

		table.Merge(zb.net.list[ragdoll], zb.net.list[ply])

		newOrg.alive = false
		newOrg.owner = ragdoll
		ragdoll:CallOnRemove("organism", hg.organism.Remove, ragdoll)
	end

	hg.organism.Clear(ply.organism)

	hook.Run("PostPostPlayerDeath", ply, ragdoll)
end)

local tickrate = 1 / 10
local delay = 0
local time, mulTime, start
local CurTime = CurTime
local SysTime = SysTime
hook.Add("Think", "homigrad-organism", function()
	time = CurTime()
	local tickrate2 = tickrate// / math.max(game.GetTimeScale(), 0.01)
	//print(delay ,time + tickrate)
	if delay + tickrate2 > time then return end

	delay = time

	if not start then
		start = SysTime()
		return
	end
	
	mulTime = (SysTime() - start) * game.GetTimeScale()

	start = SysTime()
	for owner, org in pairs(hg.organism.list) do
		hook_Run("Org Think", owner, org, mulTime)
	end
end)

hook.Add("Org Think Call", "homigrad-organism", function(owner, org)
	time = CurTime()

	if not start then
		start = SysTime()
		return
	end

	local mulTime = SysTime() - start
	
	hook_Run("Org Think", owner, org, mulTime)
end)


hook.Add("Fake", "organism", function(ply, ragdoll)
	ragdoll.organism = ply.organism
	--zb.net.list[ragdoll] = zb.net.list[ply]
end)

if SERVER then
	local function hgDeathTwitchApply(ragdoll)
		local count = ragdoll:GetPhysicsObjectCount()
		if not count or count < 2 then return end

		local limbs = math.random(1, 3)
		for i = 1, limbs do
			local phys = ragdoll:GetPhysicsObjectNum(math.random(1, count - 1))
			if not IsValid(phys) then continue end

			phys:Wake()

			local mass = phys:GetMass()
			phys:AddAngleVelocity(VectorRand() * math.Rand(40, 160))
			phys:ApplyForceCenter(VectorRand() * math.Rand(12, 35) * mass)
		end
	end

	local function hgDeathTwitchScheduleMove(ragdoll)
		if not IsValid(ragdoll) then return end
		local state = ragdoll.hg_death_twitch
		if not state then return end

		local time = CurTime()
		if time >= state.totalEnd then
			ragdoll.hg_death_twitch = nil
			return
		end

		if not state.twitchEnd or time >= state.twitchEnd then return end

		hgDeathTwitchApply(ragdoll)

		timer.Simple(math.Rand(1, 6), function()
			hgDeathTwitchScheduleMove(ragdoll)
		end)
	end

	local function hgDeathTwitchStart(ragdoll)
		local state = ragdoll.hg_death_twitch
		if not state then return end

		local time = CurTime()
		local duration = math.Rand(3, 15)

		state.twitchEnd = math.min(time + duration, state.totalEnd)
		hgDeathTwitchScheduleMove(ragdoll)
	end

	hook.Add("RagdollDeath", "hg-death-twitch", function(ply, ragdoll)
		if not IsValid(ragdoll) then return end
		if ragdoll:GetClass() ~= "prop_ragdoll" then return end

		local time = CurTime()
		ragdoll.hg_death_twitch = {
			totalEnd = time + 60
		}

		local timerName = "HG_DeathTwitch_" .. ragdoll:EntIndex()
		timer.Remove(timerName)

		timer.Create(timerName, 6, 0, function()
			if not IsValid(ragdoll) then
				timer.Remove(timerName)
				return
			end

			local state = ragdoll.hg_death_twitch
			if not state then
				timer.Remove(timerName)
				return
			end

			local t = CurTime()
			if t >= state.totalEnd then
				ragdoll.hg_death_twitch = nil
				timer.Remove(timerName)
				return
			end

			if state.twitchEnd and t < state.twitchEnd then return end

			local chance = math.Rand(0.2, 0.4)
			if math.Rand(0, 1) <= chance then
				hgDeathTwitchStart(ragdoll)
			end
		end)

		ragdoll:CallOnRemove("hg-death-twitch", function()
			timer.Remove(timerName)
		end)
	end)
end
