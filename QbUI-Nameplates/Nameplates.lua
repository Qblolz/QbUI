local ADDON_NAME, ns = ...

local core = LibStub("AceAddon-3.0"):GetAddon("QbUI")

local L = setmetatable({
    ["Nameplates"] = "Неймплейты",
    ["Enable module"] = "Включить модуль",
    ["Nameplate scale"] = "Масштаб неймплейтов",
}, { __index = function(_, key) return key end })
ns.L = L

local defaults = {
    enabled = true,
    scale = 0.83,
}

local Nameplates = core:RegisterModule({
    id = ADDON_NAME,
    name = L["Nameplates"],
    defaults = defaults,
})

local MAX_PLATES = 200
local SCAN_RATE = 0.05

local Plates = {}
local PlateChildren = {}

local scanner = CreateFrame("Frame")
scanner:Hide()


local function ResetPoint(Plate, Region, Point, RelFrame, ...)
    if RelFrame == Plate then
        Region:SetPoint(Point, Plates[Plate], ...)
    end
end

local function ReparentChildren(Plate, Visual, List, ...)
    for Index = 1, select("#", ...) do
        local Child = select(Index, ...)
        if Child and Child ~= Visual and Child:GetParent() == Plate then
            local LevelOffset = Child:GetFrameLevel() - Plate:GetFrameLevel()
            Child:SetParent(Visual)
            Child:SetFrameLevel(Visual:GetFrameLevel() + LevelOffset)
            List[#List + 1] = Child
        end
    end
end

local function ReparentRegions(Plate, Visual, List, ...)
    for Index = 1, select("#", ...) do
        local Region = select(Index, ...)
        if Region then
            Region:SetParent(Visual)
            List[#List + 1] = Region
        end
    end
end

local function SetupVisual(Plate)
    local Visual = Plates[Plate]
    local Children = PlateChildren[Plate]
    if not Visual or not Children or Children.done then
        return
    end

    pcall(function()
        ReparentChildren(Plate, Visual, Children, Plate:GetChildren())
        ReparentRegions(Plate, Visual, Children, Plate:GetRegions())
    end)

    if #Children > 0 then
        Children.done = true
    end
end

local function ApplyScale(Plate)
    local Visual = Plates[Plate]
    if Visual then
        Visual:SetScale(Nameplates.settings.scale or 1)
    end
end

local function PlateOnShow(self)
    local Visual = Plates[self]
    if not Visual then
        return
    end

    SetupVisual(self)

    if not Visual.hasSize then
        local Width, Height = self:GetSize()
        if Width and Width > 0 and Height and Height > 0 then
            Visual:SetSize(Width, Height)
            Visual.hasSize = true
        end
    end

    Visual:Show()
    ApplyScale(self)

    local Children = PlateChildren[self]
    if Children then
        for Index = 1, #Children do
            local Region = Children[Index]
            for Point = 1, Region:GetNumPoints() do
                ResetPoint(self, Region, Region:GetPoint(Point))
            end
        end
    end
end

local function PlateOnHide(self)
    local Visual = Plates[self]
    if Visual then
        Visual:Hide()
    end
end

local function PlateAdd(Plate)
    local Visual = CreateFrame("Frame", nil, Plate)
    Plates[Plate] = Visual

    Visual:Hide()
    Visual:SetPoint("CENTER", Plate, "CENTER", 0, 0)
    Visual:SetSize(Plate:GetSize())
    if Visual:GetWidth() > 0 then
        Visual.hasSize = true
    end

    local Children = {}
    PlateChildren[Plate] = Children

    SetupVisual(Plate)
    ApplyScale(Plate)

    if Visual.EnableDrawLayer then
        Visual:EnableDrawLayer("HIGHLIGHT")
    end

    Plate:HookScript("OnShow", PlateOnShow)
    Plate:HookScript("OnHide", PlateOnHide)
    if Plate:IsVisible() then
        PlateOnShow(Plate)
    end
end

local function PlatesScan()
    for Index = 1, MAX_PLATES do
        local Plate = _G["NamePlate"..Index]
        if Plate then
            if not Plates[Plate] then
                PlateAdd(Plate)
            else
                local Children = PlateChildren[Plate]
                if Children and not Children.done and Plate:IsVisible() then
                    SetupVisual(Plate)
                end
            end
        end
    end
end

local nextScan = 0
scanner:SetScript("OnUpdate", function(_, elapsed)
    nextScan = nextScan - elapsed
    if nextScan > 0 then
        return
    end
    nextScan = SCAN_RATE

    PlatesScan()
    for Plate in pairs(Plates) do
        ApplyScale(Plate)
    end
end)


function Nameplates:Apply()
    scanner:Show()
    for Plate in pairs(Plates) do
        ApplyScale(Plate)
    end
end

function Nameplates:Disable()
    scanner:Hide()
    for Plate in pairs(Plates) do
        local Visual = Plates[Plate]
        if Visual then
            Visual:SetScale(1)
        end
    end
end

function Nameplates:GetOptions()
    return {
        type = "group",
        name = self.name,
        args = {
            enabled = core:Option(self, "enabled", {
                type = "toggle",
                name = L["Enable module"],
                order = 1,
                width = "full",
            }),
            scale = core:Option(self, "scale", {
                type = "range",
                name = L["Nameplate scale"],
                order = 2,
                min = 0.3,
                max = 1.5,
                step = 0.01,
            }),
        },
    }
end
