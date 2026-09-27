local ADDON_NAME, ns = ...

local core = LibStub("AceAddon-3.0"):GetAddon("QbUI")

local L = setmetatable({
    ["OmniCC"] = "OmniCC",
    ["Enable module"] = "Включить модуль",
    ["Text"] = "Текст",
    ["Show cooldown text"] = "Показывать текст перезарядки",
    ["Scale text"] = "Масштабировать текст",
    ["Font"] = "Шрифт",
    ["Font face"] = "Гарнитура",
    ["Font size"] = "Размер шрифта",
    ["Font outline"] = "Обводка шрифта",
    ["Finish effect"] = "Эффект завершения",
    ["Timing"] = "Тайминги",
    ["Min duration"] = "Мин. длительность",
    ["Min size"] = "Мин. размер текста",
    ["Min effect duration"] = "Мин. длительность эффекта",
    ["Tenths duration"] = "Порог десятых",
    ["MM:SS duration"] = "Порог ММ:СС",
    ["Colors"] = "Цвета",
    ["Soon"] = "Скоро",
    ["Seconds"] = "Секунды",
    ["Minutes"] = "Минуты",
    ["Hours"] = "Часы",
    ["Charging"] = "Заряды",
    ["Scale"] = "Масштаб",
    ["None"] = "Нет",
    ["Blacklist"] = "Блэклист",
    ["Enable blacklist"] = "Включить блэклист",
    ["Patterns"] = "Шаблоны (по одному в строке)",
}, { __index = function(_, key) return key end })
ns.L = L

local OUTLINES = {
    ["None"] = "NONE",
    ["Outline"] = "OUTLINE",
    ["Thick outline"] = "THICKOUTLINE",
    ["Outline monochrome"] = "OUTLINEMONOCHROME",
}

local STYLE_ORDER = { "soon", "seconds", "minutes", "hours", "charging" }
local BLACKLIST_GROUP_ID = "QbUIBlacklist"
local STYLE_LABELS = {
    soon = "Soon",
    seconds = "Seconds",
    minutes = "Minutes",
    hours = "Hours",
    charging = "Charging",
}

local defaults = {
    enabled = true,
    showText = true,
    scaleText = true,
    fontFace = STANDARD_TEXT_FONT,
    fontSize = 10,
    fontOutline = "OUTLINE",
    effect = "none",
    minDuration = 2,
    minSize = 0.6,
    minEffectDuration = 28,
    tenthsDuration = 5,
    mmSSDuration = 150,
    useBlacklist = true,
    blacklist = "FocusFrameBuff\nTargetFrameBuff\nWeakAurasCooldowndr_fear\nWeakAurasCooldowndr_poly\nWeakAurasCooldowndr_stun",
    styles = {
        soon = { r = 0.9607843137254902, g = 1, b = 0.9882352941176471, a = 1, scale = 1 },
        seconds = { r = 0.9411764705882353, g = 1, b = 0.9882352941176471, a = 1, scale = 1 },
        minutes = { r = 1, g = 1, b = 1, a = 1, scale = 1 },
        hours = { r = 1, g = 1, b = 1, a = 1, scale = 1 },
        charging = { r = 1, g = 0.98, b = 0.4, a = 0.8, scale = 0.65 },
    },
}

local OmniCCModule = core:RegisterModule({
    id = ADDON_NAME,
    name = L["OmniCC"],
    defaults = defaults,
})

OmniCCModule.settings = defaults

ns.module = OmniCCModule


local function GetBaseGroup()
    local OmniCC = _G.OmniCC
    if not OmniCC or not OmniCC.sets then
        return
    end
    local groupSettings = OmniCC.sets.groupSettings
    if not groupSettings then
        return
    end
    if not groupSettings.base then
        groupSettings.base = {}
    end
    return groupSettings.base
end


