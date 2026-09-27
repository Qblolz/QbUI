local ADDON_NAME, ns = ...

local CVARS = {
    deselectOnClick = "1",
    showTargetOfTarget = "1",
    stopAutoAttackOnTargetChange = "1",
    autoSelfCast = "0",
    consolidateBuffs = "0",
    displaySpellActivationOverlays = "0",
    lossOfControl = "0",
    combatTextFloatMode = "2",
    playerStatusText = "1",
    petStatusText = "1",
    partyStatusText = "1",
    targetStatusText = "1",
    nameplateShowEnemies = "1",
    showAllEnemyDebuffs = "1",
    cameraDistanceMax = "50",
}

ns.RegisterPreset("Preset-CVars", function()
    for name, value in pairs(CVARS) do
        if GetCVar(name) ~= nil then
            SetCVar(name, value)
        end
    end
end)
