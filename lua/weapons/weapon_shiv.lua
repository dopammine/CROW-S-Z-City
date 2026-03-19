if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Shiv"
SWEP.Instructions = "A worn, improvised blade with a wrapped handle, capable of inflicting serious cuts.\n\nLMB to attack.\nRMB to block"
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/octoteam/weapons/melee/w_knife_shank.mdl"
SWEP.WorldModelReal = "models/weapons/combatknife/tactical_knife_iw7_vm.mdl"
SWEP.WorldModelExchange = "models/octoteam/weapons/melee/w_knife_shank.mdl"
SWEP.DontChangeDropped = true
SWEP.modelscale = 1.3

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_brick")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_brick"
	SWEP.BounceWeaponIcon = false
end

SWEP.weaponPos = Vector(3.5,-0.6,0)
SWEP.weaponAng = Angle(50,100,0)

SWEP.AttackHit = "Concrete.ImpactHard"
SWEP.Attack2Hit = "Concrete.ImpactHard"
SWEP.AttackHitFlesh = "snd_jack_hmcd_knifestab.wav"
SWEP.Attack2HitFlesh = "snd_jack_hmcd_knifestab.wav"
SWEP.DeploySnd = "Concrete.ImpactHard"

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 6
SWEP.DamageSecondary = 6

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 2

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 15
SWEP.StaminaSecondary = 30

SWEP.AttackTime = 0.25
SWEP.AnimTime1 = 0.7
SWEP.WaitTime1 = 0.5
SWEP.AttackLen1 = 30

SWEP.Attack2Time = 0.1
SWEP.AnimTime2 = 0.5
SWEP.WaitTime2 = 0.4
SWEP.AttackLen2 = 30
SWEP.HP = 20

function SWEP:PrimaryAttackAdd(ent, trace)
    if SERVER then
		local dmg = self.DamagePrimary
		local owner = self:GetOwner()

		if ent then
            self.HP = self.HP - 1
            if self.HP <= 0 then
                timer.Simple(0,function()
                    local Poof = EffectData()
                    Poof:SetOrigin(trace.HitPos)
                    Poof:SetScale(3)
                    Poof:SetNormal(-trace.HitNormal)
                    util.Effect("eff_jack_hmcd_poof", Poof, true, true)
                end)
                owner:EmitSound("physics/concrete/concrete_break" .. math.random(2, 3) .. ".wav",45,140)
                self:Remove()
            end
		end
    end
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.001

SWEP.AttackRads = 35
SWEP.AttackRads2 = 0

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0