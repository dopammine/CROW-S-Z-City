local CLASS = player.RegClass("bart")

function CLASS.Off(self)
    if CLIENT then return end
    if self.organism then
        self.organism.recoilmul = 1
        self.organism.meleespeed = 1
        self.organism.breakmul = 1
    end
    self.MeleeDamageMul = nil
end

function CLASS.On(self)
    if CLIENT then return end
    self:SetModel("models/hellinspector/the_simpsons_game/bart.mdl")
    self:SetPlayerColor(Color(255, 217, 15):ToVector())
    self:SetSubMaterial()
    self:SetBodyGroups("00000000000")
    GetAppearance(self)
    local Appearance = self.Appearance or GetRandomAppearance(self, 1)
    Appearance.ClothesStyle = ""
    self:SetNetVar("Accessories", "")
    self.CurAppearance = Appearance

    if self.SetMaxHealth then
        self:SetMaxHealth(60)
        self:SetHealth(60)
    else
        self:SetHealth(60)
    end

    self:SetNWString("PlayerName","Bart " .. (Appearance.Name or "Simpson"))

    -- Bart weaker
    if self.organism then
        self.organism.recoilmul = 1.4
        self.organism.meleespeed = 0.8
        self.organism.breakmul = 1.8
    end
    
    -- Reduce fist damage effectiveness for Bart
    self.MeleeDamageMul = 0.4
    
end