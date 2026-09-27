local ADDON_NAME, ns = ...

local PATH = ns.MEDIA .. "picomenu\\"

local setupDone = false

local function Setup()
    if setupDone then
        return
    end
    setupDone = true

    local menuFrame = CreateFrame("Frame", "picomenuDropDownMenu", MainMenuBar, "UIDropDownMenuTemplate")

    local menuList = {
        { text = MAINMENU_BUTTON, isTitle = true, notCheckable = true },
        {
            text = CHARACTER_BUTTON,
            icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
            func = function() securecall(ToggleCharacter, "PaperDollFrame") end,
            notCheckable = true,
        },
        {
            text = SPELLBOOK_ABILITIES_BUTTON,
            icon = "Interface\\MINIMAP\\TRACKING\\Class",
            func = function() securecall(ToggleSpellBook, BOOKTYPE_SPELL) end,
            notCheckable = true,
        },
        {
            text = TALENTS_BUTTON,
            icon = "Interface\\MINIMAP\\TRACKING\\Ammunition",
            func = function()
                if not PlayerTalentFrame then
                    LoadAddOn("Blizzard_TalentUI")
                end
                if not GlyphFrame then
                    LoadAddOn("Blizzard_GlyphUI")
                end
                securecall(ToggleTalentFrame)
            end,
            notCheckable = true,
        },
        {
            text = ACHIEVEMENT_BUTTON,
            icon = PATH .. "picomenuAchievement",
            func = function() securecall(ToggleAchievementFrame) end,
            notCheckable = true,
        },
        {
            text = QUESTLOG_BUTTON,
            icon = "Interface\\GossipFrame\\ActiveQuestIcon",
            func = function() securecall(ToggleFrame, QuestLogFrame) end,
            notCheckable = true,
        },
        {
            text = GUILD,
            icon = "Interface\\GossipFrame\\TabardGossipIcon",
            func = function()
                if IsTrialAccount() then
                    UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT, 1, 0, 0)
                else
                    securecall(ToggleGuildFrame)
                end
            end,
            notCheckable = true,
        },
        {
            text = SOCIAL_BUTTON,
            icon = "Interface\\FriendsFrame\\PlusManz-BattleNet",
            func = function() securecall(ToggleFriendsFrame, 1) end,
            notCheckable = true,
        },
        {
            text = PLAYER_V_PLAYER,
            icon = "Interface\\MINIMAP\\TRACKING\\BattleMaster",
            func = function()
                if not PVPUIFrame then
                    securecall(PVP_LoadUI)
                end
                securecall(PVPUIFrame_ToggleFrame, "PVPQueueFrame")
            end,
            notCheckable = true,
        },
        {
            text = DUNGEONS_BUTTON,
            icon = "Interface\\LFGFRAME\\BattleNetWorking0",
            func = function() securecall(PVEFrame_ToggleFrame, "GroupFinderFrame", LFDParentFrame) end,
            notCheckable = true,
        },
        {
            text = CHALLENGES,
            icon = "Interface\\BUTTONS\\UI-GroupLoot-DE-Up",
            func = function() securecall(PVEFrame_ToggleFrame, "ChallengesFrame") end,
            notCheckable = true,
        },
        {
            text = RAID_FINDER,
            icon = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-Skull",
            func = function() securecall(PVEFrame_ToggleFrame, "GroupFinderFrame", RaidFinderFrame) end,
            notCheckable = true,
        },
        {
            text = RAID,
            icon = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-Skull",
            func = function() securecall(ToggleFriendsFrame, 4) end,
            notCheckable = true,
        },
        {
            text = MOUNTS_AND_PETS,
            icon = "Interface\\MINIMAP\\TRACKING\\StableMaster",
            func = function() securecall(TogglePetJournal) end,
            notCheckable = true,
        },
        {
            text = ENCOUNTER_JOURNAL,
            icon = "Interface\\MINIMAP\\TRACKING\\Profession",
            func = function() securecall(ToggleEncounterJournal) end,
            notCheckable = true,
        },
        {
            text = GM_EMAIL_NAME,
            icon = "Interface\\CHATFRAME\\UI-ChatIcon-Blizz",
            func = function() securecall(ToggleHelpFrame) end,
            notCheckable = true,
        },
        {
            text = BATTLEFIELD_MINIMAP,
            colorCode = "|cff999999",
            func = function() securecall(ToggleBattlefieldMinimap) end,
            notCheckable = true,
        },
    }

    local f = CreateFrame("Button", nil, MainMenuBar)
    f:SetFrameStrata("HIGH")
    f:SetToplevel(true)
    f:SetSize(30, 30)
    f:SetPoint("BOTTOM", MainMenuBarRightEndCap, -13, 8)
    f:RegisterForClicks("AnyUp")

    f:SetNormalTexture(PATH .. "picomenuNormal")
    if f:GetNormalTexture() then
        f:GetNormalTexture():SetSize(30, 30)
    end
    f:SetHighlightTexture(PATH .. "picomenuHighlight")
    if f:GetHighlightTexture() and f:GetNormalTexture() then
        f:GetHighlightTexture():SetAllPoints(f:GetNormalTexture())
    end

    f:SetScript("OnMouseDown", function(self)
        self:GetNormalTexture():ClearAllPoints()
        self:GetNormalTexture():SetPoint("CENTER", 1, -1)
    end)

    f:SetScript("OnMouseUp", function(self, button)
        self:GetNormalTexture():ClearAllPoints()
        self:GetNormalTexture():SetPoint("CENTER")

        if button == "LeftButton" then
            if self:IsMouseOver() then
                if DropDownList1:IsShown() then
                    DropDownList1:Hide()
                else
                    securecall(EasyMenu, menuList, menuFrame, self, 27, 190, "MENU", 8)
                end
            end
        else
            if self:IsMouseOver() then
                ToggleFrame(GameMenuFrame)
            end
        end
        GameTooltip:Hide()
    end)

    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 25, -5)
        GameTooltip:AddLine(MAINMENU_BUTTON)
        GameTooltip:Show()
    end)

    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    if HelpOpenTicketButton then
        HelpOpenTicketButton:ClearAllPoints()
        HelpOpenTicketButton:SetPoint("TOPLEFT", f, "BOTTOMRIGHT", -26, 26)
        HelpOpenTicketButton:SetScale(0.6)
        HelpOpenTicketButton:SetParent(f)
    end
end

ns.ApplyPicomenu = function()
    if ns.module.settings.showPicomenu then
        Setup()
    end
end
