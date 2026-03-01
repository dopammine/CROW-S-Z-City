AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "Wheelchair"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/props_unique/wheelchair01.mdl"
ENT.CanSwitchHeadlights = false
ENT.CanSwitchTurnSignals = false
ENT.AngularDrag = Vector( -0.8, -0.8, -10 )

DEFINE_BASECLASS( "base_glide_car" )

if CLIENT then
    ENT.CameraOffset = Vector( -140, 0, 45 )
    ENT.CameraAngleOffset = Angle( 4, 0, 0 )
    ENT.MaxSoundDistance = 2500

    function ENT:OnUpdateMisc()
        BaseClass.OnUpdateMisc( self )

        local inVehicle = LocalPlayer():GlideGetVehicle() == self

        if inVehicle then
            if not self.happyWheelsSound then
                local snd = CreateSound( self, "happywheels.wav" )
                snd:SetSoundLevel( 140 )
                snd:PlayEx( 1, 100 )
                self.happyWheelsSound = snd
            end
        elseif self.happyWheelsSound then
            self.happyWheelsSound:Stop()
            self.happyWheelsSound = nil
        end
    end

    function ENT:OnRemove( fullUpdate )
        if self.happyWheelsSound then
            self.happyWheelsSound:Stop()
            self.happyWheelsSound = nil
        end

        BaseClass.OnRemove( self, fullUpdate )
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 8 )
    ENT.StartupTime = 0.2

    function ENT:CreateFeatures()
        self:SetSteerConeMaxAngle( 0.25 )
        self:SetForwardTractionMax( 1400 )
        self:SetSideTractionMax( 1800 )
        self:SetSideTractionMin( 700 )
        self:SetSideTractionMultiplier( 18 )

        self:SetSuspensionLength( 5 )
        self:SetSpringStrength( 350 )
        self:SetSpringDamper( 1200 )

        self:SetTransmissionEfficiency( 0.65 )
        self:SetDifferentialRatio( 0.6 )
        self:SetBrakePower( 1600 )

        self:SetMaxRPM( 5200 )
        self:SetMinRPM( 500 )
        self:SetMinRPMTorque( 700 )
        self:SetMaxRPMTorque( 1100 )

        self:CreateSeat( Vector( -12, 0, 10 ), Angle( 0, 270, 0 ), Vector( 0, 60, 0 ), true )

        self:CreateWheel( Vector( 10, 20, 5 ), { radius = 9, steerMultiplier = 1, modelScale = Vector( 0.2, 1, 1 ), disableSounds = true } )
        self:CreateWheel( Vector( 10, -20, 5 ), { radius = 9, steerMultiplier = 1, modelScale = Vector( 0.2, 1, 1 ), disableSounds = true } )
        self:CreateWheel( Vector( -22, 20, 5 ), { radius = 9, modelScale = Vector( 0.2, 1, 1 ), disableSounds = true } )
        self:CreateWheel( Vector( -22, -20, 5 ), { radius = 9, modelScale = Vector( 0.2, 1, 1 ), disableSounds = true } )

        self:ChangeWheelRadius( 9 )

        for _, w in ipairs( self.wheels ) do
            Glide.HideEntity( w, true )
        end
    end
end
