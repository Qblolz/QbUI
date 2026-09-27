local ADDON_NAME, ns = ...

local core = ns.core

local FRAME_SCALE = 1.2

local SCALED_FRAMES = {
    "QuestLogFrame",
    "QuestLogDetailFrame",
    "WatchFrame",
    "SpellBookFrame",
    "CharacterFrame",
    "PlayerTalentFrame",
    "AchievementFrame",
    "LookingForGuildFrame",
    "PVPUIFrame",
    "PVEFrame",
    "PetJournalParent",
    "EncounterJournal",
    "StoreFrame",
    "MerchantFrame",
    "GossipFrame",
    "ClassTrainerFrame",
    "QuestFrame",
    "InspectFrame",
    "ReforgingFrame",
    "ItemSocketingFrame",
}

local TOOLTIPS = {
    "GameTooltip",
    "ItemRefTooltip",
    "ShoppingTooltip1",
    "ShoppingTooltip2",
    "ShoppingTooltip3",
    "SocialToastAnchorFrame",
}

local setupDone = false

local function ResizeTooltip(tooltip)
    if tooltip and tooltip.SetScale then
        tooltip:SetScale(FRAME_SCALE)
    end
end

local function ApplyFrameScale()
    for _, name in ipairs(SCALED_FRAMES) do
        local frame = _G[name]
        if frame then
            frame:SetScale(FRAME_SCALE)
        end
    end
end

local function SetupOnce()
    if setupDone then
        return
    end
    setupDone = true

    for _, name in ipairs(TOOLTIPS) do
        local tooltip = _G[name]
        if tooltip and tooltip.HookScript then
            tooltip:HookScript("OnShow", ResizeTooltip)
        end
    end

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:SetScript("OnEvent", function()
        ApplyFrameScale()
    end)
end

local function ReapplyWatchFrame()
    local watchFrame = _G.WatchFrame
    if watchFrame then
        watchFrame:SetScale(FRAME_SCALE)
    end
end

ns.RegisterPreset("Preset-Misc", function()
    SetupOnce()
    ApplyFrameScale()
    core:ScheduleTimer(ReapplyWatchFrame, 5)
end)
