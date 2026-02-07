MODE.name = "genocide"

local MODE = MODE

local roundend = false
local fighter = {
	objective = "Kill everyone. Search in containers and find big guns.",
	name = "Traitor",
	color1 = Color(200, 50, 50)
}

net.Receive("genocide_start", function()
	roundend = false
	zb.RemoveFade()
end)

net.Receive("genocide_end", function()
	local winner = net.ReadEntity()
	roundend = CurTime()

	if IsValid(winner) then
		chat.AddText(Color(200, 50, 50), "", color_white, winner:Nick() .. " is the last one standing.")
	else
		chat.AddText(Color(200, 50, 50), "", color_white, "Nobody survived.")
	end
end)

function MODE:HUDPaint()
	if zb.ROUND_START + 20 > CurTime() then
		draw.SimpleText(
			string.FormattedTime(zb.ROUND_START + 20 - CurTime(), "%02i:%02i:%02i"),
			"ZB_HomicideMedium",
			sw * 0.5,
			sh * 0.75,
			Color(255, 55, 55),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end

	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end
	if zb.ROUND_START + 8.5 < CurTime() then return end

	zb.RemoveFade()
	local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)

	draw.SimpleText(
		"Genocide",
		"ZB_HomicideMediumLarge",
		sw * 0.5,
		sh * 0.1,
		Color(200, 50, 50, 255 * fade),
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER
	)

	local roleName = fighter.name
	local colorRole = fighter.color1
	colorRole.a = 255 * fade
	draw.SimpleText(
		"You are a " .. roleName,
		"ZB_HomicideMediumLarge",
		sw * 0.5,
		sh * 0.5,
		colorRole,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER
	)

	local objective = fighter.objective
	local colorObj = fighter.color1
	colorObj.a = 255 * fade
	draw.SimpleText(
		objective,
		"ZB_HomicideMedium",
		sw * 0.5,
		sh * 0.9,
		colorObj,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER
	)
end
