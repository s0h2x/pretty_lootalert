-- /* lua lib */
local unpack = unpack
local select = select
local pairs = pairs
local type = type
local wipe = wipe

-- /* APIs */
local UnitName = UnitName
local UnitLevel = UnitLevel
local PlaySoundFile = PlaySoundFile
local GetItemInfo = GetItemInfo
local GetUnitName = GetUnitName
local GetBattlefieldScore = GetBattlefieldScore
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldWinner = GetBattlefieldWinner
local GetBattlefieldInstanceExpiration = GetBattlefieldInstanceExpiration

-- /* assets */
local path = [[Interface\AddOns\pretty_lootalert\assets\]]
local source = {
	toastloot = path..'ui_epicloot_toast_01.ogg',
}

-- /* CONST */
LE_ITEM_QUALITY_COMMON = 1
LE_ITEM_QUALITY_EPIC = 4
LE_ITEM_QUALITY_HEIRLOOM = 7
LE_ITEM_QUALITY_LEGENDARY = 5
LE_ITEM_QUALITY_POOR = 0
LE_ITEM_QUALITY_RARE = 3
LE_ITEM_QUALITY_UNCOMMON = 2
LE_ITEM_QUALITY_WOW_TOKEN = 8
LE_ITEM_QUALITY_ARTIFACT = 6

LOOT_BORDER_BY_QUALITY = {
	[LE_ITEM_QUALITY_UNCOMMON] = {0.614258, 0.670898, 0.707031, 0.933594},
	[LE_ITEM_QUALITY_RARE] = {0.555664, 0.612305, 0.707031, 0.933594},
	[LE_ITEM_QUALITY_EPIC] = {0.790039, 0.84668, 0.707031, 0.933594},
	[LE_ITEM_QUALITY_LEGENDARY] = {0.731445, 0.788086, 0.707031, 0.933594},
	[LE_ITEM_QUALITY_HEIRLOOM] = {0.672852, 0.729492, 0.707031, 0.933594},
	[LE_ITEM_QUALITY_ARTIFACT] = {0.895508, 0.952148, 0.386719, 0.613281},
}
LOOTALERT_NUM_BUTTONS = 4
LootAlertFrameMixIn = {}
LootAlertFrameMixIn.alertQueue = {}
LootAlertFrameMixIn.alertButton = {}

local function Mixin(obj, ...)
	for i = 1, select('#', ...) do
		local mixin = select(i, ...)
		for k, v in next, mixin do
			obj[k] = v
		end
	end

	return obj
end

function LootAlertFrameMixIn:AddAlert(name, link, quality, texture, count, ignoreLevel, tooltipText)
	if not ignoreLevel then
		if UnitLevel('player') < 80 then
			if quality < 2 then
				return
			end
		else
			if quality < 4 then
				return
			end
		end
	end
	table.insert(self.alertQueue, {name = name, link = link, quality = quality, texture = texture, count = count, tooltipText = tooltipText})
end

function LootAlertFrameMixIn:CreateAlert()
	if #self.alertQueue > 0 then
		for i = 1, LOOTALERT_NUM_BUTTONS do
			local button = self.alertButton[i]
			if button and not button:IsShown() then
				local data = table.remove(self.alertQueue, 1)
				button.data = data
				return button
			end
		end
	end
	return nil
end

function LootAlertFrameMixIn:AdjustAnchors()
	local previousButton
	for i = 1, LOOTALERT_NUM_BUTTONS do
		local button = self.alertButton[i]
		button:ClearAllPoints()
		if button and button:IsShown() then
			if button.waitAndAnimOut:GetProgress() <= 0.74 then
				if not previousButton or previousButton == button then
					if DungeonCompletionAlertFrame1:IsShown() then
						button:SetPoint('BOTTOM', DungeonCompletionAlertFrame1, 'TOP', 0, 0)
					else
						button:SetPoint('CENTER', DungeonCompletionAlertFrame1, 'CENTER', 0, 0)
					end
				else
					button:SetPoint('BOTTOM', previousButton, 'TOP', 0, 4)
				end
			end
			previousButton = button
		end
	end
end

function LootAlertFrame_OnLoad(self)
	self.updateTime = 0.30
	self:RegisterEvent('CHAT_MSG_LOOT')
	self:RegisterEvent('CHAT_MSG_COMBAT_HONOR_GAIN')
	self:RegisterEvent('CHAT_MSG_BG_SYSTEM_NEUTRAL')

	Mixin(self, LootAlertFrameMixIn)
