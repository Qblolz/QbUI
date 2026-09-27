local ADDON_NAME, ns = ...

local MICRO_X = 0
local MICRO_Y = 0
local BAG_X = 0
local BAG_Y = 42

local BAG_FRAMES = {
    "MainMenuBarBackpackButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot",
    "KeyRingButton",
}

local setupDone = false

local function MicroMenuWidth()
    local count = 0
    for i = 1, #MICRO_BUTTONS do
        local button = _G[MICRO_BUTTONS[i]]
        if button and button:IsShown() then
            count = count + 1
        end
    end
    if count == 0 then
        count = 12
    end
    return (count - 1) * 25 + 28
end

local function AnchorMicroMenu()
    CharacterMicroButton:ClearAllPoints()
    CharacterMicroButton:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMRIGHT", -(MicroMenuWidth() + MICRO_X), MICRO_Y)
end

local function AnchorBags()
    for _, name in ipairs(BAG_FRAMES) do
        local frame = _G[name]
        if frame then
            frame:SetParent(UIParent)
        end
    end

    local backpack = _G.MainMenuBarBackpackButton
    if backpack then
        backpack:ClearAllPoints()
        backpack:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -BAG_X, BAG_Y)
    end
end

local function Setup()
    if setupDone then
        return
    end
    setupDone = true

    hooksecurefunc("MoveMicroButtons", function()
        AnchorMicroMenu()
    end)
end

ns.ApplyMicroBags = function()
    Setup()
    AnchorMicroMenu()
    AnchorBags()
end
