local MODE = MODE

MODE.name = "bart_vs_homer"
MODE.PrintName = "Bart vs Homer"

local banner_until = 0
local yellow = Color(255, 217, 15)
local homer_entindex = 0
local endBannerUntil = 0
local winnerTeam = 0

net.Receive("barthomer_start", function()
    homer_entindex = net.ReadUInt(16) or 0
    banner_until = CurTime() + 8
    surface.PlaySound("homerround.mp3")
end)

-- round end uses tdm_roundend panel; keep minimal banner disabled

function MODE:RenderScreenspaceEffects()
    if zb and zb.ROUND_START and (zb.ROUND_START + 7.5 > CurTime()) then
        local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(), 0, 1)
        surface.SetDrawColor(0, 0, 0, 255 * fade)
        surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
    end
end

function MODE:HUDPaint()
    local w, h = ScrW(), ScrH()
    if zb and zb.ROUND_START and (zb.ROUND_START + 8.5 > CurTime()) then
        local ply = LocalPlayer()
        local isHomer = IsValid(ply) and (ply:EntIndex() == homer_entindex)
        local fade = math.Clamp(zb.ROUND_START + 8.0 - CurTime(), 0, 1)
        local title = "Bart vs Homer"
        draw.SimpleText(title, "ZB_InterfaceMediumLarge", w * 0.5, h * 0.1, Color(yellow.r, yellow.g, yellow.b, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        local role = isHomer and "You are Homer" or "You are Bart"
        draw.SimpleText(role, "ZB_InterfaceMediumLarge", w * 0.5, h * 0.5, Color(yellow.r, yellow.g, yellow.b, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        local objective = isHomer and "Grab and throw Barts; dominate the round." or "Work together to defeat Homer. Loot to gear up."
        draw.SimpleText(objective, "ZB_InterfaceMedium", w * 0.5, h * 0.9, Color(255, 255, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    if endBannerUntil > CurTime() and winnerTeam ~= 0 then
        local text = (winnerTeam == 2) and "Homer wins" or "Barts win"
        draw.SimpleText(text, "ZB_InterfaceMediumLarge", w * 0.5, h * 0.2, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end