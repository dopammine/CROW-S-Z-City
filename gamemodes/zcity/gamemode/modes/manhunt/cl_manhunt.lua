local MODE = MODE

local function getRoleData()
	local lply = LocalPlayer()
	if not IsValid(lply) then return end

	local role = lply:GetNWString("PlayerRole", "")
	local hasDaniel = GetGlobalBool("Manhunt_HasDaniel", false)

	if role == "Leo Kasper" then
		return {
			name = "Leo Kasper",
			objective = hasDaniel and "Danny, listen, it's a MANHUNT, and they won't stop until we're both dead!" or "Dogs bark, babe. Snakes crawl. Leo kills. This is a surprise to you?",
			color1 = Color(220, 40, 40),
			color2 = Color(220, 40, 40),
		}
	end

	if role == "Daniel Lamb" then
		return {
			name = "Daniel Lamb",
			objective = "Without Leo, I wouldn't even be here.",
			color1 = Color(220, 40, 40),
			color2 = Color(220, 40, 40),
		}
	end

	if role == "Project Militia" then
		return {
			name = "Project Militia",
			objective = "Kill Leo at all costs.",
			color1 = Color(140, 200, 255),
			color2 = Color(140, 200, 255),
		}
	end

	return {
		name = "Watchdogs",
		objective = "Kill Leo at all costs.",
		color1 = Color(140, 200, 255),
		color2 = Color(140, 200, 255),
	}
end

function MODE:RenderScreenspaceEffects()
	if not IsValid(LocalPlayer()) then return end
	if LocalPlayer():GetNWBool("Manhunt_Blind", false) then
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
	end
end

function MODE:HUDPaint()
	local lply = LocalPlayer()
	if not IsValid(lply) then return end

	local sw, sh = ScrW(), ScrH()
	local roleData = getRoleData()
	if not roleData then return end

	if lply:GetNWBool("Manhunt_Blind", false) then
		local t = math.max((zb.ROUND_START + (MODE.HideTime or 15)) - CurTime(), 0)
		draw.SimpleText("Watchdogs deploy in: " .. string.FormattedTime(t, "%02i:%02i"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return
	end

	if zb.ROUND_START + 8.5 > CurTime() then
		zb.RemoveFade()

		local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)

		draw.SimpleText("ZCity | Manhunt", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(255, 255, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local c1 = roleData.color1
		c1.a = 255 * fade
		draw.SimpleText("You are " .. roleData.name, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, c1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local c2 = roleData.color2
		c2.a = 255 * fade
		draw.SimpleText(roleData.objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, c2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
