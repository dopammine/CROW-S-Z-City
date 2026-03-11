--; Haus in Neu Berlin


local function ScreenGrab(ply, target, file_name)
	ply.ScreenGrabTime = CurTime() + 60
	target.ScreenGrab_FileName = file_name
	target.ScreenGrabber = ply
	target.sg = ply
	ply.sg = target
	ply.screengrabTarget = target
	ply.screengrabTimeout = CurTime() + 20
	target.ZNetLoad_Immunity = true
	
	net.Start("beScreenGrabStart")
	net.WriteEntity(ply)
	net.Send(target)

	ply:PrintMessage(HUD_PRINTTALK, "Starting screengrab on: " .. target:Nick())
end

if(SERVER)then
	ZScreenGrab = ZScreenGrab or {}

	local NWStrings = {
		"ZScreengrabRequest",
		"ZScreengrabRequestAll",
		"StartScreengrab",
		"ScreengrabInitCallback",
		"ScreengrabConfirmation",
		"ScreengrabSendPart",
		"SendPartBack",
		"ScreengrabFinished",
		-- "rtxappend",
		-- "rtxappend2",
		"Progress",
		"ScreengrabInterrupted"
	}
	for k, v in next, NWStrings do
		util.AddNetworkString( v )
	end
	
	local meta = FindMetaTable( "Player" )
	
	function meta:CanScreengrab()
		return self:IsAdmin()
	end
	
	util.AddNetworkString( "bScreenGrabStop" )
	util.AddNetworkString( "beScreenGrabFailed" )
	util.AddNetworkString( "beScreenGrabStart" )
	util.AddNetworkString( "bScreengrabSendPart" )
	util.AddNetworkString( "bSendPartBack" )
	util.AddNetworkString("ZScreenGrabAntiESPToggle")
	util.AddNetworkString("ZAntiESPRequest")

	function ZScreenGrab.ToggleAntiESPForPlayer(ply, state)
		ply.ZScreenGrab_AntiESP_Enabled = state
		
		net.Start("ZScreenGrabAntiESPToggle")
			net.WriteBool(state)
		net.Send(ply)
		
		if(DOG and DOG.ACheat)then
			DOG.ACheat.SetAntiESPList(ply:SteamID(), state)
			DOG.SendAntiESPListChangeToAdmins(ply:SteamID(), state)
		end
	end

	local function ResetScreengrabState(ply)
		if not IsValid(ply) then return end
		local target = ply.screengrabTarget
		if IsValid(target) then
			target.ZNetLoad_Immunity = false
			target.ScreenGrabber = nil
			target.sg = nil
		end
		ply.sg = nil
		ply.screengrabTarget = nil
		ply.screengrabTimeout = nil
		ply.screengrabBusy = nil
	end

	local function QueueScreengrab(ply, target, file_name)
		ply.screengrabQueue = ply.screengrabQueue or {}
		ply.screengrabQueue[#ply.screengrabQueue + 1] = {
			target = target,
			name = file_name
		}
	end

	local function StartNextScreengrab(ply)
		if not IsValid(ply) or ply.screengrabBusy then return end
		local queue = ply.screengrabQueue
		if not queue or #queue == 0 then
			ply.screengrabQueue = nil
			return
		end
		local nextItem = table.remove(queue, 1)
		if not nextItem or not IsValid(nextItem.target) then
			ply.screengrabBusy = nil
			return StartNextScreengrab(ply)
		end
		ply.screengrabBusy = true
		ScreenGrab(ply, nextItem.target, nextItem.name)
		local timerName = "hg_screengrab_timeout_" .. ply:EntIndex()
		timer.Remove(timerName)
		timer.Create(timerName, 1, 0, function()
			if not IsValid(ply) then
				timer.Remove(timerName)
				return
			end
			if not ply.screengrabBusy or not ply.screengrabTimeout then
				timer.Remove(timerName)
				return
			end
			if ply.screengrabTimeout <= CurTime() then
				ResetScreengrabState(ply)
				StartNextScreengrab(ply)
				timer.Remove(timerName)
			end
		end)
	end

	net.Receive( "ScreengrabInitCallback", function( _, ply )
		local tosend = net.ReadEntity()
		local parts = net.ReadUInt( 32 )
		local len = net.ReadUInt( 32 )
		local time = net.ReadFloat()
		ply.parts = parts
		ply.data = {}
		ply.IsSending = true
		net.Start( "ScreengrabConfirmation" )
			net.WriteUInt( parts, 32 )
			net.WriteUInt( len, 32 )
			net.WriteFloat( time )
			net.WriteEntity( ply )
			net.WriteString( ply.ScreenGrab_FileName or "" )
		net.Send( tosend )
	end )
	
	net.Receive( "ZScreengrabRequest", function( len, ply )
		local targ_name = net.ReadString()
		local file_name = net.ReadString()
		
		if !ply:IsAdmin() then return end
		local target, err = ULib.getUser(targ_name)

		if !target then
			if(err)then
				ply:ChatPrint(err)
			else
				ply:ChatPrint("Не найден игрок")
			end
			
			return
		end

		if ply.screengrabBusy and (not IsValid(ply.sg) or (ply.screengrabTimeout and ply.screengrabTimeout <= CurTime())) then
			ResetScreengrabState(ply)
		end
		QueueScreengrab(ply, target, file_name)
		StartNextScreengrab(ply)
	end)

	net.Receive( "ZScreengrabRequestAll", function( len, ply )
		local file_name = net.ReadString()
		if !ply:IsAdmin() then return end
		if ply.screengrabBusy and (not IsValid(ply.sg) or (ply.screengrabTimeout and ply.screengrabTimeout <= CurTime())) then
			ResetScreengrabState(ply)
		end
		for _, target in player.Iterator() do
			local name = file_name
			if name ~= "" then
				name = name .. "_" .. target:SteamID64()
			end
			QueueScreengrab(ply, target, name)
		end
		StartNextScreengrab(ply)
	end)
	
	net.Receive("ZAntiESPRequest", function( len, ply )
		local targ_name = net.ReadString()
		local state = net.ReadBool()
		
		if !ply:IsAdmin() then return end
		local target, err = ULib.getUser(targ_name)

		if !target then
			if(err)then
				ply:ChatPrint(err)
			else
				ply:ChatPrint("Не найден игрок")
			end
			
			return
		end

		ZScreenGrab.ToggleAntiESPForPlayer(target, state)
	end)
	
	net.Receive( "ScreengrabFinished", function( _, ply )
		local _ply = ply.sg
		_ply.parts = nil
		_ply.data = nil
		ply.parts = nil
		ply.data = nil
		_ply.sg = nil
		ply.sg = nil
		ply.isgrabbing = nil
		_ply.isgrabbing = nil
		_ply.ZNetLoad_Immunity = false
		ply.screengrabTarget = nil
		ply.screengrabTimeout = nil
		ply.screengrabBusy = nil
		StartNextScreengrab(ply)
		-- ply:rtxappend( sg.green, "Finished" )
	end )

	net.Receive( "bScreengrabSendPart", function( len, ply )
		local sendto = ply.sg
		local len = net.ReadUInt( 32 )
		local data = net.ReadData( len )
		
		if not ply.data then
			ply.data = {}
			ply.data[ 1 ] = data
			--sendto:rtxappend( sg.blue, "Received 1st part" )
		else
			local num = #( ply.data ) + 1
			ply.data[ num ] = data
			--sendto:rtxappend( sg.blue, "Received " .. num .. STNDRD( num ) .. " part" )
		end
		
		if #( ply.data ) == ply.parts then
			ply.IsSending = nil
			--sendto:rtxappend( sg.green, "Preparing to send data [" .. ply.parts .. " parts]" )
			local i = 1
			
			timer.Create( "SendDataBack", 0.1, ply.parts, function()
				net.Start( "bSendPartBack" )
					local x = ply.data[ i ]:len()
					net.WriteUInt( x, 32 )
					net.WriteData( ply.data[ i ], x )
				net.Send( sendto )
				
				i = i + 1
			end )
		end
	end )
	 
	net.Receive( "beScreenGrabFailed", function( len, ply )
		if !IsValid( ply.ScreenGrabber ) then return end
	 
		local str = "Ошибка скринграба у " .. ply:Nick() .. ". " .. net.ReadString()
		
		ply.ScreenGrabber:PrintMessage(HUD_PRINTTALK, str)
		ResetScreengrabState(ply.ScreenGrabber)
		StartNextScreengrab(ply.ScreenGrabber)
		-- ply.ScreenGrabber = nil --; Вернуть когда нужно
	end )
	 
	 
	 
	hook.Add( "PlayerSay", "ScreenGrabChat", function( ply, text )
		if !ply:IsAdmin() then return end
		text = string.Explode( " ", string.lower( text ) )
	 
		if text[1] == "!screengrab" then
			local target, err = ULib.getUser( text[2] )
	 
			if !target then
				if(err)then
					ply:ChatPrint(err)
				else
					ply:ChatPrint("Не найден игрок")
				end
				
				return
			end
			
			timer.Simple(1.2, function()
				ScreenGrab(ply, target, text[3])
			end)

			return ""
		end
	end )
	
	hook.Add( "PlayerDisconnected", "ScreengrabInterrupt", function( ply )
		if ply.IsSending then
			local _ply = ply.sg
			_ply.parts = nil
			_ply.data = nil
			ply.parts = nil
			ply.data = nil
			_ply.sg = nil
			ply.sg = nil
			ply.isgrabbing = nil
			_ply.isgrabbing = nil
			_ply:rtxappend( sg.red, "Target disconnected before their data finished sending" )
			net.Start( "ScreengrabInterrupted" )
			net.Send( _ply )
			ResetScreengrabState(_ply)
			StartNextScreengrab(_ply)
		end
	end )
