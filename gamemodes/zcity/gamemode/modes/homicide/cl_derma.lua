local MODE = MODE
local vgui_color_main = Color(155, 0, 0, 255)
local vgui_color_bg = Color(50, 50, 50, 255)
local vgui_color_ready = Color(0, 150, 50, 255)
local vgui_color_notready = Color(0, 50, 0, 255)

-- surface.CreateFont("RoleSelection_Main", {
	-- font = "Roboto",
	-- extended = false,
	-- size = ScreenScale(10),
	-- weight = 500,
	-- blursize = 0,
	-- scanlines = 0,
	-- antialias = true,
	-- underline = false,
	-- italic = false,
	-- strikeout = false,
	-- symbol = false,
	-- rotary = false,
	-- shadow = false,
	-- additive = false,
	-- outline = false,
-- })
local function set_role(role, mode)
	if mode == "soe" then
		RunConsoleCommand(MODE.ConVarName_SubRole_Traitor_SOE, role)
	else
		RunConsoleCommand(MODE.ConVarName_SubRole_Traitor, role)
	end
end

local function screen_scale_2(num)
	return ScreenScale(num) / (ScrW() / ScrH())
end

--\\SubRole View Panel
local PANEL = {}

function PANEL:Construct()
	self:SetSkin(hg.GetMainSkin())
	
	self.Title = self.Title or "No title"
	local width, height = self:GetSize()
	local dock_bottom = 5
	
	local label_name = vgui.Create("DLabel", self)
	label_name.ZRolePanel = self
	local label_name_height = 50--height / 5
	height = height - label_name_height - dock_bottom
	label_name:SetText("")
	label_name:SetSkin(hg.GetMainSkin())
	label_name:DockMargin(0, 0, 0, dock_bottom)
	label_name:Dock(TOP)
	label_name:SetHeight(label_name_height)
	label_name:SetMouseInputEnabled(true)
	label_name.Paint = function(sel, w, h)
		if((self.Mode == "soe" and MODE.ConVar_SubRole_Traitor_SOE:GetString() == self.Role) or (self.Mode != "soe" and MODE.ConVar_SubRole_Traitor:GetString() == self.Role))then
			surface.SetDrawColor(vgui_color_main)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 3)
		end
		
		surface.SetFont("ZB_InterfaceMedium")

		local tw, th = surface.GetTextSize(self.Title)
		
		surface.SetTextColor(255, 255, 255)
		surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
		surface.DrawText(self.Title)
	end
	
	label_name.DoClick = function(sel)
		set_role(self.Role, self.Mode or "soe")
	end
	
	local text_description = vgui.Create("RichText", self)
	text_description.ZRolePanel = self
	text_description:SetText(self.Description)
	text_description:SetSkin(hg.GetMainSkin())
	text_description:Dock(FILL)
	text_description.PerformLayout = function(sel)
		if(sel:GetFont() != "ZB_InterfaceSmall")then
			sel:SetFontInternal("ZB_InterfaceSmall")
		end
		
		sel:SetFGColor(color_white)
	end
	text_description.Paint = function(sel, w, h)
		
	end
end

function PANEL:PaintOver(w, h)

end

local tex_gradient = surface.GetTextureID("vgui/gradient-d")
local mata = Material("vgui/traitor_icons/traitor_icon.png")

local rolesmaterials = {
	["traitor_default_soe"] = Material("vgui/traitor_icons/traitor_icon.png"),
}

local glow = Material("homigrad/vgui/models/circle.png")

