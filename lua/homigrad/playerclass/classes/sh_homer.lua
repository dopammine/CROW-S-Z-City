local CLASS = player.RegClass("homer")

function CLASS.Off(self)
    if CLIENT then return end
    self:SetNetVar("Fury13_Active", nil)
    if self.organism then
        self.organism.recoilmul = 1
        self.organism.meleespeed = 1
        self.organism.breakmul = 1
        local s = self.organism.stamina
        if s then
            s.regen = 1
            s.range = 180
            s.max = 180
        end
    end
    self.MeleeDamageMul = nil
end

function CLASS.On(self)
    if CLIENT then return end
    self:SetModel("models/hellinspector/homerharm/homerfm_pm.mdl")
    self:SetPlayerColor(Color(255, 217, 15):ToVector())
    self:SetSubMaterial()
    self:SetBodyGroups("00000000000")
    local Appearance
    if hg and hg.Appearance and hg.Appearance.GetRandomAppearance then
        Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
        Appearance.AClothes = ""
        self:SetNetVar("Accessories", "")
        self.CurAppearance = Appearance
    else
        self:SetNetVar("Accessories", "")
    end

    if self.SetMaxHealth then
        self:SetMaxHealth(250)
        self:SetHealth(250)
    else
        self:SetHealth(250)
    end

    -- Homer buffs
    if self.organism then
        self.organism.recoilmul = 0.5
        self.organism.meleespeed = 1.5
        self.organism.breakmul = 0.6
        local s = self.organism.stamina
        if s then
            s.regen = (s.regen or 1) * 1.5
            s.range = (s.range or 180) * 1.5
            s.max = (s.max or s.range) * 1.5
        end
        self.organism.berserk = math.max(self.organism.berserk or 0, 2)
    end

    self.MeleeDamageMul = 2.2

    if Appearance and Appearance.AName then
        self:SetNWString("PlayerName","Homer " .. Appearance.AName)
    else
        self:SetNWString("PlayerName","Homer")
    end
end
