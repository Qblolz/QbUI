local ADDON_NAME, ns = ...

local gsub = string.gsub

local function safeGsub(text, pattern, replacement)
    if type(pattern) == "string" then
        return gsub(text, pattern, replacement)
    end
    return text
end

hooksecurefunc("ActionButton_UpdateHotkeys", function(self)
    local hotkey = _G[self:GetName() .. "HotKey"]
    if not hotkey then
        return
    end

    local text = hotkey:GetText()
    if not text then
        return
    end

    text = gsub(text, "(s%-)", "S-")
    text = gsub(text, "(a%-)", "A-")
    text = gsub(text, "(c%-)", "C-")
    text = gsub(text, "(st%-)", "C-")

    for i = 1, 30 do
        text = safeGsub(text, _G["KEY_BUTTON" .. i], "M" .. i)
    end

    for i = 1, 9 do
        text = safeGsub(text, _G["KEY_NUMPAD" .. i], "Nu" .. i)
    end

    text = safeGsub(text, KEY_NUMPADDECIMAL, "Nu.")
    text = safeGsub(text, KEY_NUMPADDIVIDE, "Nu/")
    text = safeGsub(text, KEY_NUMPADMINUS, "Nu-")
    text = safeGsub(text, KEY_NUMPADMULTIPLY, "Nu*")
    text = safeGsub(text, KEY_NUMPADPLUS, "Nu+")

    text = safeGsub(text, KEY_MOUSEWHEELUP, "MU")
    text = safeGsub(text, KEY_MOUSEWHEELDOWN, "MD")
    text = safeGsub(text, KEY_NUMLOCK, "NuL")
    text = safeGsub(text, KEY_PAGEUP, "PU")
    text = safeGsub(text, KEY_PAGEDOWN, "PD")
    text = safeGsub(text, KEY_SPACE, "_")
    text = safeGsub(text, KEY_INSERT, "Ins")
    text = safeGsub(text, KEY_HOME, "Hm")
    text = safeGsub(text, KEY_DELETE, "Del")

    hotkey:SetText(text)
end)
