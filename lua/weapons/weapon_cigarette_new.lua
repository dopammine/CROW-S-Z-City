if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Cigarette"
SWEP.Instructions = "A tube-shaped tobacco product that is made of finely cut, cured tobacco leaves wrapped in thin paper. Use to smoke."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/phycignew.mdl"
if CLIENT then
	SWEP.BounceWeaponIcon = false
end
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(6, -1.7, 0)
SWEP.offsetAng = Angle(200, 180, 180)
SWEP.modeNames = {
	[1] = "smoke"
}

SWEP.DeploySnd = ""
SWEP.HolsterSnd = ""

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self.modeValues = {
		[1] = 1
	}
end

SWEP.modeValuesdef = {
	[1] = 1
}

SWEP.showstats = false

local hg_healanims = ConVarExists("hg_font") and GetConVar("hg_healanims") or CreateConVar("hg_healanims", 0, FCVAR_SERVER_CAN_EXECUTE, "Toggle heal/food animations", 0, 1)

if SERVER then
	local COUGH_SOUNDS
	local MSGS = {
		"This can't be good for me, but I feel great!",
		"I should really quit..",
		"My doctor WON'T be happy about this!",
		"I can feel my lungs begging me to stop..",
		"Man, what is this shit?",
		"So damn fucking expensive for what..?",
		"'Do it, it makes you cool!' they said.."
	}
	local function getCoughSound()
		if COUGH_SOUNDS and #COUGH_SOUNDS > 0 then
			return COUGH_SOUNDS[math.random(#COUGH_SOUNDS)]
		end

		local candidates = {}
		for i = 1, 12 do
			local p = "homigrad/player/male/male_cough" .. i .. ".wav"
			if file.Exists("sound/" .. p, "GAME") then candidates[#candidates + 1] = p end
		end
		for i = 1, 12 do
			local p = "homigrad/player/female/female_cough" .. i .. ".wav"
			if file.Exists("sound/" .. p, "GAME") then candidates[#candidates + 1] = p end
		end
		if #candidates == 0 then
			for i = 1, 5 do
				candidates[#candidates + 1] = "homigrad/player/male/male_cough" .. i .. ".wav"
			end
		end
		COUGH_SOUNDS = candidates
		return candidates[math.random(#candidates)]
	end

	function SWEP:Heal(ent, mode)
		if not IsValid(ent) then return end
		local owner = self:GetOwner()
		if ent ~= hg.GetCurrentCharacter(owner) then return end
		if ent == hg.GetCurrentCharacter(owner) and hg_healanims:GetBool() then
			self:SetHolding(math.min(self:GetHolding() + 4, 100))
			if self:GetHolding() < 100 then return end
		end

		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound(getCoughSound(), 60, math.random(90, 115))
		owner:Notify(MSGS[math.random(#MSGS)], 8, "cig_smoke_msg", 0)

		local pos = owner:EyePos() + owner:EyeAngles():Forward() * 6 + owner:EyeAngles():Right() * 1.5
		net.Start("HG_CigaretteSmoke")
			net.WriteVector(pos)
			net.WriteVector(owner:GetAimVector() * 10 + Vector(0, 0, 15))
		net.Broadcast()

		local cnt = self:GetNWInt("CigCount", 1)
		cnt = math.max(cnt - 1, 0)
		self:SetNWInt("CigCount", cnt)

		-- Track smoking frequency to trigger heavy cough if 8 cigs in < 60s
		owner.CigSmokeTimes = owner.CigSmokeTimes or {}
		local now = CurTime()
		owner.CigSmokeTimes[#owner.CigSmokeTimes + 1] = now
		for i = #owner.CigSmokeTimes, 1, -1 do
			if owner.CigSmokeTimes[i] < (now - 60) then table.remove(owner.CigSmokeTimes, i) end
		end

		if #owner.CigSmokeTimes >= 8 and not owner.CigCoughing then
			owner.CigCoughing = true
			owner.CigCoughUntil = now + 32
			local tid = "HG_CigOverCough_" .. owner:EntIndex()
			timer.Create(tid, 0.7, 0, function()
				if not IsValid(owner) or owner.CigCoughUntil == nil or owner.CigCoughUntil <= CurTime() then
					if timer.Exists(tid) then timer.Remove(tid) end
					if IsValid(owner) then
						owner.CigCoughing = false
						owner.CigCoughUntil = nil
					end
					return
				end
				local entOwner2 = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
				entOwner2:EmitSound(getCoughSound(), 55, math.random(90, 115))
				if owner.organism then
					owner.organism.disorientation = math.max(owner.organism.disorientation or 0, 1.6)
					owner.organism.dizzy_until = math.max(owner.organism.dizzy_until or 0, CurTime() + 1.5)
				end
			end)
		end

		self.modeValues[1] = 0
		owner:SelectWeapon("weapon_hands_sh")
		if cnt <= 0 then
			self:Remove()
		end
		return true
	end
end
