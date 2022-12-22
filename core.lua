---
-- /@ loot toast; // s0h2x, pretty_wow @/

local select = select;
local unpack = unpack;
local next = next;
local pairs = pairs;
local ipairs = ipairs;
local tonumber = tonumber;
local tostring = tostring;
local format = string.format;
local match = string.match;
local gsub = string.gsub;
local sub = string.sub;
local tRemove = table.remove;
local tInsert = table.insert;
local tWipe = table.wipe;

local private = select(2,...);
local config = private.config;
local mixin = private.Mixin;

-- /* config */
local scale = config.scale;
local offset_x = config.offset_x;
local point_x = config.point_x;
local point_y = config.point_y;
local ignlevel = config.ignore_level;
local uptime = config.time;
local looting = config.looting;
local creating = config.creating;
local rolling =	config.rolling;
local currency_loot = config.money;
local recipes_learned = config.recipes;
local honor_award = config.honor;
local quality_low = config.low_level;
local quality_max = config.max_level;

local LOOTALERT_NUM_BUTTONS = config.numbuttons;

-- /* api's */
local UnitName = UnitName;
local UnitLevel = UnitLevel;
local UnitFactionGroup = UnitFactionGroup;
local PlaySoundFile = PlaySoundFile;
local GetSpellInfo = GetSpellInfo;
local GetItemInfo = GetItemInfo;
local GetUnitName = GetUnitName;
local GetBattlefieldScore = GetBattlefieldScore;
local GetNumBattlefieldScores = GetNumBattlefieldScores;
local GetBattlefieldWinner = GetBattlefieldWinner;
local GetMoneyString = GetMoneyString;
local GameTooltip = GameTooltip;
local playerFaction = UnitFactionGroup("player");
local playerWinner = PLAYER_FACTION_GROUP[playerFaction];
local playerName = UnitName("player");
local GetAmountBattlefieldBonus = private.GetAmountBattlefieldBonus;

-- /* assets */
local assets = [[Interface\AddOns\pretty_lootalert\assets\]];
local picn = assets.."UI-TradeSkill-Circle";
local SOUNDKIT = {
	UI_EPICLOOT_TOAST = assets.."ui_epicloot_toast_01.ogg",
	UI_GARRISON_FOLLOWER_LEARN_TRAIT = assets.."ui_garrison_follower_trait_learned_02.ogg",
	UI_LEGENDARY_LOOT_TOAST = assets.."ui_legendary_item_toast.ogg",
	UI_RAID_LOOT_TOAST_LESSER_ITEM_WON = assets.."ui_loot_toast_lesser_item_won_01.ogg",
};

-- /* consts */
local LE_ITEM_QUALITY_COMMON = 1;
local LE_ITEM_QUALITY_EPIC = 4;
local LE_ITEM_QUALITY_HEIRLOOM = 7;
local LE_ITEM_QUALITY_LEGENDARY = 5;
local LE_ITEM_QUALITY_POOR = 0;
local LE_ITEM_QUALITY_RARE = 3;
local LE_ITEM_QUALITY_UNCOMMON = 2;
local LE_ITEM_QUALITY_WOW_TOKEN = 8;
local LE_ITEM_QUALITY_ARTIFACT = 6;

local LOOT_ROLL_TYPE_NEED = 1;
local LOOT_ROLL_TYPE_GREED = 2;
local LOOT_ROLL_TYPE_DISENCHANT = 3;

local LOOT_BORDER_BY_QUALITY = {
	[LE_ITEM_QUALITY_UNCOMMON] = {0.34082, 0.397461, 0.53125, 0.644531},
	[LE_ITEM_QUALITY_RARE] = {0.272461, 0.329102, 0.785156, 0.898438},
	[LE_ITEM_QUALITY_EPIC] = {0.34082, 0.397461, 0.882812, 0.996094},
	[LE_ITEM_QUALITY_LEGENDARY] = {0.34082, 0.397461, 0.765625, 0.878906},
	[LE_ITEM_QUALITY_HEIRLOOM] = {0.34082, 0.397461, 0.648438, 0.761719},
	[LE_ITEM_QUALITY_ARTIFACT] = {0.272461, 0.329102, 0.667969, 0.78125},
};
local HONOR_BACKGROUND_TCOORDS = {
	["Alliance"] = {277, 113, 0.001953, 0.542969, 0.460938, 0.902344},
	["Horde"] = {281, 115, 0.001953, 0.550781, 0.003906, 0.453125},
};
local SUB_COORDS = HONOR_BACKGROUND_TCOORDS[playerFaction];
local HONOR_BADGE = {SUB_COORDS[3], SUB_COORDS[4], SUB_COORDS[5], SUB_COORDS[6]};

