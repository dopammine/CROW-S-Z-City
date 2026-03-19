if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Screwdriver"
SWEP.Instructions = "A sharp screwdriver.\n\nLMB to stab.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/octoteam/weapons/screwdriver.mdl"
SWEP.WorldModelReal = "models/weapons/combatknife/tactical_knife_iw7_vm.mdl"
SWEP.WorldModelExchange = "models/octoteam/weapons/screwdriver.mdl"
SWEP.DontChangeDropped = true
SWEP.modelscale = 1
SWEP.modelscale2 = 1

SWEP.SuicidePos = Vector(16, -1, -3)
SWEP.SuicideAng = Angle(-40, 180, 0)
SWEP.SuicideCutVec = Vector(1, -5, 4)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.CanSuicide = true

SWEP.BleedMultiplier = 1.25
SWEP.PainMultiplier = 1.2

SWEP.DamagePrimary = 12
SWEP.DamageSecondary = 8

SWEP.PenetrationPrimary = 5
SWEP.PenetrationSecondary = 3
SWEP.MaxPenLen = 3
SWEP.PenetrationSizePrimary = 1.5
SWEP.PenetrationSizeSecondary = 1

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.basebone = 76

SWEP.HoldPos = Vector(-10, 0, -5)
SWEP.HoldAng = Angle(-15, 20, -10)

SWEP.AttackPos = Vector(0, 0, 0)
SWEP.AttackingPos = Vector(0, 0, 0)

SWEP.weaponPos = Vector(0.5, 0.5, -0.5)
SWEP.weaponAng = Angle(-5.9, 50, 100)

SWEP.HoldType = "knife"

SWEP.BreakBoneMul = 0.5
SWEP.ImmobilizationMul = 0.45
SWEP.StaminaMul = 0.5

SWEP.AttackTime = 0.01
SWEP.AnimTime1 = 0.8
SWEP.WaitTime1 = 0.6

SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.4

SWEP.AnimList = {
	["idle"] = "vm_knifeonly_idle",
	["deploy"] = "vm_knifeonly_raise",
	["attack"] = "vm_knifeonly_stab",
	["attack2"] = "vm_knifeonly_swipe",
}

function SWEP:Reload()
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
	addPosLerp.z = addPosLerp.z + (self:GetBlocking() and -4 or 0)
	addPosLerp.x = addPosLerp.x + (self:GetBlocking() and 15 or 0)
	addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -7 or 0)
	addAngLerp.r = addAngLerp.r + (self:GetBlocking() and 60 or 0)
	addAngLerp.y = addAngLerp.y + (self:GetBlocking() and 90 or 0)
	addAngLerp.x = addAngLerp.x + (self:GetBlocking() and -60 or 0)

	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 35
SWEP.AttackRads2 = 45

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = false
SWEP.MultiDmg2 = true
