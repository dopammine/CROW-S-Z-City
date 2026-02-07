MODE.name = "spineless_dm"

local MODE = MODE

local fighter = {
	objective = "I've fallen, and i can't get up!",
	name = "Spineless Fighter",
	color1 = Color(0,120,190)
}

function MODE:HUDPaint()
	if zb.ROUND_START + 20 > CurTime() then
		draw.SimpleText(string.FormattedTime(zb.ROUND_START + 20 - CurTime(), "%02i:%02i:%02i"), "ZB_HomicideMedium", sw * 0.5, sh * 0.75, Color(255,55,55), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
	end

	if not lply:Alive() then return end
	if zb.ROUND_START + 8.5 < CurTime() then return end
	zb.RemoveFade()
	local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)

	draw.SimpleText("Spineless Deathmatch", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0,162,255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local Rolename = fighter.name
	local ColorRole = fighter.color1
	ColorRole.a = 255 * fade
	draw.SimpleText("You are a " .. Rolename, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local Objective = fighter.objective
	local ColorObj = fighter.color1
	ColorObj.a = 255 * fade
	draw.SimpleText(Objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