local PROFESSION_ICON_TCOORDS = {
	[TOAST_PROFESSION_ENCHANTING]		= {0, 0.25, 0, 0.25},
	[TOAST_PROFESSION_ALCHEMY]		= {0.25, 0.49609375, 0, 0.25},
	[TOAST_PROFESSION_BLACKSMITHING]		= {0.49609375, 0.7421875, 0, 0.25},
	[TOAST_PROFESSION_COOKING]		= {0.7421875, 0.98828125, 0, 0.25},
	[TOAST_PROFESSION_ENGINEERING]		= {0, 0.25, 0.25, 0.5},
	[TOAST_PROFESSION_FIRST_AID]	 	= {0.25, 0.49609375, 0.25, 0.5},
	[TOAST_PROFESSION_FISHING]		= {0.49609375, 0.7421875, 0.25, 0.5},
	[TOAST_PROFESSION_TAILORING]		= {0.7421875, 0.98828125, 0.25, 0.5},
	[TOAST_PROFESSION_INSCRIPTION]		= {0, 0.25, 0.5, 0.75},
	[TOAST_PROFESSION_JEWELCRAFTING]	= {0.25, .5, 0.5, .75},
	[TOAST_PROFESSION_LEATHERWORKING]		= {0.5, 0.73828125, 0.5, .75},
	-- [TOAST_PROFESSION_MINING]	= {0.7421875, 0.98828125, 0.5, 0.75},
};

-- /* patterns */
local P_LOOT_ITEM = LOOT_ITEM:gsub("%%s%%s", "(.+)");
local P_LOOT_COUNT = ".*x(%d+)";
local P_LOOT_ITEM_CREATED_SELF = LOOT_ITEM_CREATED_SELF:gsub("%%s", "(.+)"):gsub("^", "^");
local P_LOOT_ITEM_SELF = LOOT_ITEM_SELF:gsub("%%s", "(.+)"):gsub("^", "^");
local P_LOOT_ITEM_SELF_MULTIPLE = LOOT_ITEM_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^");
local P_LOOT_ROLL_YOU_WON = LOOT_ROLL_YOU_WON:gsub("%%s", "(.+)");
local PATTERN_LEARN = ERR_LEARN_RECIPE_S:gsub("%%s", "(.+)");
local PATTERN_LOOT_MONEY = YOU_LOOT_MONEY:gsub("%%s", "(.*)");
local GOLD = GOLD_AMOUNT:gsub("%%d", "(%%d+)");
local SILVER = SILVER_AMOUNT:gsub("%%d", "(%%d+)");
local COPPER = COPPER_AMOUNT:gsub("%%d", "(%%d+)");

local expectations_list = {};
local patterns = {
	won = {
		[LOOT_ROLL_TYPE_NEED] = LOOT_ROLL_YOU_WON_NO_SPAM_NEED,
		[LOOT_ROLL_TYPE_GREED] = LOOT_ROLL_YOU_WON_NO_SPAM_GREED,
		[LOOT_ROLL_TYPE_DISENCHANT] = LOOT_ROLL_YOU_WON_NO_SPAM_DE,
	},
	rolled = {
		[LOOT_ROLL_TYPE_NEED] = LOOT_ROLL_ROLLED_NEED,
		[LOOT_ROLL_TYPE_GREED] = LOOT_ROLL_ROLLED_GREED,
		[LOOT_ROLL_TYPE_DISENCHANT] = LOOT_ROLL_ROLLED_DE,
	},
};

local prefix_table = {
	[TOAST_PROFESSION_ALCHEMY] = {ITEM_TYPE_RECIPE},
	[TOAST_PROFESSION_BLACKSMITHING] = {ITEM_TYPE_PLANS},
	[TOAST_PROFESSION_ENCHANTING] = {ITEM_TYPE_FORMULA},
	[TOAST_PROFESSION_ENGINEERING] = {ITEM_TYPE_SCHEMATIC},
	[TOAST_PROFESSION_INSCRIPTION] = {ITEM_TYPE_TECHNIQUE},
	[TOAST_PROFESSION_JEWELCRAFTING] = {ITEM_TYPE_DESIGN},
	[TOAST_PROFESSION_LEATHERWORKING] = {ITEM_TYPE_PATTERN},
	[TOAST_PROFESSION_TAILORING] = {ITEM_TYPE_PATTERN},
	[TOAST_PROFESSION_COOKING] = {ITEM_TYPE_RECIPE},
	[TOAST_PROFESSION_FIRST_AID] = {ITEM_TYPE_MANUAL},--[[ITEM_TYPE_FORMULA]]
	-- [TOAST_PROFESSION_FISHING] = {},
};

