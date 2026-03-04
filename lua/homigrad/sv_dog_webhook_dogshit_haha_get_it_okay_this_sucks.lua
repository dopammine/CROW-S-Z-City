if CLIENT then return end

hg = hg or {}
hg.DogWebhook = hg.DogWebhook or {}

local dogWebhook = CreateConVar("dog_webhook_url", "", FCVAR_ARCHIVE)

local function dogMaskWebhook(url)
	local id = string.match(url, "https?://discord%.com/api/webhooks/(%d+)/")
	if id then
		return "https://discord.com/api/webhooks/" .. id .. "/***"
	end
	return url
end

local function dogSanitizeWebhookUrl(rawUrl)
	local cleaned = tostring(rawUrl or "")
	cleaned = cleaned:gsub("[%s\"`<>]", "")
	return cleaned
end

local function dogSendWebhook(ply, cheatText, signals)
	local rawUrl = dogWebhook:GetString() or ""
	local url = dogSanitizeWebhookUrl(rawUrl)
	print(("[DOG] Webhook attempt url=%s"):format(dogMaskWebhook(url)))
	if url == "" then
		print("[DOG] Webhook url not set (dog_webhook_url)")
		return
	end
	if not string.find(url, "discord.com/api/webhooks/", 1, true) then
		print("[DOG] Webhook url unexpected domain/path")
	end
	if not string.StartWith(url, "http://") and not string.StartWith(url, "https://") then
		print("[DOG] Webhook url invalid (must start with http:// or https://)")
		return
	end
	local hostname = GetConVar("hostname") and GetConVar("hostname"):GetString() or "unknown"
	local mapname = game.GetMap() or "unknown"
	local signalText = istable(signals) and table.concat(signals, ", ") or ""
	local content = ("DOG: Cheater detected\nServer: %s\nMap: %s\nPlayer: %s (%s)\nCheat: %s\nSignals: %s"):format(
		hostname,
		mapname,
		IsValid(ply) and ply:Nick() or "unknown",
		IsValid(ply) and ply:SteamID() or "unknown",
		cheatText or "unknown",
		signalText
	)
	local payload = util.TableToJSON({content = content})
	if HTTP then
		HTTP({
			url = url,
			method = "post",
			headers = {
				["Content-Type"] = "application/json",
				["Accept"] = "application/json",
				["User-Agent"] = "DOG-AntiCheat/1.0"
			},
			body = payload,
			success = function(body, _, _, code)
				local resolvedCode = code
				if not resolvedCode and body and tonumber(body) then
					resolvedCode = tonumber(body)
				end
				print(("[DOG] Webhook response code=%s"):format(resolvedCode or "nil"))
				if resolvedCode == 200 or resolvedCode == 204 then
					print("[DOG] Webhook delivered")
				else
					print("[DOG] Webhook unexpected response")
					if body and body ~= "" then
						print(("[DOG] Webhook response body: %s"):format(body))
					end
				end
			end,
			failed = function(err)
				print(("[DOG] Webhook failed: %s"):format(err))
			end
		})
	elseif http and http.Post then
		print("[DOG] Webhook using http.Post fallback")
		http.Post(url, {content = content}, function(body, _, _, code)
			print(("[DOG] Webhook response code=%s"):format(code or "nil"))
			if code == 200 or code == 204 then
				print("[DOG] Webhook delivered")
			else
				print("[DOG] Webhook unexpected response")
				if body and body ~= "" then
					print(("[DOG] Webhook response body: %s"):format(body))
				end
			end
		end, function(err)
			print(("[DOG] Webhook failed: %s"):format(err))
		end)
	else
		print("[DOG] Webhook HTTP API unavailable")
	end
end

hg.DogWebhook.Send = dogSendWebhook

concommand.Add("dog_webhook_test", function(ply)
	if IsValid(ply) then return end
	dogSendWebhook(nil, "test", {"manual_test"})
end)

concommand.Add("dog_webhook_show", function(ply)
	if IsValid(ply) then return end
	local rawUrl = dogWebhook:GetString() or ""
	local url = dogSanitizeWebhookUrl(rawUrl)
	print(("[DOG] Webhook raw url=%s"):format(rawUrl))
	print(("[DOG] Webhook sanitized url=%s"):format(url))
end)
