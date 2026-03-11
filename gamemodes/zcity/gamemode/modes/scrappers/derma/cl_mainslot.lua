local PANEL = {}
local red = Color(239, 47, 47)

function PANEL:Init()
    self.text = "Разное"
end

function PANEL:SetWeapon(weapon)
    local isSingleSlot = self.text == "Primary"
    if isSingleSlot and istable(weapon) then
        weapon = weapon[1]
    end

    if istable(weapon) then
        local slots = {}

        self.scroll = self:Add("DScrollPanel")
        self.scroll:Dock(FILL)
        self.scroll:DockMargin(0, 0, 0, ScreenScale(10))

        self.scroll:GetVBar():SetSize(0, 0)
        
        for k, v in pairs(weapon) do
            local weapon2 = weapons.Get(v) or scripted_ents.Get(v) or {}

            slots[k] = self.scroll:Add("ZB_ScrappersButton")
            slots[k]:Dock(TOP)
            slots[k]:DockMargin(ScreenScale(1), ScreenScale(1), ScreenScale(1), 0)
            slots[k]:SetTall(ScreenScale(11))
            slots[k]:SetFont("ZB_ScrappersMedium")
            slots[k]:SetText(weapon2.PrintName or "fail")
            if slots[k].SetTextInset then
                slots[k]:SetTextInset(ScreenScale(11) + ScreenScale(3), 0)
            end

            slots[k].IconPanel = slots[k]:Add("EditablePanel")
            slots[k].IconPanel:Dock(LEFT)
            slots[k].IconPanel:SetWide(ScreenScale(11))
            slots[k].IconPanel.Paint = function(this, w, h)
                local drawn = false
                if weapon2 and isfunction(weapon2.DrawWeaponSelection) then
                    weapon2:DrawWeaponSelection(0, 0, w, h, 255)
                    drawn = true
                end

                if not drawn and weapon2 then
                    local mat
                    if weapon2.WepSelectIcon then
                        if type(weapon2.WepSelectIcon) == "IMaterial" then
                            mat = weapon2.WepSelectIcon
                        else
                            mat = Material(tostring(weapon2.WepSelectIcon), "smooth")
                        end
                    elseif weapon2.IconOverride then
                        mat = Material(weapon2.IconOverride, "smooth")
                    elseif weapon2.SelectIcon then
                        mat = Material(weapon2.SelectIcon, "smooth")
                    end

                    if mat then
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(mat)
                        local size = math.min(w - ScreenScale(2), h - ScreenScale(2))
                        surface.DrawTexturedRect((w - size) / 2, (h - size) / 2, size, size)
                        drawn = true
                    end
                end

                if not drawn and weapon2 and weapon2.WepSelectFont and weapon2.IconLetter then
                    draw.SimpleText(weapon2.IconLetter, weapon2.WepSelectFont, w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    drawn = true
                end

                if not drawn then
                    draw.SimpleText("?", "ZB_ScrappersMedium", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end

            slots[k].DoClick = function(this)
                self:DoClick(k)
            end
        end

        self.Paint = function(this, w, h)
            surface.SetDrawColor(red)
            surface.DrawOutlinedRect(0, 0, w, h, 2)

            surface.DrawRect(0, h - ScreenScale(10), w, ScreenScale(10))
            draw.SimpleText(self.text, "ZB_ScrappersMedium", ScreenScale(4), h - ScreenScale(11))
        end
    elseif weapon then
        local weapon2 = weapons.Get(weapon)

        self.icon = self:Add("DButton")
        self.icon:Dock(FILL)
        self.icon:SetText("")
        self.icon.DoClick = function(this)
            self:DoClick()
        end

        self.icon.Paint = function(this, w, h)
            local drawn = false
            if weapon2 and isfunction(weapon2.DrawWeaponSelection) then
                weapon2:DrawWeaponSelection(0, 0, w, h, 255)
                drawn = true
            end

            if not drawn and weapon2 then
                local mat
                if weapon2.WepSelectIcon then
                    if type(weapon2.WepSelectIcon) == "IMaterial" then
                        mat = weapon2.WepSelectIcon
                    else
                        mat = Material(tostring(weapon2.WepSelectIcon), "smooth")
                    end
                elseif weapon2.IconOverride then
                    mat = Material(weapon2.IconOverride, "smooth")
                elseif weapon2.SelectIcon then
                    mat = Material(weapon2.SelectIcon, "smooth")
                end

                if mat then
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(mat)
                    local size = math.min(w - ScreenScale(8), h - ScreenScale(24))
                    surface.DrawTexturedRect((w - size) / 2, (h - size) / 2, size, size)
                    drawn = true
                end
            end

            surface.SetDrawColor(red)
            surface.DrawOutlinedRect(0, 0, w, h, 2)

            if not drawn and weapon2 and weapon2.WepSelectFont and weapon2.IconLetter then
                draw.SimpleText(weapon2.IconLetter, weapon2.WepSelectFont, w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                drawn = true
            end

            if not drawn and weapon2 then
                draw.SimpleText(weapon2.PrintName or tostring(weapon), "ZB_ScrappersMedium", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            if weapon2 then
                draw.SimpleText(weapon2.PrintName, "ZB_ScrappersMedium", ScreenScale(4), ScreenScale(4))
            end

            surface.DrawRect(0, h - ScreenScale(10), w, ScreenScale(10))
            draw.SimpleText(self.text, "ZB_ScrappersMedium", ScreenScale(4), h - ScreenScale(11))
        end
    else
        self.Paint = function(this, w, h)
            surface.SetDrawColor(red)
            surface.DrawOutlinedRect(0, 0, w, h, 2)

            surface.DrawRect(0, h - ScreenScale(10), w, ScreenScale(10))
            draw.SimpleText(self.text, "ZB_ScrappersMedium", ScreenScale(4), h - ScreenScale(11))
        end
    end
end

vgui.Register("ZB_MainSlot", PANEL, "EditablePanel")
