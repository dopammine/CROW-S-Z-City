if CLIENT then
	net.Receive("HG_CigaretteSmoke", function()
		local pos = net.ReadVector()
		local vel = net.ReadVector()
		-- Small dark grey smoke puff that floats then disappears ~1s
		-- Prefer direct trail call with explicit min/max roll to avoid param mismatch
		if CreateVFireSmokeTrail then
			CreateVFireSmokeTrail(
				pos,            -- follow (Vector ok)
				1.0,            -- lifeTime (emission total)
				0.04,           -- interval
				6,              -- startRadius
				20,             -- endRadius
				1.2,            -- startLength (die time of new particles)
				0.8,            -- endLength (die time of older particles)
				Vector(0, 0, 22), -- gravity up
				0.9,            -- resist
				0.0,            -- minRoll
				0.4,            -- maxRoll
				0,              -- minBright
				30,             -- maxBright
				120,            -- minAlpha
				200,            -- maxAlpha
				0.1             -- dieTimeNoise
			)
		else
			-- Basic fallback
			local ed = EffectData()
			ed:SetOrigin(pos)
			util.Effect("vfire_smoke_plume", ed, true, true)
		end
	end)
end
