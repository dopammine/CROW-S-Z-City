MODE.name = "hideseek"

local MODE = MODE

local seekerInfo = {
	name = "a Seeker",
	objective = "Find and eliminate all hiders.",
	color1 = Color(220, 60, 60),
	color2 = Color(220, 60, 60)
}

local hiderInfo = {
	name = "a Hider",
	objective = "Hide and survive until time runs out.",
	color1 = Color(60, 140, 230),
	color2 = Color(60, 140, 230)
}

local waitSong
local waitFade = 0
local releasePlayed = false

local function IsSeeker(ply)
	if not IsValid(ply) then return false end
	if ply:GetNWBool("HS_Seeker", false) then return true end
	local role = ply.role
	if role and role.name == "Seeker" then return true end
	return ply:Team() == 0
end

net.Receive("hideseek_start", function()
	zb.RemoveFade()
	releasePlayed = false
	if IsValid(waitSong) then
		waitSong:Stop()
		waitSong = nil
	end
	waitFade = 0
	surface.PlaySound("zbattle/criresp.mp3")
	timer.Simple(3, function()
		local ply = LocalPlayer()
		if not IsValid(ply) or IsSeeker(ply) then return end
		sound.PlayFile("sound/zbattle/criresp/criepmission.mp3", "mono noblock", function(station)
			if IsValid(station) then
				station:Play()
				waitSong = station
				waitFade = 1
			end
		end)
	end)
end)

function MODE:RenderScreenspaceEffects()
	local ply = LocalPlayer()
	local hiding = GetGlobalBool("ZB_HS_HidingPhase", false)
	if IsValid(waitSong) and not hiding then
		if waitFade <= 0.01 then
			if not releasePlayed then
				surface.PlaySound(IsSeeker(ply) and "zbattle/criresp/barricadedsuspectstart.mp3" or "snd_jack_hmcd_policesiren.wav")
				releasePlayed = true
			end
			waitSong:Stop()
			waitSong = nil
		else
			waitFade = Lerp(0.01, waitFade, 0)
			waitSong:SetVolume(waitFade)
		end
	end
	if IsValid(ply) then
		if hiding and IsSeeker(ply) then
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
			return
		end
	end
	if zb.ROUND_START + 7.5 < CurTime() then return end
	local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(), 0, 1)
	surface.SetDrawColor(0, 0, 0, 255 * fade)
	surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end

