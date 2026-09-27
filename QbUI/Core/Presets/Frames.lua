local ADDON_NAME, ns = ...

local FRAME_LAYOUT = {
    { name = "PlayerFrame", point = "TOPLEFT", x = 420.22, y = -304.81, scale = 1.1 },
    { name = "TargetFrame", point = "TOPLEFT", x = 652.00, y = -305.61, scale = 1.1 },
    { name = "FocusFrame", point = "TOPLEFT", x = 648.74, y = -697.41, scale = 1.1 },
}

local TOT_LAYOUT = {
    { name = "TargetFrameToT", anchor = "TargetFrame" },
    { name = "FocusFrameToT", anchor = "FocusFrame" },
}

ns.RegisterPreset("Preset-Frames", function()
    for _, entry in ipairs(FRAME_LAYOUT) do
        local frame = _G[entry.name]
        if frame then
            if UIPARENT_MANAGED_FRAME_POSITIONS and UIPARENT_MANAGED_FRAME_POSITIONS[entry.name] then
                frame.ignoreFramePositionManager = true
            end
            frame:ClearAllPoints()
            frame:SetPoint(entry.point, UIParent, entry.point, entry.x, entry.y)
            frame:SetScale(entry.scale)
        end
    end

    for _, entry in ipairs(TOT_LAYOUT) do
        local frame = _G[entry.name]
        local anchor = _G[entry.anchor]
        if frame and anchor then
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", anchor, "Right", -60, -45)
        end
    end
end)
