AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Scary Pluv"
ENT.Category = "ZCity Other"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Chasing")
    self:NetworkVar("Entity", 0, "Target")
end
