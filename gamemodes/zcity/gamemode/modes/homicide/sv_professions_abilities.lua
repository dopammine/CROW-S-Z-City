local MODE = MODE
MODE.SendFootStepEvery = 3
-- MODE.SendFootStepEvery = 1

util.AddNetworkString("HMCD_Professions_Abilities_AddFootstep")
util.AddNetworkString("HMCD_Professions_Abilities_DisplayOrganismInfo")
util.AddNetworkString("HMCD_CraftQTE_Start")
util.AddNetworkString("HMCD_CraftQTE_Prompt")
util.AddNetworkString("HMCD_CraftQTE_Update")
util.AddNetworkString("HMCD_CraftQTE_Complete")
util.AddNetworkString("HMCD_CraftQTE_Cancel")
util.AddNetworkString("HMCD_CraftQTE_Attempt")

function MODE.DisplayOrganismInfo(organism, ply)
	local text_info = ""
	text_info = text_info .. " Saturation" .. organism.o2 .. "\n"
	
	net.Start("HMCD_Professions_Abilities_DisplayOrganismInfo")
		net.WriteString(text_info)
	net.Send(ply)
end

--\\
hook.Add("HG_PlayerFootstep_Notify", "HMCD_Professions_Abilities", function(ply, pos, foot, snd, volume, filter)
	ply.ProfessionAbility_FootstepsAmt = ply.ProfessionAbility_FootstepsAmt or 0
	ply.ProfessionAbility_FootstepsAmt = ply.ProfessionAbility_FootstepsAmt + 1
	
	if(ply.ProfessionAbility_FootstepsAmt >= MODE.SendFootStepEvery)then
		ply.ProfessionAbility_FootstepsAmt = 0
		
		net.Start("HMCD_Professions_Abilities_AddFootstep")
			net.WriteVector(pos)
			net.WriteFloat(ply:EyeAngles().y)
			net.WriteBool(foot == 0)
			
			local character_color = ply:GetNWVector("PlayerColor")
			
			if(!IsColor(character_color))then
				character_color = Color(character_color[1] * 255, character_color[2] * 255, character_color[3] * 255)
			end
			
			net.WriteColor(character_color, false)
			
			local recepients = {}
			
			for _, recepient_ply in player.Iterator() do
				if(recepient_ply.Profession == "huntsman" and recepient_ply != ply)then
					recepients[#recepients+1] = recepient_ply
				end
			end
		net.Send(recepients)
	end
end)

hook.Add("PlayerPostThink", "HMCD_Professions_Abilities", function(ply)
	if(MODE.RoleChooseRoundTypes[MODE.Type])then
		if(ply:Alive())then
			if(ply.Profession == "doctor")then
				if(ply:KeyDown(IN_SPEED))then
					if(ply:KeyPressed(IN_USE))then
						local aim_ent, other_ply = MODE.GetPlayerTraceToOther(ply)
						
						if(IsValid(aim_ent))then
							if(other_ply)then
								MODE.DisplayOrganismInfo(other_ply.organism, ply)
							end
						end
					end
				end
			end
			
			if(ply.Profession == "huntsman")then
				
			end
		end
	end
end)

MODE.CraftQTE = MODE.CraftQTE or {}

local function craft_can_pipebomb(ply)
	if not (ply:Alive() and not ply.organism.otrub and ply.Profession == "engineer") then return end
	local have_ammo
	local have_nails
	for id, amt in pairs(ply:GetAmmo()) do
		local name = game.GetAmmoName(id)
		if name == "Nails" and amt >= 3 then
			have_nails = true
			goto cont
		end
		local tbl = hg.ammotypeshuy[name]
		if tbl and tbl.BulletSettings and tbl.BulletSettings.Mass * amt > 50 then
			have_ammo = {name, amt}
		end
		::cont::
	end
	local have_pipe = ply:HasWeapon("weapon_leadpipe")
	if have_ammo and have_pipe and have_nails then
		return have_ammo
	end
end

local craft_barrels_map = {
	["models/props_c17/oildrum001.mdl"] = true,
	["models/props_c17/oildrum001_explosive.mdl"] = true
}

local function craft_can_molotov(ply)
	if not (ply:Alive() and not ply.organism.otrub and ply.Profession == "engineer") then return end
	local have_bandage = ply:HasWeapon("weapon_bandage_sh") or ply:HasWeapon("weapon_bigbandage_sh")
	local have_bottle = ply:HasWeapon("weapon_hg_bottle")
	if not (have_bandage and have_bottle) then return end
	for i, ent in ipairs(ents.FindInSphere(ply:GetPos(), 64)) do
		if craft_barrels_map[ent:GetModel()] and not ent:GetNWBool("EmptyBarrel", false) then
			return true
		end
	end
end

local function craft_can_spear(ply)
	if not (ply:Alive() and not ply.organism.otrub and ply.Profession == "engineer") then return end
	local have_hammer = ply:HasWeapon("weapon_hammer")
	local have_table_leg = ply:HasWeapon("weapon_table_leg")
	if have_hammer and have_table_leg then return true end
end

local function craft_can_shiv(ply)
	if not (IsValid(ply) and ply:Alive() and ply.organism and not ply.organism.otrub and ply.Profession == "engineer") then return end
	local wep = ply:GetActiveWeapon()
	if not (IsValid(wep) and wep:GetClass() == "weapon_ducttape") then return end
	local tr = hg.eyeTrace(ply, 64)
	if not tr or not IsValid(tr.Entity) then return end
	if not craft_barrels_map[tr.Entity:GetModel()] then return end
	if tr.Entity:GetNWBool("EmptyBarrel", false) then return end
	return true
end

local function craft_finish_pipebomb(ply, have_ammo)
	if not IsValid(ply) then return end
	local ok = craft_can_pipebomb(ply)
	if not ok then return end
	local ammo_info = have_ammo or ok
	ply:SetAmmo(ply:GetAmmoCount("Nails") - 3, "Nails")
	ply:SetAmmo(math.Round((hg.ammotypeshuy[ammo_info[1]].BulletSettings.Mass * ammo_info[2] - 50) / hg.ammotypeshuy[ammo_info[1]].BulletSettings.Mass), ammo_info[1])
	ply:StripWeapon("weapon_leadpipe")
	ply:Give("weapon_hg_pipebomb_tpik")
end

local function craft_finish_molotov(ply)
	if not IsValid(ply) then return end
	if not craft_can_molotov(ply) then return end
	if ply:HasWeapon("weapon_bandage_sh") then
		ply:StripWeapon("weapon_bandage_sh")
	else
		ply:StripWeapon("weapon_bigbandage_sh")
	end
	ply:StripWeapon("weapon_hg_bottle")
	ply:Give("weapon_hg_molotov_tpik")
end

local function craft_finish_spear(ply)
	if not IsValid(ply) then return end
	if not craft_can_spear(ply) then return end
	ply:StripWeapon("weapon_table_leg")
	ply:Give("weapon_hg_spear")
end

local function craft_finish_shiv(ply)
	if not IsValid(ply) then return end
	if not craft_can_shiv(ply) then return end
	ply:StripWeapon("weapon_ducttape")
	ply:Give("weapon_shiv")
end

local craft_finish_map = {
	pipebomb = craft_finish_pipebomb,
	molotov = craft_finish_molotov,
	woodenspear = craft_finish_spear,
	shiv = craft_finish_shiv
}

local function craftqte_start(ply, craft_id, meta)
	if not IsValid(ply) then return end
	MODE.CraftQTE[ply] = {
		craft = craft_id,
		meta = meta,
		progress = 0,
		expected = nil,
		deadline = 0,
		responded = true,
		next_prompt = CurTime()
	}
	net.Start("HMCD_CraftQTE_Start")
		net.WriteString(craft_id)
	net.Send(ply)
end

local qte_keys = {"W","A","S","D"}

local function craftqte_prompt(ply, st)
	local k = qte_keys[math.random(1, 4)]
	st.expected = k
	st.responded = false
	st.deadline = CurTime() + 4
	net.Start("HMCD_CraftQTE_Prompt")
		net.WriteString(k)
		net.WriteFloat(st.deadline)
	net.Send(ply)
end

local function craftqte_update(ply, st, result)
	net.Start("HMCD_CraftQTE_Update")
		net.WriteFloat(st.progress)
		net.WriteBool(result)
	net.Send(ply)
end

local function craftqte_complete(ply, st)
	net.Start("HMCD_CraftQTE_Complete")
		net.WriteString(st.craft or "")
	net.Send(ply)
	MODE.CraftQTE[ply] = nil
end

local function craftqte_cancel(ply, reason)
	net.Start("HMCD_CraftQTE_Cancel")
		net.WriteString(reason or "")
	net.Send(ply)
	MODE.CraftQTE[ply] = nil
end

hook.Add("Think", "HMCD_CraftQTE_Think", function()
	for ply, st in pairs(MODE.CraftQTE) do
		if not IsValid(ply) or not ply:Alive() then
			MODE.CraftQTE[ply] = nil
		else
			if st.craft == "shiv" then
				local wep = ply:GetActiveWeapon()
				if not (IsValid(wep) and wep:GetClass() == "weapon_ducttape") then
					craftqte_cancel(ply, "not_equipped")
					goto cont2
				end
			end
			if st.next_prompt and CurTime() >= st.next_prompt then
				st.next_prompt = nil
				craftqte_prompt(ply, st)
			elseif not st.responded and CurTime() > st.deadline then
				st.responded = true
				st.progress = math.max(st.progress - 0.25, 0)
				craftqte_update(ply, st, false)
				st.next_prompt = CurTime() + 4
			end
		end
		::cont2::
	end
end)

net.Receive("HMCD_CraftQTE_Attempt", function(len, ply)
	local st = MODE.CraftQTE[ply]
	if not st then return end
	if st.responded then return end
	local ch = net.ReadString()
	local in_time = CurTime() <= st.deadline
	local ok = in_time and ch == st.expected
	st.responded = true
	if ok then
		st.progress = math.min(st.progress + 0.25, 1)
		craftqte_update(ply, st, true)
		if st.progress >= 1 then
			local fin = craft_finish_map[st.craft]
			if fin then fin(ply, st.meta) end
			craftqte_complete(ply, st)
			return
		end
		st.next_prompt = CurTime() + 0.25
	else
		st.progress = math.max(st.progress - 0.25, 0)
		craftqte_update(ply, st, false)
		st.next_prompt = CurTime() + 4
	end
end)

concommand.Add("hg_create_pipebomb", function(ply)
	local ok = craft_can_pipebomb(ply)
	if ok then
		craftqte_start(ply, "pipebomb", ok)
	end
end)

concommand.Add("hg_create_molotov", function(ply)
	if craft_can_molotov(ply) then
		craftqte_start(ply, "molotov")
	end
end)

concommand.Add("hg_create_wooden_spear", function(ply)
	if craft_can_spear(ply) then
		craftqte_start(ply, "woodenspear")
	end
end)

concommand.Add("hg_create_shiv", function(ply)
	if craft_can_shiv(ply) then
		craftqte_start(ply, "shiv")
	end
end)
--//
