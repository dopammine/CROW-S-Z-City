if CLIENT then
    local fadeUntil = 0
    local fadeStart = 0
    local fadeDuration = 0
    net.Receive("HG_CigarFade", function()
        local dur = net.ReadFloat() or 10
        fadeStart = CurTime()
        fadeDuration = math.max(dur, 0.1)
        fadeUntil = fadeStart + fadeDuration
    end)
	    hook.Add("HUDPaint", "HG_CigarFadeOverlay", function()
        if fadeUntil <= CurTime() then return end
        local t = CurTime() - fadeStart
        local half = fadeDuration * 0.5
        local alpha
        if t <= half then
	            alpha = math.Clamp(t / half, 0, 1) * 102 -- 40% of 255 ≈ 102
        else
	            alpha = math.Clamp(1 - ((t - half) / half), 0, 1) * 102
        end
	        -- 40% grey overlay (neutral gray tint)
	        surface.SetDrawColor(128, 128, 128, alpha)
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end)
end
