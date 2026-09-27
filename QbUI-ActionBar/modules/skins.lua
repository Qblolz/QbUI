local ADDON_NAME, ns = ...

local _G = _G

local function settings()
    return ns.module.settings
end

local function IsSpecificButton(self, name)
    local frameName = self.GetName and self:GetName()
    return frameName ~= nil and frameName:match(name) ~= nil
end

hooksecurefunc("ActionButton_UpdateHotkeys", function(self)
    local st = settings()
    local hotkey = _G[self:GetName() .. "HotKey"]
    if not hotkey then
        return
    end

    local show
    if IsSpecificButton(self, "OverrideActionBarButton") then
        show = st.showVehicleKeybinds
    else
        show = st.showKeybinds
    end

    if show then
        hotkey:Show()
    else
        hotkey:Hide()
    end
end)

hooksecurefunc("ActionButton_Update", function(self)
    local st = settings()
    local name = self.GetName and self:GetName()
    if not name then
        return
    end

    local macroname = _G[name .. "Name"]
    if macroname then
        macroname:SetAlpha(st.showMacronames and 1 or 0)
    end
end)

hooksecurefunc("ActionButton_UpdateUsable", function(self)
    local name = self.GetName and self:GetName()
    if not name then
        return
    end

    local icon = _G[name .. "Icon"]
    if icon then
        icon:SetVertexColor(1, 1, 1)
    end

    local normal = _G[name .. "NormalTexture"]
    if normal then
        normal:SetVertexColor(1, 1, 1, 1)
    end
end)

hooksecurefunc("ActionButton_UpdateOverlayGlow", function(self)
    if self.overlay then
        ActionButton_HideOverlayGlow(self)
    end
end)
