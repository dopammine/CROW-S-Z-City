if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Blunt"
SWEP.Instructions = "Marijuana rolled inside tobacco paper."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/customhq/tobaccofarm/blunt.mdl"
if CLIENT then
	SWEP.BounceWeaponIcon = false
end
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(4, -1.5, 0)
SWEP.offsetAng = Angle(-30, 90, 180)
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
	function SWEP:Heal(ent, mode)
		if not IsValid(ent) then return end
		local owner = self:GetOwner()
		local org = ent.organism
		if not org then return end
		if ent ~= hg.GetCurrentCharacter(owner) then return end
		if ent == hg.GetCurrentCharacter(owner) and hg_healanims:GetBool() then
			self:SetHolding(math.min(self:GetHolding() + 4, 100))
			if self:GetHolding() < 100 then return end
		end
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound("snd_jack_hmcd_pillsuse.wav", 60, math.random(95, 105))
		org.analgesiaAdd = math.min((org.analgesiaAdd or 0) + 1.2, 4)
		org.dizzy_until = math.max(org.dizzy_until or 0, CurTime() + 70)
		owner:SetNetVar("blunt_high_until", CurTime() + 70)
		owner:Notify("OohOhohoOHoHOOHO THIS SHITs GOoD...", 10, "blunt_high_msg", 0)
		self.modeValues[1] = 0
		owner:SelectWeapon("weapon_hands_sh")
		self:Remove()
		return true
	end
end
