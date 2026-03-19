local MODE = MODE
MODE.name = "hmcd"

--\\Local Functions
local function screen_scale_2(num)
	return ScreenScale(num) / (ScrW() / ScrH())
end
--//

local visual_cvar = CLIENT and CreateClientConVar("hg_visualspmo", "1", true, false, "", 0, 1)

local killEffectEndTime = 0
local killEffectDuration = 1
local killEffectColor = 1
local manhuntEffectEndTime = 0
local manhuntEffectDuration = 6
local manhuntEffectColor = 1
local HMCD_FX_MUL = 1.5

function TriggerKillEffect()
	killEffectEndTime = CurTime() + killEffectDuration
end

local function TriggerManhuntEffect(duration)
	manhuntEffectDuration = duration or 6
	manhuntEffectEndTime = CurTime() + manhuntEffectDuration
end

net.Receive("HMCD_TriggerKillEffect", function()
	killEffectColor = net.ReadUInt(2)
	TriggerKillEffect()
end)

net.Receive("HG_TriggerManhuntEffect", function()
	manhuntEffectColor = net.ReadUInt(2)
	TriggerManhuntEffect(net.ReadFloat())
end)

hook.Add("HUDPaint", "HMCD_KillEffect", function()
	if visual_cvar and visual_cvar:GetBool() then return end
	if killEffectEndTime <= CurTime() then return end

	local w = math.Clamp((killEffectEndTime - CurTime()) / killEffectDuration, 0, 1)
	local sw, sh = ScrW(), ScrH()

	local r, g, b = 255, 255, 255
	if killEffectColor == 1 then
		r, g, b = 180, 30, 30
	elseif killEffectColor == 2 then
		r, g, b = 120, 0, 0
	end

	surface.SetDrawColor(r, g, b, math.min(255, 55 * w * HMCD_FX_MUL))
	surface.DrawRect(0, 0, sw, sh)

	local lines = math.floor(10 + 30 * w)
	for i = 1, lines do
		local y = math.random(0, sh - 2)
		local h = math.random(1, 2)
		local x = math.random(0, sw - 10)
		local ww = math.random(20, math.min(260, sw - x))
		surface.SetDrawColor(255, 255, 255, math.min(255, math.random(8, 28) * w * HMCD_FX_MUL))
		surface.DrawRect(x, y, ww, h)
	end

	local pixels = math.floor(120 + 320 * w)
	for i = 1, pixels do
		local bright = math.random(0, 255)
		surface.SetDrawColor(bright, bright, bright, math.min(255, 10 * w * HMCD_FX_MUL))
		surface.DrawRect(math.random(0, sw), math.random(0, sh), 1, 1)
	end
end)

hook.Add("HUDPaint", "HG_ManhuntEffect", function()
	if visual_cvar and visual_cvar:GetBool() then return end
	if manhuntEffectEndTime <= CurTime() then return end

	local w = math.Clamp((manhuntEffectEndTime - CurTime()) / manhuntEffectDuration, 0, 1)
	local sw, sh = ScrW(), ScrH()

	local r, g, b = 255, 255, 255
	if manhuntEffectColor == 1 then
		r, g, b = 180, 30, 30
	elseif manhuntEffectColor == 2 then
		r, g, b = 120, 0, 0
	end

	surface.SetDrawColor(r, g, b, math.min(255, 65 * w * HMCD_FX_MUL))
	surface.DrawRect(0, 0, sw, sh)

	local lines = math.floor(10 + 30 * w)
	for i = 1, lines do
		local y = math.random(0, sh - 2)
		local h = math.random(1, 2)
		local x = math.random(0, sw - 10)
		local ww = math.random(20, math.min(260, sw - x))
		surface.SetDrawColor(255, 255, 255, math.min(255, math.random(10, 34) * w * HMCD_FX_MUL))
		surface.DrawRect(x, y, ww, h)
	end

	local pixels = math.floor(120 + 320 * w)
	for i = 1, pixels do
		local bright = math.random(0, 255)
		surface.SetDrawColor(bright, bright, bright, math.min(255, 12 * w * HMCD_FX_MUL))
		surface.DrawRect(math.random(0, sw), math.random(0, sh), 1, 1)
	end
end)

