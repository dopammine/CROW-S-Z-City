include("shared.lua")

local scaryTexts = {
    "MOVE AWAY FROM IT",
    "LEAVE LEAVE LEAVE",
    "RUN FOR YOUR LIFE",
    "RUN NOW",
    "IT'S DANGEROUS",
    "DON'T LOOK BACK",
    "IT'S COMING",
    "YOU ARE NOT SAFE"
}

function ENT:Draw()
    self:DrawModel()
end

local function DrawScaryText()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local pluvs = ents.FindByClass("ent_scary_pluv")
    local closestPluv = nil
    local minDist = 2000 * 2000
    
    for _, pluv in ipairs(pluvs) do
        local dist = ply:GetPos():DistToSqr(pluv:GetPos())
        if dist < minDist then
            minDist = dist
            closestPluv = pluv
        end
    end

    if not IsValid(closestPluv) then return end
    
    local isChasing = closestPluv:GetChasing()
    local target = closestPluv:GetTarget()
    local closeRange = 500 * 500
    
    if (isChasing and target == ply) or minDist < closeRange then
        local maxDist = 1500 * 1500
        local intensity = 1 - (minDist / maxDist)
        
        if isChasing and target == ply then
            intensity = intensity + 0.3
        end
        
        intensity = math.Clamp(intensity, 0, 1)
        
        if intensity <= 0.1 then return end

        surface.SetFont("DermaLarge")
        
        local col = math.sin(CurTime() * 10) > 0 and Color(255, 0, 0) or Color(255, 255, 255)
        surface.SetTextColor(col.r, col.g, col.b, 255 * intensity)
        
        local count = math.floor(intensity * 15) + 1
        
        for i = 1, count do
            local text = scaryTexts[math.random(#scaryTexts)]
            local w, h = surface.GetTextSize(text)
            
            local x = math.random(ScrW() - w)
            local y = math.random(ScrH() - h)
            
            local shakeAmt = intensity * 20
            x = x + math.random(-shakeAmt, shakeAmt)
            y = y + math.random(-shakeAmt, shakeAmt)
            
            surface.SetTextPos(x, y)
            surface.DrawText(text)
        end
    end
end

hook.Add("HUDPaint", "ScaryPluvText", DrawScaryText)

local function DrawScaryContrast()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local pluvs = ents.FindByClass("ent_scary_pluv")
    local closestPluv = nil
    local minDist = 2000 * 2000
    
    for _, pluv in ipairs(pluvs) do
        local dist = ply:GetPos():DistToSqr(pluv:GetPos())
        if dist < minDist then
            minDist = dist
            closestPluv = pluv
        end
    end

    if not IsValid(closestPluv) then return end
    
    local isChasing = closestPluv:GetChasing()
    local target = closestPluv:GetTarget()
    local closeRange = 500 * 500
    
    if (isChasing and target == ply) or minDist < closeRange then
        local maxDist = 1500 * 1500
        local intensity = 1 - (minDist / maxDist)
        
        if isChasing and target == ply then
            intensity = intensity + 0.3
        end
        
        intensity = math.Clamp(intensity, 0, 1)
        
        if intensity <= 0.1 then return end
        
        local contrast = 1 - (intensity * 0.8) -- Lower contrast as intensity increases
        local saturation = math.Clamp(1 - intensity, 0, 1) -- Lower saturation (greyer) as intensity increases
        
        local tab = {
            [ "$pp_colour_addr" ] = 0,
            [ "$pp_colour_addg" ] = 0,
            [ "$pp_colour_addb" ] = 0,
            [ "$pp_colour_brightness" ] = 0,
            [ "$pp_colour_contrast" ] = contrast,
            [ "$pp_colour_colour" ] = saturation,
            [ "$pp_colour_mulr" ] = 0,
            [ "$pp_colour_mulg" ] = 0,
            [ "$pp_colour_mulb" ] = 0
        }
        
        DrawColorModify( tab )
    end
end

hook.Add("RenderScreenspaceEffects", "ScaryPluvContrast", DrawScaryContrast)
