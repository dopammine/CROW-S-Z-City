local CLASS = player.RegClass("headcrabzombie")

function CLASS.Off(self)
	if CLIENT then return end
end

function CLASS.On(self)
	if CLIENT then return end

	local model = "models/zombie/fast.mdl"
	if not util.IsValidModel(model) then
		model = "models/player/zombie_fast.mdl"
	end
	if not util.IsValidModel(model) then
		model = "models/player/zombie_soldier.mdl"
	end
	if not util.IsValidModel(model) then
		model = "models/zombie/classic.mdl"
	end

	ApplyAppearance(self, nil, nil, nil, true)
	self:SetModel(model)
	self:SetPlayerColor(Color(80, 140, 80):ToVector())
	self:SetBodyGroups("000000000")
end

function CLASS.Guilt(self, Victim)
	if CLIENT then return end
end
