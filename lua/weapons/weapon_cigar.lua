if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Cigar"
SWEP.Instructions = "A rolled bundle of dried and fermented tobacco leaves made to be smoked. All the big notorious mafia bosses love this one."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/jellik/cigar.mdl"
if CLIENT then
    SWEP.BounceWeaponIcon = false
end
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(6, -1.7, 0)      -- same as cigarette
SWEP.offsetAng = Angle(30, -35, 180)    -- same as cigarette
SWEP.modeNames = {
    [1] = "smoke"
}
SWEP.showstats = false

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

local hg_healanims = ConVarExists("hg_font") and GetConVar("hg_healanims") or CreateConVar("hg_healanims", 0, FCVAR_SERVER_CAN_EXECUTE, "Toggle heal/food animations", 0, 1)

if SERVER then
    local COUGH_SOUNDS
    local MAFIA_MSGS = {
        "Damn, this is GOOD!",
        "Now I see why mafia bosses loved these..",
        "That's the stuff..",
        "I feel like a level 100 mafia boss!",
        "This is how the mafia works.. or whatever that ad said.."
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

        local pos = owner:EyePos() + owner:EyeAngles():Forward() * 6 + owner:EyeAngles():Right() * 1.5
        net.Start("HG_CigarSmoke")
            net.WriteVector(pos)
            net.WriteVector(owner:GetAimVector() * 14 + Vector(0, 0, 20))
        net.Broadcast()

        if owner.Notify then owner:Notify(MAFIA_MSGS[math.random(#MAFIA_MSGS)], 8, "cigar_smoke_msg", 0) end
        local entOwner2 = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
        entOwner2:EmitSound(getCoughSound(), 58, math.random(92, 110))
        if util and util.NetworkIDToString then end
        if util then
            net.Start("HG_CigarFade")
                net.WriteFloat(10)
            net.Send(owner)
        end

        if ent.organism then
            ent.organism.fear = (ent.organism.fear or 0) * 0.7
            ent.organism.fearadd = (ent.organism.fearadd or 0) * 0.7
            local tid = "HG_CigarRelax_" .. owner:EntIndex()
            if timer.Exists(tid) then timer.Remove(tid) end
            local ticks = 15
            timer.Create(tid, 1.0, ticks, function()
                if not IsValid(owner) or not owner.organism then
                    if timer.Exists(tid) then timer.Remove(tid) end
                    return
                end
                owner.organism.fear = owner.organism.fear * 0.98
                owner.organism.fearadd = owner.organism.fearadd * 0.98
            end)
        end

        self.modeValues[1] = 0
        owner:SelectWeapon("weapon_hands_sh")
        self:Remove()
        return true
    end
end
