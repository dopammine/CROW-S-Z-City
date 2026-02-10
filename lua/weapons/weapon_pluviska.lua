if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bigconsumable"
SWEP.PrintName = "Pluviska"
SWEP.Instructions = "PluvTown's Finest. A true delicacy."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/props/pluv.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("pluv/pluv.png")
	SWEP.IconOverride = "pluv/pluv.png"
	SWEP.BounceWeaponIcon = true
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(4, -2, -1)
SWEP.offsetAng = Angle(180, 0, 0)
SWEP.showstats = false

SWEP.ofsV = Vector(-2,-10,8)
SWEP.ofsA = Angle(90,-90,90)

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self:SetModel("models/props/pluv.mdl")
	self:SetCurModel("models/props/pluv.mdl")
	self.WorldModel = "models/props/pluv.mdl"

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		if IsValid(self:GetPhysicsObject()) then
			self:GetPhysicsObject():Wake()
		end
	end
end

function SWEP:DrawWorldModel2()
	self.model = IsValid(self.model) and self.model or ClientsideModel( self:GetCurModel() )
	self.model:SetNoDraw(true)
	local WorldModel = self.model
	local owner = hg.GetCurrentCharacter(self:GetOwner())
	
	if not IsValid(WorldModel) then return end
	if WorldModel:GetModel() ~= self:GetCurModel() then WorldModel:Remove() return end

	--WorldModel:SetMaterial("phoenix_storms/gear")
	--WorldModel:SetColor(Color(255, 84, 58))
	WorldModel:SetModelScale(0.75 + math.abs(math.sin(CurTime() * 2)) * 0.15)
	
	if IsValid(owner) then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not owner.organism.larmamputated)) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		local matrix = owner:GetBoneMatrix(boneid)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		local targetPly = owner
		local targetPos = owner:EyePos()
		local nearestDistSqr = math.huge
		local searchRadius = 200
		local searchRadiusSqr = searchRadius * searchRadius
		for _, ply in ipairs(player.GetAll()) do
			if ply == owner or not ply:Alive() then continue end
			local head = ply:LookupBone("ValveBiped.Bip01_Head1")
			local headPos = head and ply:GetBonePosition(head) or ply:EyePos()
			local distSqr = headPos:DistToSqr(newPos)
			if distSqr <= searchRadiusSqr and distSqr < nearestDistSqr then
				nearestDistSqr = distSqr
				targetPly = ply
				targetPos = headPos
			end
		end
		local lookAng = (targetPos - newPos):Angle()
		lookAng:RotateAroundAxis(lookAng:Right(), offsetAng[1])
		lookAng:RotateAroundAxis(lookAng:Up(), offsetAng[2])
		lookAng:RotateAroundAxis(lookAng:Forward(), offsetAng[3] + 180)
		self.pluvLookAng = LerpAngle(FrameTime() * 8, self.pluvLookAng or lookAng, lookAng)
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(self.pluvLookAng)
		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end
	
		WorldModel:DrawModel()
end

if SERVER then
	function SWEP:Heal(ent, mode, bone)
		local org = ent.organism
		if not org then return end
		self.Eating = self.Eating or 0
		self.CDEating = self.CDEating or 0
		if self.CDEating > CurTime() then return end

		org.satiety = org.satiety + 0.5
		local ply = self:GetOwner()
		ply:ViewPunch(Angle(3,0,0))

		ent:EmitSound("snd_jack_hmcd_eat4.wav", 60, math.random(95, 105))

		self.CDEating = CurTime() + 0.5
		self.Eating = self.Eating + 1
		--self:SetHolding(0.98)
		if self.Eating > 50 then
			self:GetOwner():SelectWeapon("weapon_hands_sh")
			self:Remove()
		end

		return true
	end
end