function PANEL:PostPaintPanel(w, h)
	/*if((self.Mode == "soe" and MODE.ConVar_SubRole_Traitor_SOE:GetString() == self.Role) or (self.Mode != "soe" and MODE.ConVar_SubRole_Traitor:GetString() == self.Role))then
		local y_start = 0
		
		surface.SetDrawColor(vgui_color_main)
		//surface.SetTexture(tex_gradient)
		surface.SetMaterial(mata)
		surface.DrawTexturedRect(0, -100, w, h + 200)
	end*/
	if rolesmaterials[self.Role] then
		//surface.SetDrawColor(vgui_color_main)
		//surface.SetMaterial(rolesmaterials[self.Role])
		//surface.DrawTexturedRect(0, -100, w, h + 200)

		--[[ --whatever
        render.SetStencilWriteMask(0xFF)
        render.SetStencilTestMask(0xFF)
        render.SetStencilReferenceValue(0)
        render.SetStencilCompareFunction(STENCIL_NEVER)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.ClearStencil()
        
        render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilFailOperation(STENCIL_REPLACE)

		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.SetMaterial(glow)
		local x, y = self:ScreenToLocal(gui.MouseX() - 0, gui.MouseY() - 0)
		draw.Circle( x, y, 200, 16 )

        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilCompareFunction(STENCIL_EQUAL)

		surface.SetDrawColor(Color(255, 0, 0, 50))
		surface.SetMaterial(rolesmaterials[self.Role])
		surface.DrawTexturedRect(0, -100, w, h + 200)

		render.SetStencilEnable( false )--]]
	end
end

derma.DefineControl("HMCD_RolePanel", "", PANEL, "DPanel")
--||Sub role carousel
local PANEL = {}

function PANEL:Construct()
	self:SetSkin(hg.GetMainSkin())
	
	self.RolesIDsList = self.RolesIDsList or MODE.RoleChooseRoundTypes["standard"].Traitor
	local width, height = self:GetSize()
	local dock_bottom = 5
	
	local hscroll = vgui.Create("ZHorizontalScroller", self)
	local hscroll_height = height - 50
	height = height - hscroll_height
	hscroll:SetHeight(hscroll_height)
	hscroll:SetSkin(hg.GetMainSkin())
	hscroll:DockMargin(0, 0, 0, dock_bottom)
	hscroll:Dock(TOP)
	hscroll:SetOverlap(-10)
	-- hscroll:SetUseLiveDrag(true)
	-- hscroll:InvalidateParent(false)
	for role_id, _ in pairs(self.RolesIDsList) do
		local role_info = MODE.SubRoles[role_id]
		local role_name = role_info.Name
		local role_description = role_info.Description
		
		local role_panel = vgui.Create("HMCD_RolePanel", hscroll)
		role_panel.Title = role_name
		role_panel.Description = role_description
		role_panel.Role = role_id
		role_panel.Mode = self.Mode or "soe"
		role_panel:SetWidth(ScreenScale(170))
		-- role_panel:SetHeight(hscroll_height)
		-- role_panel:InvalidateParent(false)
		role_panel:Construct()
		
		hscroll:AddPanel(role_panel)
	end
	
	local button_ready = vgui.Create("DButton", self)
	button_ready:Dock(FILL)
	button_ready:SetSkin(hg.GetMainSkin())
	button_ready:SetText("APPLY")
	button_ready.DoClick = function(sel)
		//if(sel.Clicked)then
			if(IsValid(VGUI_HMCD_RolePanelList))then
				VGUI_HMCD_RolePanelList:Remove()
			end
		//end
		
		//sel.Clicked = true
		
		//net.Start("HMCD(StartPlayersRoleSelection)")
		//net.SendToServer()
	end
	button_ready.Paint = function(sel, w, h)
		if(sel.Clicked)then
			surface.SetDrawColor(vgui_color_ready)
		else
			surface.SetDrawColor(vgui_color_notready)
		end
		
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 10)
		surface.DrawRect(0, 0, w, h * 0.45)
		surface.SetDrawColor(color_black)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
end

function PANEL:Paint()
	
end

derma.DefineControl("HMCD_RolePanelList", "", PANEL, "DPanel")
--//

local CTR_TOTAL_POINTS = 30
local CTR_PANEL_BG = Color(8, 12, 20, 240)
local CTR_ACCENT = Color(40, 120, 220)
local CTR_ACCENT_SOFT = Color(40, 120, 220, 120)
local CTR_GRADIENT = Material("vgui/gradient-d")