hook.Add("RenderScreenspaceEffects", "HG_ManhuntEffect", function()
	if visual_cvar and visual_cvar:GetBool() then return end
	if manhuntEffectEndTime <= CurTime() then return end
	local w = math.Clamp((manhuntEffectEndTime - CurTime()) / manhuntEffectDuration, 0, 1)

	DrawMotionBlur(0.08 * w * HMCD_FX_MUL, 0.9 * w * HMCD_FX_MUL, 0.01)
	DrawToyTown(2.5 * w * HMCD_FX_MUL, 1.5 * ScrH())
	DrawSharpen(1.5 * w * HMCD_FX_MUL, 1)

	DrawColorModify({
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = -0.6 * w,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0,
	})
end)

MODE.TypeSounds = {
	["standard"] = {"snd_jack_hmcd_psycho.mp3","snd_jack_hmcd_shining.mp3"},
	["soe"] = "snd_jack_hmcd_disaster.mp3",
	["gunfreezone"] = "snd_jack_hmcd_panic.mp3" ,
	["suicidelunatic"] = "zbattle/jihadmode.mp3",
	["wildwest"] = "snd_jack_hmcd_wildwest.mp3",
	["supermario"] = "snd_jack_hmcd_psycho.mp3"
}
local fade = 0
net.Receive("HMCD_RoundStart",function()
	for i, ply in player.Iterator() do
		ply.isTraitor = false
		ply.isGunner = false
	end

	--\\
	lply.isTraitor = net.ReadBool()
	lply.isGunner = net.ReadBool()
	MODE.Type = net.ReadString()
	local screen_time_is_default = net.ReadBool()
	lply.SubRole = net.ReadString()
	lply.MainTraitor = net.ReadBool()
	MODE.TraitorWord = net.ReadString()
	MODE.TraitorWordSecond = net.ReadString()
	MODE.TraitorExpectedAmt = net.ReadUInt(MODE.TraitorExpectedAmtBits)
	StartTime = CurTime()
	MODE.TraitorsLocal = {}

	if(lply.isTraitor and screen_time_is_default)then
		if(MODE.TraitorExpectedAmt == 1)then
			chat.AddText("You are alone on your mission.")
		else
			if(MODE.TraitorExpectedAmt == 2)then
				chat.AddText("You have 1 accomplice")
			else
				chat.AddText("There are(is) " .. MODE.TraitorExpectedAmt - 1 .. " traitor(s) besides you")
			end

			chat.AddText("Traitor secret words are: \"" .. MODE.TraitorWord .. "\" and \"" .. MODE.TraitorWordSecond .. "\".")
		end

		if(lply.MainTraitor)then
			if(MODE.TraitorExpectedAmt > 1)then
				chat.AddText("Traitor names (only you, as a main traitor can see them):")
			end

			for key = 1, MODE.TraitorExpectedAmt do
				local traitor_info = {net.ReadColor(false), net.ReadString()}

				if(MODE.TraitorExpectedAmt > 1)then
					MODE.TraitorsLocal[#MODE.TraitorsLocal + 1] = traitor_info

					chat.AddText(traitor_info[1], "\t" .. traitor_info[2])
				end
			end
		end
	end

	lply.Profession = net.ReadString()
	--//

	if(MODE.RoleChooseRoundTypes[MODE.Type] and !screen_time_is_default)then
		MODE.DynamicFadeScreenEndTime = CurTime() + MODE.RoleChooseRoundStartTime
	else
		MODE.DynamicFadeScreenEndTime = CurTime() + MODE.DefaultRoundStartTime
	end

	MODE.RoleEndedChosingState = screen_time_is_default

	if(screen_time_is_default)then
		if istable(MODE.TypeSounds[MODE.Type]) then
			surface.PlaySound(table.Random(MODE.TypeSounds[MODE.Type]))
		else
			surface.PlaySound(MODE.TypeSounds[MODE.Type])
		end
	end

	fade = 0
end)

MODE.TypeNames = {
	["standard"] = "Standard",
	["soe"] = "State of Emergency",
	["gunfreezone"] = "Gun Free Zone",
	["suicidelunatic"] = "Suicide Lunatic",
	["wildwest"] = "Wild west",
	["supermario"] = "Super Mario"
}

--local hg_coolvetica = ConVarExists("hg_coolvetica") and GetConVar("hg_coolvetica") or CreateClientConVar("hg_coolvetica", "0", true, false, "changes every text to coolvetica because its good", 0, 1)
local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", "Bahnschrift", true, false, "change every text font to selected because ui customization is cool")
local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Bahnschrift"
    local usefont = "Bahnschrift"

    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end

    return usefont
end

surface.CreateFont("ZB_HomicideSmall", {
	font = font(),
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideMedium", {
	font = font(),
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideMediumLarge", {
	font = font(),
	size = ScreenScale(25),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideLarge", {
	font = font(),
	size = ScreenScale(30),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideHumongous", {
	font = font(),
	size = 255,
	weight = 400,
	antialias = true
})

MODE.TypeObjectives = {}
MODE.TypeObjectives.soe = {
	traitor = {
		objective = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
		name = "a Traitor",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "You are an innocent with a hunting weapon. Find and neutralize the traitor before it's too late.",
		name = "an Innocent",
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = "You are an innocent, rely only on yourself, but stick around with crowds to make traitor's job harder.",
		name = "an Innocent",
		color1 = Color(0,120,190)
	},
}

MODE.TypeObjectives.standard = {
	traitor = {
		objective = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
		name = "a Murderer",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "You are a bystander with a concealed firearm. You've tasked yourself to help police find the criminal faster.",
		name = "a Bystander",
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = "You are a bystander of a murder scene, although it didn't happen to you, you better be cautious.",
		name = "a Bystander",
		color1 = Color(0,120,190)
	},
}

MODE.TypeObjectives.wildwest = {
	traitor = {
		objective = "This town ain't that big for all of us.",
		name = "The Killer",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "You're the sheriff of this town. You gotta find and kill the lawless bastard.",
		name = "The Sheriff",
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = "We gotta get justice served over here, there's a lawless prick murdering men.",
		name = "a Fellow Cowboy",
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},
}

MODE.TypeObjectives.gunfreezone = {
	traitor = {
		objective = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
		name = "a Murderer",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "You are a bystander of a murder scene, although it didn't happen to you, you better be cautious.",
		name = "a Bystander",
		color1 = Color(0,120,190)
	},

	innocent = {
		objective = "You are a bystander of a murder scene, although it didn't happen to you, you better be cautious.",
		name = "a Bystander",
		color1 = Color(0,120,190)
	},
}

MODE.TypeObjectives.suicidelunatic = {
	traitor = {
		objective = "My brother insha'Allah, don't let him down.",
		name = "a Shahid",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "Sheep fucker's gone crazy, now you need to survive.",
		name = "an Innocent",
		color1 = Color(0,120,190)
	},

	innocent = {
		objective = "Sheep fucker's gone crazy, now you need to survive.",
		name = "an Innocent",
		color1 = Color(0,120,190)
	},
}


MODE.TypeObjectives.supermario = {
	traitor = {
		objective = "You're the evil Mario! Jump around and take down everyone.",
		name = "Traitor Mario",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = "You're the hero Mario! Use your jumping ability to stop the traitor.",
		name = "Hero Mario",
		color1 = Color(158,0,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = "You're a bystander Mario, survive and avoid the traitor's traps!",
		name = "Innocent Mario",
		color1 = Color(0,120,190)
	},
}

function MODE:RenderScreenspaceEffects()
	-- MODE.DynamicFadeScreenEndTime = MODE.DynamicFadeScreenEndTime or 0
	fade_end_time = MODE.DynamicFadeScreenEndTime or 0
	local time_diff = fade_end_time - CurTime()

	if(time_diff > 0)then
		zb.RemoveFade()

		local fade = math.min(time_diff / MODE.FadeScreenTime, 1)

		surface.SetDrawColor(0, 0, 0, 255 * fade)
		surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1 )
	end

	-- respect hg_visualspmo: 1 disables homicide manhunt/kill visuals, 0 enables
	if (not visual_cvar or not visual_cvar:GetBool()) and killEffectEndTime > CurTime() then
		local w = math.Clamp((killEffectEndTime - CurTime()) / killEffectDuration, 0, 1)
		DrawMotionBlur(0.08 * w, 0.9 * w, 0.01)
		DrawToyTown(2.5 * w, 1.5 * ScrH())
		DrawSharpen(1.5 * w, 1)
	end
end

local handicap = {
	[1] = "You are handicapped: your right leg is broken.",
	[2] = "You are handicapped: you are suffering from severe obesity.",
	[3] = "You are handicapped: you are suffering from hemophilia.",
	[4] = "You are handicapped: you are physically incapacitated."
}

function MODE:HUDPaint()
	if not MODE.Type or not MODE.TypeObjectives[MODE.Type] then return end
	if lply:Team() == TEAM_SPECTATOR then return end
	if StartTime + 12 < CurTime() then return end
	
	fade = Lerp(FrameTime()*1, fade, math.Clamp(StartTime + 5 - CurTime(),-2,2))

	draw.SimpleText("Homicide | " .. (MODE.TypeNames[MODE.Type] or "Unknown"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0,162,255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local Rolename = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.name ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.name ) or MODE.TypeObjectives[MODE.Type].innocent.name
	local ColorRole = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.color1 ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.color1 ) or MODE.TypeObjectives[MODE.Type].innocent.color1
	ColorRole.a = 255 * fade

	local color_role_innocent = MODE.TypeObjectives[MODE.Type].innocent.color1
	color_role_innocent.a = 255 * fade

	local color_white_faded = Color(255, 255, 255, 255 * fade)
	color_white_faded.a = 255 * fade

	draw.SimpleText("You are "..Rolename , "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)



	local cur_y = sh * 0.5

	-- local ColorRole = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.color1 ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.color1 ) or MODE.TypeObjectives[MODE.Type].innocent.color1
	-- ColorRole.a = 255 * fade
	if(lply.SubRole and lply.SubRole != "")then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText("" .. ((MODE.SubRoles[lply.SubRole] and MODE.SubRoles[lply.SubRole].Name or lply.SubRole) or lply.SubRole), "ZB_HomicideMediumLarge", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if(!lply.MainTraitor and lply.isTraitor)then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText("Assistant", "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end


	if(lply.isTraitor)then
		cur_y = cur_y + ScreenScale(20)

		if(lply.MainTraitor)then
			MODE.TraitorsLocal = MODE.TraitorsLocal or {}

			if(#MODE.TraitorsLocal > 1)then
				draw.SimpleText("Traitors list:", "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				for _, traitor_info in ipairs(MODE.TraitorsLocal) do
					local traitor_color = Color(traitor_info[1].r, traitor_info[1].g, traitor_info[1].b, 255 * fade)
					cur_y = cur_y + ScreenScale(15)

					draw.SimpleText(traitor_info[2], "ZB_HomicideMedium", sw * 0.5, cur_y, traitor_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		else
			draw.SimpleText("Traitor secret words:", "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			cur_y = cur_y + ScreenScale(15)

			draw.SimpleText("\"" .. MODE.TraitorWord .. "\"", "ZB_HomicideMedium", sw * 0.5, cur_y, color_white_faded, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			cur_y = cur_y + ScreenScale(15)

			draw.SimpleText("\"" .. MODE.TraitorWordSecond .. "\"", "ZB_HomicideMedium", sw * 0.5, cur_y, color_white_faded, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	if(lply.Profession and lply.Profession != "")then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText("Occupation: " .. ((MODE.Professions[lply.Profession] and MODE.Professions[lply.Profession].Name or lply.Profession) or lply.Profession), "ZB_HomicideMedium", sw * 0.5, cur_y, color_role_innocent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	if(handicap[lply:GetLocalVar("karma_sickness", 0)])then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText(handicap[lply:GetLocalVar("karma_sickness", 0)], "ZB_HomicideMedium", sw * 0.5, cur_y, color_role_innocent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local Objective = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.objective ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.objective ) or MODE.TypeObjectives[MODE.Type].innocent.objective

	if(lply.SubRole and lply.SubRole != "")then
		if(MODE.SubRoles[lply.SubRole] and MODE.SubRoles[lply.SubRole].Objective)then
			Objective = MODE.SubRoles[lply.SubRole].Objective
		end
	end

	if(!lply.MainTraitor and lply.isTraitor)then
		Objective = "You are equipped with nothing. Help other traitors win."
	end

	--; WARNING Traitor's objective is not lined up with SubRole's
	if(!MODE.RoleEndedChosingState)then
		Objective = "Round is starting..."
	end

	local ColorObj = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.color2 ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.color2 ) or MODE.TypeObjectives[MODE.Type].innocent.color2 or Color(255,255,255)
	ColorObj.a = 255 * fade
	draw.SimpleText( Objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if hg.PluvTown.Active then
		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * fade / 2)
		surface.DrawTexturedRect(sw * 0.25, sh * 0.44 - ScreenScale(15), sw / 2, ScreenScale(30))

		draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2, sh * 0.44 - ScreenScale(2), Color(0, 0, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local CreateEndMenu

net.Receive("hmcd_roundend", function()
	local traitors, gunners = {}, {}

	for key = 1, net.ReadUInt(MODE.TraitorExpectedAmtBits) do
		local traitor = net.ReadEntity()
		traitors[key] = traitor
		traitor.isTraitor = true
	end

	for key = 1, net.ReadUInt(MODE.TraitorExpectedAmtBits) do
		local gunner = net.ReadEntity()
		gunners[key] = gunner
		gunner.isGunner = true
	end

	timer.Simple(2.5, function()


		lply.isPolice = false
		lply.isTraitor = false
		lply.isGunner = false
		lply.MainTraitor = false
		lply.SubRole = nil
		lply.Profession = nil
	end)

	traitor = traitors[1] or Entity(0)

	CreateEndMenu(traitor)
end)

surface.CreateFont("TraitorPanelTitle", {
	font = "coolvetica",
	size = 22,
	weight = 500,
	antialias = true
})

surface.CreateFont("TraitorPanelText", {
	font = "coolvetica",
	size = 19,
	weight = 500,
	antialias = true
})

surface.CreateFont("TraitorPanelWords", {
	font = "coolvetica",
	size = 24,
	weight = 700,
	antialias = true,
	italic = false
})

local traitor_panel = {
    assistants = {},
    dead_anim = {},
    width = 300,
    height = 280,
    assist_height = 200,
    spacing = 26,
    padding = 15,
    left_padding = 90,
    avatar_size = 24,
    fade_speed = 3,
    instance = nil,
    visible = true,
    target_x = 0,
    smooth_toggle = 0,
    alpha = 255,
    last_toggle_time = 0,
    toggle_cooldown = 0.3,
    assistant_status_cache = {},
    assistant_avatars = {},
    colors = {
        bg = Color(30, 0, 0, 230),
        border = Color(180, 0, 0, 255),
        border_inner = Color(90, 0, 0, 150),
        title = Color(255, 255, 255, 255),
        words = Color(255, 80, 80, 255),
        assistant = Color(200, 70, 70, 255)
    }
}

local function CreateAvatarPanel(steamid)
    if not steamid or steamid == "" then return nil end
    if traitor_panel.assistant_avatars[steamid] and IsValid(traitor_panel.assistant_avatars[steamid]) then
        return traitor_panel.assistant_avatars[steamid]
    end
    local avatar = vgui.Create("AvatarImage")
    avatar:SetSize(traitor_panel.avatar_size, traitor_panel.avatar_size)
    avatar:SetVisible(false)
    local ply = player.GetBySteamID(steamid)
    if IsValid(ply) then
        avatar:SetPlayer(ply, traitor_panel.avatar_size)
    end
    traitor_panel.assistant_avatars[steamid] = avatar
    return avatar
end

hook.Add("PlayerButtonDown", "TraitorPanelToggle", function(ply, btn)
    if ply ~= LocalPlayer() or btn ~= KEY_F4 then return end
    if not LocalPlayer().isTraitor then return end
    local current_time = CurTime()
    if current_time - traitor_panel.last_toggle_time < traitor_panel.toggle_cooldown then
        return
    end
    traitor_panel.last_toggle_time = current_time
    traitor_panel.visible = not traitor_panel.visible
    if traitor_panel.visible then
        surface.PlaySound("buttons/button14.wav")
    end
end)

net.Receive("HMCD_UpdateTraitorAssistants", function()
    local count = net.ReadUInt(8)
    MODE.TraitorsLocal = {}
    for i = 1, count do
        local color = net.ReadColor()
        local name = net.ReadString()
        local steamID = net.ReadString()
        table.insert(MODE.TraitorsLocal, {color, name, steamID})
    end
end)

net.Receive("HMCD_TraitorDeathState", function()
    local traitor_name = net.ReadString()
    local is_alive = net.ReadBool()
    if traitor_name and traitor_name ~= "" then
        traitor_panel.assistant_status_cache[traitor_name] = is_alive
    end
end)

hook.Add("HUDPaint", "DrawTraitorPanel", function()
    local ply = LocalPlayer()
    if not ply.isTraitor or not ply:Alive() then
        traitor_panel.visible = false
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
        return
    end
    local target = traitor_panel.visible and 0 or traitor_panel.width + 40
    traitor_panel.smooth_toggle = Lerp(FrameTime() * 10, traitor_panel.smooth_toggle, target)
    local is_main = ply.MainTraitor
    local height = is_main and traitor_panel.height or traitor_panel.assist_height
    local x = ScrW() - traitor_panel.width - 20 + traitor_panel.smooth_toggle
    local y = ScrH() / 2 - (height / 2)
    if traitor_panel.smooth_toggle > traitor_panel.width + 30 then
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
        return
    end
    draw.RoundedBox(6, x, y, traitor_panel.width, height, traitor_panel.colors.bg)
    surface.SetDrawColor(traitor_panel.colors.border_inner)
    surface.DrawOutlinedRect(x + 3, y + 3, traitor_panel.width - 6, height - 6, 1)
    surface.SetDrawColor(traitor_panel.colors.border)
    surface.DrawOutlinedRect(x, y, traitor_panel.width, height, 2)
    local title = is_main and "MAIN TRAITOR" or "ASSISTANT"
    draw.SimpleText(title, "TraitorPanelTitle", x + traitor_panel.width/2, y + 15, traitor_panel.colors.title, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    surface.SetDrawColor(traitor_panel.colors.border)
    surface.DrawLine(x + 15, y + 30, x + traitor_panel.width - 15, y + 30)
    draw.SimpleText("Press F4 to toggle panel", "TraitorPanelText", x + traitor_panel.width/2, y + 42, Color(180, 180, 180, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local word_y = y + 65
    draw.SimpleText("Secret Words:", "TraitorPanelText", x + traitor_panel.width/2, word_y, Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    word_y = word_y + 25
    local word1 = MODE.TraitorWord or "???"
    draw.SimpleText(word1, "TraitorPanelWords", x + traitor_panel.width/2, word_y, traitor_panel.colors.words, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    word_y = word_y + 30
    local word2 = MODE.TraitorWordSecond or "???"
    draw.SimpleText(word2, "TraitorPanelWords", x + traitor_panel.width/2, word_y, traitor_panel.colors.words, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    if is_main then
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
        local assist_y = y + 150
        MODE.TraitorsLocal = MODE.TraitorsLocal or {}
        draw.SimpleText("Traitor Team:", "TraitorPanelText", x + traitor_panel.width/2, assist_y, Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        assist_y = assist_y + 25
        for _, traitor_info in ipairs(MODE.TraitorsLocal) do
            if not traitor_info or #traitor_info < 2 then continue end
            if ply.MainTraitor and ply.CurAppearance and traitor_info[2] == ply.CurAppearance.AName then
                continue
            end
            local color = traitor_info[1]
            local name = traitor_info[2]
            local steamID = traitor_info[3] or ""
            local player_found = nil
            for _, v in player.Iterator() do
                if v.isTraitor and v.CurAppearance and v.CurAppearance.AName == name then
                    player_found = v
                    break
                end
            end
            local is_alive = true
            if traitor_panel.assistant_status_cache[name] == false then
                is_alive = false
            end
            if player_found then
                is_alive = player_found:Alive() and (not player_found.organism or not player_found.organism.incapacitated)
                traitor_panel.assistant_status_cache[name] = is_alive
            end
            if not is_alive then
                traitor_panel.dead_anim[name] = traitor_panel.dead_anim[name] or 255
                traitor_panel.dead_anim[name] = math.max(traitor_panel.dead_anim[name] - FrameTime() * 100 * traitor_panel.fade_speed, 0)
                if traitor_panel.dead_anim[name] <= 0 then continue end
            else
                traitor_panel.dead_anim[name] = nil
            end
            local alpha = traitor_panel.dead_anim[name] or 255
            local display_color = is_alive and color or Color(150, 150, 150)
            display_color = Color(display_color.r, display_color.g, display_color.b, alpha)
            local status = is_alive and "" or " [DEAD]"
            local display_name = name
            if #name > 20 then
                display_name = string.sub(name, 1, 18) .. ".."
            end
            if steamID and steamID ~= "" then
                local avatar_player = player.GetBySteamID(steamID)
                if IsValid(avatar_player) then
                    local avatar = CreateAvatarPanel(steamID)
                    if avatar then
                        avatar:SetPos(x + 15, assist_y - traitor_panel.avatar_size/2)
                        avatar:SetSize(traitor_panel.avatar_size, traitor_panel.avatar_size)
                        avatar:SetAlpha(alpha)
                        avatar:SetVisible(true)
                        surface.SetDrawColor(50, 50, 50, alpha)
                        surface.DrawOutlinedRect(x + 15, assist_y - traitor_panel.avatar_size/2, traitor_panel.avatar_size, traitor_panel.avatar_size, 1)
                    end
                end
            end
            draw.SimpleText(display_name..status, "TraitorPanelText", x + traitor_panel.left_padding, assist_y, display_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            assist_y = assist_y + 25
            if assist_y > y + height - 30 then
                break
            end
        end
    else
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
    end
end)

hook.Add("PostPlayerDeath", "ClearTraitorPanel", function(ply)
    if ply == LocalPlayer() then
        traitor_panel.dead_anim = {}
        traitor_panel.smooth_toggle = 0
        traitor_panel.visible = false
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
    end
end)

hook.Add("Think", "UpdateTraitorAssistants", function()
	if not LocalPlayer().isTraitor then return end
	if not traitor_panel.next_assistant_check or traitor_panel.next_assistant_check < CurTime() then
		traitor_panel.next_assistant_check = CurTime() + 0.5
		for name, alpha in pairs(traitor_panel.dead_anim) do
			local is_alive = false
			for _, v in player.Iterator() do
				if v.isTraitor and v.CurAppearance and v.CurAppearance.AName == name then
					is_alive = v:Alive() and (not v.organism or not v.organism.incapacitated)
					break
				end
			end
			if is_alive then
				traitor_panel.dead_anim[name] = nil
			end
		end
	end
end)

hook.Add("Think", "RequestTraitorStatus", function()
	if not LocalPlayer().isTraitor then return end
	if not traitor_panel.next_status_request or traitor_panel.next_status_request < CurTime() then
		traitor_panel.next_status_request = CurTime() + 2
		net.Start("HMCD_RequestTraitorStatuses")
		net.SendToServer()
	end
end)
net.Receive("hmcd_announce_traitor_lose", function()
	local traitor = net.ReadEntity()
	local traitor_alive = net.ReadBool()

	if(IsValid(traitor))then
		chat.AddText(color_white, "Traitor ", traitor:GetPlayerColor():ToColor(), traitor:GetPlayerName() .. ", " .. traitor:Nick(), color_white, " was " .. (traitor_alive and "arrested." or "killed."))
	end
end)

local colGray = Color(85,85,85)
local colRed = Color(130,10,10)
local colRedUp = Color(160,30,30)

local colBlue = Color(10,10,160)
local colBlueUp = Color(40,40,160)
local col = Color(255,255,255,255)

local colSpect1 = Color(75,75,75,255)
local colSpect2 = Color(255,255,255)

local colorBG = Color(55,55,55,255)
local colorBGBlacky = Color(40,40,40,255)

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

BlurBackground = BlurBackground or hg.DrawBlur

if IsValid(hmcdEndMenu) then
	hmcdEndMenu:Remove()
	hmcdEndMenu = nil
end

CreateEndMenu = function(traitor)
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end

	Dynamic = 0
	hmcdEndMenu = vgui.Create("ZFrame")

	if !IsValid(hmcdEndMenu) then return end

	local players = {}

	local traitorName = IsValid(traitor) and traitor:GetPlayerName() or "unknown"
	local traitorNick = IsValid(traitor) and traitor:Nick() or "unknown"

	for i, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if !IsValid(ply) then return end
		
		players[#players + 1] = {
			nick = ply:Nick(),
			name = ply:GetPlayerName(),
			isTraitor = ply.isTraitor,
			isGunner = ply.isGunner,
			incapacitated = ply.organism and ply.organism.otrub,
			alive = ply:Alive(),
			col = ply:GetPlayerColor():ToColor(),
			frags = ply:Frags(),
			steamid = ply:IsBot() and "BOT" or ply:SteamID64(),
		}
	end

	surface.PlaySound("ambient/alarms/warningbell1.wav")

	local sizeX,sizeY = ScrW() / 2.5, ScrH() / 1.2
	local posX,posY = ScrW() / 1.3 - sizeX / 2, ScrH() / 2 - sizeY / 2

	hmcdEndMenu:SetPos(posX, posY)
	hmcdEndMenu:SetSize(sizeX, sizeY)
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:SetKeyboardInputEnabled(false)
	hmcdEndMenu:ShowCloseButton(false)

	local closebutton = vgui.Create("DButton", hmcdEndMenu)
	closebutton:SetPos(5, 5)
	closebutton:SetSize(ScrW() / 20, ScrH() / 30)
	closebutton:SetText("")

	closebutton.DoClick = function()
		if IsValid(hmcdEndMenu) then
			hmcdEndMenu:Close()
			hmcdEndMenu = nil
		end
	end

	closebutton.Paint = function(self,w,h)
		surface.SetDrawColor(122, 122, 122, 255)
		surface.DrawOutlinedRect(0, 0, w, h, 2.5)
		surface.SetFont("ZB_InterfaceMedium")
		surface.SetTextColor(col.r, col.g, col.b, col.a)
		local lengthX, lengthY = surface.GetTextSize("Close")
		surface.SetTextPos(lengthX - lengthX / 1.1, 4)
		surface.DrawText("Close")
	end

	hmcdEndMenu.PaintOver = function(self,w,h)
		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize(traitorName .. " was a traitor ("..traitorNick..")")
		surface.SetTextPos(w / 2 - lengthX / 2, 20)
		surface.DrawText(traitorName .. " was a traitor ("..traitorNick..")")
	end

	-- PLAYERS
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)

	for i, info in ipairs(players) do
		local but = vgui.Create("DButton",DScrollPanel)

		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")

		but.Paint = function(self,w,h)
			local col1 = (info.isTraitor and colRed) or (info.alive and colBlue) or colGray
			local col2 = info.isTraitor and (info.alive and colRedUp or colSpect1) or ((info.alive and !info.incapacitated) and colBlueUp) or colSpect1
			local name = info.nick
			surface.SetDrawColor(col1.r, col1.g, col1.b, col1.a)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(col2.r, col2.g, col2.b, col2.a)
			surface.DrawRect(0, h / 2, w, h / 2)

			local col = info.col
			surface.SetFont("ZB_InterfaceMediumLarge")
			local lengthX, lengthY = surface.GetTextSize(name)

			surface.SetTextColor(0, 0, 0, 255)
			surface.SetTextPos(w / 2 + 1, h / 2 - lengthY / 2 + 1)
			surface.DrawText(name)

			surface.SetTextColor(col.r, col.g, col.b, col.a)
			surface.SetTextPos(w / 2, h / 2 - lengthY / 2)
			surface.DrawText(name)


			local col = colSpect2
			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize(info.name)
			surface.SetTextPos(15, h / 2 - lengthY / 2)
			surface.DrawText(info.name .. ((!info.alive and " - died") or (info.incapacitated and " - incapacitated") or ""))

			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(col.r, col.g, col.b, col.a)
			local lengthX, lengthY = surface.GetTextSize(info.frags)
			surface.SetTextPos(w - lengthX -15,h/2 - lengthY/2)
			surface.DrawText(info.frags)
		end

		function but:DoClick()
			if info.steamid == "BOT" then chat.AddText(Color(255, 0, 0), "That's a bot.") return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..info.steamid)
		end

		DScrollPanel:AddItem(but)
	end

	return true
end

function MODE:RoundStart()
	-- if IsValid(hmcdEndMenu) then
	-- 	hmcdEndMenu:Remove()
	-- 	hmcdEndMenu = nil
	-- end
end

--\\
net.Receive("HMCD(StartPlayersRoleSelection)", function()
	local role = net.ReadString()

	hg.SelectPlayerRole(role)
end)

function hg.SelectPlayerRole(role, mode)
	role = role or "Traitor"
	mode = mode or "soe"

	if(IsValid(VGUI_HMCD_RolePanelList))then
		VGUI_HMCD_RolePanelList:Remove()
	end

	if(MODE.RoleChooseRoundTypes[mode])then
		//VGUI_HMCD_RolePanelList = vgui.Create("ZB_TraitorSelectionMenu")
		//VGUI_HMCD_RolePanelList:Center()
		VGUI_HMCD_RolePanelList = vgui.Create("HMCD_RolePanelList")
		VGUI_HMCD_RolePanelList.RolesIDsList = MODE.RoleChooseRoundTypes[mode][role]	--; WARNING TCP Reroute
		VGUI_HMCD_RolePanelList.Mode = mode
		-- VGUI_HMCD_RolePanelList:SetSize(ScreenScale(600), ScreenScale(300))
		VGUI_HMCD_RolePanelList:SetSize(screen_scale_2(700), screen_scale_2(300))
		VGUI_HMCD_RolePanelList:Center()
		VGUI_HMCD_RolePanelList:InvalidateParent(false)
		VGUI_HMCD_RolePanelList:Construct()
		VGUI_HMCD_RolePanelList:MakePopup()
	end
end

function hg.OpenCTRMenu()
	if IsValid(VGUI_HMCD_CTRPanel) then
		VGUI_HMCD_CTRPanel:Remove()
	end

	VGUI_HMCD_CTRPanel = vgui.Create("HMCD_CTRPanel")
	VGUI_HMCD_CTRPanel:SetSize(screen_scale_2(720), screen_scale_2(520))
	VGUI_HMCD_CTRPanel:Center()
	VGUI_HMCD_CTRPanel:InvalidateParent(false)
	VGUI_HMCD_CTRPanel:Construct()
	VGUI_HMCD_CTRPanel:MakePopup()
end

net.Receive("HMCD(EndPlayersRoleSelection)", function()
	if(IsValid(VGUI_HMCD_RolePanelList))then
		VGUI_HMCD_RolePanelList:Remove()
	end
end)

net.Receive("HMCD(SetSubRole)", function(len, ply)
	lply.SubRole = net.ReadString()
end)
--//

--CreateEndMenu()
