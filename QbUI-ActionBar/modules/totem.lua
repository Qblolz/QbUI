local ADDON_NAME, ns = ...

local function settings()
    return ns.module.settings
end

local setupDone = false

local function Setup()
    if setupDone then
        return
    end
    if not MultiCastActionBarFrame or not MultiCastActionButton1 or not MultiCastSlotButton1 then
        return
    end
    setupDone = true

    local anchor = CreateFrame("Frame", "QbUI_ActionBar_TotemAnchor", UIParent)
    anchor:SetSize(10, 10)
    anchor:SetPoint("CENTER", UIParent)
    anchor:SetMovable(true)
    anchor:SetUserPlaced(true)

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", function()
        MultiCastActionBarFrame:ClearAllPoints()
        MultiCastActionBarFrame:SetPoint("CENTER", anchor)
    end)

    for i = 1, 12 do
        for _, button in pairs({
            _G["MultiCastSlotButton1"],
            _G["MultiCastSlotButton2"],
            _G["MultiCastSlotButton3"],
            _G["MultiCastSlotButton4"],
            _G["MultiCastActionBarFrame"],
            _G["MultiCastActionButton" .. i],
            _G["MultiCastRecallSpellButton"],
            _G["MultiCastSummonSpellButton"],
        }) do
            if button then
                button:RegisterForDrag("LeftButton")
                button:HookScript("OnDragStart", function()
                    if IsControlKeyDown() then
                        anchor:StartMoving()
                    end
                end)
                button:HookScript("OnDragStop", function()
                    anchor:StopMovingOrSizing()
                end)
            end
        end
    end

    MultiCastActionButton1:ClearAllPoints()
    MultiCastActionButton1:SetPoint("CENTER", MultiCastSlotButton1)
    if MultiCastActionButton5 then
        MultiCastActionButton5:ClearAllPoints()
        MultiCastActionButton5:SetPoint("CENTER", MultiCastSlotButton1)
    end
    if MultiCastActionButton9 then
        MultiCastActionButton9:ClearAllPoints()
        MultiCastActionButton9:SetPoint("CENTER", MultiCastSlotButton1)
    end

    hooksecurefunc("MultiCastFlyoutFrame_LoadSlotSpells", function(self, slot, ...)
        local numSpells = select("#", ...)
        if numSpells == 0 then
            return
        end
        for i = 2, numSpells + 1 do
            local icon = _G["MultiCastFlyoutButton" .. i .. "Icon"]
            if icon then
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
        end
    end)
end

ns.ApplyTotem = function()
    local st = settings()
    if not st.shortBar and not st.moveableExtraBars then
        return
    end
    if not MultiCastActionBarFrame then
        return
    end

    Setup()

    MultiCastActionBarFrame:SetScale(st.totemScale)
    if MultiCastFlyoutFrame then
        MultiCastFlyoutFrame:SetScale(st.totemScale * 1.1)
    end

    if st.totemHideRecall and MultiCastRecallSpellButton and not MultiCastRecallSpellButton.__qbuiHooked then
        MultiCastRecallSpellButton.__qbuiHooked = true
        hooksecurefunc(MultiCastRecallSpellButton, "Show", function(self)
            self:Hide()
        end)
    end
end