local function ctr_draw_text(text, font, posX, posY, color, textAlign)
	draw.DrawText(text, font, posX + 2, posY + 2, ColorAlpha(color_black, 200), textAlign)
	draw.DrawText(text, font, posX, posY, color, textAlign)
end

local CTR_SECTIONS = {
	{
		id = "soe",
		title = "SOE",
		items = {
			{id = "soe_walter_p22", name = "Walter P22 (+1 mag)", cost = 3, group = "soe", exclusive = "soe_gun"},
			{id = "soe_cyanide_capsule", name = "Cyanide Capsule", cost = 4, group = "soe"},
			{id = "soe_cyanide_canister", name = "Cyanide Canister", cost = 3, group = "soe"},
			{id = "soe_curare_vial", name = "Curare Vial", cost = 4, group = "soe"},
			{id = "soe_tetrodotoxin_syringe", name = "Tetrodotoxin Syringe", cost = 2, group = "soe"},
			{id = "soe_shuriken", name = "Shuriken", cost = 2, group = "soe"},
			{id = "soe_sog_seal_2000", name = "SOG SEAL 2000", cost = 2, group = "soe"},
			{id = "soe_rgd_5", name = "RGD - 5", cost = 5, group = "soe"},
			{id = "soe_f1", name = "F1", cost = 4, group = "soe"},
			{id = "soe_molotov", name = "Molotov Cocktail", cost = 3, group = "soe"},
			{id = "soe_type59", name = "Type-59 Grenade", cost = 4, group = "soe"},
			{id = "soe_pipebomb", name = "Pipebomb", cost = 3, group = "soe"},
			{id = "soe_ied", name = "I.E.D.", cost = 4, group = "soe"},
			{id = "soe_beretta_m9", name = "Beretta M9", cost = 4, group = "soe", exclusive = "soe_gun"},
			{id = "soe_glock_17", name = "Glock 17", cost = 6, group = "soe", exclusive = "soe_gun"},
			{id = "soe_explosive_belt", name = "Explosive Belt", cost = 9, group = "soe"},
		},
	},
	{
		id = "std",
		title = "STD",
		items = {
			{id = "std_zoraki_stalker_m906", name = "Zoraki Stalker M906", cost = 3, group = "std", exclusive = "std_gun"},
			{id = "std_buck_120_general", name = "Buck 120 General", cost = 2, group = "std"},
			{id = "std_tranquilazier_gun", name = "Tranquilazier gun", cost = 5, group = "std", exclusive = "std_gun"},
			{id = "std_rgd_5", name = "RGD - 5", cost = 4, group = "std"},
			{id = "std_flashbang", name = "Flashbang", cost = 3, group = "std"},
			{id = "std_heavy_dragoon_pistol", name = "Heavy Dragoon Pistol", cost = 4, group = "std", exclusive = "std_gun"},
			{id = "std_ied", name = "I.E.D.", cost = 4, group = "std"},
			{id = "std_cyanide_capsule", name = "Cyanide Capsule", cost = 3, group = "std"},
			{id = "std_cyanide_canister", name = "Cyanide Canister", cost = 3, group = "std"},
			{id = "std_curare_vial", name = "Curare Vial", cost = 4, group = "std"},
			{id = "std_tetrodotoxin_syringe", name = "Tetrodotoxin Syringe", cost = 2, group = "std"},
			{id = "std_shuriken", name = "Shuriken", cost = 2, group = "std"},
			{id = "std_f1", name = "F1", cost = 4, group = "std"},
			{id = "std_molotov", name = "Molotov Cocktail", cost = 3, group = "std"},
			{id = "std_type59", name = "Type-59 Grenade", cost = 4, group = "std"},
			{id = "std_pipebomb", name = "Pipebomb", cost = 3, group = "std"},
		},
	},
	{
		id = "abilities",
		title = "Abilities",
		items = {
			{id = "ability_assassin", name = "Assassin", cost = 13, group = "abilities"},
			{id = "ability_infiltraitor", name = "Infiltraitor", cost = 13, group = "abilities"},
		},
	},
}

