if not CLIENT then return end

local function aprilFoolsEnabled()
	local cvar = GetConVar("hg_aprilfools")
	if cvar then
		return cvar:GetBool()
	end
	return GetGlobalBool("hg_aprilfools", false)
end

local function getRawDraw()
	if hg and hg.arabicRaw and hg.arabicRaw.draw_SimpleText then
		return hg.arabicRaw.draw_SimpleText
	end
	return draw.SimpleText
end

local warningUntil = 0
local warningStart = 0
net.Receive("hg_halal_zero", function()
	warningStart = CurTime()
	warningUntil = warningStart + 6
end)

hook.Add("HUDPaint", "hg_halal_bar", function()
	if not aprilFoolsEnabled() then return end
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local halal = ply:GetNWFloat("hg_halal", 100)
	ply.hg_halal_lerp = Lerp(FrameTime() * 6, ply.hg_halal_lerp or halal, halal)
	local w = ScreenScale(10)
	local h = ScreenScale(200)
	local x = ScrW() - w - ScreenScale(24)
	local y = ScrH() * 0.5 - h * 0.5

	local rawDrawText = getRawDraw()
	rawDrawText("HALAL BAR", "ZCity_Tiny", x + w * 0.5, y - ScreenScaleH(10), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	draw.RoundedBox(6, x, y, w, h, Color(20, 20, 20, 200))
	draw.RoundedBox(6, x - 1, y - 1, w + 2, h + 2, Color(0, 0, 0, 255))
	draw.RoundedBox(6, x + 1, y + 1, w - 2, h - 2, Color(0, 0, 0, 255))
	local fill = math.Clamp((ply.hg_halal_lerp or halal) / 100, 0, 1)
	local low = 1 - math.Clamp(fill / 0.35, 0, 1)
	local barColor = Color(255 * low + 0 * (1 - low), 200 * (1 - low) + 60 * low, 100 * (1 - low) + 60 * low, 230)
	draw.RoundedBox(6, x, y + (1 - fill) * h, w, h * fill, barColor)

	local now = CurTime()
	if now < warningUntil then
		local t = math.Clamp((now - warningStart) / 0.6, 0, 1)
		local shake = (1 - t) * 6
		local sx = math.sin(now * 28) * shake
		local sy = math.cos(now * 24) * shake
		local scale = 1 + t * 0.6
		local cx, cy = ScrW() * 0.5, ScrH() * 0.2
		local mat = Matrix()
		mat:Translate(Vector(cx, cy, 0))
		mat:Scale(Vector(scale, scale, 1))
		mat:Translate(Vector(-cx, -cy, 0))
		cam.PushModelMatrix(mat)
			local alpha = math.Clamp(255 * t, 0, 255)
			rawDrawText("SO NOT HALAL MODE", "ZCity_Big", cx + sx + 2, cy + sy + 2, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			rawDrawText("SO NOT HALAL MODE", "ZCity_Big", cx + sx, cy + sy, Color(255, 75, 75, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			rawDrawText("NUKE INCOMING", "ZCity_Small", cx + sx + 2, cy + sy + ScreenScaleH(24) + 2, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			rawDrawText("NUKE INCOMING", "ZCity_Small", cx + sx, cy + sy + ScreenScaleH(24), Color(255, 106, 86, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.PopModelMatrix()
	end
end)
