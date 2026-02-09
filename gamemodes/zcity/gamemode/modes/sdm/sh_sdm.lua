local MODE = MODE

MODE.name = "sdm"
MODE.MapSize = 7500

function MODE:HG_MovementCalc_2(mul, ply, cmd, mv)
	if (zb.ROUND_START or 0) + 20 > CurTime() and cmd then
		local speed = math.Clamp(cmd:GetForwardMove() / 400, 0, 1) + math.Clamp(math.abs(cmd:GetSideMove()) / 400, 0, 1)
		mul[1] = mul[1] * (1 - speed)
	end
end

function MODE:PlayerCanLegAttack(ply)
	if zb.CROUND ~= "sdm" then return end
	if (zb.ROUND_START or 0) + 20 > CurTime() then
		return false
	end
end
