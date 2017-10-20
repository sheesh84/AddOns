
-- Using the Bagnon way to retrieve names, namespaces and stuff
local MODULE =  ...
local ADDON, Addon = MODULE:match("[^_]+"), _G[MODULE:match("[^_]+")]
local ArtifactPower = Bagnon:NewModule("ArtifactPower", Addon)

-- Lua API
local _G = _G
local math_floor = math.floor
local table_wipe = table.wipe
local tonumber = tonumber
local tostring = tostring
local string_find = string.find
local string_gsub = string.gsub
local string_match = string.match

-- WoW API
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetItemInfo = _G.GetItemInfo

-- WoW Constants
local ARTIFACT_POWER = _G.ARTIFACT_POWER
local ARTIFACT_COLOR = BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_ARTIFACT]

-- Tracking our current knowledge level
local KNOWLEDGE_LEVEL = C_ArtifactUI and C_ArtifactUI.GetArtifactKnowledgeLevel() or 0

-- Get the current client locale
local gameLocale = GetLocale()

local strings = {} -- cache of artifact power fontstrings
local cache = {} -- cache of artifact power values
local ignored = {} -- items with no artifact power we'll ignore (todo: add item types to this on startup, to reduce scanning delay)

-- Event frame
local knowledgeTracker = CreateFrame("Frame")
knowledgeTracker:RegisterEvent("ARTIFACT_UPDATE")
knowledgeTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
knowledgeTracker:SetScript("OnEvent", function(self, event, ...) 

	if (event == "ADDON_LOADED") then
		local addon = ...
		if (addon ~= "Blizzard_ArtifactUI") then
			return
		end
		self:UnregisterEvent("ADDON_LOADED")
	end

	if (not C_ArtifactUI) then
		return self:RegisterEvent("ADDON_LOADED")
	end

	local knowledgeLevel = C_ArtifactUI.GetArtifactKnowledgeLevel()
	if (knowledgeLevel ~= KNOWLEDGE_LEVEL) then
		KNOWLEDGE_LEVEL = knowledgeLevel

		-- Wipe our cache if the knowledge level changed, 
		-- as this also changes artifact power from items.
		table_wipe(cache)
	end
end)

-- Tooltip used for scanning
local scanner = CreateFrame("GameTooltip", "BagnonArtifactPowerScannerTooltip", WorldFrame, "GameTooltipTemplate")
local scannerName = scanner:GetName()

-- Number abbreviations
local shorten = (gameLocale == "zhCN") and function(value)
	value = tonumber(value)
	if not value then return "" end
	if value >= 1e8 then
		return ("%.1f亿"):format(value / 1e8):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e4 or value <= -1e3 then
		return ("%.1f万"):format(value / 1e4):gsub("%.?0+([km])$", "%1")
	else
		return tostring(math_floor(value))
	end 
end

or function(value)
	value = tonumber(value)
	if not value then return "" end
	if value >= 1e9 then
		return ("%.1fb"):format(value / 1e9):gsub("%.?0+([kmb])$", "%1")
	elseif value >= 1e6 then
		return ("%.1fm"):format(value / 1e6):gsub("%.?0+([kmb])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?0+([kmb])$", "%1")
	else
		return tostring(math_floor(value))
	end	
end

ArtifactPower.OnEnable = function(self)
	hooksecurefunc(Bagnon.ItemSlot, "Update", function(self) 

		local itemLink = self:GetItem() -- GetContainerItemLink(self:GetBag(), self:GetID())
		if itemLink then

			local itemHasArtifactPower = cache[itemLink]
			if (not itemHasArtifactPower) then
				local itemID = tonumber(string_match(itemLink, "item:(%d+)"))
				if itemID and (not ignored[itemID]) then
					
					scanner.owner = self
					scanner:SetOwner(self, "ANCHOR_NONE")
					scanner:SetBagItem(self:GetBag(), self:GetID())
					
					local line = _G[scannerName.."TextLeft2"]
					if line then
						local msg = line:GetText()
						if msg and string_find(msg, ARTIFACT_POWER) then
							line = _G[scannerName.."TextLeft4"]
							if line then
								msg = line:GetText()
								if msg then
									msg = string_gsub(msg, ",", "")

									local artifactPower = string_match(msg, "(%d+)")
									if artifactPower then
										-- Cache the itemLink, since there can be multiple 
										-- instances of the same itemID in your bags. 
										cache[itemLink] = artifactPower

										itemHasArtifactPower = artifactPower
									end
								end
							end
						else
							-- Don't scan this itemID again this session, it has no AP!
							ignored[itemID] = true
						end
					end

				end
			end

			if itemHasArtifactPower then 
				if (not strings[self]) then
					-- Adding an extra layer to get it above glow and border textures
					local holder = _G[self:GetName().."ExtraInfoFrame"] or CreateFrame("Frame", self:GetName().."ExtraInfoFrame", self)
					holder:SetAllPoints()

					-- Using standard blizzard fonts here
					local itemAP = holder:CreateFontString()
					itemAP:SetDrawLayer("ARTWORK")
					itemAP:SetPoint("TOPLEFT", 2, -2)
					itemAP:SetFontObject(_G.NumberFont_Outline_Med or _G.NumberFontNormal) 
					itemAP:SetFont(itemAP:GetFont(), 12, "OUTLINE")
					itemAP:SetShadowOffset(1, -1)
					itemAP:SetShadowColor(0, 0, 0, .5)
					itemAP:SetTextColor(ARTIFACT_COLOR.r, ARTIFACT_COLOR.g, ARTIFACT_COLOR.b)

					strings[self] = itemAP
				end

				strings[self]:SetText(shorten(itemHasArtifactPower))

			else
				if strings[self] then
					strings[self]:SetText("")
				end
				

			end
		else
			if strings[self] then
				strings[self]:SetText("")
			end
		end

	end)
end

