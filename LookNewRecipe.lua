LookNewRecipe = {}
LookNewRecipe_Settings = {
	playSound = 1
}

closeFrame = CreateFrame("Frame")
background = MerchantFrame:CreateTexture("TestFrameBackground", "BACKGROUND")
loopCount = 0
maxLoops = 10
--LookNewRecipe_ScanningTooltip = CreateFrame("GameTooltip")
--LookNewRecipe_ScanningTooltip:SetOwner(UIParent, "ANCHOR_NONE");

local timerFrame = CreateFrame("Frame")
local animationGroup = timerFrame:CreateAnimationGroup()
local animation = animationGroup:CreateAnimation("Animation")
animation:SetDuration(2) -- timer set to 3 sec
animationGroup:SetLooping("NONE")

function cacheInventory(...)
	loopCount = loopCount + 1
	--print("loop "..loopCount)
	if (loopCount > maxLoops) then
		LookNewRecipe_ScanningTooltip:SetScript("OnTooltipSetItem",nil)
		return 0
	end
	--print("Caching inventory...")
	local numMerchantItems = GetMerchantNumItems()
	--print(numMerchantItems)
	LookNewRecipe_ScanningTooltip:SetScript("OnTooltipSetItem",checkCache)
	animationGroup:SetScript("OnFinished", checkInventory)
	animationGroup:Play()
	--print("Starting timer...")
	for i = 1, numMerchantItems do
		local link = GetMerchantItemLink(i)
		--print(i)
		--print(link)
		if link then --trying to catch errors here
			LookNewRecipe_ScanningTooltip:SetHyperlink(link)
		else
			break
		end
	end
	
end

function checkCache()
	--print("Checking cache...")
	--We want to make sure the item on our tooltip exists.
	if LookNewRecipe_ScanningTooltip:GetItem() then
		local trace = "Validating item cache..."
		local numMerchantItems = GetMerchantNumItems()
		local allCached = true
		for i = 1, numMerchantItems do
			if GetMerchantItemLink(i) == nil then
				allCached = false
				trace = trace.."invalid."
				break
			end
		end
		
		if allCached then
			trace = trace.."valid!"
			--print(trace)
			LookNewRecipe_ScanningTooltip:SetScript("OnTooltipSetItem",nil)
			checkInventory()
		else
			--print(trace)
			LookNewRecipe_ScanningTooltip:SetScript("OnTooltipSetItem",cacheInventory)
		end
	end
end

function checkInventory(...)

	local numMerchantItems = GetMerchantNumItems()
	--print(MerchantFrame:GetWidth())
	animationGroup:SetScript("OnFinished", nil)
	LookNewRecipe_ScanningTooltip:SetScript("OnTooltipSetItem",nil)
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
				
				LookNewRecipe_ScanningTooltip:SetMerchantItem(i)
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
		if LookNewRecipe_Settings.playSound == 1 then
			PlayNewRecipeSound()
		end
		ShowNewRecipeTexture()
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

function ShowNewRecipeTexture()
	-- Create a sample frame and give it a visible background color
	background:Show()
	closeFrame:RegisterEvent("MERCHANT_CLOSED")
	closeFrame:SetScript("OnEvent",HideNewRecipeTexture)
	background:SetTexture("Interface\\Addons\\LookNewRecipe\\assets\\textures\\alert-image.tga")

	-- Set the top left corner 5px to the right and 15px above UIParent's top left corner
	background:SetPoint("TOPLEFT", 142,-340)
	 
	-- Set the bottom edge to be 10px below WorldFrame's center
	background:SetWidth(220)

	-- Set the right edge to be 20px to the left of WorldFrame's right edge
	background:SetHeight(110)
	closeFrame:SetScript("OnUpdate",RollDown)
end

function RollDown()
	local point, relativeTo, relativePoint, xOffset, yOffset = background:GetPoint(1)
	
	if (yOffset + 454) < 3 then
		--handle anim done
		closeFrame:SetScript("OnUpdate",nil)
	else
		local newTop = (yOffset + 454) * 0.025
		background:SetPoint("TOPLEFT",142,yOffset-newTop)
	end
end

function HideNewRecipeTexture()
	background:Hide()
end

function PlayNewRecipeSound()
	local num = math.random(12)
	PlaySoundFile("Interface\\Addons\\LookNewRecipe\\assets\\sounds\\nr"..num..".ogg")
end

function MerchantShowHandler(...)
	loopCount = 0
	LookNewRecipe_ScanningTooltip:SetScript("OnTooltipSetItem",nil)
	animationGroup:SetScript("OnFinished", nil)
	cacheInventory(...)
end

function LookNewRecipe_init()
	--Let's set up our slash commands.
	SlashCmdList["LOOK_NEW_RECIPE"] = LookNewRecipe_ShowSettings;
	SLASH_LOOK_NEW_RECIPE1 = "/looknewrecipe";
	SLASH_LOOK_NEW_RECIPE2 = "/lnr";

	--Set up our frames
	LookNewRecipe.eventFrame = CreateFrame("Frame")
	LookNewRecipe.eventFrame:Hide()
	LookNewRecipe.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	LookNewRecipe.eventFrame:SetScript("OnEvent", function() Professions:Update() end)
	LookNewRecipe.frame = CreateFrame("Frame")
	LookNewRecipe.frame:RegisterEvent("MERCHANT_SHOW")
	LookNewRecipe.frame:SetScript("OnEvent", MerchantShowHandler)
		
	
	ChatFrame1:AddMessage("Look! New Recipe! loaded. Type /LNR for settings.", 1.0, 0.22, 1.0);
	SetupOptionsPanel()
	
	--Deal with some settings.
	if LookNewRecipe_Settings.playSound == nil then
		LookNewRecipe_Settings.playSound = 1
	end
	--NewRecipe_loadSettings();
end

function LookNewRecipe_ShowSettings()
	InterfaceOptionsFrame_OpenToCategory(LookNewRecipe.settingsPanel)
end

function UpdateSettings()
	LookNewRecipe.playSounds_check:SetChecked(LookNewRecipe_Settings.playSound == 1)
end

function SaveSettings()
	if LookNewRecipe.playSounds_check:GetChecked() then
		LookNewRecipe_Settings.playSound = 1
	else
		LookNewRecipe_Settings.playSound = 0
	end
end

 function SetupOptionsPanel()
	LookNewRecipe.settingsPanel = CreateFrame( "Frame", "MyAddonPanel", UIParent );
	LookNewRecipe.settingsPanel:SetScript("OnShow",UpdateSettings)
	-- Register in the Interface Addon Options GUI
	-- Set the name for the Category for the Options Panel
	LookNewRecipe.settingsPanel.name = "Look! New Recipe!";
	-- Add the panel to the Interface Options
	InterfaceOptions_AddCategory(LookNewRecipe.settingsPanel);

	LookNewRecipe.playSounds_check = CreateFrame( "CheckButton", "PlaySounds", LookNewRecipe.settingsPanel, "UICheckButtonTemplate")
	LookNewRecipe.playSounds_check:ClearAllPoints()
	LookNewRecipe.playSounds_check:SetPoint("Center",0,0)
	_G[LookNewRecipe.playSounds_check:GetName() .. "Text"]:SetText("Play Sounds")
	
	LookNewRecipe.settingsPanel.okay = function(self) SaveSettings(); end;
 end