-- /* tables */
local LootAlertFrameMixIn = {};
LootAlertFrameMixIn.alertQueue = {};
LootAlertFrameMixIn.alertButton = {};

function LootAlertFrameMixIn:AddAlert(name, link, quality, texture, count, ignore, label, toast, rollType, rollLink, tip, money, subType)
	if not ignore then
		if UnitLevel("player") < 80 then
			if quality < quality_low then
				return;
			end
		else
			if quality < quality_max then
				return;
			end
		end
	end

	tInsert(self.alertQueue,{
		name 		= name,
		link 		= link,
		quality 	= quality,
		texture 	= texture,
		count 		= count,
		label 		= label,
		toast 		= toast,
		rollType 	= rollType,
		rollLink 	= rollLink,
		tip 		= tip,
		money		= money,
		subType 	= subType
	});
end

function LootAlertFrameMixIn:CreateAlert()
	if #self.alertQueue > 0 then
		for i=1, LOOTALERT_NUM_BUTTONS do
			local button = self.alertButton[i];
			if button and not button:IsShown() then
				local data = tRemove(self.alertQueue, 1);
				button.data = data;
				return button;
			end
		end
	end
	return nil;
end

function LootAlertFrameMixIn:AdjustAnchors()
	local previousButton;
	for i=1, LOOTALERT_NUM_BUTTONS do
		local button = self.alertButton[i];
		button:ClearAllPoints();
		if button and button:IsShown() then
			if button.waitAndAnimOut:GetProgress() <= 0.74 then
				if not previousButton or previousButton == button then
					if DungeonCompletionAlertFrame1:IsShown() then
						button:SetPoint("BOTTOM", DungeonCompletionAlertFrame1, "TOP", point_x, point_y);
					else
						button:SetPoint("CENTER", DungeonCompletionAlertFrame1, "CENTER", point_x, point_y);
					end
				else
					button:SetPoint("BOTTOM", previousButton, "TOP", 0, offset_x);
				end
			end
			previousButton = button;
		end
	end
end

function LootAlertFrame_OnLoad(self)
	self.updateTime = uptime;
	
	self:RegisterEvent("CHAT_MSG_LOOT");
	self:RegisterEvent("CHAT_MSG_SYSTEM");
	self:RegisterEvent("CHAT_MSG_MONEY");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");

	mixin(self, LootAlertFrameMixIn);
end

local function LootAlertFrame_HandleChatMessage(message)
	local link, quantity, rollType, roll;

	if expectations_list.disenchant_result then
		link, quantity = message:cmatch(LOOT_ITEM_SELF_MULTIPLE);
		if not link then
			link = message:cmatch(LOOT_ITEM_SELF);
		end
		if link and expectations_list[link] then
			rollType = LOOT_ROLL_TYPE_DISENCHANT;
			quantity = tonumber(quantity) or 1;
			expectations_list[link] = nil;
			expectations_list.disenchant_result = false;
			return link, quantity, rollType;
		end
	end

	link = message:cmatch(LOOT_ROLL_YOU_WON)
	if link and expectations_list[link] then
		rollType, roll = expectations_list[link][1], expectations_list[link][2];
		if rollType == LOOT_ROLL_TYPE_DISENCHANT then
			expectations_list.disenchant_result = true;
			return;
		else
			expectations_list[link] = nil;
			return link, 1, rollType, roll;
		end
	end

	for rollType, pattern in pairs(patterns.rolled) do
		local roll, link, player = message:cmatch(pattern);
		if roll and player == playerName then
			expectations_list[link] = {rollType, roll};
			return;
		end
	end

	for rollType, pattern in pairs(patterns.won) do
		local roll, link = message:cmatch(pattern);
		if roll then
			return link, 1, rollType, roll;
		end
	end
  
	return link, quantity, rollType, roll;
end

