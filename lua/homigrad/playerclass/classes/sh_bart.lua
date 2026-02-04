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
        self:SetMaxHealth(60)
        self:SetHealth(60)
    else
        self:SetHealth(60)
    end

    if Appearance and Appearance.AName then
        self:SetNWString("PlayerName","Bart " .. Appearance.AName)
    else
        self:SetNWString("PlayerName","Bart")
    end

    -- Bart weaker
    if self.organism then
        self.organism.recoilmul = 1.4
        self.organism.meleespeed = 0.8
        self.organism.breakmul = 1.8
    end
    
    -- Reduce fist damage effectiveness for Bart
    self.MeleeDamageMul = 0.4
    
end
