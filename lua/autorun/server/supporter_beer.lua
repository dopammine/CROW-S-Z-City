local function getGroup(ply)
	if ULib and ULib.ucl and ULib.ucl.getUserGroup then
		return ULib.ucl.getUserGroup(ply)
	end
	return ply:GetUserGroup()
end

hook.Add("PlayerSpawn", "supporter_beer_spawn", function(ply)
	timer.Simple(0, function()
		if not IsValid(ply) or not ply:Alive() then return end
		local group = getGroup(ply)
		if group and string.lower(group) == "supporter" and not ply:HasWeapon("weapon_hg_beer") then
			ply:Give("weapon_hg_beer")
		end
	end)
end)
