local MODE = MODE

local EVENT = {}
EVENT.Name = "scary_black_guy"
EVENT.Chance = 0.2

local walk_speed = 80
local run_speed = 320

local function GetNearBehindPos(pos, viewer, viewerAng)
    pos = pos + vector_up * 32
    viewerAng.pitch = 0
    local min_dist = 700
    local max_dist = 1500
    for i = 1, 6 do
        local ang = Angle(0, viewerAng.yaw + math.Rand(-120, 120), 0)
        local dist = math.Rand(min_dist, max_dist)
        local desired = pos - ang:Forward() * dist
        local tr = util.TraceHull({
            start = pos,
            endpos = desired,
            filter = viewer,
            maxs = Vector(32,32,32),
            mins = -Vector(32,32,32)
        })
        local return_pos = tr.HitPos
        return_pos = util.TraceLine({
            start = return_pos,
            endpos = return_pos - vector_up * 300
        }).HitPos
        local real_dist = return_pos:Distance(pos)
        if real_dist > min_dist and real_dist < max_dist then
            return return_pos
        end
    end
    return false
end

function EVENT:StartScare( ply )
    local pos = GetNearBehindPos(ply:GetPos(),ply,ply:EyeAngles())
    if not pos then return false, "failed" end
    self.Ent = ents.Create("ent_zc_anim")
    self.Ent:SetPos(pos)--
    self.Ent:SetModel("models/Humans/Group01/male_06.mdl")
    self.Ent:SetMaterial("models/debug/debugwhite")
    self.Ent:SetColor(color_black)
    local ang = ply:EyeAngles()
    ang.pitch = 0
    ang.roll = 0
    self.Ent:SetAngles(ang)
    self.Ent:Spawn()
    self.Ent:SetWhiteListToSee(true)
    self.Ent:SetNetVar("CanSeeUserID",{[ply:UserID()] = true})
    self.Ent:ResetSequence(126)
    self.Target = ply
    local EndIndex = self.Ent:EntIndex()
    timer.Simple(1,function()
        if IsValid(ply) and ply:Alive() then return end
        ply:SendLua("Entity("..EndIndex.."):EmitSound(\"cry1.wav\")") -- 
    end)
    self.Started = CurTime()
end
--126 idle
--13 attack
--EVENT:StartScare( Player(13) )--

function EVENT:Think( ply )
    if !ply:Alive() then self:StopScare() return end
    if !IsValid(self.Ent) then self:StopScare() return end
    if self.Started + 90 < CurTime() then self:StopScare() return end
    local target = self.Target or ply
    local entpos = self.Ent:GetPos()
    local targetpos = target:GetPos()
    local lookpos = entpos + vector_up * 32
    if IsLookingAt(ply, lookpos, 0.75) and hg.isVisible(lookpos, ply:EyePos(), {self.Ent, ply}, MASK_VISIBLE) then
        self.Seen = true
        self.LookinTime = self.LookinTime or CurTime() + 0.2
        if self.LookinTime < CurTime() then
            self:Run(ply)
            return
        end
    end
    if self.Seen then
        self:Run(ply)
        return
    end
    local dir = targetpos - entpos
    if dir:LengthSqr() > 1 then
        local step = math.min(walk_speed * FrameTime(), dir:Length())
        self.Ent:SetPos(entpos + dir:GetNormalized() * step)
    end
    self.Ent:SetAngles((targetpos - self.Ent:GetPos()):Angle())
end

function EVENT:IsActive( ply )
    return IsValid(self.Ent) and IsValid(ply) and ply:Alive()
end

function EVENT:Run( ply )
    local plypos = ply:GetPos()
    local entpos = self.Ent:GetPos()
    local dir = plypos - entpos
    if dir:LengthSqr() > 1 then
        local step = math.min(run_speed * FrameTime(), dir:Length())
        self.Ent:SetPos(entpos + dir:GetNormalized() * step)
    end
    self.Ent:SetAngles((plypos - self.Ent:GetPos()):Angle())
    if !self.ScareSoundSend then
        self.ScareSoundSend = true
        self.Ent:ResetSequence(13)
        ply:SendLua("surface.PlaySound(\"lurker_scream.wav\")")
    end
    if self.Ent:GetPos():Distance(ply:GetPos()) < 50 then
        ply:KillSilent()
        timer.Simple(0, function()
            if IsValid(ply.FakeRagdoll) then
                ply.FakeRagdoll:Remove()
            end
            local rag = ply:GetRagdollEntity()
            if IsValid(rag) then
                rag:Remove()
            end
        end)
        timer.Simple(0.6,function()
            ply:SendLua("RunConsoleCommand(\"stopsound\")")
        end)--
        for k,v in player.Iterator() do
            v:ScreenFade(SCREENFADE.IN, Color(0,0,0), 0.7, 0.4)
        end
        self.Ent:Remove()
    end
end

function EVENT:StopScare( ply )
    if IsValid(self.Ent) then
        self.Ent:Remove()
    end
end

MODE:AddEvent(EVENT)