local CTR_ITEM_INDEX = {}
for _, section in ipairs(CTR_SECTIONS) do
	for _, item in ipairs(section.items) do
		CTR_ITEM_INDEX[item.id] = item
	end
end

local function ctr_calc_used(selected)
	local used = 0
	if not selected then return used end
	for id, enabled in pairs(selected) do
		if enabled then
			local item = CTR_ITEM_INDEX[id]
			if item then
				used = used + (item.cost or 0)
			end
		end
	end
	return used
end

local function ctr_clean_selected(selected)
	local cleaned = {}
	if not selected then return cleaned end
	for id, enabled in pairs(selected) do
		if enabled and CTR_ITEM_INDEX[id] then
			cleaned[id] = true
		end
	end
	return cleaned
end

local function ctr_create_item_button(panel, parent, item)
	local btn = vgui.Create("DButton", parent)
	btn:Dock(TOP)
	btn:DockMargin(0, 0, 0, screen_scale_2(4))
	btn:SetTall(screen_scale_2(24))
	btn:SetText("")
	btn.ItemId = item.id
	btn.Paint = function(sel, w, h)
		local selected = panel.Selected and panel.Selected[sel.ItemId]
		draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(color_black, 205))
		if selected then
			surface.SetDrawColor(CTR_ACCENT.r, CTR_ACCENT.g, CTR_ACCENT.b, 200)
			surface.SetMaterial(CTR_GRADIENT)
			surface.DrawTexturedRect(0, 0, w, h)
			surface.SetDrawColor(80, 180, 255, 155)
			surface.DrawOutlinedRect(0, 0, w, h, 2)
		else
			surface.SetDrawColor(CTR_ACCENT.r, CTR_ACCENT.g, CTR_ACCENT.b, 60)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end
		local name = item.name
		local cost = tostring(item.cost) .. " pts"
		local textY = h / 2 - screen_scale_2(6)
		ctr_draw_text(name, "HomigradFontSmall", screen_scale_2(8), textY, color_white, TEXT_ALIGN_LEFT)
		ctr_draw_text(cost, "HomigradFontSmall", w - screen_scale_2(8), textY, color_white, TEXT_ALIGN_RIGHT)
	end
	btn.DoClick = function(sel)
		if panel.Selected[sel.ItemId] then
			panel.Selected[sel.ItemId] = nil
			panel:UpdatePoints()
			return
		end
		local used = ctr_calc_used(panel.Selected)
		if used + item.cost > panel.PointsMax then return end
		if item.group == "abilities" then
			for id, enabled in pairs(panel.Selected) do
				if enabled then
					local it = CTR_ITEM_INDEX[id]
					if it and it.group == "abilities" then
						panel.Selected[id] = nil
					end
				end
			end
		end
		if item.exclusive then
			for id, enabled in pairs(panel.Selected) do
				if enabled then
					local it = CTR_ITEM_INDEX[id]
					if it and it.exclusive == item.exclusive then
						panel.Selected[id] = nil
					end
				end
			end
		end
		panel.Selected[sel.ItemId] = true
		panel:UpdatePoints()
	end
	return btn
end

local function ctr_style_scrollbar(scroll)
	local bar = scroll:GetVBar()
	if not IsValid(bar) then return end
	bar:SetWide(screen_scale_2(6))
	bar:SetHideButtons(true)
	bar.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(color_black, 200))
	end
	bar.btnGrip.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, CTR_ACCENT)
	end
end

local PANEL = {}

