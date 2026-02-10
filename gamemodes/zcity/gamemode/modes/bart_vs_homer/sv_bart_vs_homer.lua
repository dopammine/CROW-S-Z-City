local MODE = MODE

MODE.name = "bart_vs_homer"
MODE.PrintName = "Bart vs Homer"
MODE.ROUND_TIME = 300
MODE.start_time = 8

util.AddNetworkString("bvh_roundend")
util.AddNetworkString("barthomer_start")
util.AddNetworkString("bvh_roundstart")

local function IsHomer(ply)
    local n = ply.PlayerClassName or ""
    return n == "homer"
end

local function AssignClasses(homer)
    for _, ply in ipairs(player.GetHumans()) do
        if not IsValid(ply) then continue end
        if ply == homer then
            ply:SetPlayerClass("homer")
            ply:SetTeam(1)
            if not ply:HasWeapon("weapon_hands_sh") then ply:Give("weapon_hands_sh") end
        else
            ply:SetPlayerClass("bart")
            ply:SetTeam(0)
            if not ply:HasWeapon("weapon_hands_sh") then ply:Give("weapon_hands_sh") end
        end
    end
end

local function GetHomer(self)
    local hid = self.saved and self.saved.homer_entindex or nil
    local homer = hid and Entity(hid) or nil
    if not IsValid(homer) then
        for _, ply in ipairs(player.GetHumans()) do
            local cls = (ply.GetPlayerClass and ply:GetPlayerClass()) or ply.PlayerClassName
            if cls == "homer" then return ply end
        end
    end
    return homer
end

function MODE:Intermission()
    game.CleanUpMap()
    local all = player.GetHumans()
    local candidates = {}
    for _, ply in ipairs(all) do
        if IsValid(ply) and ply:Team() ~= TEAM_SPECTATOR then
            candidates[#candidates + 1] = ply
        end
    end
    local homer = #candidates > 0 and candidates[math.random(#candidates)] or nil
    self.saved = self.saved or {}
    self.saved.homer_entindex = IsValid(homer) and homer:EntIndex() or nil

    AssignClasses(homer)
    for _, ply in ipairs(player.GetHumans()) do
        ply:SetupTeam(ply:Team())
    end

    net.Start("barthomer_start")
    net.WriteUInt(IsValid(homer) and homer:EntIndex() or 0, 16)
    net.Broadcast()

    net.Start("bvh_roundstart")
    net.Broadcast()

    if hg and hg.UpdateRoundTime then
        hg.UpdateRoundTime(self.ROUND_TIME)
    end
end

function MODE:RoundStart()
    for _, ply in ipairs(player.GetAll()) do
        ply:Freeze(false)
    end
    self._started = CurTime()
    if not (self.saved and self.saved.homer_entindex) then
        local all = player.GetHumans()
        local candidates = {}
        for _, p in ipairs(all) do
            if IsValid(p) and p:Team() ~= TEAM_SPECTATOR then
                candidates[#candidates + 1] = p
            end
        end
        local homer = #candidates > 0 and candidates[math.random(#candidates)] or nil
        self.saved = self.saved or {}
        self.saved.homer_entindex = IsValid(homer) and homer:EntIndex() or nil
        AssignClasses(homer)
    end
end

function MODE:PlayerSpawn(ply)
    if not IsValid(ply) then return end
    local hid = self.saved and self.saved.homer_entindex or nil
    local homer = hid and Entity(hid) or nil
    if IsValid(homer) and ply == homer then
        ply:SetPlayerClass("homer")
        ply:SetTeam(1)
        if not ply:HasWeapon("weapon_hands_sh") then ply:Give("weapon_hands_sh") end
    else
        ply:SetPlayerClass("bart")
        ply:SetTeam(0)
        if not ply:HasWeapon("weapon_hands_sh") then ply:Give("weapon_hands_sh") end
    end
end

function MODE:GiveEquipment()
    timer.Simple(0.1, function()
        local hid = self.saved and self.saved.homer_entindex or nil
        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) or not ply:Alive() then continue end
            local isHomer = (hid and ply:EntIndex() == hid)
            if isHomer then
                if ply:Team() ~= 1 then ply:SetTeam(1) end
                ply:SetPlayerClass("homer")
                zb.GiveRole(ply, "Homer", Color(255, 217, 15))
            else
                if ply:Team() ~= 0 then ply:SetTeam(0) end
                ply:SetPlayerClass("bart")
                zb.GiveRole(ply, "Bart", Color(220, 220, 220))
            end
            if not ply:HasWeapon("weapon_hands_sh") then ply:Give("weapon_hands_sh") end
            ply:SelectWeapon("weapon_hands_sh")
        end
    end)
end

function MODE:GetTeamSpawn()
    return nil, nil
end

function MODE:CheckAlivePlayers()
    return zb:CheckAliveTeams(true)
end

function MODE:ShouldRoundEnd()
    local grace = (self.start_time or 8) + 10
    if self._started and (CurTime() < (self._started + grace)) then
        return false
    end

    local homer = GetHomer(self)
    if not IsValid(homer) or not homer:Alive() then
        return true
    end

    local anyBartAlive = false
    for _, ply in ipairs(player.GetHumans()) do
        if ply == homer then continue end
        if ply:Alive() then
            local cls = (ply.PlayerClassName) or ((ply.GetPlayerClass and ply:GetPlayerClass()) and ply:GetPlayerClass())
            if cls == "bart" then
                anyBartAlive = true
                break
            end
        end
    end

    if not anyBartAlive then
        return true
    end

    return nil
end

function MODE:EndRound()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply.organism then
            ply.MeleeDamageMul = nil
            ply.organism.recoilmul = 1
            ply.organism.meleespeed = 1
            ply.organism.breakmul = 1
            local s = ply.organism.stamina
            if s then
                s.regen = 1
                s.range = 180
                s.max = 180
            end
        end
    end

    local homer = GetHomer(self)
    local winner = ""
    if IsValid(homer) and homer:Alive() then
        local anyBartAlive = false
        for _, ply in ipairs(player.GetHumans()) do
            if ply == homer then continue end
            if ply:Alive() then
                local cls = (ply.PlayerClassName) or ((ply.GetPlayerClass and ply:GetPlayerClass()) and ply:GetPlayerClass())
                if cls == "bart" then
                    anyBartAlive = true
                    break
                end
            end
        end
        if not anyBartAlive then
            winner = "homer"
        end
    else
        winner = "barts"
    end

    local data = {}
    for _, ply in ipairs(player.GetAll()) do
        local cls = (ply.PlayerClassName) or ((ply.GetPlayerClass and ply:GetPlayerClass()) and ply:GetPlayerClass())
        local role
        if cls == "homer" then
            role = "homer"
        elseif cls == "bart" then
            role = "bart"
        end
        if role then
            data[#data + 1] = {
                name = ply:Nick(),
                nick = ply:Nick(),
                role = role,
                alive = ply:Alive(),
                frags = ply:Frags()
            }
        end
    end

    timer.Simple(2, function()
        net.Start("bvh_roundend")
        net.WriteString(winner)
        net.WriteTable(data)
        net.Broadcast()
    end)
end

function MODE.GuiltCheck(attacker, victim, add, harm, amt)
    return 1, true
end
