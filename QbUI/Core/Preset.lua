local ADDON_NAME, ns = ...

local core = ns.core

ns.presets = {}

function ns.RegisterPreset(id, apply)
    ns.presets[#ns.presets + 1] = { id = id, apply = apply }
end

function ns.ApplyPreset()
    core:RunOutOfCombat(function()
        for _, preset in ipairs(ns.presets) do
            local ok, err = pcall(preset.apply)
            if not ok then
                core:PrintError(preset.id .. ": " .. tostring(err))
            end
        end
    end)
end
