hg.bone = hg.bone or {} -- посттравматический синдром личности

local tbl = {
	["head"] = "ValveBiped.Bip01_Head1",
	["spine"] = "ValveBiped.Bip01_Spine",
	["spine1"] = "ValveBiped.Bip01_Spine1",
	["spine2"] = "ValveBiped.Bip01_Spine2",
	["pelvis"] = "ValveBiped.Bip01_Pelvis",
	["r_upperarm"] = "ValveBiped.Bip01_R_UpperArm",
	["r_forearm"] = "ValveBiped.Bip01_R_Forearm",
	["l_upperarm"] = "ValveBiped.Bip01_L_UpperArm",
	["l_forearm"] = "ValveBiped.Bip01_L_Forearm",
}

hg.bone.client_only = {
	["r_finger0"] = "ValveBiped.Bip01_R_Finger0",
	["r_finger1"] = "ValveBiped.Bip01_R_Finger1",
	["r_finger11"] = "ValveBiped.Bip01_R_Finger11",
	["r_finger12"] = "ValveBiped.Bip01_R_Finger12",
	["l_finger0"] = "ValveBiped.Bip01_L_Finger0",
	["l_finger01"] = "ValveBiped.Bip01_L_Finger01",
	["l_finger02"] = "ValveBiped.Bip01_L_Finger02",
	["l_finger1"] = "ValveBiped.Bip01_L_Finger1",
	["l_finger11"] = "ValveBiped.Bip01_L_Finger11",
	["l_finger2"] = "ValveBiped.Bip01_L_Finger2",
	["l_finger21"] = "ValveBiped.Bip01_L_Finger21",
	["l_finger3"] = "ValveBiped.Bip01_L_Finger3",
	["l_finger31"] = "ValveBiped.Bip01_L_Finger31",
	["l_finger4"] = "ValveBiped.Bip01_L_Finger4",
	["l_finger41"] = "ValveBiped.Bip01_L_Finger41",
}

local PLAYER = FindMetaTable("Player")

function PLAYER:MBPosition(bone, pos)
	--if self:GetManipulateBonePosition(bone):IsEqualTol(pos, 0.01) then return end

	timer.Simple(0, function()
		self:ManipulateBonePosition(bone, pos)
	end)
end

function PLAYER:MBAngles(bone, ang)
	--if self:GetManipulateBoneAngles(bone):IsEqualTol(ang, 0.01) then return end

	timer.Simple(0, function()
		self:ManipulateBoneAngles(bone, ang)
	end)
end

hg.bone.matrixManual_Name = tbl

local matrix, matrixSet

local vecZero, angZero, vecFull = Vector(0, 0, 0), Angle(0, 0, 0), Vector(1, 1, 1)
local layer, name, boneName, boneID
if SERVER and not ConVarExists("hg_aprilfools") then
	CreateConVar("hg_aprilfools", 0, bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE), "enable april fools bone animation", 0, 1)
end
if SERVER then
	local cvar = GetConVar("hg_aprilfools")
	if cvar then
		SetGlobalBool("hg_aprilfools", cvar:GetBool())
		cvars.AddChangeCallback("hg_aprilfools", function(_, _, newValue)
			SetGlobalBool("hg_aprilfools", tonumber(newValue) == 1)
			if tonumber(newValue) == 1 then
				local now = CurTime()
				for _, ply in ipairs(player.GetAll()) do
					if not IsValid(ply) then continue end
					ply.HG_AF_DanceCooldown = now + 50
					ply.HG_AF_NextDanceCheck = now + math.Rand(10, 20)
				end
			end
		end, "hg_aprilfools_sync")
	end
end
local function aprilFoolsEnabled()
	if CLIENT then
		return GetGlobalBool("hg_aprilfools", false)
	end
	local cvar = GetConVar("hg_aprilfools")
	return cvar and cvar:GetBool()
end
if SERVER then
	hook.Add("PlayerSpawn", "hg-aprilfools-random-dance", function(ply)
		if not aprilFoolsEnabled() then return end
		local now = CurTime()
		ply.HG_AF_DanceCooldown = now + 50
		ply.HG_AF_NextDanceCheck = now + math.Rand(10, 20)
	end)

	hook.Add("Think", "hg-aprilfools-random-dance", function()
		if not aprilFoolsEnabled() then return end
		local now = CurTime()
		for _, ply in ipairs(player.GetAll()) do
			if not IsValid(ply) or not ply:Alive() or ply:InVehicle() then continue end
			if ply:GetNWFloat("hg_dance_until", 0) > now then continue end
			ply.HG_AF_DanceCooldown = ply.HG_AF_DanceCooldown or 0
			if now < ply.HG_AF_DanceCooldown then continue end
			ply.HG_AF_NextDanceCheck = ply.HG_AF_NextDanceCheck or 0
			if now < ply.HG_AF_NextDanceCheck then continue end
			ply.HG_AF_NextDanceCheck = now + math.Rand(10, 20)
			if math.random() <= 0.2 then
				local duration = SoundDuration("bbq.wav")
				if not duration or duration <= 0 then
					duration = 3
				end
				ply:SetNWFloat("hg_dance_until", now + duration)
				ply:EmitSound("bbq.wav", 100, 100, 1, CHAN_AUTO)
				ply.HG_AF_DanceCooldown = now + 50
			end
		end
	end)