function LootAlertFrame_OnEvent(self, event, ...)
	if event == "CHAT_MSG_LOOT" then
		local player, label, toast;
		local itemName					  = arg1:match(P_LOOT_ITEM);
		local itemLoot					  = arg1:match(P_LOOT_ITEM_SELF);
		local itemMultiple				  = arg1:match(P_LOOT_ITEM_SELF_MULTIPLE);
		local itemCreate				  = arg1:match(P_LOOT_ITEM_CREATED_SELF);
		local count						  = arg1:match(P_LOOT_COUNT);
		local itemRoll, _, rollType, roll = LootAlertFrame_HandleChatMessage(arg1);
		
		if not itemName and not player then
			if itemCreate and creating then
				itemName 	= itemCreate;
				label 		= YOU_CREATED_LABEL;
			elseif itemLoot or itemMultiple then
				if not looting then return; end
				itemName 	= itemLoot or itemMultiple;
				label 		= YOU_RECEIVED_LABEL;
			elseif itemRoll and rolling then
				itemName 	= itemRoll;
				label 		= YOU_WON_LABEL;
			end
			player = GetUnitName("player");
		end

		if itemName then
			local name, link, quality, iLevel, _, itemType, subType, _, _, texture = GetItemInfo(itemName);
			local legendary	  = quality == LE_ITEM_QUALITY_LEGENDARY;
			local average	  = quality >= LE_ITEM_QUALITY_UNCOMMON and not legendary;
			local common	  = quality <= LE_ITEM_QUALITY_COMMON;
			local heroic	  = iLevel >= 271 and not legendary;
			local pets		  = subType == PET or subType == PETS;
			local mounts	  = subType == ITEM_TYPE_MOUNT or subType == ITEM_TYPE_MOUNTS;
			
			if average then toast = "defaulttoast"; end
			if common then toast = "commontoast"; end
			if heroic then toast = "heroictoast"; end
			
			if legendary then
				label = LEGENDARY_ITEM_LOOT_LABEL;
				toast = "legendarytoast";
			end
			if pets then
				toast = "pettoast";
			elseif mounts then
				toast = "mounttoast";
			end
			
			if config.filter then
				for _, ignored in ipairs(config.filter_type) do
					if tostring(itemType) == tostring(ignored) then
						return;
					end
				end
			end
			-- print(itemType)
			
			if link then
				LootAlertFrameMixIn:AddAlert(name, link, quality, texture, count, ignlevel, label, toast, rollType, roll);
			end
		end
	end
	
	-- [[ MoneyWonAlertFrameTemplate ]] --
	if event == "CHAT_MSG_MONEY" and currency_loot then
		local currency = arg1:match(PATTERN_LOOT_MONEY);
		local gold     = arg1:match(GOLD);
		local silver   = arg1:match(SILVER);
		local copper   = arg1:match(COPPER);
		
		gold   = (gold and tonumber(gold)) or 0;
		silver = (silver and tonumber(silver)) or 0;
		copper = (copper and tonumber(copper)) or 0;
		
		local money = copper + silver * 100 + gold * 10000;
		local amount = GetMoneyString(money, true);
		if currency then
			if playerName then
				local label		= YOU_RECEIVED_LABEL;
				local quality 	= LE_ITEM_QUALITY_ARTIFACT;
				local toast 	= "moneytoast";
				
				LootAlertFrameMixIn:AddAlert(amount, false, quality, false, false, true, label, toast, false, false, false, money);
			end
		end
	end
	
	-- [[ NewRecipeLearnedAlertFrameTemplate ]] --
	if event == "CHAT_MSG_SYSTEM" and recipes_learned then
		local skill = arg1:match(PATTERN_LEARN);
		if skill then
			for prof, prefixes in next, prefix_table do
				if GetSpellInfo(prof) then
					for key, prefix in next, prefixes do -- Glory to Ukraine!
						local recipe = prefix .. skill or skill;
						local label = NEW_RECIPE_LEARNED_TITLE;
						local toast = "recipetoast";
						local tip = ERR_LEARN_RECIPE_S:gsub("%%s", skill);
						local _, link, quality = GetItemInfo(recipe);
						if link then
							LootAlertFrameMixIn:AddAlert(skill, link, quality, picn, false, true, label, toast, false, false, tip, false, prof);
						end
					end
				end
			end
		end
	end

	-- [[ HonorAwardedAlertFrameTemplate ]] --
	if event == "UPDATE_BATTLEFIELD_STATUS" and honor_award then
		if (not GetBattlefieldWinner() or BATTLEFIELD_SHUTDOWN_TIMER <= 0 or IsActiveBattlefieldArena()) then return; end
		local link, entry, count, texture, quality, label, toast, tip;
		local honorIcon = assets.."PVPCurrency-Honor-"..playerFaction;
		local bonusIcon = assets.."achievement_legionpvptier4";
		local numScores = GetNumBattlefieldScores();
		local hasWon, winHonorAmount, winArenaAmount = GetAmountBattlefieldBonus();
		
		RequestBattlefieldScoreData();
		for i=1, numScores do
			local name, _, _, _, honorGained = GetBattlefieldScore(i);
			if name and name == playerName then
				link 	 	= "item:43308";
				entry 	  	= HONOR_POINTS;
				count	 	= honorGained;
				texture   	= honorIcon;
				quality   	= LE_ITEM_QUALITY_ARTIFACT;
				label 	  	= YOU_EARNED_LABEL;
				toast 		= "battlefieldtoast";
				tip 	  	= TOOLTIP_HONOR_POINTS;
				break;
			end
		end
		
		if link then
			LootAlertFrameMixIn:AddAlert(entry, link, quality, texture, count, true, label, toast, false, false, tip);
		end
		if not hasWon and GetBattlefieldWinner() == playerWinner then
			link	  	= "item:43307";
			entry	  	= ARENA_POINTS;
			count	  	= winArenaAmount;
			texture	  	= bonusIcon;
			tip 	  	= TOOLTIP_ARENA_POINTS;
			
			LootAlertFrameMixIn:AddAlert(entry, link, quality, texture, count, true, label, toast, false, false, tip);
		end
	end
