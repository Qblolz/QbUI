local ADDON_NAME, ns = ...

local function settings()
    return ns.module.settings
end

local function ApplyMainBar(st)
    if st.hideGryphons then
        if MainMenuBarLeftEndCap then
            MainMenuBarLeftEndCap:SetTexCoord(0, 0, 0, 0)
        end
        if MainMenuBarRightEndCap then
            MainMenuBarRightEndCap:SetTexCoord(0, 0, 0, 0)
        end
    end
    MainMenuBar:SetScale(st.mainScale)
    OverrideActionBar:SetScale(st.vehicleScale)
end

local function ApplyMultiBars(st)
    MultiBarLeft:SetScale(st.mainScale)
    MultiBarLeft:SetParent(UIParent)

    MultiBarRight:SetScale(st.mainScale)

    MultiBarRight:ClearAllPoints()
    MultiBarRight:SetPoint("RIGHT", UIParent, "RIGHT", -7, 0)
    MultiBarRightButton1:ClearAllPoints()
    MultiBarRightButton1:SetPoint("TOPRIGHT", MultiBarRight, "TOPRIGHT", 0, 0)

    MultiBarLeft:ClearAllPoints()
    MultiBarLeft:SetPoint("RIGHT", MultiBarRight, "LEFT", -5, 0)
    MultiBarLeftButton1:ClearAllPoints()
    MultiBarLeftButton1:SetPoint("TOPRIGHT", MultiBarLeft, "TOPRIGHT", 0, 0)
end

local function ApplyPetStancePossess(st)
    PetActionBarFrame:SetFrameStrata("HIGH")
    PetActionBarFrame:SetScale(st.petScale)

    StanceBarFrame:SetFrameStrata("HIGH")
    StanceBarFrame:SetScale(st.stanceScale)

    PossessBarFrame:SetScale(st.possessScale)

    if st.stanceHide then
        for i = 1, NUM_STANCE_SLOTS do
            local button = _G["StanceButton" .. i]
            if button then
                button:SetAlpha(0)
                button.SetAlpha = function() end
                button:EnableMouse(false)
                button.EnableMouse = function() end
            end
        end
    end
end

ns.ApplyBars = function()
    local st = settings()
    ApplyMainBar(st)
    ApplyMultiBars(st)
    ApplyPetStancePossess(st)
end
