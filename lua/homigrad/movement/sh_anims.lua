local Angle, Vector, AngleRand, VectorRand, math, hook, util, game = Angle, Vector, AngleRand, VectorRand, math, hook, util, game
--\\ Custom running anim rate
	hook.Add("UpdateAnimation", "NormAnimki", function(ply, vel, maxSeqGroundSpeed)
		if not IsValid(ply) or not ply:Alive() or not ply:OnGround() then return end
		if ply:GetNWFloat("hg_dance_until", 0) > CurTime() then
			local seq = ply:LookupSequence("amod_oneyplaysdance")
			if seq and seq > 0 then
				ply:SetSequence(seq)
				ply:SetPlaybackRate(1)
				ply:SetCycle((CurTime() * 0.15) % 1)
				return ply, vel, maxSeqGroundSpeed
			end
		end

		if vel:LengthSqr() >= 77000 and vel:LengthSqr() < 110000 then
			ply:SetPlaybackRate(1.2)
			return ply, vel, maxSeqGroundSpeed
		end

		if vel:LengthSqr() >= 77000 then
			ply:SetPlaybackRate(1.4)
			return ply, vel, maxSeqGroundSpeed
		end
	end)
--//

--\\ Custom running anim activity
	local runHoldTypes = {
		["normal"] = true,
		["slam"] = true,
		["grenade"] = true
	}

	hook.Add( "CalcMainActivity", "RunningAnim", function(ply, vel)
	if ply:GetNWFloat("hg_dance_until", 0) > CurTime() then
		local seq = ply:LookupSequence("amod_oneyplaysdance")
		if seq and seq > 0 then
			return ACT_IDLE, seq
		end
	end
		local wep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon()
		local isAmputated = ply.organism and (ply.organism.llegamputated or ply.organism.rlegamputated)
		if (not ply:InVehicle()) and ply:IsOnGround() and vel:Length() > 250 and wep and runHoldTypes[wep:GetHoldType()] and not isAmputated then
			local isFurry = ply.PlayerClassName == "furry"
			local anim = ACT_HL2MP_RUN_FAST
			if ply:IsOnFire() then
				anim = ACT_HL2MP_RUN_PANICKED
			elseif isFurry then
				if hg.KeyDown(ply, IN_WALK) and not hg.KeyDown(ply, IN_BACK) then
					anim = ACT_HL2MP_RUN_ZOMBIE_FAST
				else
					anim = ACT_HL2MP_RUN_FAST
				end
			else
				anim = ACT_HL2MP_RUN_FAST
			end

			return anim, -1
		end

		if (not ply:InVehicle()) and ply:IsOnGround() and isAmputated then
			local anim = ACT_HL2MP_WALK_ZOMBIE_06
			if vel:Length() > 250 then
				anim = ACT_HL2MP_RUN_ZOMBIE_FAST
			end
			return anim, -1
		end
	end)
--//

hook.Add("HG_MovementCalc_2", "AmputatedNoJump", function(mul, ply, cmd, mv)
	if not IsValid(ply) or not ply:Alive() then return end
	if ply:GetNWFloat("hg_dance_until", 0) > CurTime() then
		if cmd then
			cmd:SetForwardMove(0)
			cmd:SetSideMove(0)
			cmd:RemoveKey(IN_FORWARD)
			cmd:RemoveKey(IN_BACK)
			cmd:RemoveKey(IN_MOVELEFT)
			cmd:RemoveKey(IN_MOVERIGHT)
			cmd:RemoveKey(IN_JUMP)
			cmd:RemoveKey(IN_DUCK)
			cmd:RemoveKey(IN_SPEED)
		end
		if mv then
			mv:SetForwardSpeed(0)
			mv:SetSideSpeed(0)
			mv:SetMaxClientSpeed(0)
			mv:SetMaxSpeed(0)
		end
		mul[1] = 0.01
		return
	end
	if ply.organism and (ply.organism.llegamputated or ply.organism.rlegamputated) then
		if cmd and cmd:KeyDown(IN_SPEED) then
			local run = ply:GetRunSpeed()
			local walk = ply:GetWalkSpeed()
			if run > 0 and walk > 0 then
				mul[1] = math.min(mul[1], walk / run)
			end
		end
		if cmd then
			cmd:RemoveKey(IN_JUMP)
		end
		if mv then
			mv:RemoveKey(IN_JUMP)
		end
		if SERVER then
			if (ply._amputatedTripNext or 0) <= CurTime() then
				ply._amputatedTripNext = CurTime() + 0.4
				if ply:IsOnGround() and not ply:InVehicle() and ply:GetVelocity():Length2D() > 60 then
					if math.random() < 0.12 then
						hg.LightStunPlayer(ply, 0.7)
					end
				end
			end
		end
	end
end)
