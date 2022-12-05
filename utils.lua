---
-- /@ loot toast; // s0h2x, pretty_wow @/

local _, private = ...;
local assert, next, pairs = assert, next, pairs;
local unpack = unpack;
local tonumber = tonumber;
local getmetatable = getmetatable;
local tInsert = table.insert;

local texture, fontstring;
local prototype = {CreateFrame("Frame"), CreateFrame("Button")};

local subinit = function()
	for _, data in pairs(prototype) do
		texture = getmetatable(data:CreateTexture());
		fontstring = getmetatable(data:CreateFontString());
	end
end
subinit();

-- mixin frames to table
private.Mixin = function(object, ...)
	local mixins = {...};
	for _, mixin in pairs(mixins) do
		for k, v in next, mixin do
			object[k] = v;
		end
	end
	return object;
end

-- method shown
local methodshown = function(self, data)
	if data and data ~= false then
		self:Show();
	else
		self:Hide();
	end
end

function texture.__index:SetShown(...)
	methodshown(self, ...);
end

function fontstring.__index:SetShown(...)
	methodshown(self, ...);
end

local GetNumBattlegroundTypes = GetNumBattlegroundTypes;
local GetBattlegroundInfo = GetBattlegroundInfo;
local GetRandomBGHonorCurrencyBonuses = GetRandomBGHonorCurrencyBonuses;
local GetHolidayBGHonorCurrencyBonuses = GetHolidayBGHonorCurrencyBonuses;

-- get info about battlefield rewards
private.GetAmountBattlefieldBonus = function()
	-- @param [boolean] hasWon - whether player has won bonus BG
	-- @param [numbers] winHonorAmount - bonus honor points on current BG
	-- @param [numbers] winArenaAmount - bonus arena points on current BG
	local name, canEnter, isHoliday, isRandom;
	local hasWon, winHonorAmount, winArenaAmount;
	for i=1, GetNumBattlegroundTypes() do
		name, canEnter, isHoliday, isRandom = GetBattlegroundInfo(i);
		if isRandom and name then
			hasWon, winHonorAmount, winArenaAmount = GetRandomBGHonorCurrencyBonuses();
		elseif isHoliday and name then
			hasWon, winHonorAmount, winArenaAmount = GetHolidayBGHonorCurrencyBonuses();
		end
	end
	-- returns: info about battlefield rewards
	return hasWon, winHonorAmount, winArenaAmount;
end

-- sanitizes and convert patterns into gmatch compatible ones
local sanitize_cache = {};
local function SanitizePattern(pattern)
	assert(pattern, "bad argument #1 to \'SanitizePattern\' (string expected, got nil)");
	if not sanitize_cache[pattern] then
		-- @param [string] "pattern" - unformatted pattern
		local ret = pattern;
		-- remove '|3-formid(text)' grammar sequence (no need to handle this for this case)
		-- ret = ret:gsub("%|3%-1%((.-)%)", "%1")
		-- escape magic characters
		ret = ret:gsub("([%+%-%*%(%)%?%[%]%^])", "%%%1");
		-- remove capture indexes
		ret = ret:gsub("%d%$", "");
		-- catch all characters
		ret = ret:gsub("(%%%a)", "%(%1+%)");
		-- convert all %s to .+
		ret = ret:gsub("%%s%+", ".+");
		-- set priority to numbers over strings
		ret = ret:gsub("%(.%+%)%(%%d%+%)", "%(.-%)%(%%d%+%)");
		-- cache it
		sanitize_cache[pattern] = ret;
	end
	-- returns: [string] simplified gmatch compatible pattern
	return sanitize_cache[pattern];
end

local capture_cache = {};
local function GetCaptures(pat)
	-- returns the indexes of a given regex pattern
	-- @param [string] "pat" - unformatted pattern
	if not capture_cache[pat] then
		local result = {};
		for capture_index in pat:gmatch("%%(%d)%$") do
			capture_index = tonumber(capture_index);
			tInsert(result, capture_index);
		end
		capture_cache[pat] = #result > 0 and result;
	end
	-- returns: [numbers] capture indexes
	return capture_cache[pat];
end

-- same as string.match but aware of capture indexes
string.cmatch = function(str, pat)
	-- @param [string] "str" - input string that should be matched
	-- @param [string] "pat" - unformatted pattern
	
	-- read capture indexes:
	local capture_indexes = GetCaptures(pat);
	local sanitized_pat = SanitizePattern(pat);
	
	-- if no capture indexes then use original string.match
	if not capture_indexes then
		return str:match(sanitized_pat);
	end
	-- read captures
	local captures = {str:match(sanitized_pat)};
	if #captures == 0 then return; end
	
	-- put entries into the proper return values
	local result = {};
	for current_index, capture in pairs(captures) do
		local correct_index = capture_indexes[current_index];
		result[correct_index] = capture;
	end
	-- returns: [strings] matched string in capture order
	return unpack(result);
end