end
local function reset(ply)
	ply.manipulated = ply.manipulated or {}
	ply.unmanipulated = {}
	ply.manipulate = {}
	ply.matrixes = {}
	
	for bone = 0, ply:GetBoneCount() do
		ply:ManipulateBonePosition(bone, vecZero, true)
		ply:ManipulateBoneAngles(bone, angZero, true)
		ply:ManipulateBoneScale(bone, vecFull, true)
	end
	
	ply.manipulated = {}
end

local function createLayer(ply, layer, lookup_name)
	boneName = hg.bone.matrixManual_Name[lookup_name]
	boneID = isnumber(lookup_name) and lookup_name or ply:LookupBone(boneName)
	
	if not boneID then return end

	ply.manipulated = ply.manipulated or {}
	ply.manipulated[boneID] = ply.manipulated[boneID] or {}
	ply.manipulated[boneID].Pos = ply.manipulated[boneID].Pos or Vector(0, 0, 0)
	ply.manipulated[boneID].Ang = ply.manipulated[boneID].Ang or Angle(0, 0, 0)
	ply.manipulated[boneID].layers = ply.manipulated[boneID].layers or {}
	ply.manipulated[boneID].layers[layer] = ply.manipulated[boneID].layers[layer] or {Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0)}
end

hook.Add("Player Getup", "homigrad-bones", function(ply) reset(ply) end)

local CurTime, LerpVector, LerpAngle = CurTime, LerpVector, LerpAngle
local m, mSet, mAngle, mPos
local vecZero, angZero = Vector(0, 0, 0), Angle(0, 0, 0)
local tickInterval = engine.TickInterval
local FrameTime = FrameTime
local math_min = math.min
local mul = 1
local timeHuy = CurTime()
local hook_Run = hook.Run
local angle = FindMetaTable("Angle")

function math.EqualWithTolerance(val1, val2, tol)
    return math.abs(val1 - val2) <= tol
end

function angle:IsEqualTol(ang, tol)
    if (tol == nil) then
        return self == ang
    end

    return math.EqualWithTolerance(self[1], ang[1], tol)
        and math.EqualWithTolerance(self[2], ang[2], tol)
        and math.EqualWithTolerance(self[3], ang[3], tol)
end

function angle:AngIsEqualTo(otherAng, huy)
	if not angle.IsEqualTol then return false end
	return self:IsEqualTol(otherAng, huy)
end

local hg_anims_draw_distance = ConVarExists("hg_anims_draw_distance") and GetConVar("hg_anims_draw_distance") or CreateClientConVar("hg_anims_draw_distance", 1024, true, nil, "distance to draw anims (0 = infinite)", 0, 4096)
local hg_anim_fps = ConVarExists("hg_anim_fps") and GetConVar("hg_anim_fps") or CreateClientConVar("hg_anim_fps", 66, true, nil, "fps to draw anims (0 = maximum fps available)", 0, 250)

local function recursive_bones(ply, bone)
	local children = ply:GetChildBones(bone)

	local parent = ply:GetBoneParent(bone)
	parent = parent ~= -1 and parent or 0

	local matp = ply.unmanipulated[parent] or ply:GetBoneMatrix(parent)

	if ply.matrixes[bone] then
		local new_matrix = ply.matrixes[bone]
		--print(new_matrix:GetAngles())
		local old_matrix = ply.unmanipulated[bone]
		
		local lmat = old_matrix:GetInverse() * new_matrix
		local ang = lmat:GetAngles()
		local vec, _ = WorldToLocal(new_matrix:GetTranslation(), angle_zero, old_matrix:GetTranslation(), matp:GetAngles())
		--print(old_matrix:GetTranslation())
		--ply.manipulate[bone] = {vec, ang}

		--ply:ManipulateBonePosition(bone, vec)
		--ply:ManipulateBoneAngles(bone, lmat:GetAngles())

		--ply:MBPosition(bone, vec)
		--ply:MBAngles(bone, lmat:GetAngles())

		--ply:MBPosition(bone, lpos)
		--ply:MBAngles(bone, ang)
	end

	for i = 1, #children do
		local bonec = children[i]

		recursive_bones(ply, bonec)
	end
end

