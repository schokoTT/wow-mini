local _G = getfenv(0)
local knownTable = {} -- Save known items for later use

-- Tooltip and scanning by Phanx @ http://www.wowinterface.com/forums/showthread.php?p=271406
-- Search string by Phanx @ https://github.com/Phanx/BetterBattlePetTooltip/blob/master/Addon.lua
local S_PET_KNOWN = strmatch(_G.ITEM_PET_KNOWN, "[^%(]+")

local scantip = CreateFrame("GameTooltip", "AKScanningTooltip", nil, "GameTooltipTemplate")
scantip:SetOwner(UIParent, "ANCHOR_NONE")

local function _checkIfKnown(itemLink)
	if knownTable[itemLink] then -- Check if we have scanned this item already and it was known then
		return true
	end
	scantip:ClearLines()
	scantip:SetHyperlink(itemLink)

	for i = 2, scantip:NumLines() do -- Line 1 is always the name so you can skip it.
		local text = _G["AKScanningTooltipTextLeft"..i]:GetText()
		if text == _G.ITEM_SPELL_KNOWN or strmatch(text, S_PET_KNOWN) then
			knownTable[itemLink] = true -- Mark as known far later use
			return true -- Item is known or collected
		end
	end
	return false -- Item is not known, uncollected... or something went wrong
end

hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function() -- Most of this found from FrameXML/MerchantFrame.lua
	for i = 1, _G.MERCHANT_ITEMS_PER_PAGE do
		local index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i)
		local itemButton = _G["MerchantItem"..i.."ItemButton"]
		local merchantButton = _G["MerchantItem"..i]
		local itemLink = GetMerchantItemLink(index)

		if itemLink and _checkIfKnown(itemLink) then
			SetItemButtonNameFrameVertexColor(merchantButton, 0, 1, 0)
			SetItemButtonSlotVertexColor(merchantButton, 0, 1, 0)
			SetItemButtonTextureVertexColor(itemButton, 0, 0.9, 0)
			SetItemButtonNormalTextureVertexColor(itemButton, 0, 0.9, 0)
		end
	end
end)