end

function LootAlertFrame_OnEvent(self, event, ...)
	if event == 'CHAT_MSG_LOOT' then
		local itemEntry = string.match(arg1, gsub(LOOT_ITEM, '%%s', '(.+)'))
		local count = string.match(arg1, '.*x(%d+)')
		local player

		if not itemEntry and not player then
			itemEntry = strmatch(arg1, gsub(LOOT_ITEM_SELF, '%%s', '(.+)'))
			player = GetUnitName('player')
		end

		if itemEntry then
			local name,link,quality,iLevel,reqLevel,class,subclass,maxStack,equipSlot,texture,vendorPrice = GetItemInfo(itemEntry)
			if link then
				LootAlertFrameMixIn:AddAlert(name, link, quality, texture, count, false)
			end
		end
	end
	if event == 'CHAT_MSG_COMBAT_HONOR_GAIN'
	   or event == 'CHAT_MSG_BG_SYSTEM_NEUTRAL' then
		RequestBattlefieldScoreData()
		local numScores = GetNumBattlefieldScores()
		local winner = GetBattlefieldWinner()
		local expiration = GetBattlefieldInstanceExpiration()
		local faction = UnitFactionGroup('player') or 'Alliance'
		local isPlayer = UnitName('player')

		for i = 1, numScores do
			local name, _, _, _, honorGained = GetBattlefieldScore(i)
			local honorCount = format('%d', honorGained)
			if name and name == isPlayer then
				link 		= 'item:43308'
				entry 		= HONOR_POINTS
				count 		= honorCount
				texture 	= path..'PVPCurrency-Honor-'..faction
				quality 	= LE_ITEM_QUALITY_EPIC
				tooltipText = TOOLTIP_HONOR_POINTS
				if (expiration > 0 or winner == 0 or winner == 1) then
					LootAlertFrameMixIn:AddAlert(entry, link, quality, texture, count)
				end
			end
		end
	end
end

function LootAlertFrame_OnUpdate(self, elapsed)
	self.updateTime = self.updateTime - elapsed
	if self.updateTime <= 0 then
		local alert = LootAlertFrameMixIn:CreateAlert()
		if alert then
			alert:ClearAllPoints()
			alert:Show()
			alert.animIn:Play()
			LootAlertFrameMixIn:AdjustAnchors()
		end
		self.updateTime = 0.30
	end
end

function LootAlertButtonTemplate_OnLoad(self)
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	table.insert(LootAlertFrameMixIn.alertButton, self)
end

function LootAlertButtonTemplate_OnShow(self)
	if not self.data then
		self:Hide()
		return
	end

	local data = self.data
	if data.name then
		local qualityColor = ITEM_QUALITY_COLORS[data.quality] or nil
		if data.count then
			self.Count:SetText(data.count)
		else
			self.Count:SetText(' ')
		end

		self.Icon:SetTexture(data.texture)
		self.ItemName:SetText(data.name)
		
		PlaySoundFile(source.toastloot)
		if qualityColor then
			self.ItemName:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)
		end

		if LOOT_BORDER_BY_QUALITY[data.quality] then
			self.IconBorder:SetTexCoord(unpack(LOOT_BORDER_BY_QUALITY[data.quality]))
		end

		self.hyperLink 		= data.link
		self.tooltipText 	= data.tooltipText
		self.name 			= data.name

		self.glow.animIn:Play()
		self.shine.animIn:Play()
	end
end

function LootAlertButtonTemplate_OnHide(self)
	self:Hide()
	self.animIn:Stop()
	self.waitAndAnimOut:Stop()

	self.glow.animIn:Stop()
	self.shine.animIn:Stop()

	wipe(self.data)

	LootAlertFrameMixIn:AdjustAnchors()
end

function LootAlertButtonTemplate_OnClick(self, button)
	if button == 'RightButton' then
		self:Hide()
	else
		if HandleModifiedItemClick(self.hyperLink) then
			return
		end
	end
end

function LootAlertButtonTemplate_OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT', -14, -6)
	if self.tooltipText then
		GameTooltip:SetText(self.name, 1, 1, 1)
		GameTooltip:AddLine(self.tooltipText, nil, nil, nil, 1)
	else
		GameTooltip:SetHyperlink(self.hyperLink)
	end
	GameTooltip:Show()
end
