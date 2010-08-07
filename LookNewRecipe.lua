local function checkInventory(...)
	local numMerchantItems = GetMerchantNumItems()
	knownRecipes = {}
	unknownRecipes = {}
	unableToLearnRecipes = {}
	local itemsOnCooldown = 0
	for i = 1, numMerchantItems do
		local link = GetMerchantItemLink(i)
		if link then
			local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(link)
			
			if class == "Recipe" then
				LookNewRecipe_ScanningTooltip:SetMerchantItem(i);
				local completeTooltipText = {
					LookNewRecipe_ScanningTooltipTextLeft1:GetText(),
					LookNewRecipe_ScanningTooltipTextLeft2:GetText(),
					LookNewRecipe_ScanningTooltipTextLeft3:GetText(),
					LookNewRecipe_ScanningTooltipTextLeft4:GetText(),
					LookNewRecipe_ScanningTooltipTextLeft5:GetText()
				}
				local result = scanTable(completeTooltipText)
				if result == 3 then
					table.insert(unknownRecipes,link)
				elseif result == 2 then
					table.insert(unableToLearnRecipes,link)
				elseif result == 1 then
					table.insert(known,link)
				end	
			end
		end
	end
	
	if # unknownRecipes > 0 then
		ChatFrame1:AddMessage("Look! New recipe!", 1.0, 0.22, 1.0);
		printTable(unknownRecipes)
	end
	
	if # knownRecipes > 0 then
		ChatFrame1:AddMessage("Known Recipes", 0.0, 0.46, 0.0);
		printTable(knownRecipes)
	end
	
	if # unableToLearnRecipes > 0 then 
		ChatFrame1:AddMessage("Unlearnable Recipes", 1.0, 0.0, 0.0);
		printTable(unableToLearnRecipes)
	end
end

function printTable(t)
	for k,v in pairs(t) do
		print("    "..v)
	end
end

function scanTable(t)
	local requires = false
	for k,v in pairs(t) do
		if v:find("Already known") then
			return 1
		elseif v:find("Requires") then
			requires = true
		end
	end
	if requires then
		return 2
	else
		return 3
	end
end

print("Look! Loading!")
--First, we want to determine the tradeskills our player has.
local Professions = {}

local tradeskills = {
    (GetSpellInfo(2259)), -- Alchemy
    (GetSpellInfo(2018)), -- Blacksmithing
    (GetSpellInfo(2550)), -- Cooking
    (GetSpellInfo(7411)), -- Enchanting
    (GetSpellInfo(4036)), -- Engineering
    (GetSpellInfo(3273)), -- First Aid
    (GetSpellInfo(25229)), -- Jewelcrafting
    (GetSpellInfo(2108)), -- Leatherworking
    (GetSpellInfo(2656)), -- Smelting
    (GetSpellInfo(2842)), -- Poisons
    (GetSpellInfo(3908)), -- Tailoring
    (GetSpellInfo(53428)), -- Runeforging
    (GetSpellInfo(45357)), -- Inscription
}

local eventFrame = CreateFrame("Frame")
eventFrame:Hide()
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function() Professions:Update() end)

function Professions:Update()
    for k,v in pairs(tradeskills) do
		Professions[v] = nil
        if GetSpellInfo(v) then
			Professions[v] = "known"
		else
			Professions[v] = "unknown"
        end
    end
	--Professions:Display()
end

function Professions:Display()
	for k,v in pairs(Professions) do
		if v then
			print(k)
			print(v)
		end
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")
frame:SetScript("OnEvent", checkInventory)