function MODE:HUDPaint()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local hiding = GetGlobalBool("ZB_HS_HidingPhase", false)
	if not ply:Alive() and not (IsSeeker(ply) and hiding) then return end

	local sw, sh = ScrW(), ScrH()

	if zb.ROUND_START + 8.5 > CurTime() then
		zb.RemoveFade()
		local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)
		local isSeeker = IsSeeker(ply)
		local data = isSeeker and seekerInfo or hiderInfo
		local titleColor = Color(0, 162, 255, 255 * fade)
		draw.SimpleText("ZBattle | Hide and Seek", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local roleColor = data.color1
		roleColor.a = 255 * fade
		draw.SimpleText("You are " .. data.name, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, roleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local objColor = data.color2
		objColor.a = 255 * fade
		draw.SimpleText(data.objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, objColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local hideEnd = GetGlobalFloat("ZB_HS_HideEnd", 0)
	if hiding and hideEnd > CurTime() then
		local isSeeker = IsSeeker(ply)
		local timeLeft = math.max(0, hideEnd - CurTime())
		local timeText = string.FormattedTime(timeLeft, "%02i:%02i")
		local label = isSeeker and "You are released in " or "Seekers arrive in "
		local color = isSeeker and Color(220, 60, 60) or Color(60, 140, 230)
		draw.SimpleText(label .. timeText, "ZB_HomicideMedium", sw * 0.5, sh * 0.86, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local colGray = Color(85, 85, 85, 255)
local colSeeker = Color(170, 50, 50)
local colSeekerUp = Color(200, 70, 70)
local colHider = Color(50, 120, 200)
local colHiderUp = Color(70, 150, 230)
local col = Color(255, 255, 255, 255)
local colSpect1 = Color(75, 75, 75, 255)
local colSpect2 = Color(255, 255, 255)

local function WinnerText(winner)
	if winner == 0 then return "Seekers Win!" end
	if winner == 1 then return "Hiders Win!" end
	if winner == 2 then return "Time's Up! Hiders Win!" end
	return "Round Over"
end

local hsEndMenu
local CreateEndMenu

net.Receive("hideseek_roundend", function()
	local winner = net.ReadUInt(2)
	CreateEndMenu(winner)
end)

if IsValid(hsEndMenu) then
	hsEndMenu:Remove()
	hsEndMenu = nil
end

CreateEndMenu = function(winner)
	if IsValid(hsEndMenu) then
		hsEndMenu:Remove()
		hsEndMenu = nil
	end

	hsEndMenu = vgui.Create("ZFrame")
	local sizeX, sizeY = ScrW() / 2.6, ScrH() / 1.3
	local posX, posY = ScrW() / 2 - sizeX / 2, ScrH() / 2 - sizeY / 2
	hsEndMenu:SetPos(posX, posY)
	hsEndMenu:SetSize(sizeX, sizeY)
	hsEndMenu:MakePopup()
	hsEndMenu:SetKeyboardInputEnabled(false)
	hsEndMenu:ShowCloseButton(false)

	local closebutton = vgui.Create("DButton", hsEndMenu)
	closebutton:SetPos(5, 5)
	closebutton:SetSize(ScrW() / 20, ScrH() / 30)
	closebutton:SetText("")
	closebutton.DoClick = function()
		if IsValid(hsEndMenu) then
			hsEndMenu:Close()
			hsEndMenu = nil
		end
	end

	closebutton.Paint = function(self, w, h)
		surface.SetDrawColor(122, 122, 122, 255)
		surface.DrawOutlinedRect(0, 0, w, h, 2.5)
		surface.SetFont("ZB_InterfaceMedium")
		surface.SetTextColor(col.r, col.g, col.b, col.a)
		local lengthX = surface.GetTextSize("Close")
		surface.SetTextPos(lengthX - lengthX / 1.1, 4)
		surface.DrawText("Close")
	end

	hsEndMenu.PaintOver = function(self, w, h)
		local txt = WinnerText(winner)
		surface.SetFont("ZB_InterfaceMediumLarge")
		surface.SetTextColor(col.r, col.g, col.b, col.a)
		local lengthX = surface.GetTextSize(txt)
		surface.SetTextPos(w / 2 - lengthX / 2, 20)
		surface.DrawText(txt)
	end

	local DScrollPanel = vgui.Create("DScrollPanel", hsEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton", DScrollPanel)
		but:SetSize(100, 50)
		but:Dock(TOP)
		but:DockMargin(8, 6, 8, -1)
		but:SetText("")
		but.Paint = function(self, w, h)
			local isSeeker = ply:GetNWBool("HS_Seeker", false)
			local alive = ply:Alive() and not (ply.organism and ply.organism.incapacitated)
			local col1 = alive and (isSeeker and colSeeker or colHider) or colGray
			local col2 = alive and (isSeeker and colSeekerUp or colHiderUp) or colSpect1
			surface.SetDrawColor(col1.r, col1.g, col1.b, col1.a)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(col2.r, col2.g, col2.b, col2.a)
			surface.DrawRect(0, h / 2, w, h / 2)

			surface.SetFont("ZB_InterfaceMediumLarge")
			local name = ply:GetPlayerName() or "Unknown"
			local lengthX, lengthY = surface.GetTextSize(name)
			surface.SetTextColor(0, 0, 0, 255)
			surface.SetTextPos(w / 2 - lengthX / 2 + 1, h / 2 - lengthY / 2 + 1)
			surface.DrawText(name)
			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(w / 2 - lengthX / 2, h / 2 - lengthY / 2)
			surface.DrawText(name)

			local roleText = isSeeker and "Seeker" or "Hider"
			local statusText = alive and "alive" or "dead"
			local status = roleText .. " - " .. statusText
			surface.SetFont("ZB_InterfaceMedium")
			surface.SetTextColor(colSpect2.r, colSpect2.g, colSpect2.b, colSpect2.a)
			surface.SetTextPos(15, h / 2 - 10)
			surface.DrawText(status)
		end
		DScrollPanel:AddItem(but)
	end
end
