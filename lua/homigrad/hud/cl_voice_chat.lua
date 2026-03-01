hg = hg or {}
hg.VoiceIndicator = hg.VoiceIndicator or {}
local VI = hg.VoiceIndicator

VI.Speakers = VI.Speakers or {}

local accent = Color(40, 120, 220)
local bg = Color(0, 0, 0)
local gradient = Material("vgui/gradient-d")

local function draw_text_shadow(text, font, x, y, color, alpha)
	draw.DrawText(text, font, x + 2, y + 2, ColorAlpha(bg, 200 * alpha), TEXT_ALIGN_LEFT)
	draw.DrawText(text, font, x, y, ColorAlpha(color, 255 * alpha), TEXT_ALIGN_LEFT)
end

hook.Add("PlayerStartVoice", "hg_voice_indicator_start", function(ply)
	if not IsValid(ply) then return end
	local data = VI.Speakers[ply] or {}
	data.active = true
	data.alpha = data.alpha or 0
	data.last = CurTime()
	if not IsValid(data.avatar) then
		data.avatar = vgui.Create("AvatarImage")
		data.avatar:SetPlayer(ply, 32)
		data.avatar:SetPaintedManually(true)
	end
	VI.Speakers[ply] = data
end)

hook.Add("PlayerEndVoice", "hg_voice_indicator_end", function(ply)
	local data = VI.Speakers[ply]
	if not data then return end
	data.active = false
	data.last = CurTime()
end)

hook.Add("HUDPaint", "hg_voice_indicator_draw", function()
	local entries = {}
	for ply, data in pairs(VI.Speakers) do
		if not IsValid(ply) then
			if IsValid(data.avatar) then
				data.avatar:Remove()
			end
			VI.Speakers[ply] = nil
		else
			local is_speaking = ply:IsSpeaking()
			data.active = is_speaking
			data.alpha = LerpFT(0.2, data.alpha or 0, is_speaking and 1 or 0)
			if data.alpha < 0.01 and not data.active then
				if IsValid(data.avatar) then
					data.avatar:Remove()
				end
				VI.Speakers[ply] = nil
			else
				entries[#entries + 1] = {ply = ply, data = data}
			end
		end
	end

	if #entries == 0 then return end
	if IsValid(g_VoicePanelList) then
		g_VoicePanelList:SetVisible(false)
	end

	surface.SetFont("HomigradFontSmall")
	local padding = ScreenScale(4)
	local line_h = ScreenScale(16)
	local avatar_size = line_h - ScreenScale(2)
	local max_w = ScreenScale(90)
	for _, entry in ipairs(entries) do
		local name = entry.ply:Nick()
		local tw = surface.GetTextSize(name)
		max_w = math.max(max_w, tw + padding * 3 + avatar_size + ScreenScale(8))
	end

	local x = ScrW() - max_w - ScreenScale(12)
	local y = ScrH() - (#entries * (line_h + ScreenScale(3))) - ScreenScale(24)

	for i, entry in ipairs(entries) do
		local alpha = entry.data.alpha or 0
		local shake_x = entry.data.active and math.sin(CurTime() * 28 + entry.ply:EntIndex()) * ScreenScale(1) or 0
		local shake_y = entry.data.active and math.cos(CurTime() * 24 + entry.ply:EntIndex()) * ScreenScale(1) or 0
		local row_y = y + (i - 1) * (line_h + ScreenScale(3)) + shake_y

		draw.RoundedBox(0, x + shake_x, row_y, max_w, line_h, ColorAlpha(bg, 200 * alpha))
		surface.SetDrawColor(40, 120, 220, 180 * alpha)
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(x + shake_x, row_y, max_w, line_h)
		draw.RoundedBox(0, x + shake_x, row_y, ScreenScale(2), line_h, ColorAlpha(accent, 220 * alpha))

		if IsValid(entry.data.avatar) then
			entry.data.avatar:SetSize(avatar_size, avatar_size)
			entry.data.avatar:SetPos(x + shake_x + padding, row_y + ScreenScale(1))
			entry.data.avatar:PaintManual()
		end

		local text_x = x + shake_x + padding * 2 + avatar_size
		local text_y = row_y + line_h * 0.5 - ScreenScale(6)
		draw_text_shadow(entry.ply:Nick(), "HomigradFontSmall", text_x, text_y, color_white, alpha)
	end
end)