end

function LootAlertFrame_OnUpdate(self, elapsed)
	self.updateTime = self.updateTime - elapsed;
	if self.updateTime <= 0 then
		local alert = LootAlertFrameMixIn:CreateAlert();
		if alert then
			alert:SetScale(scale);
			alert:ClearAllPoints();
			alert:Show();
			alert.animIn:Play();
			LootAlertFrameMixIn:AdjustAnchors();
		end
		self.updateTime = uptime;
	end
end

function LootAlertButtonTemplate_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	tInsert(LootAlertFrameMixIn.alertButton, self);
end

-- [[ NewRecipeLearnedAlertFrame ]] --
local function NewRecipeLearnedAlertFrame_GetStarTextureFromRank(quality)
	if quality == 2 then
		return "|T"..assets.."toast-star:12:12:0:0:32:32:0:21:0:21|t";
	elseif quality == 3 then
		return "|T"..assets.."toast-star-2:12:24:0:0:64:32:0:42:0:21|t";
	elseif quality == 4 then
		return "|T"..assets.."toast-star-3:12:36:0:0:64:32:0:64:0:21|t";
	end
	return nil;
end

function LootAlertButtonTemplate_OnShow(self)
	if not self.data then
		self:Hide();
		return;
	end

	local data = self.data;
	if data.name then
		local defaultToast 		= data.toast == "defaulttoast";
		local recipeToast 		= data.toast == "recipetoast";
		local battlefieldToast  = data.toast == "battlefieldtoast";
		local moneyToast 		= data.toast == "moneytoast";
		local legendaryToast 	= data.toast == "legendarytoast";
		local commonToast 		= data.toast == "commontoast";
		local qualityColor 		= ITEM_QUALITY_COLORS[data.quality] or nil;
		local averageToast		= not recipeToast and not moneyToast and not commonToast;
	
		if data.count then
			self.Count:SetText(data.count);
		else
			self.Count:SetText(" ");
		end

		self.Icon:SetTexture(data.texture);
		self.Icon:SetShown(averageToast);
		self.IconBorder:SetShown(averageToast);
		self.LessIcon:SetTexture(data.texture);
		self.ItemName:SetText(data.name);
		self.ItemName:SetShown(averageToast);
		self.LessItemName:SetText(data.name);
		self.Label:SetText(data.label);
		self.Label:SetShown(averageToast);
		self.RollWon:SetShown(data.rollLink);
		self.MoneyLabel:SetShown(moneyToast);
		self.Amount:SetShown(moneyToast);
		self.Amount:SetText(data.name);
		
		self.Background:SetShown(defaultToast);
		self.HeroicBackground:SetShown(data.toast == "heroictoast");
		self.PvPBackground:SetShown(battlefieldToast);
		self.PvPBackground:SetSize(SUB_COORDS[1], SUB_COORDS[2]);
		self.PvPBackground:SetTexCoord(unpack(HONOR_BADGE));
		self.RecipeBackground:SetShown(recipeToast);
		self.RecipeTitle:SetShown(recipeToast);
		self.RecipeName:SetShown(recipeToast);
		self.RecipeIcon:SetShown(recipeToast);
		self.LessBackground:SetShown(commonToast);
		self.LessItemName:SetShown(commonToast);
		self.LessIcon:SetShown(commonToast);
		self.LegendaryBackground:SetShown(legendaryToast);
		self.RollWonTitle:SetShown(data.rollLink);
		self.MoneyBackground:SetShown(moneyToast);
		self.MoneyLabel:SetShown(moneyToast);
		self.MoneyBackground:SetShown(moneyToast);
		self.MoneyIconBorder:SetShown(moneyToast);
		self.MoneyIcon:SetShown(moneyToast);
		self.MountToastBackground:SetShown(data.toast == "mounttoast");
		self.PetToastBackground:SetShown(data.toast == "pettoast");
		
		if data.rollLink then
			if data.rollType == LOOT_ROLL_TYPE_NEED then
				self.RollWonTitle:SetTexture([[Interface\Buttons\UI-GroupLoot-Dice-Up]]);
			elseif data.rollType == LOOT_ROLL_TYPE_GREED then
				self.RollWonTitle:SetTexture([[Interface\Buttons\UI-GroupLoot-Coin-Up]]);
			else
				self.RollWonTitle:Hide();
			end
			self.RollWon:SetText(data.rollLink);
		end

		if recipeToast then
			self.RecipeIcon:SetTexture(data.texture);
			local craftIcon = PROFESSION_ICON_TCOORDS[data.subType];
			if craftIcon then
				self.RecipeIcon:SetTexCoord(unpack(craftIcon));
			end
			
			local rankTexture = NewRecipeLearnedAlertFrame_GetStarTextureFromRank(data.quality);
			if rankTexture then
				self.RecipeName:SetFormattedText("%s %s", data.name, rankTexture);
			else
				self.RecipeName:SetText(data.name);
			end
			self.RecipeTitle:SetText(data.label);
		end

		if qualityColor then
			self.ItemName:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b);
		end

		if LOOT_BORDER_BY_QUALITY[data.quality] then
			self.IconBorder:SetTexCoord(unpack(LOOT_BORDER_BY_QUALITY[data.quality]));
		end
		
		if config.sound then
			if legendaryToast then
				PlaySoundFile(SOUNDKIT.UI_LEGENDARY_LOOT_TOAST);
			elseif commonToast then
				PlaySoundFile(SOUNDKIT.UI_RAID_LOOT_TOAST_LESSER_ITEM_WON);
			elseif recipeToast then
				PlaySoundFile(SOUNDKIT.UI_GARRISON_FOLLOWER_LEARN_TRAIT);
			else
				PlaySoundFile(SOUNDKIT.UI_EPICLOOT_TOAST);
			end
		end
		
		if config.anims then
			if legendaryToast then
				self.legendaryGlow.animIn:Play();
				self.legendaryShine.animIn:Play();
			elseif recipeToast then
				self.recipeGlow.animIn:Play();
				self.recipeShine.animIn:Play();
			else
				self.glow.animIn:Play();
				self.shine.animIn:Play();
			end
		end
		
		self.hyperLink 		= data.link;
		self.tip 			= data.tip;
		self.name 			= data.name;
		self.money			= data.money;
	end
