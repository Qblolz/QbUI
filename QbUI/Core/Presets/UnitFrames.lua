local ADDON_NAME, ns = ...

local UNIT_FRAMES = { "TargetFrame", "FocusFrame" }

local FONT_PATH = "Fonts\\ARIALN.TTF"
local FONT_SIZE = 14
local FONT_FLAGS = "OUTLINE"

local FONT_BARS = {
    PetFrameHealthBar = true,
    PetFrameManaBar = true,
    TargetFrameHealthBar = true,
    TargetFrameManaBar = true,
    FocusFrameHealthBar = true,
    FocusFrameManaBar = true,
    PlayerFrameHealthBar = true,
    PlayerFrameManaBar = true,
}

local FONT_TEXTS = {
    PetFrameHealthBarText = true,
    PetFrameManaBarText = true,
}

local setupDone = false

local function HideElement(frame)
    if not frame then
        return
    end
    if frame.ClearAllPoints then
        frame:ClearAllPoints()
    end
    if frame.SetAlpha then
        frame:SetAlpha(0)
    end
    if frame.Hide then
        frame:Hide()
    end
end

local function UpdateBarFont(statusBar, textString)
    if not textString or not textString.SetFont then
        return
    end
    local textName = textString.GetName and textString:GetName()
    if textName and FONT_TEXTS[textName] then
        textString:SetFont(FONT_PATH, FONT_SIZE, FONT_FLAGS)
        return
    end
    local barName = statusBar and statusBar.GetName and statusBar:GetName()
    if barName and FONT_BARS[barName] then
        textString:SetFont(FONT_PATH, FONT_SIZE, FONT_FLAGS)
    end
end

local function SetupOnce()
    if setupDone then
        return
    end
    setupDone = true
    if type(TextStatusBar_UpdateTextStringWithValues) == "function" then
        hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", UpdateBarFont)
    end
end

local function HidePlayerPVPTimer()
    local timerText = _G.PlayerPVPTimerText
    if not timerText or timerText.__qbuiHooked then
        return
    end
    timerText.__qbuiHooked = true
    timerText:Hide()
    hooksecurefunc(timerText, "Show", function(self)
        self:Hide()
    end)
end

ns.RegisterPreset("Preset-UnitFrames", function()
    SetupOnce()
    HidePlayerPVPTimer()

    for _, name in ipairs(UNIT_FRAMES) do
        local unitFrame = _G[name]
        if unitFrame then
            HideElement(unitFrame.pvpIcon)
            HideElement(unitFrame.renegadeIcon)
            if unitFrame.TextureFrame then
                HideElement(unitFrame.TextureFrame.RankFrame)
            end
        end
        HideElement(_G[name .. "TextureFrameRankFrame"])
        HideElement(_G[name .. "HeadHuntingWantedFrame"])
    end
end)