local dtime
function hg.HomigradBones(ply, dtime)
	--if !IsValid(ply) or !ply:IsPlayer() or !ply:Alive() or IsValid(ply.FakeRagdoll) then return end
	if !IsValid(ply) or !ply:IsPlayer() or !ply:Alive() then return end

	local dist = CLIENT and LocalPlayer():GetPos():Distance(ply:GetPos()) or 0
	local drawdistance = CLIENT and hg_anims_draw_distance:GetInt() or 0
	local time = CurTime()
	
	if CLIENT and (!ply.shouldTransmit or ply.NotSeen) then return end

	local dtime2 = SysTime() - (ply.timeFrameasd or (SysTime() - 1))
	local fps = CLIENT and (hg_anim_fps:GetInt() != 0 and hg_anim_fps:GetInt() or 99999) or 15
	
	if CLIENT and (dtime2 < 1 / fps) then return end
	if SERVER and dtime2 < 0.2 then return end
	
	//dtime = dtime2
	ply.timeFrameasd = SysTime()

	hook_Run("Bones", ply, dtime2)
	
	--[[for bonename, tbl in pairs(ply.manipulated) do
		boneName = hg.bone.matrixManual_Name[bonename]
		boneID = ply:LookupBone(boneName)
		ply:ManipulateBonePosition(boneID, tbl.Pos, false)
		ply:ManipulateBoneAngles(boneID, tbl.Ang, false)
	end--]]

	if IsValid(ply.FakeRagdoll) then return end

	if not ply.manipulated then reset(ply) return end
	
	for bone, tbl in pairs(ply.manipulated) do
		for layer, tbl in pairs(tbl.layers) do
			if (tbl.lastset != time) then
				if tbl.Pos:IsEqualTol(vector_origin, 0.01) and tbl.Ang:IsEqualTol(angle_zero, 0.01) then
					ply.manipulated[bone] = nil

					continue
				end

				hg.bone.Set(ply, bone, vector_origin, angle_zero, layer, 0.01, dtime2, true)
			end
		end
	end

	do return end

	if SERVER then return end

	--[[
	local vec = Vector(0,0,0)
	local ang = Angle(0,50,0)

	ply:MBPosition(1, vec)
	ply:MBAngles(1, ang)

	local vec = ply:GetManipulateBonePosition(1)
	local ang = ply:GetManipulateBoneAngles(1)

	local mat = ply:GetBoneMatrix(1)
	local matp = ply:GetBoneMatrix(0)

	local ang1 = matp:GetAngles()

	local vec2 = ang1:Forward() * vec[1] + ang1:Right() * -vec[2] + ang1:Up() * vec[3]
	local ang2 = mat:GetAngles()
	--ОБЯЗАТЕЛЬНО В ПОРЯДКЕ 3 1 2!!! (roll pitch yaw)
	ang2:RotateAroundAxis(ang2:Forward(), -ang[3])
	ang2:RotateAroundAxis(ang2:Right(), ang[1])
	ang2:RotateAroundAxis(ang2:Up(), -ang[2])

	mat:SetTranslation(mat:GetTranslation() - vec2)
	mat:SetAngles(ang2)

	print(mat:GetTranslation(), mat:GetAngles(), 1)
	
	local ang2 = mat:GetAngles()
	local mat = ply:GetBoneMatrix(10)

	local ang1 = mat:GetAngles()

	ang1:RotateAroundAxis(ang2:Forward(), -ang[3])
	ang1:RotateAroundAxis(ang2:Right(), ang[1])
	ang1:RotateAroundAxis(ang2:Up(), -ang[2])

	mat:SetTranslation(mat:GetTranslation() - vec2)
	mat:SetAngles(ang1)

	print(mat:GetTranslation(), mat:GetAngles(), 2, "\n")
	--проблема в том что оно не учитывает то что позиция кости меняется при ее повороте...
	--]]

	--better version, здесь учитывает
	--[[
	local vec = Vector(0,0,0)
	local ang = Angle(0,0,0)

	ply:MBPosition(1, vec)
	ply:MBAngles(1, ang)

	local vec = ply:GetManipulateBonePosition(1)
	local ang = ply:GetManipulateBoneAngles(1)

	local mat = ply:GetBoneMatrix(1)
	local matp = ply:GetBoneMatrix(0)

	local ang1 = matp:GetAngles()

	local vec2 = ang1:Forward() * vec[1] + ang1:Right() * -vec[2] + ang1:Up() * vec[3]
	local ang2 = mat:GetAngles()
	--ОБЯЗАТЕЛЬНО В ПОРЯДКЕ 3 1 2!!! (roll pitch yaw)
	ang2:RotateAroundAxis(ang2:Forward(), -ang[3])
	ang2:RotateAroundAxis(ang2:Right(), ang[1])
	ang2:RotateAroundAxis(ang2:Up(), -ang[2])

	mat:SetTranslation(mat:GetTranslation() - vec2)
	mat:SetAngles(ang2)

	print(mat:GetTranslation(), mat:GetAngles(), 1)
	
	local mat2 = ply:GetBoneMatrix(10)

	local mats = mat * (ply:GetBoneMatrix(1):GetInverse() * mat2)

	print(mats:GetTranslation(), mats:GetAngles(), 2, "\n")
	--]]

	if not ply.matrixes then return end
	--ply:MBAngles(ply:LookupBone("ValveBiped.Bip01_Spine2"), Angle(0,0,0))

	--[[
	--о да.

	--ply:MBAngles(ply:LookupBone("ValveBiped.Bip01_R_UpperArm"), Angle(50,50,50))
	--ply:MBAngles(ply:LookupBone("ValveBiped.Bip01_R_Forearm"), Angle(50,50,50))

	--print(ply.unmanipulated[ply:LookupBone("ValveBiped.Bip01_R_Hand")]:GetTranslation())
	--reset(ply)

	
	local arm = ply:LookupBone("ValveBiped.Bip01_R_Forearm")
	local uparm = ply:LookupBone("ValveBiped.Bip01_R_UpperArm")
	local mat = ply:GetBoneMatrix(arm)
	local unmanip = ply.unmanipulated[arm]

	mat:SetTranslation(unmanip:GetTranslation() + vector_up * 10)
	mat:SetAngles(ply:EyeAngles())

	local lmat = unmanip:GetInverse() * mat
	--print(lmat:GetAngles(),lmat:GetTranslation())

	local vec = mat:GetTranslation() - unmanip:GetTranslation()
	local matp = ply.unmanipulated[uparm]
	local vec, _ = WorldToLocal(mat:GetTranslation(), angle_zero, unmanip:GetTranslation(), matp:GetAngles())

	--vec:Rotate(ang)

	--ply:ManipulateBonePosition(arm, vec)
	--ply:ManipulateBoneAngles(arm, lmat:GetAngles())
	--]]
	
	--recursive_bones(ply, 0)

	--[[for i = 0, ply:GetBoneCount() - 1 do
		if not ply.manipulate[i] then continue end
		hg.bone.Set(ply, i, ply.manipulate[i][1], ply.manipulate[i][2], "huy", 1, dtime, true)
	end--]]