end

function LootAlertButtonTemplate_OnHide(self)
	self:Hide();
	self.animIn:Stop();
	self.waitAndAnimOut:Stop();
	
	if config.anims then
		if self.data.toast == "legendarytoast" then
			self.legendaryGlow.animIn:Stop();
			self.legendaryShine.animIn:Stop();
		elseif self.data.toast == "recipetoast" then
			self.recipeGlow.animIn:Stop();
			self.recipeShine.animIn:Stop();
		else
			self.glow.animIn:Stop();
			self.shine.animIn:Stop();
		end
	end

	tWipe(self.data);
	LootAlertFrameMixIn:AdjustAnchors();
end

function LootAlertButtonTemplate_OnClick(self, button)
	if button == "RightButton" then
		self:Hide();
	else
		if HandleModifiedItemClick(self.hyperLink) then
			return;
		end
	end
end

function LootAlertButtonTemplate_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -14, -6);
	if self.tip then
		GameTooltip:SetText(self.name, 1, 1, 1);
		GameTooltip:AddLine(self.tip, nil, nil, nil, 1);
	elseif self.money then
		GameTooltip:AddLine(YOU_RECEIVED_LABEL);
		SetTooltipMoney(GameTooltip, self.money, nil);
	else
		GameTooltip:SetHyperlink(self.hyperLink);
	end
	GameTooltip:Show();
end