function PANEL:Construct()
	self:SetSkin(hg.GetMainSkin())
	self.Selected = ctr_clean_selected(self.Selected or {})
	self.PointsMax = self.PointsMax or CTR_TOTAL_POINTS
	self.Mode = self.Mode or "soe"
	self:DockPadding(screen_scale_2(8), screen_scale_2(8), screen_scale_2(8), screen_scale_2(8))

	self.Header = vgui.Create("DPanel", self)
	self.Header:Dock(TOP)
	self.Header:SetTall(screen_scale_2(36))
	self.Header.CloseWidth = screen_scale_2(60)
	self.Header.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, CTR_PANEL_BG)
		surface.SetDrawColor(CTR_ACCENT)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
		ctr_draw_text("Custom Traitor Role", "HomigradFontMedium", screen_scale_2(8), h / 2 - screen_scale_2(10), CTR_ACCENT, TEXT_ALIGN_LEFT)
		ctr_draw_text(self.PointsText or "", "HomigradFontMedium", w - sel.CloseWidth - screen_scale_2(12), h / 2 - screen_scale_2(10), CTR_ACCENT, TEXT_ALIGN_RIGHT)
	end

	local close_btn = vgui.Create("DButton", self.Header)
	close_btn:Dock(RIGHT)
	close_btn:SetWide(self.Header.CloseWidth)
	close_btn:SetText("")
	close_btn.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(color_black, 205))
		surface.SetDrawColor(CTR_ACCENT)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		ctr_draw_text("Close", "HomigradFontSmall", w / 2, h / 2 - screen_scale_2(6), color_white, TEXT_ALIGN_CENTER)
	end
	close_btn.DoClick = function()
		self:Remove()
	end

	local body = vgui.Create("DPanel", self)
	body:Dock(FILL)
	body:DockMargin(0, screen_scale_2(8), 0, 0)
	body.Paint = function() end

	local left = vgui.Create("DPanel", body)
	left:Dock(LEFT)
	left:SetWide(screen_scale_2(240))
	left:DockMargin(0, 0, screen_scale_2(10), 0)
	left.Paint = function() end

	local mode_label = vgui.Create("DLabel", left)
	mode_label:Dock(TOP)
	mode_label:SetFont("HomigradFontSmall")
	mode_label:SetTextColor(color_white)
	mode_label:SetText("Mode")
	mode_label:DockMargin(0, screen_scale_2(8), 0, screen_scale_2(4))
	mode_label:SizeToContents()

	local mode_panel = vgui.Create("DPanel", left)
	mode_panel:Dock(TOP)
	mode_panel:SetTall(screen_scale_2(26))
	mode_panel.Paint = function() end

	local mode_soe = vgui.Create("DButton", mode_panel)
	mode_soe:Dock(LEFT)
	mode_soe:SetWide(screen_scale_2(80))
	mode_soe:SetText("")
	mode_soe.Paint = function(sel, w, h)
		local active = self.Mode == "soe"
		draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(color_black, 205))
		if active then
			surface.SetDrawColor(CTR_ACCENT.r, CTR_ACCENT.g, CTR_ACCENT.b, 200)
			surface.SetMaterial(CTR_GRADIENT)
			surface.DrawTexturedRect(0, 0, w, h)
		end
		surface.SetDrawColor(CTR_ACCENT)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		ctr_draw_text("SOE", "HomigradFontSmall", w / 2, h / 2 - screen_scale_2(6), color_white, TEXT_ALIGN_CENTER)
	end
	mode_soe.DoClick = function()
		self.Mode = "soe"
		self:UpdateModePanels()
	end

	local mode_std = vgui.Create("DButton", mode_panel)
	mode_std:Dock(LEFT)
	mode_std:SetWide(screen_scale_2(80))
	mode_std:SetText("")
	mode_std:DockMargin(screen_scale_2(6), 0, 0, 0)
	mode_std.Paint = function(sel, w, h)
		local active = self.Mode == "std"
		draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(color_black, 205))
		if active then
			surface.SetDrawColor(CTR_ACCENT.r, CTR_ACCENT.g, CTR_ACCENT.b, 200)
			surface.SetMaterial(CTR_GRADIENT)
			surface.DrawTexturedRect(0, 0, w, h)
		end
		surface.SetDrawColor(CTR_ACCENT)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		ctr_draw_text("STD", "HomigradFontSmall", w / 2, h / 2 - screen_scale_2(6), color_white, TEXT_ALIGN_CENTER)
	end
	mode_std.DoClick = function()
		self.Mode = "std"
		self:UpdateModePanels()
	end

	local abilities_label = vgui.Create("DLabel", left)
	abilities_label:Dock(TOP)
	abilities_label:SetFont("HomigradFontSmall")
	abilities_label:SetTextColor(color_white)
	abilities_label:SetText("Abilities")
	abilities_label:DockMargin(0, screen_scale_2(10), 0, screen_scale_2(4))
	abilities_label:SizeToContents()

	local abilities_panel = vgui.Create("DScrollPanel", left)
	abilities_panel:Dock(FILL)
	abilities_panel:DockMargin(0, 0, 0, screen_scale_2(6))
	ctr_style_scrollbar(abilities_panel)

	for _, section in ipairs(CTR_SECTIONS) do
		if section.id == "abilities" then
			for _, item in ipairs(section.items) do
				ctr_create_item_button(self, abilities_panel, item)
			end
		end
	end

	local controls = vgui.Create("DPanel", left)
	controls:Dock(BOTTOM)
	controls:SetTall(screen_scale_2(26))
	controls.Paint = function() end
	local apply_btn = vgui.Create("DButton", controls)
	apply_btn:Dock(FILL)
	apply_btn:SetText("")
	apply_btn.Paint = function(sel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(color_black, 205))
		surface.SetDrawColor(CTR_ACCENT)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		ctr_draw_text("APPLY", "HomigradFontSmall", w / 2, h / 2 - screen_scale_2(6), color_white, TEXT_ALIGN_CENTER)
	end
	apply_btn.DoClick = function()
		local selected = {}
		for id, enabled in pairs(self.Selected or {}) do
			if enabled then
				selected[#selected + 1] = id
			end
		end
		net.Start("HMCD(CTRApply)")
		net.WriteString(self.Mode or "soe")
		net.WriteUInt(#selected, 8)
		for _, id in ipairs(selected) do
			net.WriteString(id)
		end
		net.SendToServer()
		self:Remove()
	end

	local right = vgui.Create("DPanel", body)
	right:Dock(FILL)
	right.Paint = function() end

	local function build_items_section(parent, section, dock_mode, width)
		local panel = vgui.Create("DPanel", parent)
		panel:Dock(dock_mode or LEFT)
		if width then
			panel:SetWide(width)
			panel:DockMargin(0, 0, screen_scale_2(10), 0)
		end
		panel.Paint = function() end

		local section_label = vgui.Create("DLabel", panel)
		section_label:Dock(TOP)
		section_label:SetFont("HomigradFontMedium")
		section_label:SetTextColor(color_white)
		section_label:SetText(section.title)
		section_label:DockMargin(0, 0, 0, screen_scale_2(6))
		section_label:SizeToContents()

		local scroll = vgui.Create("DScrollPanel", panel)
		scroll:Dock(FILL)
		ctr_style_scrollbar(scroll)

		for _, item in ipairs(section.items) do
			ctr_create_item_button(self, scroll, item)
		end
		return panel
	end

	for _, section in ipairs(CTR_SECTIONS) do
		if section.id == "soe" then
			self.SoeSection = build_items_section(right, section, FILL)
		end
	end

	for _, section in ipairs(CTR_SECTIONS) do
		if section.id == "std" then
			self.StdSection = build_items_section(right, section, FILL)
		end
	end

	self.UpdateModePanels = function()
		if IsValid(self.SoeSection) then
			self.SoeSection:SetVisible(self.Mode == "soe")
		end
		if IsValid(self.StdSection) then
			self.StdSection:SetVisible(self.Mode == "std")
		end
	end

	self:UpdateModePanels()
	self:UpdatePoints()
end

function PANEL:UpdatePoints()
	local used = ctr_calc_used(self.Selected)
	local remaining = math.max(self.PointsMax - used, 0)
	self.PointsText = "Points: " .. tostring(remaining) .. " / " .. tostring(self.PointsMax)
end

function PANEL:Paint()
	draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), CTR_PANEL_BG)
	surface.SetDrawColor(CTR_ACCENT)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), 2)