end

function hg.get_unmanipulated_bones(ply, bone, matmodify)--set bone to 0 for the 1-st recurse
	ply.unmanipulated = ply.unmanipulated or {}
	matmodify = matmodify or Matrix()

	local vec = ply:GetManipulateBonePosition(bone)
	local ang = ply:GetManipulateBoneAngles(bone)

	local parent = ply:GetBoneParent(bone)
	parent = parent != -1 and parent or 0
	local mat = ply:GetBoneMatrix(bone)
	local matp = ply:GetBoneMatrix(parent)

	local ang1 = matp:GetAngles()

	local vec2 = ang1:Forward() * vec[1] + ang1:Right() * -vec[2] + ang1:Up() * vec[3]
	local ang2 = mat:GetAngles()
	--ОБЯЗАТЕЛЬНО В ПОРЯДКЕ 3 1 2!!! (roll pitch yaw)
	ang2:RotateAroundAxis(ang2:Forward(), -ang[3])
	ang2:RotateAroundAxis(ang2:Right(), ang[1])
	ang2:RotateAroundAxis(ang2:Up(), -ang[2])

	mat:SetTranslation(mat:GetTranslation() - vec2)
	mat:SetAngles(ang2)

	if matmodify then
		mat = matmodify * mat
	end

	ply.unmanipulated[bone] = mat

	local children = ply:GetChildBones(bone)

	local modify = mat * ply:GetBoneMatrix(bone):GetInverse()
	
	for i = 1, #children do
		local bonec = children[i]

		hg.get_unmanipulated_bones(ply, bonec, modify)
	end
end

hook.Add("Player Think", "homigrad-bones", function(ply, time, dtime)
	hg.HomigradBones(ply, dtime)
end)

