local ADDON_NAME, ns = ...

local FONT = "Fonts\\ARIALN.ttf"

ns.ApplyExpRep = function()
    local st = ns.module.settings

    MainMenuBarExpText:SetFont(FONT, st.expFontsize, "THINOUTLINE")
    MainMenuBarExpText:SetShadowOffset(0, 0)
    MainMenuBarExpText:SetAlpha(1)
    MainMenuBarExpText:Show()

    ReputationWatchStatusBarText:SetFont(FONT, st.repFontsize, "THINOUTLINE")
    ReputationWatchStatusBarText:SetShadowOffset(0, 0)
    ReputationWatchStatusBarText:SetAlpha(1)
    ReputationWatchStatusBarText:Show()
end