end

derma.DefineControl("HMCD_CTRPanel", "", PANEL, "DPanel")

--\\Manual Click detection
local delta = 0
hook.Add("CreateMove", "HMCD_RolePanelClick", function(cmd)
	local dlta = (input.WasMousePressed(MOUSE_WHEEL_DOWN) and -1) or (input.WasMousePressed(MOUSE_WHEEL_UP) and 1) or 0

	delta = LerpFT(0.05, delta, dlta)
	local delta = delta * 2

	if(math.abs(delta) > 0.01)then
		local hovered_panel = vgui.GetHoveredPanel()

		local parent_panel = IsValid(hovered_panel) and hovered_panel:GetParent()
		local parent_panel2 = IsValid(parent_panel) and parent_panel:GetParent()
		local parent_panel3 = IsValid(parent_panel2) and parent_panel2:GetParent()
		local parent_panel4 = IsValid(parent_panel3) and parent_panel3:GetParent()
		local parent_panel5 = IsValid(parent_panel4) and parent_panel4:GetParent()

		if IsValid(hovered_panel) and hovered_panel.OnMouseWheeled then
			hovered_panel:OnMouseWheeled(delta)
		end

		if IsValid(parent_panel) and parent_panel.OnMouseWheeled then
			parent_panel:OnMouseWheeled(delta)
		end

		if IsValid(parent_panel2) and parent_panel2.OnMouseWheeled then
			parent_panel2:OnMouseWheeled(delta)
		end

		if IsValid(parent_panel3) and parent_panel3.OnMouseWheeled then
			parent_panel3:OnMouseWheeled(delta)
		end

		if IsValid(parent_panel4) and parent_panel4.OnMouseWheeled then
			parent_panel4:OnMouseWheeled(delta)
		end

		if IsValid(parent_panel5) and parent_panel5.OnMouseWheeled then
			parent_panel5:OnMouseWheeled(delta)
		end
	end

	if(input.WasMousePressed(MOUSE_LEFT))then
			-- print("Left mouse button was pressed")
		local hovered_panel = vgui.GetHoveredPanel()
		
		if(IsValid(hovered_panel) and IsValid(hovered_panel.ZRolePanel))then
			set_role(hovered_panel.ZRolePanel.Role, hovered_panel.ZRolePanel.Mode)
		end
	end
end)
--//

