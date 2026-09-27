local ADDON_NAME, ns = ...

local CHAT_FONT_SIZE = 16

local CHAT_POSITION = {
    window = 1,
    point = "BOTTOMLEFT",
    x = 0.015253,
    y = 0.038737,
    width = 608.000061,
    height = 175.574066,
}

local CHAT_TABS = {
    {
        name = "General",
        messages = {
            "SYSTEM", "SYSTEM_NOMENU", "SAY", "EMOTE", "YELL", "OFFICER",
            "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE", "MONSTER_WHISPER",
            "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER", "ERRORS", "AFK", "DND",
            "IGNORED", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "COMBAT_FACTION_CHANGE",
            "SKILL", "LOOT", "MONEY", "CHANNEL", "ACHIEVEMENT", "TARGETICONS",
            "BN_WHISPER_INFORM", "BN_CONVERSATION", "BN_INLINE_TOAST_ALERT",
        },
    },
    {
        name = "Combat Log",
        messages = {
            "OPENING", "TRADESKILLS", "PET_INFO", "COMBAT_XP_GAIN",
            "COMBAT_HONOR_GAIN", "COMBAT_MISC_INFO",
        },
    },
    {
        name = "Группа",
        messages = {
            "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING",
            "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER",
        },
    },
    {
        name = "Гильдия",
        messages = { "GUILD", "GUILD_ACHIEVEMENT" },
    },
    {
        name = "/w",
        messages = { "WHISPER", "CHANNEL", "BN_WHISPER" },
    },
}

local function FindChatWindowByName(name)
    if not FCF_GetChatWindowInfo then
        return nil
    end
    for index = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame" .. index]
        if frame and FCF_GetChatWindowInfo(index) == name then
            return frame
        end
    end
    return nil
end

local function ApplyChatTabs()
    for _, tab in ipairs(CHAT_TABS) do
        local frame = FindChatWindowByName(tab.name)
        if not frame and FCF_OpenNewWindow then
            local created = FCF_OpenNewWindow(tab.name)
            frame = created or FindChatWindowByName(tab.name)
            if frame and FCF_SetWindowName then
                FCF_SetWindowName(frame, tab.name)
            end
        end
        if frame then
            if ChatFrame_RemoveAllMessageGroups then
                ChatFrame_RemoveAllMessageGroups(frame)
            end
            if ChatFrame_AddMessageGroup then
                for _, group in ipairs(tab.messages) do
                    pcall(ChatFrame_AddMessageGroup, frame, group)
                end
            end
        end
    end
end

local function ApplyChatFont()
    if not FCF_SetChatWindowFontSize then
        return
    end
    for index = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame" .. index]
        if frame then
            FCF_SetChatWindowFontSize(nil, frame, CHAT_FONT_SIZE)
        end
    end
end

local function ApplyChatPosition()
    local frame = _G["ChatFrame" .. CHAT_POSITION.window]
    if not frame then
        return
    end
    frame:ClearAllPoints()
    frame:SetPoint(CHAT_POSITION.point,
        CHAT_POSITION.x * GetScreenWidth(),
        CHAT_POSITION.y * GetScreenHeight())
    frame:SetSize(CHAT_POSITION.width, CHAT_POSITION.height)
    frame:SetUserPlaced(true)
    if FCF_SavePositionAndDimensions then
        FCF_SavePositionAndDimensions(frame)
    end
end

local function EnsureChatFrameAlpha()
    local defaultAlpha = DEFAULT_CHATFRAME_ALPHA or 0.25
    for index = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame" .. index]
        if frame and frame.oldAlpha == nil then
            frame.oldAlpha = defaultAlpha
        end
    end
end

ns.RegisterPreset("Preset-Chat", function()
    EnsureChatFrameAlpha()
    ApplyChatTabs()
    ApplyChatFont()
    ApplyChatPosition()
end)
