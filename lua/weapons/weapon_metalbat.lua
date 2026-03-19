if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Metal bat"
SWEP.Instructions = "A heavy-duty metal bat. Its solid steel construction and balanced weight distribution allow it to deliver devastating, bone-crushing blows.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "slam"

SWEP.WorldModel = "models/octoteam/weapons/melee/w_me_bat_metal.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_bat_metal.mdl"
SWEP.WorldModelExchange = "models/octoteam/weapons/melee/w_me_bat_metal.mdl"
SWEP.DontChangeDropped = false
SWEP.ViewModel = ""
SWEP.modelscale = 1

SWEP.basebone = 94

SWEP.Weight = 0
SWEP.weight = 1.5

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_baseballbat")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_baseballbat"
	SWEP.BounceWeaponIcon = false
end

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 27
SWEP.DamageSecondary = 11

SWEP.PenetrationPrimary = 4
SWEP.PenetrationSecondary = 6

SWEP.MaxPenLen = 2

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.5

SWEP.StaminaPrimary = 27
SWEP.StaminaSecondary = 12

SWEP.HoldPos = Vector(-8,0,0)
SWEP.HoldAng = Angle(0,0,-10)

SWEP.AttackTime = 0.27
SWEP.AnimTime1 = 1.3
SWEP.WaitTime1 = 0.95
SWEP.AttackLen1 = 65
SWEP.ViewPunch1 = Angle(2,4,0)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.AttackLen2 = 40
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0, 1, 0)
SWEP.weaponAng = Angle(0, -70, -12)

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/wood/wood_plank_impact_soft2.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.NoHolster = true

SWEP.BreakBoneMul = 0.5
SWEP.PainMultiplier = 0.85

SWEP.AttackTimeLength = 0.2
SWEP.Attack2TimeLength = 0.001

SWEP.AttackRads = 120
SWEP.AttackRads2 = 0

SWEP.SwingAng = -5
SWEP.SwingAng2 = 0

SWEP.MinSensivity = 0.6