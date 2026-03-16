if not CLIENT then return end

hg = hg or {}
if hg._aprilfools_arabic then return end
hg._aprilfools_arabic = true

local map = {
	["a"] = "ا", ["b"] = "ب", ["c"] = "ج", ["d"] = "د", ["e"] = "ي", ["f"] = "ف", ["g"] = "ق", ["h"] = "ه",
	["i"] = "ي", ["j"] = "ج", ["k"] = "ك", ["l"] = "ل", ["m"] = "م", ["n"] = "ن", ["o"] = "و", ["p"] = "پ",
	["q"] = "ق", ["r"] = "ر", ["s"] = "س", ["t"] = "ت", ["u"] = "و", ["v"] = "ڤ", ["w"] = "و", ["x"] = "خ",
	["y"] = "ي", ["z"] = "ز",
	["A"] = "ا", ["B"] = "ب", ["C"] = "ج", ["D"] = "د", ["E"] = "ي", ["F"] = "ف", ["G"] = "ق", ["H"] = "ه",
	["I"] = "ي", ["J"] = "ج", ["K"] = "ك", ["L"] = "ل", ["M"] = "م", ["N"] = "ن", ["O"] = "و", ["P"] = "پ",
	["Q"] = "ق", ["R"] = "ر", ["S"] = "س", ["T"] = "ت", ["U"] = "و", ["V"] = "ڤ", ["W"] = "و", ["X"] = "خ",
	["Y"] = "ي", ["Z"] = "ز",
	["0"] = "٠", ["1"] = "١", ["2"] = "٢", ["3"] = "٣", ["4"] = "٤",
	["5"] = "٥", ["6"] = "٦", ["7"] = "٧", ["8"] = "٨", ["9"] = "٩"
}

local wordMap = {
	["disconnect"] = "قطع الاتصال",
	["main"] = "الرئيسية",
	["menu"] = "القائمة",
	["settings"] = "الإعدادات",
	["appearance"] = "المظهر",
	["achievements"] = "الإنجازات",
	["discord"] = "ديسكورد",
	["return"] = "عودة",
	["vote"] = "تصويت",
	["end"] = "إنهاء",
	["round"] = "الجولة",
	["vote end round"] = "تصويت إنهاء الجولة",
	["halal"] = "حلال",
	["bar"] = "شريط",
	["crow's"] = "كرو",
	["z-city"] = "ز-المدينة",
	["fuck you"] = "بس يا حلو"
}

local skipPhrases = {
	["halal bar"] = true,
	["so not halal mode"] = true,
	["nuke incoming"] = true,
	["skip ad"] = true
}

local map2 = {
	["th"] = "ث",
	["sh"] = "ش",
	["ch"] = "تش",
	["kh"] = "خ",
	["gh"] = "غ",
	["ph"] = "ف",
	["wh"] = "و"
}

local function aprilFoolsEnabled()
	local cvar = GetConVar("hg_aprilfools")
	if cvar then
		return cvar:GetBool()
	end
	return GetGlobalBool("hg_aprilfools", false)
end

local function applyDigits(text)
	return text:gsub("%d", function(d) return map[d] or d end)
end

local function transliterateWord(word)
	local out = {}
	local i = 1
	while i <= #word do
		local ch = word:sub(i, i)
		local nextch = word:sub(i + 1, i + 1)
		local pair = nextch ~= "" and string.lower(ch .. nextch) or nil
		if pair and map2[pair] then
			out[#out + 1] = map2[pair]
			i = i + 2
		else
			out[#out + 1] = map[ch] or ch
			i = i + 1
		end
	end
	return table.concat(out)
end

local function arabifySegment(text)
	local normalized = string.lower(text)
	normalized = normalized:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
	if skipPhrases[normalized] then
		return text
	end
	if wordMap[normalized] then
		return wordMap[normalized]
	end
	local out = {}
	for word, sep in string.gmatch(text, "([%a%']+)([^%a%']*)") do
		local lw = string.lower(word)
		out[#out + 1] = wordMap[lw] or transliterateWord(word)
		out[#out + 1] = sep
	end
	if #out == 0 then return text end
	return table.concat(out)
end

local function arabify(text)
	if not isstring(text) or not aprilFoolsEnabled() then return text end
	local out = {}
	local i = 1
	while i <= #text do
		local c = text:sub(i, i)
		if c == "<" then
			local close = text:find(">", i, true)
			if close then
				out[#out + 1] = text:sub(i, close)
				i = close + 1
			else
				out[#out + 1] = c
				i = i + 1
			end
		else
			local nextTag = text:find("<", i, true) or (#text + 1)
			local segment = text:sub(i, nextTag - 1)
			segment = applyDigits(segment)
			out[#out + 1] = arabifySegment(segment)
			i = nextTag
		end
	end
	return table.concat(out)
end

hg.AprilFoolsArabify = arabify

local surface_DrawText = surface.DrawText
hg.arabicRaw = hg.arabicRaw or {}
hg.arabicRaw.surface_DrawText = surface_DrawText
surface.DrawText = function(text)
	return surface_DrawText(arabify(text))
end

local surface_GetTextSize = surface.GetTextSize
hg.arabicRaw.surface_GetTextSize = surface_GetTextSize
surface.GetTextSize = function(text)
	return surface_GetTextSize(arabify(text))
end

local draw_DrawText = draw.DrawText
hg.arabicRaw.draw_DrawText = draw_DrawText
draw.DrawText = function(text, font, x, y, color, align)
	return draw_DrawText(arabify(text), font, x, y, color, align)
end

local draw_SimpleText = draw.SimpleText
hg.arabicRaw.draw_SimpleText = draw_SimpleText
draw.SimpleText = function(text, font, x, y, color, xalign, yalign)
	return draw_SimpleText(arabify(text), font, x, y, color, xalign, yalign)
end

local draw_SimpleTextOutlined = draw.SimpleTextOutlined
hg.arabicRaw.draw_SimpleTextOutlined = draw_SimpleTextOutlined
draw.SimpleTextOutlined = function(text, font, x, y, color, xalign, yalign, outlinewidth, outlinecolor)
	return draw_SimpleTextOutlined(arabify(text), font, x, y, color, xalign, yalign, outlinewidth, outlinecolor)
end
