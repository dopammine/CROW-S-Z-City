util.AddNetworkString("hg_vote_endround")

local votes = {}
local cooldown = {}
local minPlayers = 2
local ratio = 0.6
local voteCooldown = 20
local minRoundTime = 600

local function getEligiblePlayers()
	local count = 0
	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR then
			count = count + 1
		end
	end
	return count
end

local function votesNeeded()
	return math.max(1, math.ceil(getEligiblePlayers() * ratio))
end

local function clearVotes()
	table.Empty(votes)
end

hook.Add("ZB_EndRound", "hg_vote_endround_clear", clearVotes)
hook.Add("ZB_StartRound", "hg_vote_endround_clear_start", clearVotes)
hook.Add("PlayerDisconnected", "hg_vote_endround_disconnect", function(ply)
	if votes[ply:SteamID()] then
		votes[ply:SteamID()] = nil
	end
end)

net.Receive("hg_vote_endround", function(_, ply)
	if not IsValid(ply) then return end
	if zb and zb.ROUND_STATE ~= 1 then
		ply:ChatPrint("Round is not active.")
		return
	end
	if zb and zb.ROUND_START and CurTime() < zb.ROUND_START + minRoundTime then
		local remaining = math.ceil((zb.ROUND_START + minRoundTime) - CurTime())
		ply:ChatPrint("You can vote in " .. remaining .. "s.")
		return
	end

	local eligible = getEligiblePlayers()
	if eligible < minPlayers then
		ply:ChatPrint("Not enough players to vote.")
		return
	end

	local now = CurTime()
	if cooldown[ply] and cooldown[ply] > now then
		local remaining = math.ceil(cooldown[ply] - now)
		ply:ChatPrint("Wait " .. remaining .. "s before voting again.")
		return
	end
	cooldown[ply] = now + voteCooldown

	local sid = ply:SteamID()
	if votes[sid] then
		votes[sid] = nil
		ply:ChatPrint("You canceled your vote to end the round.")
	else
		votes[sid] = true
		ply:ChatPrint("You voted to end the round.")
	end

	local count = table.Count(votes)
	local need = votesNeeded()
	for _, p in player.Iterator() do
		if p:Team() ~= TEAM_SPECTATOR then
			p:ChatPrint("End round votes: " .. count .. "/" .. need)
		end
	end

	if count >= need then
		clearVotes()
		if zb and type(zb.EndRound) == "function" then
			zb:EndRound()
		end
	end
end)
