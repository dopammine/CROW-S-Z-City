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
    GetAppearance(self)
    local Appearance = self.Appearance or GetRandomAppearance(self, 1)
    Appearance.ClothesStyle = ""
    self:SetNetVar("Accessories", "")
    self.CurAppearance = Appearance

    if self.SetMaxHealth then
        self:SetMaxHealth(250)
        self:SetHealth(250)
    else
        self:SetHealth(250)
    end

    -- Treat Homer fists throws as Fury-13 for strong throws
    self:SetNetVar("Fury13_Active", true)

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
    end

    self.MeleeDamageMul = 3

    

    self:SetNWString("PlayerName","Homer " .. (Appearance.Name or "Simpson"))
end