local function ParsePatterns(text)
    local patterns = {}
    for line in tostring(text or ""):gmatch("[^\r\n,;]+") do
        line = strtrim(line)
        if line ~= "" then
            patterns[#patterns + 1] = line
        end
    end
    return patterns
end


local function ApplyBlacklist(module)
    local OmniCC = _G.OmniCC
    if not OmniCC or not OmniCC.sets then
        return
    end

    local groupSettings = OmniCC.sets.groupSettings
    local groups = OmniCC.sets.groups
    if not groupSettings or not groups then
        return
    end

    local index = OmniCC:GetGroupIndex(BLACKLIST_GROUP_ID)
    if not index then
        OmniCC:AddGroup(BLACKLIST_GROUP_ID)
        index = OmniCC:GetGroupIndex(BLACKLIST_GROUP_ID)
    end
    if not index then
        return
    end

    local group = groups[index]
    local settings = groupSettings[BLACKLIST_GROUP_ID]
    if not group or not settings then
        return
    end

    group.rules = ParsePatterns(module.settings.blacklist)
    group.enabled = module.settings.useBlacklist and true or false
    settings.enabled = false

    OmniCC:UpdateGroups()
end


function OmniCCModule:Apply()
    local base = GetBaseGroup()
    if not base then
        return
    end

    local settings = self.settings

    base.enabled = settings.showText ~= false
    base.scaleText = settings.scaleText
    base.fontFace = settings.fontFace
    base.fontSize = settings.fontSize
    base.fontOutline = settings.fontOutline
    base.effect = settings.effect
    base.minDuration = settings.minDuration
    base.minSize = settings.minSize
    base.minEffectDuration = settings.minEffectDuration
    base.tenthsDuration = settings.tenthsDuration
    base.mmSSDuration = settings.mmSSDuration

    base.styles = base.styles or {}
    for index = 1, #STYLE_ORDER do
        local key = STYLE_ORDER[index]
        local source = settings.styles[key]
        if source then
            local target = base.styles[key]
            if not target then
                target = {}
                base.styles[key] = target
            end
            target.r, target.g, target.b, target.a, target.scale =
                source.r, source.g, source.b, source.a, source.scale
        end
    end

    ApplyBlacklist(self)

    local OmniCC = _G.OmniCC
    if OmniCC.Timer then
        OmniCC.Timer:ForAll("UpdateShown")
        OmniCC.Timer:ForAll("UpdateText", true)
    end
    if OmniCC.Cooldown then
        OmniCC.Cooldown:ForAll("UpdateOpacity")
    end
end


local function EffectValues()
    local values = {}
    local OmniCC = _G.OmniCC
    if OmniCC and OmniCC.effects then
        for id, effect in pairs(OmniCC.effects) do
            values[effect.name or id] = id
        end
    end
    if next(values) == nil then
        values[L["None"]] = "none"
    end
    return values
end


function OmniCCModule:GetOptions()
    local module = self

    local function opt(key, option)
        return core:Option(module, key, option)
    end

    local function styleColor(key, order)
        return {
            type = "color",
            name = L[STYLE_LABELS[key]],
            order = order,
            hasAlpha = true,
            get = function()
                local style = module.settings.styles[key]
                return style.r, style.g, style.b, style.a
            end,
            set = function(_, r, g, b, a)
                local style = module.settings.styles[key]
                style.r, style.g, style.b, style.a = r, g, b, a
                module:Apply()
            end,
        }
    end

    local function styleScale(key, order)
        return {
            type = "range",
            name = L["Scale"] .. " (" .. L[STYLE_LABELS[key]] .. ")",
            order = order,
            min = 0.5,
            max = 2,
            step = 0.05,
            get = function()
                return module.settings.styles[key].scale
            end,
            set = function(_, value)
                module.settings.styles[key].scale = value
                module:Apply()
            end,
        }
    end

    local colorArgs = {}
    for index = 1, #STYLE_ORDER do
        local key = STYLE_ORDER[index]
        colorArgs[key .. "Color"] = styleColor(key, index * 2 - 1)
        colorArgs[key .. "Scale"] = styleScale(key, index * 2)
    end

    return {
        type = "group",
        name = self.name,
        args = {
            enabled = opt("enabled", {
                type = "toggle",
                name = L["Enable module"],
                order = 1,
                width = "full",
            }),

            text = {
                type = "group",
                name = L["Text"],
                inline = true,
                order = 2,
                args = {
                    showText = opt("showText", {
                        type = "toggle",
                        name = L["Show cooldown text"],
                        order = 1,
                        width = "full",
                    }),
                    scaleText = opt("scaleText", {
                        type = "toggle",
                        name = L["Scale text"],
                        order = 2,
                        width = "full",
                    }),
                    effect = opt("effect", {
                        type = "select",
                        name = L["Finish effect"],
                        order = 3,
                        values = EffectValues,
                    }),
                },
            },

            font = {
                type = "group",
                name = L["Font"],
                inline = true,
                order = 3,
                args = {
                    fontFace = opt("fontFace", {
                        type = "input",
                        name = L["Font face"],
                        order = 1,
                        width = "full",
                    }),
                    fontSize = opt("fontSize", {
                        type = "range",
                        name = L["Font size"],
                        order = 2,
                        min = 2,
                        max = 48,
                        step = 1,
                    }),
                    fontOutline = opt("fontOutline", {
                        type = "select",
                        name = L["Font outline"],
                        order = 3,
                        values = OUTLINES,
                    }),
                },
            },

            timing = {
                type = "group",
                name = L["Timing"],
                inline = true,
                order = 4,
                args = {
                    minDuration = opt("minDuration", {
                        type = "range",
                        name = L["Min duration"],
                        order = 1,
                        min = 0,
                        max = 30,
                        step = 0.5,
                    }),
                    minSize = {
                        type = "range",
                        name = L["Min size"],
                        order = 2,
                        min = 0,
                        max = 100,
                        step = 1,
                        get = function()
                            return floor(module.settings.minSize * 100 + 0.5)
                        end,
                        set = function(_, value)
                            module.settings.minSize = value / 100
                            module:Apply()
                        end,
                    },
                    minEffectDuration = opt("minEffectDuration", {
                        type = "range",
                        name = L["Min effect duration"],
                        order = 3,
                        min = 0,
                        max = 60,
                        step = 1,
                    }),
                    tenthsDuration = opt("tenthsDuration", {
                        type = "range",
                        name = L["Tenths duration"],
                        order = 4,
                        min = 0,
                        max = 10,
                        step = 1,
                    }),
                    mmSSDuration = {
                        type = "range",
                        name = L["MM:SS duration"],
                        order = 5,
                        min = 0,
                        max = 15,
                        step = 0.5,
                        get = function()
                            return module.settings.mmSSDuration / 60
                        end,
                        set = function(_, value)
                            module.settings.mmSSDuration = value * 60
                            module:Apply()
                        end,
                    },
                },
            },

            colors = {
                type = "group",
                name = L["Colors"],
                inline = true,
                order = 5,
                args = colorArgs,
            },

            blacklist = {
                type = "group",
                name = L["Blacklist"],
                inline = true,
                order = 6,
                args = {
                    useBlacklist = opt("useBlacklist", {
                        type = "toggle",
                        name = L["Enable blacklist"],
                        order = 1,
                        width = "full",
                    }),
                    blacklist = opt("blacklist", {
                        type = "input",
                        name = L["Patterns"],
                        order = 2,
                        width = "full",
                        multiline = 10,
                    }),
                },
            },
        },
    }
end
