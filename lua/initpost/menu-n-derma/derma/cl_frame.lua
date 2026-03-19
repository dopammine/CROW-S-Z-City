local PANEL = {}
hg = hg or {}
local color_blacky = Color(25,25,30,220)
local color_reddy = Color(0,0,155,240)
local blurMat = Material("pp/blurscreen")

if not hg.DrawBlur then
    function hg.DrawBlur(panel, amount)
        local x, y = panel:LocalToScreen(0, 0)
        local w, h = panel:GetWide(), panel:GetTall()
        surface.SetMaterial(blurMat)
        surface.SetDrawColor(255, 255, 255)
        for i = 1, 3 do
            blurMat:SetFloat("$blur", (i / 3) * (amount or 2))
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x, y, w, h)
        end
    end
end

function PANEL:Init()
    self.Itensens = {}
    self:SetAlpha( 0 )
    self:SetTitle( "" )

    self.DrawBorder = true

    self.ColorBG = Color(color_blacky:Unpack())
    self.ColorBR = Color(color_reddy:Unpack())
    self.BlurStrengh = 2

    timer.Simple(0,function()
        if self.First then
            self:First()
        end
    end)
end

function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,self.ColorBG)
    hg.DrawBlur(self, self.BlurStrengh)

    if self.DrawBorder then
        surface.SetDrawColor(self.ColorBR)
        surface.DrawOutlinedRect(0,0,w,h,1.5)
    end
end

function PANEL:SetBorder( bDraw )
    self.DrawBorder = bDraw
end

function PANEL:SetColorBG( cColor )
    self.ColorBG = cColor
end

function PANEL:SetColorBR( cColor )
    self.ColorBR = cColor
end

function PANEL:SetBlurStrengh( floatVal )
    self.BlurStrengh = floatVal
end

function PANEL:First( ply )
    self:SetY(self:GetY() + self:GetTall())
    self:MoveTo(self:GetX(), self:GetY() - self:GetTall(), 0.4, 0, 0.2, function() end)
    self:AlphaTo( 255, 0.2, 0.1, nil )

    if self.PostInit then
        self:PostInit()
    end
end

function PANEL:Close()
    if self.Closing then return end
    self.Closing = true
    self:MoveTo(self:GetX(), ScrH() / 2 + self:GetTall(), 5, 0, 0.3, function()
    end)
    self:AlphaTo( 0, 0.2, 0, function()
        if self.OnClose then self:OnClose() end
        self:Remove()
    end)
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
end

vgui.Register( "ZFrame", PANEL, "DFrame")