--\\https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/vgui/dhorizontalscroller.lua
local PANEL = {}

AccessorFunc( PANEL, "m_iOverlap",			"Overlap" )
AccessorFunc( PANEL, "m_bShowDropTargets",	"ShowDropTargets", FORCE_BOOL )

function PANEL:Init()

	self.Panels = {}
	self.OffsetX = 0
	self.FrameTime = 0

	self.pnlCanvas = vgui.Create( "DDragBase", self )
	self.pnlCanvas:SetDropPos( "6" )
	self.pnlCanvas:SetUseLiveDrag( false )
	self.pnlCanvas.OnModified = function() self:OnDragModified() end

	self.pnlCanvas.UpdateDropTarget = function( Canvas, drop, pnl )
		if ( !self:GetShowDropTargets() ) then return end
		DDragBase.UpdateDropTarget( Canvas, drop, pnl )
	end

	self.pnlCanvas.OnChildAdded = function( Canvas, child )

		local dn = Canvas:GetDnD()
		if ( dn ) then

			child:Droppable( dn )
			child.OnDrop = function()

				local x, y = Canvas:LocalCursorPos()
				local closest, id = self.pnlCanvas:GetClosestChild( x, Canvas:GetTall() / 2 ), 0

				for k, v in pairs( self.Panels ) do
					if ( v == closest ) then id = k break end
				end

				table.RemoveByValue( self.Panels, child )
				table.insert( self.Panels, id, child )

				self:InvalidateLayout()

				return child

			end
		end

	end

	self:SetOverlap( 0 )

	self.btnLeft = vgui.Create( "DButton", self )
	self.btnLeft:SetText( "" )
	self.btnLeft.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "ButtonLeft", panel, w, h ) end

	self.btnRight = vgui.Create( "DButton", self )
	self.btnRight:SetText( "" )
	self.btnRight.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "ButtonRight", panel, w, h ) end

