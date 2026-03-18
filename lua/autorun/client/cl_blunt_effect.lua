local endTime = 0
local alpha = 0
local segLen = 3.0
local music
local MUSIC_PATH_DEFAULT = "sound/becauseigothigh.mp3"
local MUSIC_PATH_ALT = "sound/420.mp3"
local chosenPath = nil
local TARGET_VOL = 0.3

hook.Add("Think", "HG_Blunt_Update", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	if not ply:Alive() or ply:Team() == TEAM_SPECTATOR then
		endTime = 0
		alpha = 0
		if IsValid(music) then music:Stop() music = nil end
	else
		endTime = ply:GetNetVar("blunt_high_until", 0) or 0
		-- music management
		local shouldPlay = endTime > CurTime()
		if shouldPlay then
			if not IsValid(music) then
				if not chosenPath then
					chosenPath = (math.random(100) <= 50) and MUSIC_PATH_ALT or MUSIC_PATH_DEFAULT
				end
				sound.PlayFile(chosenPath, "noplay noblock", function(audio)
					if IsValid(audio) then
						audio:SetVolume(0)
						audio:EnableLooping(true)
						audio:Play()
						music = audio
					end
				end)
			end
			if IsValid(music) then
				local vol = (ply.organism and ply.organism.otrub) and 0 or TARGET_VOL
				music:SetVolume(vol)
			end
		else
			if IsValid(music) then music:Stop() music = nil end
			chosenPath = nil
		end
	end
end)

hook.Add("RenderScreenspaceEffects", "HG_BluntRainbow", function()
	if endTime <= CurTime() then return end
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() or ply:Team() == TEAM_SPECTATOR then return end

	local total = 70
	local left = math.max(endTime - CurTime(), 0)
	local frac = math.Clamp(left / total, 0, 1)
	local targetAlpha = 0.35 * frac
	alpha = Lerp(FrameTime() * 5, alpha, targetAlpha)

	local palette = {
		{r = 10, g = 50, b = 10},
		{r = 30, g = 90, b = 30},
		{r = 45, g = 150, b = 45},
		{r = 60, g = 200, b = 60},
	}
	local phase = CurTime() / segLen
	local i = math.floor(phase) % #palette
	local n = (i + 1) % #palette
	local t = phase - math.floor(phase)
	local c1 = palette[i + 1]
	local c2 = palette[n + 1]
	local r = Lerp(t, c1.r, c2.r)
	local g = Lerp(t, c1.g, c2.g)
	local b = Lerp(t, c1.b, c2.b)

	surface.SetDrawColor(r, g, b, math.floor(255 * alpha))
	surface.DrawRect(0, 0, ScrW(), ScrH())
end)

hook.Add("ZB_EndRound", "HG_BluntMusic_Stop", function()
	if IsValid(music) then music:Stop() music = nil end
end)

hook.Add("ShutDown", "HG_BluntMusic_Stop", function()
	if IsValid(music) then music:Stop() music = nil end
end)
