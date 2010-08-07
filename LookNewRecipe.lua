function checkInventory(...)
	local numMerchantItems = GetMerchantNumItems()
	knownRecipes = {}
	unknownRecipes = {}
	unableToLearnRecipes = {}
	nonProfession = {}
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
					LookNewRecipe_ScanningTooltipTextLeft5:GetText(),
					LookNewRecipe_ScanningTooltipTextLeft6:GetText(),
					LookNewRecipe_ScanningTooltipTextLeft7:GetText()
				}
				
				local parsedProfession, garbage = string.gsub(string.gsub(completeTooltipText[2],"Requires ","")," %(%d+%)","")
				local mname, mtexture, mprice, mquantity, mnumAvailable, misUsable, mextendedCost = GetMerchantItemInfo(i)
				if Professions[subclass] then --possible recipe!
					local result = scanTable(completeTooltipText)
					if result == 1 then
						table.insert(knownRecipes,link)
					elseif misUsable then
						table.insert(unknownRecipes,link)
					elseif result == 2 then
						table.insert(unableToLearnRecipes,link)
					end
				else
					table.insert(nonProfession,link)
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
	
	if # nonProfession > 0 then 
		ChatFrame1:AddMessage("Other Recipes", 0.6, 0.6, 0.6);
		printTable(nonProfession)
	end
end

function printTable(t)
	
	for k,v in pairs(t) do
		print("    "..k..". "..v)
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

Professions = {}

Professions["Alchemy"] = false
Professions["Blacksmithing"] = false
Professions["Cooking"] = false
Professions["Enchanting"] = false
Professions["Engineering"] = false
Professions["First Aid"] = false
Professions["Jewelcrafting"] = false
Professions["Leatherworking"] = false
Professions["Smelting"] = false
Professions["Poisions"] = false
Professions["Tailoring"] = false
Professions["Runeforging"] = false
Professions["Inscription"] = false

tradeskills = {
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
	
function Professions:Update()
    for k,v in pairs(tradeskills) do
        if GetSpellInfo(v) and v ~= "Update" and v ~= "Display" then
			Professions[v] = true
		else
			Professions[v] = false
        end
    end
	--Professions:Display()
end

function Professions:Display()
	for k,v in pairs(Professions) do
		if v and k ~= "Update" and k ~= "Display" then
			print("---")
			print(k)
			print(v)
		end
	end
end

function LookNewRecipe_showSettings()
	ChatFrame1:AddMessage("Look! New Recipe! settings don't exist.", 1.0, 0.22, 1.0);
end

function LookNewRecipe_init()
	--First, we want to determine the tradeskills our player has.

	local eventFrame = CreateFrame("Frame")
	eventFrame:Hide()
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:SetScript("OnEvent", function() Professions:Update() end)
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("MERCHANT_SHOW")
	frame:SetScript("OnEvent", checkInventory)
	ChatFrame1:AddMessage("Look! New Recipe! loaded. Type /LNR for settings.", 1.0, 0.22, 1.0);
	SlashCmdList["LOOK_NEW_RECIPE"] = LookNewRecipe_showSettings;
	SLASH_LOOK_NEW_RECIPE1 = "/looknewrecipe";
	SLASH_LOOK_NEW_RECIPE2 = "/lnr";
	--NewRecipe_loadSettings();
end