local MODE = MODE

MODE.name = "spineless_dm"
MODE.PrintName = "Spineless Deathmatch"
MODE.Description = "Deathmatch with broken spines and no pain."
MODE.base = "dm"
MODE.Chance = 0.04

local function ApplySpineless(ply)
	if not ply.organism then return end

	local org = ply.organism

	org.pain = 0
	org.avgpain = 0
	org.painadd = 0
	org.hurt = 0
	org.hurtadd = 0
	org.shock = 0

	org.analgesia = math.max(org.analgesia or 0, 1)
	org.analgesiaAdd = 0
	org.naloxone = 0
	org.naloxoneadd = 0

	org.fear = 0
	org.fearadd = 0
	org.disorientation = 0
end

function MODE:RoundStart()
	if zb.modes.dm and zb.modes.dm.RoundStart then
		zb.modes.dm:RoundStart()
	end

	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		ApplySpineless(ply)
		if not IsValid(ply.FakeRagdoll) then
			hg.Fake(ply, nil, true)
		end
	end
end

function MODE:RoundThink()
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		ApplySpineless(ply)
		if not IsValid(ply.FakeRagdoll) then
			hg.Fake(ply, nil, true)
		end
	end
end

local function SpinelessActive()
	if not CurrentRound then return false end
	local rnd = CurrentRound()
	return rnd and rnd.name == "spineless_dm"
end

hook.Add("Should Fake Up", "spineless_dm_block_fakeup", function(ply)
	if not SpinelessActive() then return end
	return false
end)
