MODE.name = "bart_vs_homer"

local MODE = MODE

local roundEndTime = 0
local winnerTeam = ""
local endData = {}
local bvhEndMenu

net.Receive("bvh_roundend", function()
    winnerTeam = net.ReadString() or ""
    endData = net.ReadTable() or {}
    roundEndTime = CurTime()

    if MODE and MODE.CreateEndMenu then
        MODE:CreateEndMenu()
    end
end)


net.Receive("bvh_roundstart", function()
    surface.PlaySound("bartman.wav")
end)

function MODE:RenderScreenspaceEffects()
    if zb.ROUND_START + 7.5 < CurTime() then return end
    local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(), 0, 1)

    surface.SetDrawColor(0, 0, 0, 255 * fade)
    surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end

function MODE:HUDPaint()
    if not lply:Alive() then return end

    if zb.ROUND_START + 8.5 >= CurTime() then
        zb.RemoveFade()
        local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)

        local roleName = nil
        local class = lply.PlayerClassName or (lply.GetPlayerClass and lply:GetPlayerClass())
        if class == "homer" then
            roleName = "Homer"
        elseif class == "bart" then
            roleName = "Bart"
        else
            local role = lply.role
            if role and role.name and role.name ~= "Player" then
                roleName = role.name
            end
        end

        draw.SimpleText("ZCity | Bart VS Homer", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0, 162, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if roleName then
            draw.SimpleText("You are " .. roleName, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, Color(255, 217, 15, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        draw.SimpleText("KILL HOMER OR BART FUCKING LOSESERRRRR", "ZB_HomicideMedium", sw * 0.5, sh * 0.9, Color(255, 255, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if roundEndTime > 0 then
        local elapsed = CurTime() - roundEndTime
        if elapsed > 8 then
            roundEndTime = 0
            winnerTeam = ""
            return
        end

        local fade = 1
        if elapsed > 4 then
            fade = math.Clamp(1 - (elapsed - 4) / 4, 0, 1)
        end

        local text = "Round over."
        if winnerTeam == "homer" then
            text = "Homer wins!"
        elseif winnerTeam == "barts" then
            text = "Barts win!"
        end

        draw.SimpleText(text, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.4, Color(255, 217, 15, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function MODE:CreateEndMenu()
    if IsValid(bvhEndMenu) then
        bvhEndMenu:Remove()
        bvhEndMenu = nil
    end

    bvhEndMenu = vgui.Create("ZFrame")

    local sizeX, sizeY = ScrW() / 2.5, ScrH() / 1.2
    local posX, posY = ScrW() / 1.3 - sizeX / 2, ScrH() / 2 - sizeY / 2

    bvhEndMenu:SetPos(posX, posY)
    bvhEndMenu:SetSize(sizeX, sizeY)
    bvhEndMenu:MakePopup()
    bvhEndMenu:SetKeyboardInputEnabled(false)
    bvhEndMenu:ShowCloseButton(false)

    local closeButton = vgui.Create("DButton", bvhEndMenu)
    closeButton:SetPos(5, 5)
    closeButton:SetSize(ScrW() / 20, ScrH() / 30)
    closeButton:SetText("")

    closeButton.DoClick = function()
        if IsValid(bvhEndMenu) then
            bvhEndMenu:Close()
            bvhEndMenu = nil
        end
    end

    closeButton.Paint = function(self, w, h)
        surface.SetDrawColor(122, 122, 122, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        surface.SetFont("ZB_InterfaceMedium")
        surface.SetTextColor(255, 255, 255, 255)
        local text = "Close"
        local lengthX, lengthY = surface.GetTextSize(text)
        surface.SetTextPos(w / 2 - lengthX / 2, h / 2 - lengthY / 2)
        surface.DrawText(text)
    end

    bvhEndMenu.PaintOver = function(self, w, h)
        local title = "Bart VS Homer"
        if winnerTeam == "homer" then
            title = "Homer wins!"
        elseif winnerTeam == "barts" then
            title = "Barts win!"
        end

        surface.SetFont("ZB_InterfaceMediumLarge")
        surface.SetTextColor(255, 255, 255, 255)
        local lengthX, lengthY = surface.GetTextSize(title)
        surface.SetTextPos(w / 2 - lengthX / 2, 20)
        surface.DrawText(title)
    end

    local scroll = vgui.Create("DScrollPanel", bvhEndMenu)
    scroll:SetPos(10, 80)
    scroll:SetSize(sizeX - 20, sizeY - 90)

    for _, info in ipairs(endData or {}) do
        local row = vgui.Create("DButton", scroll)
        row:SetSize(100, 50)
        row:Dock(TOP)
        row:DockMargin(8, 6, 8, -1)
        row:SetText("")

        row.Paint = function(self, w, h)
            local isHomer = info.role == "homer"
            local isBart = info.role == "bart"
            local isWinner = (winnerTeam == "homer" and isHomer) or (winnerTeam == "barts" and isBart)

            local bgTop
            local bgBottom

            if isWinner then
                bgTop = Color(217, 201, 99, 255)
                bgBottom = Color(207, 181, 59, 255)
            elseif info.alive then
                bgTop = Color(10, 10, 160, 255)
                bgBottom = Color(40, 40, 160, 255)
            else
                bgTop = Color(85, 85, 85, 255)
                bgBottom = Color(75, 75, 75, 255)
            end

            surface.SetDrawColor(bgTop.r, bgTop.g, bgTop.b, bgTop.a)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(bgBottom.r, bgBottom.g, bgBottom.b, bgBottom.a)
            surface.DrawRect(0, h / 2, w, h / 2)

            surface.SetFont("ZB_InterfaceMediumLarge")

            local statusRole = "Unknown"
            if isHomer then
                statusRole = "Homer"
            elseif isBart then
                statusRole = "Bart"
            end

            local status = statusRole
            if info.alive == false then
                status = statusRole .. " - died"
            else
                status = statusRole .. " - alive"
            end

            local leftText = info.name or info.nick or "Unknown"
            local rightText = tostring(info.frags or 0)

            surface.SetTextColor(0, 0, 0, 255)
            local lengthX, lengthY = surface.GetTextSize(leftText)
            surface.SetTextPos(w / 2 + 1, h / 2 - lengthY / 2 + 1)
            surface.DrawText(leftText)

            surface.SetTextColor(255, 255, 255, 255)
            surface.SetTextPos(w / 2, h / 2 - lengthY / 2)
            surface.DrawText(leftText)

            surface.SetTextColor(255, 255, 255, 255)
            local statusLengthX, statusLengthY = surface.GetTextSize(status)
            surface.SetTextPos(15, h / 2 - statusLengthY / 2)
            surface.DrawText(status)

            local fragsLengthX, fragsLengthY = surface.GetTextSize(rightText)
            surface.SetTextPos(w - fragsLengthX - 15, h / 2 - fragsLengthY / 2)
            surface.DrawText(rightText)
        end

        scroll:AddItem(row)
    end
end

function MODE:RoundStart()
    endData = {}
    winnerTeam = ""
    roundEndTime = 0

    if IsValid(bvhEndMenu) then
        bvhEndMenu:Remove()
        bvhEndMenu = nil
    end
end
