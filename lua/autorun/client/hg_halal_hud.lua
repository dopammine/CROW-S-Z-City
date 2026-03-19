if not CLIENT then return end
local cvar = CreateClientConVar("hg_aprilfools", "0", true, false)
local col_bg = Color(0, 0, 0, 160)
local col_bar = Color(0, 180, 255, 220)
local col_text = Color(255, 255, 255, 220)
local zero_until = 0
local zero_alpha = 0
net.Receive("hg_halal_zero", function()
	zero_until = CurTime() + 6
end)
hook.Add("HUDPaint", "HG_HalalHUD", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	if not cvar:GetBool() and not GetGlobalBool("hg_aprilfools", false) then return end
	local v = ply:GetNWFloat("hg_halal", -1)
	if v < 0 then return end
	local w = 220
	local h = 20
	local x = ScrW() - w - 20
	local y = 20
	surface.SetDrawColor(col_bg)
	surface.DrawRect(x, y, w, h)
	local frac = math.Clamp(v / 100, 0, 1)
	surface.SetDrawColor(col_bar)
	surface.DrawRect(x + 2, y + 2, (w - 4) * frac, h - 4)
	draw.SimpleText("Halal "..math.floor(v).."%", "DermaDefaultBold", x + w / 2, y + h + 6, col_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	if zero_until > CurTime() then
		zero_alpha = Lerp(FrameTime() * 5, zero_alpha, 1)
	else
		zero_alpha = Lerp(FrameTime() * 2, zero_alpha, 0)
	end
	if zero_alpha > 0.01 then
		surface.SetDrawColor(255, 40, 40, math.floor(160 * zero_alpha))
		surface.DrawRect(0, 0, ScrW(), ScrH())
		draw.SimpleText("NOT HALAL", "DermaLarge", ScrW() / 2, ScrH() * 0.2, Color(255, 255, 255, math.floor(255 * zero_alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)
