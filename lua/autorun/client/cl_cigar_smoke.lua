if CLIENT then
    net.Receive("HG_CigarSmoke", function()
        local pos = net.ReadVector()
        local vel = net.ReadVector()
        -- Slightly larger, thicker smoke than cigarette
        if CreateVFireSmokeTrail then
            CreateVFireSmokeTrail(
                pos,            -- follow (Vector ok)
                1.4,            -- lifeTime (emission total)
                0.035,          -- interval
                10,             -- startRadius (larger)
                28,             -- endRadius (larger)
                1.4,            -- startLength (particle die time)
                1.0,            -- endLength
                Vector(0, 0, 26), -- gravity up
                0.85,           -- resist
                0.0,            -- minRoll
                0.45,           -- maxRoll
                0,              -- minBright
                25,             -- maxBright (darker)
                140,            -- minAlpha
                220,            -- maxAlpha
                0.12            -- dieTimeNoise
            )
        else
            local ed = EffectData()
            ed:SetOrigin(pos)
            util.Effect("vfire_smoke_plume", ed, true, true)
        end
    end)
end
