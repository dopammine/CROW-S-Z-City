if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Cigarette Pack"
SWEP.Instructions = "a rectangular container, mostly of paperboard, which contains cigarettes."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/boxopencigshib.mdl"
if CLIENT then
	SWEP.BounceWeaponIcon = false
end
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(4, -1.5, 0)
SWEP.offsetAng = Angle(30, 180, 180)
SWEP.modeNames = {
	[1] = "use"
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

local function add_cigs_and_remove(self)
	if not SERVER then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local cig = owner:GetWeapon("weapon_cigarette_new")
	if not IsValid(cig) then
		cig = owner:Give("weapon_cigarette_new")
	end
	if IsValid(cig) then
		local cnt = cig:GetNWInt("CigCount", 0)
		cig:SetNWInt("CigCount", cnt + 8)
	end
	owner:SelectWeapon("weapon_hands_sh")
	timer.Simple(0, function()
		if IsValid(owner) then owner:SelectWeapon("weapon_hands_sh") end
	end)
	self:Remove()
end

function SWEP:PrimaryAttack()
	add_cigs_and_remove(self)
end

function SWEP:SecondaryAttack()
	add_cigs_and_remove(self)
end

if SERVER then
	function SWEP:Heal(ent, mode)
		if not IsValid(ent) then return end
		local owner = self:GetOwner()
		if ent ~= hg.GetCurrentCharacter(owner) then return end
		self:SetHolding(100)

		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound("items/ammocrate_open.wav", 60, 110)
		add_cigs_and_remove(self)
		return true
	end
end
