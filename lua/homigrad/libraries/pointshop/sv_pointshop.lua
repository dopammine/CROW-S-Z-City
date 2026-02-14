--
hg.Pointshop = hg.Pointshop or {}

local PLUGIN = hg.Pointshop
PLUGIN.PlayerInstances = PLUGIN.PlayerInstances or {}

hook.Add("DatabaseConnected", "PointshopCreateData", function()
	local query

	query = mysql:Create("hg_pointshop")
		query:Create("steamid", "VARCHAR(20) NOT NULL")
		query:Create("steam_name", "VARCHAR(32) NOT NULL")
		query:Create("donpoints", "FLOAT NOT NULL")
		query:Create("points", "FLOAT NOT NULL")
        query:Create("items", "TEXT NOT NULL")
		query:PrimaryKey("steamid")
	query:Execute()

    --hook.Run("ZPointshopLoaded")

    PLUGIN.Active = true
end)

--local query = mysql:Drop("zb_experience")
--query:Execute()

hook.Add( "PlayerInitialSpawn","Pointshop_OnInitSpawn", function( ply )
    local name = ply:Name()
	local steamID64 = ply:SteamID64()

    if not PLUGIN.Active then
        PLUGIN.PlayerInstances[steamID64] = {}

		PLUGIN.PlayerInstances[steamID64].donpoints = 0
        PLUGIN.PlayerInstances[steamID64].points = 0
        PLUGIN.PlayerInstances[steamID64].items = {}
        return
    end 

	local query = mysql:Select("hg_pointshop")
		query:Select("donpoints")
		query:Select("points")
        query:Select("items")
		query:Where("steamid", steamID64)
		query:Callback(function(result)
			if (IsValid(ply) and istable(result) and #result > 0 and result[1].donpoints) then
				local updateQuery = mysql:Update("hg_pointshop")
					updateQuery:Update("steam_name", name)
					updateQuery:Where("steamid", steamID64)
				updateQuery:Execute()

				PLUGIN.PlayerInstances[steamID64] = {}

                PLUGIN.PlayerInstances[steamID64].donpoints = tonumber(result[1].donpoints)
                PLUGIN.PlayerInstances[steamID64].points = tonumber(result[1].points)
                PLUGIN.PlayerInstances[steamID64].items = util.JSONToTable(result[1].items)

                hook.Run( "PS_PlayerLoaded", ply, steamID64 )
			else
				local insertQuery = mysql:Insert("hg_pointshop")
					insertQuery:Insert("steamid", steamID64)
					insertQuery:Insert("steam_name", name)
					insertQuery:Insert("donpoints", 0)
		            insertQuery:Insert("points", 0)
                    insertQuery:Insert("items", util.TableToJSON({}))
				insertQuery:Execute()

				PLUGIN.PlayerInstances[steamID64] = {}

				PLUGIN.PlayerInstances[steamID64].donpoints = 0
                PLUGIN.PlayerInstances[steamID64].points = 0
                PLUGIN.PlayerInstances[steamID64].items = {}

			end
		end)
	query:Execute()
end)


local plyMeta = FindMetaTable("Player")

function plyMeta:GetPointshopVars()
    local steamID64 = self:SteamID64()
    if not util.IsBinaryModuleInstalled("mysqloo")  then
        PLUGIN.PlayerInstances[steamID64] = PLUGIN.PlayerInstances[steamID64] or {}
        PLUGIN.PlayerInstances[steamID64].donpoints = PLUGIN.PlayerInstances[steamID64].donpoints or 0
        PLUGIN.PlayerInstances[steamID64].points = PLUGIN.PlayerInstances[steamID64].points or 0
        PLUGIN.PlayerInstances[steamID64].items = PLUGIN.PlayerInstances[steamID64].items or {}
        return PLUGIN.PlayerInstances[steamID64]
    end

    return PLUGIN.PlayerInstances[steamID64]
end

function plyMeta:PS_AddPoints( ammout )
    local pointshopVars = self:GetPointshopVars()

    if ammout < 1 then
        return false, "How."
    end

    self:PS_SetPoints(pointshopVars.points + ammout)

    if callback then
        callback( self )
    end

    return true, ammout .. " points added !pointshop to open a pointshop"
end

function plyMeta:PS_SetPoints( value )
	local steamID64 = self:SteamID64()
    local pointshopVars = self:GetPointshopVars()

    if util.IsBinaryModuleInstalled("mysqloo") then
        local updateQuery = mysql:Update("hg_pointshop")
            updateQuery:Update("points", value)
            updateQuery:Where("steamid", steamID64)
        updateQuery:Execute()
    end

    pointshopVars.points = value
end

function plyMeta:PS_TakePoints( ammout, callback )
    local pointshopVars = self:GetPointshopVars()

    if ammout > pointshopVars.points then
        return false, "Not enough ZPoints."
    end

    self:PS_SetPoints(pointshopVars.points - ammout)

    if callback then
        callback( self )
    end

    return true, ammout .. " ZPoints spent."
end

-- ATTACK THE D POINT

function plyMeta:PS_AddDPoints( ammout )
    local pointshopVars = self:GetPointshopVars()

    if ammout < 1 then
        return false, "How."
    end

    self:PS_SetDPoints(pointshopVars.donpoints + ammout)

    if callback then
        callback( self )
    end

    return true, ammout .. " DZPoints added !pointshop to open a pointshop"
end

function plyMeta:PS_SetDPoints( value )
	local steamID64 = self:SteamID64()
    local pointshopVars = self:GetPointshopVars()

    if util.IsBinaryModuleInstalled("mysqloo") then
        local updateQuery = mysql:Update("hg_pointshop")
            updateQuery:Update("donpoints", value)
            updateQuery:Where("steamid", steamID64)
        updateQuery:Execute()
    end

    pointshopVars.donpoints = value
end

function plyMeta:PS_TakeDPoints( ammout, callback )
    local pointshopVars = self:GetPointshopVars()

    if ammout > pointshopVars.donpoints then
        return false, "Not enough DZPoints."
    end

    self:PS_SetDPoints(pointshopVars.donpoints - ammout)

    if callback then
        callback( self )
    end

    return true, ammout .. " DZPoints spent."
end

-- Items functions

function plyMeta:PS_SetItems( tItems )
    local steamID64 = self:SteamID64()
    local pointshopVars = self:GetPointshopVars()

    if util.IsBinaryModuleInstalled("mysqloo") then
        local updateQuery = mysql:Update("hg_pointshop")
            updateQuery:Update("items", util.TableToJSON(tItems))
            updateQuery:Where("steamid", steamID64)
        updateQuery:Execute()
    end

    pointshopVars.items = tItems
end

function plyMeta:PS_AddItem( uid )
    if not hg.PointShop.Items[uid] then return end
    local pointshopVars = self:GetPointshopVars()

    pointshopVars.items[ uid ] = true

    self:PS_SetItems(pointshopVars.items)
end

function plyMeta:PS_HasItem( uid )
    local pointshopVars = self:GetPointshopVars()
    --PrintTable(pointshopVars)
    if !pointshopVars then return false end
    return pointshopVars.items[ uid ] or false
end

--print(Player(2):PS_HasItem( "test_item_1" ))

-- networking and other

util.AddNetworkString("hg_pointshop_net")
util.AddNetworkString("hg_pointshop_sync")

function PLUGIN:NET_SendPointShopVars( ply )

    net.Start( "hg_pointshop_net" )
        net.WriteTable( ply:GetPointshopVars() )
    net.Send( ply )
end

--PLUGIN:NET_SendPointShopVars( Player(2) )

util.AddNetworkString("hg_pointshop_send_notificate")

function PLUGIN:NET_BuyItem( ply, uid )
    if hg.PointShop.Items[uid].ISDONATE then return end
    if not hg.PointShop.Items[uid] then print(ply, "[PS-ZCity] The player is trying to buy invalid item.", "UID: "..uid ) return end
    if ply:PS_HasItem( uid ) then PLUGIN:NET_SendPointShopVars( ply ) return end

    local yes = false
    local reason = ""

    if hg.PointShop.Items[uid].ISDONATE then
        yes, reason = ply:PS_TakeDPoints(hg.PointShop.Items[uid].PRICE, function() ply:PS_AddItem( uid ) end)
    else
        yes, reason = ply:PS_TakePoints(hg.PointShop.Items[uid].PRICE, function() ply:PS_AddItem( uid ) end)
    end
    
    net.Start( "hg_pointshop_send_notificate" )
        net.WriteString(reason)
    net.Send( ply )

    PLUGIN:NET_SendPointShopVars( ply )
end

function PLUGIN:NET_GetBuyedItems( ply )
    PLUGIN:NET_SendPointShopVars( ply )
end

net.Receive("hg_pointshop_net",function( _, ply )
    if ply.PSNetCD and ply.PSNetCD > CurTime() then return end

    ply.PSNetCD = CurTime() + 0.01

    local str = net.ReadString()
    local funcstring = PLUGIN[ "NET_" .. str ]

    if not funcstring then print(ply, "[PS-ZCity] Player trying to call an invalid function!", "NAME: "..str ) return end
    local vars = net.ReadTable()
    if table.Count(vars) > 5 then print(ply, "[PS-ZCity] The player is trying to send a bunch of vars to the net.", "NAME: "..str ) return end

    funcstring( PLUGIN, ply, unpack(vars) )
end)

hook.Add("HG_PlayerSay","OpenPointShop",function(ply, txtTbl, txt)
    if txt == "!pointshop" then
        ply:ConCommand("hg_pointshop")
    end
end)

hook.Add("PlayerDeath", "PointshopEarnPoints", function(victim, _, attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if attacker == victim then return end
    if IsValid(victim) and victim:IsPlayer() and attacker.Team and victim.Team and attacker:Team() == victim:Team() then return end

    attacker:PS_AddPoints(5)
end)

concommand.Add("hg_setpoints",function(ply, cmd, args)
    if not ply:IsAdmin() then return end

    local lenargs = #args
    local target = player.GetListByName(lenargs > 1 and args[1] or ply:Name())[1]
    if not IsValid(target) then return end

    local newpoints = tonumber(lenargs > 1 and args[2] or args[1])
    if not newpoints then return end

    target:PS_SetPoints(math.max(newpoints, 0))
    net.Start("hg_pointshop_sync")
        net.WriteTable(target:GetPointshopVars())
    net.Send(target)
end)
