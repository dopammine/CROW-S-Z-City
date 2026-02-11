AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    local model = "models/props/pluvmask.mdl"
    if not util.IsValidModel(model) then
        model = "models/props_c17/doll01.mdl"
    end
    
    self:SetModel(model)
    self:SetMoveType(MOVETYPE_NOCLIP)
    self:SetSolid(SOLID_NONE)
    self:SetColor(Color(0, 0, 0))
    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    
    self.State = "PATROL"
    self.NextPatrolTime = 0
    self.PatrolPos = self:GetPos()
    
    self.Speed = 200
end

function ENT:Think()
    local targets = player.GetAll()
    local closestDist = 2000 * 2000
    local closestTarget = nil

    for _, ply in ipairs(targets) do
        if not ply:Alive() then continue end
        local dist = self:GetPos():DistToSqr(ply:GetPos())
        if dist < closestDist then
            closestDist = dist
            closestTarget = ply
        end
    end

    if IsValid(closestTarget) then
        self:SetTarget(closestTarget)
        
        if self.State == "PATROL" then
            self.State = "STARE"
            self.StareEndTime = CurTime() + 2
            self:EmitSound("cry1.wav")
        end
    else
        self.State = "PATROL"
        self:SetTarget(NULL)
        self:SetChasing(false)
    end

    if self.State == "PATROL" then
        self:SetChasing(false)
        if CurTime() > self.NextPatrolTime or self:GetPos():DistToSqr(self.PatrolPos) < 1000 then
            local randVec = Vector(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-200, 200))
            self.PatrolPos = self:GetPos() + randVec
            self.NextPatrolTime = CurTime() + 5
        end
        
        local dir = (self.PatrolPos - self:GetPos()):GetNormalized()
        self:SetPos(self:GetPos() + dir * self.Speed * FrameTime())
        local ang = dir:Angle()
        ang:RotateAroundAxis(ang:Up(), 180)
        self:SetAngles(ang)

    elseif self.State == "STARE" then
        self:SetChasing(true)
        if IsValid(closestTarget) then
            local ang = (closestTarget:EyePos() - self:GetPos()):Angle()
            ang:RotateAroundAxis(ang:Up(), 180)
            self:SetAngles(ang)
            if CurTime() > self.StareEndTime then
                self.State = "CHASE"
            end
        else
            self.State = "PATROL"
        end

    elseif self.State == "CHASE" then
        self:SetChasing(true)
        if IsValid(closestTarget) then
            local targetPos = closestTarget:EyePos()
            local dir = (targetPos - self:GetPos()):GetNormalized()
            local currentSpeed = 50
            self:SetPos(self:GetPos() + dir * currentSpeed * FrameTime())
            local ang = dir:Angle()
            ang:RotateAroundAxis(ang:Up(), 180)
            self:SetAngles(ang)
            
            if self:GetPos():DistToSqr(targetPos) < (100 * 100) then
                self.State = "SNATCH"
            end
        else
            self.State = "PATROL"
        end

    elseif self.State == "SNATCH" then
        if IsValid(closestTarget) and closestTarget:Alive() then
            local ent = closestTarget
            ent = hg.RagdollOwner(ent) or ent
            
            local bot = ents.Create("bot_fear")
            if IsValid(bot) then
                bot.Victim = ent
                bot:Spawn()
            end
            
            ent:Kill()
            self:EmitSound("physics/flesh/flesh_bloody_break.wav")
            
            -- Head Explosion Logic
            timer.Simple(0, function()
                if not IsValid(ent) then return end
                local rag = ent:GetRagdollEntity() or ent.FakeRagdoll
                if IsValid(rag) and Gib_Input then
                    Gib_Input(rag, rag:LookupBone("ValveBiped.Bip01_Head1"), Vector(0, 0, 100))
                end
            end)
            
            self.State = "PATROL"
            self.NextPatrolTime = CurTime() + 2 -- Give it a moment before moving again
        else
            self.State = "PATROL"
        end
    end

    self:NextThink(CurTime())
    return true
end
