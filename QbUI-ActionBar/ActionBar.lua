local ADDON_NAME, ns = ...

local core = LibStub("AceAddon-3.0"):GetAddon("QbUI")

local L = setmetatable({
    ["Action Bar"] = "Панели действий",
    ["Enable module"] = "Включить модуль",
    ["Main bar"] = "Основная панель",
    ["Main bar scale"] = "Масштаб основной панели",
    ["Vehicle bar scale"] = "Масштаб панели транспорта",
    ["Hide gryphons"] = "Скрыть грифонов",
    ["Short bar"] = "Короткая панель",
    ["Skin buttons"] = "Скин кнопок",
    ["Moveable extra bars"] = "Перемещаемые доп. панели",
    ["Buttons"] = "Кнопки",
    ["Show keybinds"] = "Показывать бинды",
    ["Show macro names"] = "Показывать имена макросов",
    ["Show vehicle keybinds"] = "Показывать бинды транспорта",
    ["Keybind font size"] = "Размер шрифта биндов",
    ["Macro name font size"] = "Размер шрифта имён макросов",
    ["Count font size"] = "Размер шрифта счётчика",
    ["Bars"] = "Панели",
    ["Alpha"] = "Прозрачность",
    ["Hidden alpha"] = "Прозрачность вне наведения",
    ["Mouseover"] = "Показ при наведении",
    ["Scale"] = "Масштаб",
    ["Hide"] = "Скрыть",
    ["Left bar"] = "Левая панель",
    ["Right bar"] = "Правая панель",
    ["Bottom left bar"] = "Нижняя левая панель",
    ["Bottom right bar"] = "Нижняя правая панель",
    ["Pet bar"] = "Панель питомца",
    ["Stance bar"] = "Панель стоек",
    ["Possess bar"] = "Панель контроля",
    ["Experience bar"] = "Полоса опыта",
    ["Reputation bar"] = "Полоса репутации",
    ["Show text on mouseover"] = "Текст при наведении",
    ["Font size"] = "Размер шрифта",
    ["Totem bar"] = "Панель тотемов",
    ["Hide recall button"] = "Скрыть кнопку возврата",
    ["Picomenu"] = "Пикоменю",
    ["Show picomenu"] = "Показывать пикоменю",
}, { __index = function(_, key) return key end })
ns.L = L

ns.MEDIA = "Interface\\AddOns\\QbUI-ActionBar\\media\\"

local defaults = {
    enabled = true,

        mainScale = 1,
        vehicleScale = 0.8,
        hideGryphons = false,
        shortBar = true,
        moveableExtraBars = false,

        showKeybinds = true,
        showMacronames = true,
        showVehicleKeybinds = true,

        petScale = 1,
        stanceScale = 1, stanceHide = false,
        possessScale = 1,

        expFontsize = 14,
        repFontsize = 14,

        totemScale = 1, totemHideRecall = false,

    showPicomenu = true,
}

local ActionBar = core:RegisterModule({
    id = ADDON_NAME,
    name = L["Action Bar"],
    defaults = defaults,
})

ActionBar.settings = defaults

ns.module = ActionBar

local function opt(key, option)
    return core:Option(ActionBar, key, option)
end

local function toggle(key, name, order)
    return opt(key, { type = "toggle", name = name, order = order, width = "full" })
end

local function range(key, name, order, min, max, step)
    return opt(key, { type = "range", name = name, order = order, min = min, max = max, step = step })
end

local function barGroup(prefix, label, order)
    return {
        type = "group",
        name = label,
        inline = true,
        order = order,
        args = {
            scale = range(prefix .. "Scale", L["Scale"], 1, 0.5, 2, 0.05),
        },
    }
end

function ActionBar:GetOptions()
    return {
        type = "group",
        name = self.name,
        args = {
            enabled = toggle("enabled", L["Enable module"], 1),

            main = {
                type = "group",
                name = L["Main bar"],
                order = 2,
                args = {
                    mainScale = range("mainScale", L["Main bar scale"], 1, 0.5, 2, 0.05),
                    vehicleScale = range("vehicleScale", L["Vehicle bar scale"], 2, 0.5, 2, 0.05),
                    hideGryphons = toggle("hideGryphons", L["Hide gryphons"], 3),
                    shortBar = toggle("shortBar", L["Short bar"], 4),
                    moveableExtraBars = toggle("moveableExtraBars", L["Moveable extra bars"], 5),
                },
            },

            buttons = {
                type = "group",
                name = L["Buttons"],
                order = 3,
                args = {
                    showKeybinds = toggle("showKeybinds", L["Show keybinds"], 1),
                    showMacronames = toggle("showMacronames", L["Show macro names"], 2),
                    showVehicleKeybinds = toggle("showVehicleKeybinds", L["Show vehicle keybinds"], 3),
                },
            },

            bars = {
                type = "group",
                name = L["Bars"],
                order = 4,
                args = {
                    pet = barGroup("pet", L["Pet bar"], 1),
                    stance = barGroup("stance", L["Stance bar"], 2),
                    stanceHide = toggle("stanceHide", L["Hide"] .. ": " .. L["Stance bar"], 3),
                    possess = barGroup("possess", L["Possess bar"], 4),
                },
            },

            exprep = {
                type = "group",
                name = L["Experience bar"],
                order = 5,
                args = {
                    expFontsize = range("expFontsize", L["Font size"], 1, 6, 30, 1),
                    repFontsize = range("repFontsize", L["Font size"], 2, 6, 30, 1),
                },
            },

            totem = {
                type = "group",
                name = L["Totem bar"],
                order = 6,
                args = {
                    totemScale = range("totemScale", L["Scale"], 1, 0.5, 2, 0.05),
                    totemHideRecall = toggle("totemHideRecall", L["Hide recall button"], 2),
                },
            },

            picomenu = {
                type = "group",
                name = L["Picomenu"],
                order = 7,
                args = {
                    showPicomenu = toggle("showPicomenu", L["Show picomenu"], 1),
                },
            },
        },
    }
end

function ActionBar:Apply()
    ns.ApplyBars()
    ns.ApplyShort()
    ns.ApplyMicroBags()
    ns.ApplyExpRep()
    ns.ApplyTotem()
    ns.ApplyPicomenu()
end