hook.Add("Bones", "homigrad-walk-torso", function(ply, dtime)
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
	if ply:GetNWFloat("hg_dance_until", 0) > CurTime() then
		local t = CurTime()
		local speed = 5.5
		local armSpeed = 8.5
		local hipSide = math.sin(t * speed) * 26
		local hipTwist = math.cos(t * speed) * 18
		local bounce = math.abs(math.sin(t * speed * 0.5)) * 6
		local armSide = -math.sin(t * armSpeed) * 55
		local armForward = math.cos(t * armSpeed) * 35
		local foreTwist = math.sin(t * armSpeed + math.pi / 2) * 25
		local knee = math.sin(t * speed) * 12

		hg.bone.Set(ply, "spine", vector_origin, Angle(bounce, hipTwist * 0.6, hipSide * 0.6), "dance", 0.08, dtime)
		hg.bone.Set(ply, "spine1", vector_origin, Angle(bounce, hipTwist * 0.6, hipSide * 0.6), "dance", 0.08, dtime)
		hg.bone.Set(ply, "spine2", vector_origin, Angle(bounce, hipTwist * 0.6, hipSide * 0.6), "dance", 0.08, dtime)
		hg.bone.Set(ply, "pelvis", vector_origin, Angle(-bounce, -hipTwist, hipSide), "dance", 0.08, dtime)
		hg.bone.Set(ply, "head", vector_origin, Angle(bounce * 0.4, hipTwist * 0.4, -hipSide * 0.2), "dance", 0.08, dtime)

		hg.bone.Set(ply, "l_upperarm", vector_origin, Angle(armForward * 1.6, -hipTwist * 0.7, armSide * 1.8), "dance", 0.08, dtime)
		hg.bone.Set(ply, "r_upperarm", vector_origin, Angle(armForward * 1.6, hipTwist * 0.7, armSide * 1.8), "dance", 0.08, dtime)
		hg.bone.Set(ply, "l_forearm", vector_origin, Angle(armForward * 1.0, foreTwist * 1.9, armSide * 1.1), "dance", 0.08, dtime)
		hg.bone.Set(ply, "r_forearm", vector_origin, Angle(armForward * 1.0, -foreTwist * 1.9, armSide * 1.1), "dance", 0.08, dtime)

		hg.bone.Set(ply, "ValveBiped.Bip01_L_Thigh", vector_origin, Angle(knee, -hipTwist * 0.2, -hipSide * 0.3), "dance", 0.08, dtime)
		hg.bone.Set(ply, "ValveBiped.Bip01_R_Thigh", vector_origin, Angle(-knee, hipTwist * 0.2, hipSide * 0.3), "dance", 0.08, dtime)
		hg.bone.Set(ply, "ValveBiped.Bip01_L_Calf", vector_origin, Angle(-knee * 0.6, 0, 0), "dance", 0.08, dtime)
		hg.bone.Set(ply, "ValveBiped.Bip01_R_Calf", vector_origin, Angle(knee * 0.6, 0, 0), "dance", 0.08, dtime)
		hg.bone.Set(ply, "ValveBiped.Bip01_L_Foot", vector_origin, Angle(knee * 0.2, 0, -hipSide * 0.2), "dance", 0.08, dtime)
		hg.bone.Set(ply, "ValveBiped.Bip01_R_Foot", vector_origin, Angle(-knee * 0.2, 0, hipSide * 0.2), "dance", 0.08, dtime)
		return
	end
	if aprilFoolsEnabled() then
		if not ply:OnGround() then
			local vz = math.abs(ply:GetVelocity().z)
			local airScale = math.Clamp(vz / 300, 0.2, 1.2)
			local t = CurTime()
			local pitch = math.sin(t * 6.5) * 35 * airScale
			local yaw = math.cos(t * 5.5) * 45 * airScale
			local roll = math.sin(t * 8.5) * 25 * airScale

			local torsoAng = Angle(pitch, yaw, roll)
			local legKick = math.sin(t * 7.5 + 1.2) * 55 * airScale
			local calfKick = -legKick * 0.7
			local footKick = legKick * 0.5

			hg.bone.Set(ply, "spine", vector_origin, torsoAng, "walk", 0.08, dtime)
			hg.bone.Set(ply, "spine1", vector_origin, torsoAng, "walk", 0.08, dtime)
			hg.bone.Set(ply, "spine2", vector_origin, torsoAng, "walk", 0.08, dtime)
			hg.bone.Set(ply, "pelvis", vector_origin, Angle(-pitch * 0.8, -yaw * 0.8, roll * 0.6), "walk", 0.08, dtime)
			hg.bone.Set(ply, "head", vector_origin, Angle(pitch * 0.6, yaw * 0.6, roll * -0.4), "walk", 0.08, dtime)
			hg.bone.Set(ply, "l_upperarm", vector_origin, Angle(-pitch * 0.7, -yaw * 1.1, roll * 1.2), "walk", 0.08, dtime)
			hg.bone.Set(ply, "r_upperarm", vector_origin, Angle(-pitch * 0.7, yaw * 1.1, -roll * 1.2), "walk", 0.08, dtime)
			hg.bone.Set(ply, "l_forearm", vector_origin, Angle(pitch * 0.8, yaw * 0.4, roll * 0.6), "walk", 0.08, dtime)
			hg.bone.Set(ply, "r_forearm", vector_origin, Angle(pitch * 0.8, -yaw * 0.4, -roll * 0.6), "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_L_Thigh", vector_origin, Angle(legKick, -yaw * 0.3, 0), "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_R_Thigh", vector_origin, Angle(-legKick, yaw * 0.3, 0), "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_L_Calf", vector_origin, Angle(calfKick, 0, 0), "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_R_Calf", vector_origin, Angle(-calfKick, 0, 0), "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_L_Foot", vector_origin, Angle(footKick, 0, 0), "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_R_Foot", vector_origin, Angle(-footKick, 0, 0), "walk", 0.08, dtime)
			return
		end

		local speed = ply:GetVelocity():Length2D()
		local scale = math.Clamp(speed / 200, 0, 1)
		local runBoost = speed >= 220 and 1.4 or 1
		scale = math.min(scale * runBoost, 1.5)
		if scale <= 0.05 then
			hg.bone.Set(ply, "spine", vector_origin, angle_zero, "walk", 0.08, dtime)
			hg.bone.Set(ply, "spine1", vector_origin, angle_zero, "walk", 0.08, dtime)
			hg.bone.Set(ply, "spine2", vector_origin, angle_zero, "walk", 0.08, dtime)
			hg.bone.Set(ply, "pelvis", vector_origin, angle_zero, "walk", 0.08, dtime)
			hg.bone.Set(ply, "l_upperarm", vector_origin, angle_zero, "walk", 0.08, dtime)
			hg.bone.Set(ply, "r_upperarm", vector_origin, angle_zero, "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_L_Thigh", vector_origin, angle_zero, "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_R_Thigh", vector_origin, angle_zero, "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_L_Calf", vector_origin, angle_zero, "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_R_Calf", vector_origin, angle_zero, "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_L_Foot", vector_origin, angle_zero, "walk", 0.08, dtime)
			hg.bone.Set(ply, "ValveBiped.Bip01_R_Foot", vector_origin, angle_zero, "walk", 0.08, dtime)
			return
		end

		local t = CurTime()
		local pitch = math.sin(t * 6) * 30 * scale
		local yaw = math.cos(t * 5) * 40 * scale
		local roll = math.sin(t * 8) * 18 * scale
		local torsoAng = Angle(pitch, yaw, roll)

		local armPitch = pitch * 0.6
		local armYaw = yaw * 0.8
		local armRoll = roll * 1.2

		local legPitch = math.sin(t * 7 + 1.5) * 55 * scale
		local legYaw = math.cos(t * 6 + 0.7) * 16 * scale
		local calfPitch = -legPitch * 0.6
		local footPitch = legPitch * 0.3

		hg.bone.Set(ply, "spine", vector_origin, torsoAng, "walk", 0.08, dtime)
		hg.bone.Set(ply, "spine1", vector_origin, torsoAng, "walk", 0.08, dtime)
		hg.bone.Set(ply, "spine2", vector_origin, torsoAng, "walk", 0.08, dtime)
		hg.bone.Set(ply, "pelvis", vector_origin, Angle(-pitch * 0.8, -yaw * 0.8, roll * 0.6), "walk", 0.08, dtime)
		hg.bone.Set(ply, "head", vector_origin, Angle(pitch * 0.5, yaw * 0.5, roll * -0.3), "walk", 0.08, dtime)

		hg.bone.Set(ply, "l_upperarm", vector_origin, Angle(-armPitch * 1.2, -armYaw * 1.2, armRoll * 1.3), "walk", 0.08, dtime)
		hg.bone.Set(ply, "r_upperarm", vector_origin, Angle(-armPitch * 1.2, armYaw * 1.2, -armRoll * 1.3), "walk", 0.08, dtime)
		hg.bone.Set(ply, "l_forearm", vector_origin, Angle(armPitch * 0.9, armYaw * 0.4, armRoll * 0.6), "walk", 0.08, dtime)
		hg.bone.Set(ply, "r_forearm", vector_origin, Angle(armPitch * 0.9, -armYaw * 0.4, -armRoll * 0.6), "walk", 0.08, dtime)

		hg.bone.Set(ply, "ValveBiped.Bip01_L_Thigh", vector_origin, Angle(legPitch, -legYaw, 0), "walk", 0.08, dtime)
		hg.bone.Set(ply, "ValveBiped.Bip01_R_Thigh", vector_origin, Angle(-legPitch, legYaw, 0), "walk", 0.08, dtime)
		hg.bone.Set(ply, "ValveBiped.Bip01_L_Calf", vector_origin, Angle(calfPitch, legYaw * 0.4, 0), "walk", 0.08, dtime)
		hg.bone.Set(ply, "ValveBiped.Bip01_R_Calf", vector_origin, Angle(-calfPitch, -legYaw * 0.4, 0), "walk", 0.08, dtime)
		hg.bone.Set(ply, "ValveBiped.Bip01_L_Foot", vector_origin, Angle(footPitch, 0, 0), "walk", 0.08, dtime)
		hg.bone.Set(ply, "ValveBiped.Bip01_R_Foot", vector_origin, Angle(-footPitch, 0, 0), "walk", 0.08, dtime)
		return
	end

	if not ply:OnGround() then
		hg.bone.Set(ply, "spine", vector_origin, angle_zero, "walk", 0.08, dtime)
		hg.bone.Set(ply, "spine1", vector_origin, angle_zero, "walk", 0.08, dtime)
		hg.bone.Set(ply, "spine2", vector_origin, angle_zero, "walk", 0.08, dtime)
		return
	end

	local speed = ply:GetVelocity():Length2D()
	local scale = math.Clamp(speed / 200, 0, 1)
	if scale <= 0.05 then
		hg.bone.Set(ply, "spine", vector_origin, angle_zero, "walk", 0.08, dtime)
		hg.bone.Set(ply, "spine1", vector_origin, angle_zero, "walk", 0.08, dtime)
		hg.bone.Set(ply, "spine2", vector_origin, angle_zero, "walk", 0.08, dtime)
		return
	end

	local t = CurTime() * 7
	local pitch = math.sin(CurTime() * 4) * 4 * scale
	local yaw = math.cos(t * 0.7) * 6 * scale
	local ang = Angle(pitch, yaw, 0)

	hg.bone.Set(ply, "spine", vector_origin, ang, "walk", 0.08, dtime)
	hg.bone.Set(ply, "spine1", vector_origin, ang, "walk", 0.08, dtime)
	hg.bone.Set(ply, "spine2", vector_origin, ang, "walk", 0.08, dtime)
end)

