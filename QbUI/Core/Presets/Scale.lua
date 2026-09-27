local ADDON_NAME, ns = ...

local UI_SCALE = 0.595

ns.RegisterPreset("Preset-Scale", function()
    UIParent:SetScale(UI_SCALE)
end)