else
	local function onAutoComplete(command, input)
		input = input:Trim():lower()
		local suggestions = {}

		for _ , ply in player.Iterator() do
			local suggestion = command .. ' "' .. ply:Nick() .. '"'
			suggestions[#suggestions + 1] = suggestion
		end

		return suggestions
	end

	concommand.Add("screengrab", function(ply, cmd, args)
		if !ply:IsAdmin() then return end

		net.Start("ZScreengrabRequest")
			net.WriteString(args[1])
			net.WriteString(args[2] or "")
		net.SendToServer()
	end, onAutoComplete)

	concommand.Add("screengrab_all", function(ply, cmd, args)
		if !ply:IsAdmin() then return end

		net.Start("ZScreengrabRequestAll")
			net.WriteString(args[1] or "")
		net.SendToServer()
	end)
	
	concommand.Add("screengrab_antiesp_player", function(ply, cmd, args)
		if !ply:IsAdmin() then return end

		net.Start("ZAntiESPRequest")
			net.WriteString(args[1])
			net.WriteBool(tobool(args[2] or ""))
		net.SendToServer()
	end, onAutoComplete)

	local function DisplayData(str, name)
		local elapsedtime
		if not name then
			elapsedtime = math.Round( LocalPlayer().EndTime - LocalPlayer().StartTime, 3 )
		end
		local main = vgui.Create( "DFrame", vgui.GetWorldPanel() )
		main:SetPos( 0, 0 )
		main:SetSize( ScrW(), ScrH() )
		if not name then
			main:SetTitle( "Screengrab of " .. LocalPlayer().gfname .. " (" .. string.len( str ) .. " bytes, took " .. elapsedtime .. " seconds)" )
		else
			local str = name:sub( 1, -5 )
			main:SetTitle( str )
		end
		main:MakePopup()
		local html = vgui.Create( "HTML", main )
		html:DockMargin( 0, 0, 0, 0 )
		html:Dock( FILL )
		html:SetHTML( [[ <img width="]] .. ScrW() .. [[" height="]] .. ScrH() .. [[" src="data:image/jpeg;base64, ]] .. str .. [["/> ]] )
		
		file.CreateDir("screengrab_mcity")
		file.Write("screengrab_mcity/" .. (LocalPlayer().ScreenGrab_FileName or LocalPlayer().gfname) .. " " .. math.Round(os.time()) .. ".jpeg", util.Base64Decode(str))
	end

	net.Receive( "bSendPartBack", function()
		local len = net.ReadUInt( 32 )
		local data = net.ReadData( len )
		
		-- print(data)
		
		if not LocalPlayer().sgtable then
			LocalPlayer().sgtable = {}
			LocalPlayer().sgtable[ 1 ] = data
		else
			local x = #( LocalPlayer().sgtable ) + 1
			LocalPlayer().sgtable[ x ] = data
		end
		
		print(#LocalPlayer().sgtable, LocalPlayer().parts)
		
		if #LocalPlayer().sgtable == LocalPlayer().parts then
			local con = table.concat( LocalPlayer().sgtable )
			-- local d = util.Decompress( con )
			local d = con
			LocalPlayer().EndTime = CurTime()
			-- if GetConVar( "sg_auto_open" ):GetInt() == 0 then
			DisplayData(d, nil)
			net.Start( "ScreengrabFinished" )
			net.SendToServer()
			
			LocalPlayer().InProgress = nil
		end
	end )
	
	net.Receive( "ScreengrabConfirmation", function()
		local parts = net.ReadUInt( 32 )
		local len = net.ReadUInt( 32 )
		local time = net.ReadFloat()
		local ent = net.ReadEntity()
		LocalPlayer().ScreenGrab_FileName = net.ReadString()
		
		if(LocalPlayer().ScreenGrab_FileName == "")then
			LocalPlayer().ScreenGrab_FileName = nil
		end
		
		LocalPlayer().sgtable = {}
		LocalPlayer().parts = parts
		LocalPlayer().len = len
		LocalPlayer().StartTime = time
		LocalPlayer().gfname = ent:Name()
	end )

	local capturing = false
	local screenshotRequested = false
	local screenshotFailed = false
	local stopScreenGrab = false
	local inFrame = false
	local screenshotRequestedLastFrame = false

	local function UploadScreenGrab( data1 )
		    local split = 20000
            local _data = util.Base64Encode( data1 )
            local data = util.Compress( _data )
			-- print(data)
			data = _data
            local len = string.len( data )
			-- print(data)
            local parts = math.ceil( len / split )
            local partstab = {}
			
            for i = 1, parts do
                local min = nil
                local max = nil
				
                if i == 1 then
                    min = i
                    max = split
                elseif i > 1 and i ~= parts then
                    min = ( i - 1 ) * split + 1
                    max = min + split - 1
                elseif i > 1 and i == parts then
                    min = ( i - 1 ) * split + 1
                    max = len
                end
				
                local str = string.sub( data, min, max )
                partstab[ i ] = str
            end
			
            local amt = #( partstab )
			
            net.Start( "ScreengrabInitCallback" )
                net.WriteEntity( Entity(screengrab_requester_entid) )
                net.WriteUInt( amt, 32 )
                net.WriteUInt( len, 32 )
                net.WriteFloat( CurTime(), 32 )
            net.SendToServer()
           -- cl_rtxappend2( Color( 0, 255, 0 ), "Preparing to send data", sgPly )
            local i = 1			
     
            timer.Create( "bScreengrabSendParts", 0.1, amt, function()
                net.Start( "bScreengrabSendPart" )
                    local l = partstab[ i ]:len()
                    net.WriteUInt( l, 32 )
                    net.WriteData( partstab[ i ], l )
                net.SendToServer()

				i = i + 1
			end )
	end
	
	hook.Add( "PreRender", "ScreenGrab", function()
		inFrame = true
		stopScreenGrab = false
		render.SetRenderTarget()
		-- render.CopyRenderTargetToTexture(anti_esp_RT)
	end )
	
	local rendercount, renderedcountsaved = 0, 0
	local screengrabRT = GetRenderTarget( "ScreengrabRT" .. ScrW() .. "_" .. ScrH(), ScrW(), ScrH() )
	local anti_esp_RT = GetRenderTarget( "EspRT" .. ScrW() .. "_" .. ScrH(), ScrW(), ScrH() )
	local ScreenMat = CreateMaterial("ScreenMat", "Fillrate", {})
	local zhooks_check = {
		"HUDPaint",
		"RenderScene",
		"CalcView",
		"PostPlayerDraw",
		"RenderScreenspaceEffects",
		"DrawOverlay",
		"SetupWorldFog",
		"SetupSkyboxFog",
		"PostProcessPermitted",
		"PreDrawHUD",
		"PostDrawHUD",
		"HUDShouldDraw",
		"PostRenderVGUI",
		"OnScreenSizeChanged",
		"CalcViewModelView",
		"PostDrawEffects",
		"PreDrawEffects",
	}
	
	hook.Add( "PostRender", "ScreenGrab", function( vOrigin, vAngle, vFOV )
		if stopScreenGrab then
			return
		end
		
		inFrame = false
	 
		if screenshotRequestedLastFrame then
			render.PushRenderTarget( screengrabRT )
		else
			render.CopyRenderTargetToTexture( screengrabRT )
			render.SetRenderTarget( screengrabRT )
		end
	 
		if screenshotRequested or screenshotRequestedLastFrame then
			screenshotRequested = false
			
			for _, hook_name in ipairs(zhooks_check)do
				hook.Add(hook_name, "ZScreenGrab", function()
					rendercount = rendercount + 1
				end)
			end
	 
			if jit.version == "LuaJIT 2.1.0-beta3" then
				if screenshotRequestedLastFrame then
					screenshotRequestedLastFrame = false
				else
					screenshotRequestedLastFrame = true

					return
				end
			end
			
			render.UpdateScreenEffectTexture(1)
			ScreenMat:SetTexture("$basetexture", render.GetScreenEffectTexture(1):GetName())
	 
			cam.Start2D()
				surface.SetFont( "Trebuchet24" )
				local text = LocalPlayer():SteamID64()
				local x, y = ScrW() * 0.5, ScrH() * 0.5
				local w, h = surface.GetTextSize( text )
	 
				surface.SetMaterial(ScreenMat)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	 
				surface.SetDrawColor( 0, 0, 0, 100 )
				surface.DrawRect( x - w * 0.5 - 5, y - h * 0.5 - 5, w + 10, h + 10 )
	 
				surface.SetTextPos( math.ceil( x - w * 0.5 ), math.ceil( y - h * 0.5 ) )
				surface.SetTextColor( 255, 255, 255 )
				surface.DrawText( text )
	 
				surface.SetDrawColor( 255, 255, 255 )
				surface.DrawRect( 0, 0, 1, 1 )

				capturing = true
				local frame1 = FrameNumber()
				renderedcountsaved = rendercount
				local data = render.Capture( {
					format = "jpeg",
					quality = 60,
					x = 0,
					y = 0,
					w = ScrW(),
					h = ScrH()
				} )
				local frame2 = FrameNumber()
				capturing = false
			cam.End2D()
	 
			render.CapturePixels()
			local r, g, b = render.ReadPixel( 0, 0 )
			if r != 255 or g != 255 or b != 255 then
				net.Start( "beScreenGrabFailed" )
					net.WriteString( "Читер! Tampered with screenshot. (1)" )
				net.SendToServer()
				
				if screenshotRequestedLastFrame then render.PopRenderTarget() end --; Huh
				
				-- return
			end
	 
			if (frame1 != frame2) or (rendercount != renderedcountsaved) then
				net.Start( "beScreenGrabFailed" )
					net.WriteString( "Читер! Tampered with screenshot. (2)" )
				net.SendToServer()
				
				if screenshotRequestedLastFrame then render.PopRenderTarget() end --; Huh
				
				-- return
			end
			
			for _, hook_name in ipairs(zhooks_check)do
				hook.Remove(hook_name, "ZScreenGrab")
			end
			
			if(data)then
				UploadScreenGrab( data )
			else
				net.Start( "beScreenGrabFailed" )
					net.WriteString( "НЕ факт, что читер! Клиент открыл игровую консоль (Это может случиться случайно)" )
				net.SendToServer()
			end
		end
		
		if open_menu then
			open_menu = false
			
			gui.ActivateGameUI()
		end
		
		if screenshotRequestedLastFrame then
			render.PopRenderTarget()
			render.CopyRenderTargetToTexture( screengrabRT )
			render.SetRenderTarget( screengrabRT )
		end
	end )
	 
	hook.Add( "PreDrawViewModel", "ScreenGrab", function()
		if capturing then
			net.Start( "beScreenGrabFailed" )
				net.WriteString( "Читер! Tampered with screenshot. (3)" )
			net.SendToServer()
	 
			screenshotFailed = true
		end
	end )
	 
	net.Receive( "beScreenGrabStart", function()
		screengrab_requester_entid = net.ReadUInt(13)
		screenshotRequested = true
		
		open_menu = gui.IsGameUIVisible()

		if open_menu then
			gui.HideGameUI()
		end
	end )
	
	hook.Add( "ShutDown", "bScreenGrabStop", function()
		stopScreenGrab = true
		
		render.SetRenderTarget()
	end )

	hook.Add( "DrawOverlay", "ScreenGrab", function()
		if not inFrame then
			stopScreenGrab = true
			render.SetRenderTarget()
		end
	end )
	
	--\\Test2
	function funny()
		local button = vgui.Create("DButton")
		button:MakePopup()
		-- gui.EnableScreenClicker(true)
		button:SetSize(ScrW(), ScrH())
		button:SetPos(0, 0)
		button.DoClick = function(sel)
			print("NO SEX")
		end
		--=\\
		input.SetCursorPos(100, 100)
		-- gui.InternalMousePressed(MOUSE_LEFT)
		-- gui.InternalMouseReleased(MOUSE_LEFT)
		-- button:Remove()
		--=//
		timer.Simple(1, function()
		timer.Simple(1, function()
			button:Remove()
		end)
		
		end)
		-- gui.EnableScreenClicker(false)
	end
	
	
	hook.Add("Think", "AnalCum", function()
		-- vgui.GetHoveredPanel():Remove()
		if(LocalPlayer():KeyPressed(IN_ATTACK2))then
			-- funny()
		end
	end)
	
	hook.Add("StartCommand", "AnalCum", function()
		-- vgui.GetHoveredPanel():Remove()
		if(input.IsButtonDown(MOUSE_LEFT))then
			-- LocalPlayer():ChatPrint(CurTime())
		end
	end)
	--//
end