if CLIENT then
	local ghostTrail = {}
	local ghostInterval = 0.05
	local ghostLife = 0.25
	local nextGhostTime = 0
	local ghostColors = {Color(0, 255, 0), Color(255, 0, 0)}
	local ghostColorIndex = 1
	local ghostBackOffset = 24

	local function clearGhosts()
		for i = #ghostTrail, 1, -1 do
			local g = ghostTrail[i]
			if IsValid(g.modelEnt) then
				g.modelEnt:Remove()
			end
			table.remove(ghostTrail, i)
		end
	end

	local function captureBones(ply)
		local mats = {}
		for i = 0, ply:GetBoneCount() do
			local m = ply:GetBoneMatrix(i)
			if m then
				mats[i] = Matrix(m)
			end
		end
		return mats
	end

	local function spawnGhost(ply, color)
		local model = ply:GetModel()
		if not model or model == "" then return end
		local backPos = ply:GetPos() - ply:GetForward() * ghostBackOffset
		table.insert(ghostTrail, {
			model = model,
			pos = backPos,
			ang = ply:GetAngles(),
			bones = captureBones(ply),
			color = color,
			born = CurTime(),
			life = ghostLife
		})
	end

	hook.Add("Think", "homigrad-aprilfools-ghosttrail", function()
		if not aprilFoolsEnabled() then
			clearGhosts()
			return
		end
		local now = CurTime()
		if now < nextGhostTime then return end
		for _, ply in ipairs(player.GetAll()) do
			if not IsValid(ply) then continue end
			local speed = ply:GetVelocity():Length2D()
			local isSprinting = ply:Alive()
				and not ply:InVehicle()
				and ((ply.IsSprinting and ply:IsSprinting()) or ply:KeyDown(IN_SPEED))
				and speed > 300
			if isSprinting then
				spawnGhost(ply, ghostColors[ghostColorIndex])
				ghostColorIndex = ghostColorIndex % #ghostColors + 1
			end
		end
		nextGhostTime = now + ghostInterval
	end)

	hook.Add("PostDrawTranslucentRenderables", "homigrad-aprilfools-ghosttrail", function()
		if #ghostTrail == 0 then return end
		local now = CurTime()
		for i = #ghostTrail, 1, -1 do
			local g = ghostTrail[i]
			local age = now - g.born
			if age >= g.life then
				if IsValid(g.modelEnt) then
					g.modelEnt:Remove()
				end
				table.remove(ghostTrail, i)
			else
				if not IsValid(g.modelEnt) or g.modelEnt:GetModel() ~= g.model then
					if IsValid(g.modelEnt) then
						g.modelEnt:Remove()
					end
					g.modelEnt = ClientsideModel(g.model, RENDERGROUP_TRANSLUCENT)
					g.modelEnt:SetNoDraw(true)
					g.modelEnt:SetRenderMode(RENDERMODE_TRANSCOLOR)
					g.modelEnt:SetMaterial("models/debug/debugwhite")
				end
				render.SetColorModulation(g.color.r / 255, g.color.g / 255, g.color.b / 255)
				local alpha = math.Clamp(1 - age / g.life, 0, 1)
				g.modelEnt:SetPos(g.pos)
				g.modelEnt:SetAngles(g.ang)
				g.modelEnt:SetupBones()
				for boneId, mat in pairs(g.bones) do
					g.modelEnt:SetBoneMatrix(boneId, mat)
				end
				g.modelEnt:SetColor(Color(255, 255, 255, math.floor(alpha * 200)))
				g.modelEnt:DrawModel()
				render.SetColorModulation(1, 1, 1)
			end
		end
	end)

	local sprintSounds = {
		{path = "mach1.wav"},
		{path = "mach2.wav"},
		{path = "mach3.wav"},
		{path = "mach4.wav"},
	}
	for _, snd in ipairs(sprintSounds) do
		util.PrecacheSound(snd.path)
		local duration = SoundDuration(snd.path)
		if not duration or duration <= 0 then
			duration = 1
		end
		snd.duration = duration
	end
	local currentSprintSound
	local currentSprintDuration = 1
	local sprintLoopNext = 0
	local nextSprintCheck = 0

	hook.Add("Think", "homigrad-sprint-sound", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		if not aprilFoolsEnabled() then
			if currentSprintSound then
				ply:StopSound(currentSprintSound)
				currentSprintSound = nil
			end
			sprintLoopNext = 0
			return
		end
		local now = CurTime()
		if now < nextSprintCheck then return end
		nextSprintCheck = now + 0.05

		local speed = ply:GetVelocity():Length2D()
		local isSprinting = ply:Alive()
			and not ply:InVehicle()
			and ((ply.IsSprinting and ply:IsSprinting()) or ply:KeyDown(IN_SPEED))
			and speed > 40

		if isSprinting then
			local tier
			if speed < 300 then
				tier = sprintSounds[1]
			elseif speed < 600 then
				tier = sprintSounds[2]
			elseif speed < 900 then
				tier = sprintSounds[3]
			else
				tier = sprintSounds[4]
			end
			if currentSprintSound ~= tier.path then
				if currentSprintSound then
					ply:StopSound(currentSprintSound)
				end
				currentSprintSound = tier.path
				currentSprintDuration = tier.duration or 1
				sprintLoopNext = 0
			end
			if now >= sprintLoopNext then
				ply:EmitSound(currentSprintSound, 140, 100, 1, CHAN_BODY)
				sprintLoopNext = now + currentSprintDuration
			end
		elseif currentSprintSound then
			ply:StopSound(currentSprintSound)
			currentSprintSound = nil
			sprintLoopNext = 0
		end
	end)
