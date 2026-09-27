local ADDON_NAME, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local QbUI = AceAddon:NewAddon(ADDON_NAME, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")

local L = setmetatable({
    ["Settings reset"] = "Настройки сброшены",
    ["Fixed preset is applied automatically."] = "Фиксированный пресет применяется автоматически.",
}, { __index = function(_, key) return key end })

QbUI.modules = {}
QbUI.moduleByID = {}
QbUI.deferred = {}

ns.core = QbUI
ns.L = L
QbUI.L = L

local function CopyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
            CopyDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

function QbUI:RegisterModule(def)
    assert(type(def) == "table", "QbUI: module must be a table")
    assert(type(def.id) == "string", "QbUI: module.id must be a string")
    self.pendingModules = self.pendingModules or {}
    self.pendingModules[#self.pendingModules + 1] = def
    return def
end

function QbUI:OnInitialize()
    QbUIDB = QbUIDB or {}
    QbUIDB.modules = QbUIDB.modules or {}
    self.db = QbUIDB

    self:RegisterChatCommand("qbui", "OnChatCommand")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("DISPLAY_SIZE_CHANGED")
end

function QbUI:OnEnable()
    self:InitializeModules()
    self:ApplyEverything()
end

function QbUI:InitializeModules()
    if self.modulesInitialized then
        return
    end
    self.modulesInitialized = true

    for _, def in ipairs(self.pendingModules or {}) do
        local settings = QbUIDB.modules[def.id]
        if type(settings) ~= "table" then
            settings = {}
            QbUIDB.modules[def.id] = settings
        end
        CopyDefaults(settings, def.defaults or {})
        def.settings = settings
        def.core = self
        self.modules[#self.modules + 1] = def
        self.moduleByID[def.id] = def
    end

    self:BuildOptions()
end

function QbUI:PLAYER_ENTERING_WORLD()
    self:ApplyEverything()
end

function QbUI:DISPLAY_SIZE_CHANGED()
    self:ApplyEverything()
end

function QbUI:PLAYER_REGEN_ENABLED()
    self:FlushDeferred()
end

function QbUI:ApplyEverything()
    if ns.ApplyPreset then
        ns.ApplyPreset()
    end
    self:ApplyAll()
end

function QbUI:ApplyAll()
    for _, def in ipairs(self.modules) do
        self:ApplyModule(def)
    end
end

function QbUI:ApplyModule(def)
    if def.settings.enabled == false then
        if def.Disable then
            local ok, err = pcall(def.Disable, def)
            if not ok then
                self:PrintError(def.id .. ": " .. tostring(err))
            end
        end
        return
    end
    if not def.Apply then
        return
    end
    local ok, err = pcall(def.Apply, def)
    if not ok then
        self:PrintError(def.id .. ": " .. tostring(err))
    end
end

function QbUI:RunOutOfCombat(func)
    if InCombatLockdown() then
        self.deferred[#self.deferred + 1] = func
    else
        func()
    end
end

function QbUI:FlushDeferred()
    local queue = self.deferred
    self.deferred = {}
    for index = 1, #queue do
        local ok, err = pcall(queue[index])
        if not ok then
            self:PrintError(tostring(err))
        end
    end
end

function QbUI:BuildOptions()
    local root = {
        type = "group",
        name = "QbUI",
        childGroups = "tree",
        args = {
            about = {
                type = "description",
                name = L["Fixed preset is applied automatically."],
                order = 0,
            },
        },
    }
    for index, def in ipairs(self.modules) do
        if def.GetOptions then
            local options = def:GetOptions()
            options.order = options.order or (index + 1)
            root.args[def.id] = options
        end
    end
    self.options = root
    AceConfig:RegisterOptionsTable(ADDON_NAME, root)
    AceConfigDialog:AddToBlizOptions(ADDON_NAME, "QbUI")
end

function QbUI:ResetAll()
    for _, def in ipairs(self.modules) do
        if def.settings then
            for key in pairs(def.settings) do
                def.settings[key] = nil
            end
            CopyDefaults(def.settings, def.defaults or {})
        end
    end
    self:ApplyAll()
    self:Print(L["Settings reset"])
end

function QbUI:OnChatCommand(input)
    input = strtrim((input or ""):lower())
    if input == "reset" then
        self:ResetAll()
    else
        AceConfigDialog:Open(ADDON_NAME)
    end
end

function QbUI:PrintError(message)
    self:Print("|cffff5555" .. tostring(message) .. "|r")
end

function QbUI:BindOption(def, key)
    local function get()
        return def.settings[key]
    end
    local function set(_, value)
        def.settings[key] = value
        self:ApplyModule(def)
    end
    return get, set
end

function QbUI:Option(def, key, option)
    option.get, option.set = self:BindOption(def, key)
    return option
end

function ns.Bind(def, key)
    return def.core:BindOption(def, key)
end

function ns.Option(def, key, option)
    return def.core:Option(def, key, option)
end