end

function PANEL:GetCanvas()
	return self.pnlCanvas
end

function PANEL:ScrollToChild( panel )

	-- make sure our size is all good
	self:InvalidateLayout( true )

	local x, y = self.pnlCanvas:GetChildPosition( panel )
	local w, h = panel:GetSize()

	x = x + w * 0.5
	x = x - self:GetWide() * 0.5

	self:SetScroll( x )

end

function PANEL:SetScroll( x )

	self.OffsetX = x
	self:InvalidateLayout( true )

end

function PANEL:SetUseLiveDrag( bool )
	self.pnlCanvas:SetUseLiveDrag( bool )
end

function PANEL:MakeDroppable( name, allowCopy )
	self.pnlCanvas:MakeDroppable( name, allowCopy )
end

function PANEL:AddPanel( pnl )

	table.insert( self.Panels, pnl )

	pnl:SetParent( self.pnlCanvas )
	self:InvalidateLayout( true )

end

function PANEL:Clear()
	self.pnlCanvas:Clear()
	self.Panels = {}
end

function PANEL:OnMouseWheeled( dlta )

	self.OffsetX = self.OffsetX + dlta * -30
	self:InvalidateLayout( true )

	return true

end

function PANEL:Think()

	-- Hmm.. This needs to really just be done in one place
	-- and made available to everyone.
	local FrameRate = VGUIFrameTime() - self.FrameTime
	self.FrameTime = VGUIFrameTime()

	if ( self.btnRight:IsDown() ) then
		self.OffsetX = self.OffsetX + ( 500 * FrameRate )
		self:InvalidateLayout( true )
	end

	if ( self.btnLeft:IsDown() ) then
		self.OffsetX = self.OffsetX - ( 500 * FrameRate )
		self:InvalidateLayout( true )
	end

	if ( dragndrop.IsDragging() ) then

		local x, y = self:LocalCursorPos()

		if ( x < 30 ) then
			self.OffsetX = self.OffsetX - ( 350 * FrameRate )
		elseif ( x > self:GetWide() - 30 ) then
			self.OffsetX = self.OffsetX + ( 350 * FrameRate )
		end

		self:InvalidateLayout( true )

	end

end

function PANEL:PerformLayout()

	local w, h = self:GetSize()

	self.pnlCanvas:SetTall( h )

	local x = 0

	for k, v in pairs( self.Panels ) do
		if ( !IsValid( v ) ) then continue end
		if ( !v:IsVisible() ) then continue end

		v:SetPos( x, 0 )
		v:SetTall( h )
		if ( v.ApplySchemeSettings ) then v:ApplySchemeSettings() end

		x = x + v:GetWide() - self.m_iOverlap

	end

	self.pnlCanvas:SetWide( x + self.m_iOverlap )

	if ( w < self.pnlCanvas:GetWide() ) then
		self.OffsetX = math.Clamp( self.OffsetX, 0, self.pnlCanvas:GetWide() - self:GetWide() )
	else
		self.OffsetX = 0
	end

	self.pnlCanvas.x = self.OffsetX * -1

	self.btnLeft:SetSize( 15, 15 )
	self.btnLeft:AlignLeft( 4 )
	self.btnLeft:AlignBottom( 5 )

	self.btnRight:SetSize( 15, 15 )
	self.btnRight:AlignRight( 4 )
	self.btnRight:AlignBottom( 5 )

	self.btnLeft:SetVisible( self.pnlCanvas.x < 0 )
	self.btnRight:SetVisible( self.pnlCanvas.x + self.pnlCanvas:GetWide() > self:GetWide() )

end

function PANEL:OnDragModified()
	-- Override me
end

derma.DefineControl( "ZHorizontalScroller", "", PANEL, "Panel" )
--//