end

function hg.bone.Set(ply, lookup_name, vec, ang, layer, lerp, dtime2)
	local dtime = dtime2 or dtime
	boneName = hg.bone.matrixManual_Name[lookup_name]
	boneID = isnumber(lookup_name) and lookup_name or ply:LookupBone(boneName ~= nil and boneName or lookup_name)

	if not boneID then return end
	
	layer = layer or "unspecified"

	if layer and layer != "all" then
		createLayer(ply, layer, boneID)
		
		if lerp then
			vec = LerpVector(hg.lerpFrameTime(lerp, dtime), ply.manipulated[boneID].layers[layer].Pos, vec)
			ang = LerpAngle(hg.lerpFrameTime(lerp, dtime), ply.manipulated[boneID].layers[layer].Ang, ang)
		end
		
		local oldpos, oldang = hg.bone.Get(ply, boneID)
		--print(oldang)
		local setPos = oldpos - ply.manipulated[boneID].layers[layer].Pos + vec
		local setAng = oldang - ply.manipulated[boneID].layers[layer].Ang + ang

		hg.bone.SetRaw(ply, boneID, setPos, setAng)

		--print(layer, lookup_name, oldang, ply.layers[layer][lookup_name].Ang, ang, setAng)

		ply.manipulated[boneID].layers[layer].Pos = -(-vec)
		ply.manipulated[boneID].layers[layer].Ang = -(-ang)
		ply.manipulated[boneID].layers[layer].lastset = CurTime()
	end
end
--PrintTable(Player(3).manipulated)
function hg.bone.SetRaw(ply, boneID, vec, ang)
	ply.manipulated = ply.manipulated or {}
	ply.manipulated[boneID] = ply.manipulated[boneID] or {}

	ply.manipulated[boneID].Pos = vec
	ply.manipulated[boneID].Ang = ang
	
	ply:ManipulateBonePosition(boneID, vec, false)
	ply:ManipulateBoneAngles(boneID, ang, false)
end

function hg.bone.Get(ply, lookup_name)
	boneName = hg.bone.matrixManual_Name[lookup_name]
	boneID = isnumber(lookup_name) and lookup_name or ply:LookupBone(boneName)

	if not boneID or not ply.manipulated[boneID] then return end

	return ply.manipulated[boneID].Pos, ply.manipulated[boneID].Ang
end
