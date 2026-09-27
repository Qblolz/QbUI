local ADDON_NAME, ns = ...

local _G = _G

-- On /reload PLAYER_ENTERING_WORLD fires before GetActionCooldown returns real
-- values, and nothing re-runs ActionButton_UpdateCooldown afterwards, so a spell
-- that is already on cooldown shows no spiral until the button is redrawn
-- (e.g. moving the spell between slots -> ACTIONBAR_SLOT_CHANGED).
-- Force a couple of delayed refresh passes to pick the cooldowns up.

local BAR_PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
    "MultiBar5Button",
    "MultiBar6Button",
    "MultiBar7Button",
}

local function RefreshCooldowns()
    for _, prefix in ipairs(BAR_PREFIXES) do
        for i = 1, 12 do
            local button = _G[prefix .. i]
            if button and button.cooldown and button.action and HasAction(button.action) then
                ActionButton_UpdateCooldown(button)
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self)
    RefreshCooldowns()
    self.delays = { 0.5, 2 }
    self.elapsed = 0
end)

frame:SetScript("OnUpdate", function(self, elapsed)
    local delays = self.delays
    if not delays then
        return
    end
    self.elapsed = self.elapsed + elapsed
    for i = #delays, 1, -1 do
        if self.elapsed >= delays[i] then
            table.remove(delays, i)
            RefreshCooldowns()
        end
    end
    if #delays == 0 then
        self.delays = nil
    end
end)
