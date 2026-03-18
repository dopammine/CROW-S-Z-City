local msgs = {
	"I killed them, I feel sick..",
	"I'm gonna puke..",
	"What have I done..?",
	"I'm not feeling well.."
}

hook.Add("PlayerDeath", "HG_Homicide_BystanderPsych", function(victim, inflictor, attacker)
	if not IsValid(attacker) or not attacker:IsPlayer() then return end
	if not IsValid(victim) or not victim:IsPlayer() then return end
	local gm = engine.ActiveGamemode()
	if not gm or not string.find(string.lower(gm), "homicide", 1, true) then return end
	-- try to exclude special roles if present; default to bystander if unknown
	if attacker.isTraitor == true then return end
	attacker:Notify(msgs[math.random(#msgs)], 8, "kill_shock", 0)
	timer.Simple(10, function()
		if IsValid(attacker) and attacker.organism then
			if hg and hg.organism and hg.organism.Vomit then
				hg.organism.Vomit(attacker)
			end
		end
	end)
	-- Maintain adrenaline and fear for ~30 seconds
	local id = "HG_KillShock_" .. attacker:EntIndex()
	if timer.Exists(id) then timer.Remove(id) end
	local ticks = 60
	timer.Create(id, 0.5, ticks, function()
		if not IsValid(attacker) or not attacker.organism then
			timer.Remove(id)
			return
		end
		attacker.organism.adrenalineAdd = math.max(attacker.organism.adrenalineAdd or 0, 1.5)
		attacker.organism.fearadd = (attacker.organism.fearadd or 0) + 0.06
	end)
end)
