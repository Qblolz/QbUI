local ADDON_NAME, ns = ...

local shortBarDone = false

local function SetupShortBar()
    if shortBarDone then
        return
    end
    shortBarDone = true

    for _, frame in pairs({
        "MultiBarLeft",
        "MultiBarRight",
        "MultiBarBottomRight",
        "PossessBarFrame",
        "MULTICASTACTIONBAR_YPOS",
        "MultiCastActionBarFrame",
        "PETACTIONBAR_YPOS",
    }) do
        UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
    end

    for i = 2, 3 do
        for _, object in pairs({
            _G["ActionBarUpButton"],
            _G["ActionBarDownButton"],
            _G["MainMenuBarTexture" .. i],
            _G["MainMenuMaxLevelBar" .. i],
            _G["MainMenuXPBarTexture" .. i],
            _G["ReputationWatchBarTexture" .. i],
            _G["ReputationXPBarTexture" .. i],
            _G["MainMenuBarPageNumber"],
            _G["SlidingActionBarTexture0"],
            _G["SlidingActionBarTexture1"],
            _G["StanceBarLeft"],
            _G["StanceBarMiddle"],
            _G["StanceBarRight"],
            _G["PossessBackground1"],
            _G["PossessBackground2"],
        }) do
            if object then
                hooksecurefunc(object, "Show", function(self)
                    self:Hide()
                end)
                object:Hide()
            end
        end
    end

    for _, object in pairs({
        _G["MainMenuBar"],
        _G["MainMenuExpBar"],
        _G["MainMenuBarMaxLevelBar"],
        _G["ReputationWatchBar"],
        _G["ReputationWatchStatusBar"],
    }) do
        if object then
            object:SetWidth(512)
        end
    end

    for i = 1, 19, 2 do
        local object = _G["MainMenuXPBarDiv" .. i]
        if object then
            hooksecurefunc(object, "Show", function(self)
                self:Hide()
            end)
            object:Hide()
        end
    end

    if _G["MainMenuXPBarDiv2"] then
        hooksecurefunc(_G["MainMenuXPBarDiv2"], "Show", function()
            local divWidth = MainMenuExpBar:GetWidth() / 10
            local xpos = divWidth - 4.5
            for i = 2, 19, 2 do
                local texture = _G["MainMenuXPBarDiv" .. i]
                if texture then
                    texture:SetPoint("LEFT", floor(xpos), 1)
                end
                xpos = xpos + divWidth
            end
        end)
        _G["MainMenuXPBarDiv2"]:Show()
    end

    MultiBarBottomRight:EnableMouse(false)
    MultiBarBottomRightButton1:ClearAllPoints()
    MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton1, "TOPLEFT", 0, 6)

    MainMenuBarTexture0:SetPoint("BOTTOM", MainMenuBarArtFrame, -128, 0)
    MainMenuBarTexture1:SetPoint("BOTTOM", MainMenuBarArtFrame, 128, 0)
    MainMenuMaxLevelBar0:SetPoint("BOTTOM", MainMenuBarMaxLevelBar, "TOP", -128, 0)

    MainMenuBarLeftEndCap:SetPoint("BOTTOM", MainMenuBarArtFrame, -289, 0)
    MainMenuBarRightEndCap:SetPoint("BOTTOM", MainMenuBarArtFrame, 289, 0)

    MainMenuBarVehicleLeaveButton:HookScript("OnShow", function(self)
        self:ClearAllPoints()
        self:SetPoint("LEFT", MainMenuBar, "RIGHT", 10, 75)
    end)
end

ns.ApplyShort = function()
    if ns.module.settings.shortBar then
        SetupShortBar()
    end
end
