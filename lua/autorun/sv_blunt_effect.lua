hook.Add("Player_Death", "HG_Blunt_ClearOnDeath", function(ply)
	if not IsValid(ply) then return end
	if ply.SetNetVar then ply:SetNetVar("blunt_high_until", 0) end
	ply:SetNWFloat("blunt_high_until", 0)
	if ply.organism then
		ply.organism.dizzy_until = nil
		ply.organism.disorientation = 0
	end
	ply.CigCoughing = false
	ply.CigCoughUntil = nil
	ply.CigSmokeTimes = nil
end)

hook.Add("Player Spawn", "HG_Blunt_ClearOnSpawn", function(ply)
	if not IsValid(ply) then return end
	if ply.SetNetVar then ply:SetNetVar("blunt_high_until", 0) end
	ply:SetNWFloat("blunt_high_until", 0)
	if ply.organism then
		ply.organism.dizzy_until = nil
		ply.organism.disorientation = 0
	end
end)

hook.Add("ZB_EndRound", "HG_Blunt_ClearOnRoundEnd", function()
	for _, ply in player.Iterator() do
		if IsValid(ply) then
			if ply.SetNetVar then ply:SetNetVar("blunt_high_until", 0) end
			ply:SetNWFloat("blunt_high_until", 0)
			if ply.organism then
				ply.organism.dizzy_until = nil
				ply.organism.disorientation = 0
			end
			ply.CigCoughing = false
			ply.CigCoughUntil = nil
			ply.CigSmokeTimes = nil
		end
	end
end)

hook.Add("ZB_PreRoundStart", "HG_Blunt_ClearOnRoundStart", function()
	for _, ply in player.Iterator() do
		if IsValid(ply) then
			if ply.SetNetVar then ply:SetNetVar("blunt_high_until", 0) end
			ply:SetNWFloat("blunt_high_until", 0)
			if ply.organism then
				ply.organism.dizzy_until = nil
				ply.organism.disorientation = 0
			end
			ply.CigCoughing = false
			ply.CigCoughUntil = nil
			ply.CigSmokeTimes = nil
		end
	end
end)
