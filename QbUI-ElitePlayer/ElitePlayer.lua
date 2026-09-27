local ADDON_NAME, ns = ...

local ELITE_TEXTURE = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite"
local RARE_ELITE_TEXTURE = "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite"

local function ResolveFrameTexture(unitFrameName)
    local unitFrame = _G[unitFrameName]
    if unitFrame and unitFrame.borderTexture then
        return unitFrame.borderTexture
    end
    local textureFrame = _G[unitFrameName .. "TextureFrame"]
    if textureFrame then
        local texture = textureFrame.texture or textureFrame.Texture
        if texture then
            return texture
        end
    end
    return _G[unitFrameName .. "Texture"]
end

local function ForceTexture(unitFrameName, texture)
    local frameTexture = ResolveFrameTexture(unitFrameName)
    if frameTexture and frameTexture.SetTexture then
        frameTexture:SetTexture(texture)
    end
end

local function HookTexture(unitFrameName, texture)
    local frameTexture = ResolveFrameTexture(unitFrameName)
    if not frameTexture or frameTexture.__qbuiEliteHooked then
        return
    end
    frameTexture.__qbuiEliteHooked = true
    hooksecurefunc(frameTexture, "SetTexture", function(self, value)
        if value ~= texture then
            self:SetTexture(texture)
        end
    end)
end

local function Apply()
    ForceTexture("PlayerFrame", ELITE_TEXTURE)
    ForceTexture("TargetFrame", RARE_ELITE_TEXTURE)
    ForceTexture("FocusFrame", RARE_ELITE_TEXTURE)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON_NAME then
            UnitClassification = function()
                return "rareelite"
            end
            HookTexture("PlayerFrame", ELITE_TEXTURE)
            HookTexture("TargetFrame", RARE_ELITE_TEXTURE)
            HookTexture("FocusFrame", RARE_ELITE_TEXTURE)
            Apply()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        Apply()
    elseif event == "PLAYER_TARGET_CHANGED" then
        ForceTexture("TargetFrame", RARE_ELITE_TEXTURE)
    elseif event == "PLAYER_FOCUS_CHANGED" then
        ForceTexture("FocusFrame", RARE_ELITE_TEXTURE)
    end
end)
