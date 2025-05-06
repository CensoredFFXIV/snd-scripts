local itemsWanted = {
    ["Vacuum Suit Identification Key"] = 200,
    ["Cosmosuit Coffer"] = 50,
    ["Micro Rover"] = 25,
    ["Ballroom Etiquette - Personal Per..."] = 25, --Ballroom Etiquette - Personal Perfection
    ["Loparasol"] = 5,
    ["The Faces We Wear - Tinted Sungl..."] = 5,   --The Faces We Wear - Tinted Sunglasses
    ["Verdant Partition"] = 5,
    ["Stellar Opportunity"] = 0,
    ["Metallic Cobalt Green Dye"] = 0,
    ["Metallic Dark Blue Dye"] = 0,
    ["Metallic Pink Dye"] = 0,
    ["Metallic Ruby Red Dye"] = 0,
    ["Cracked Prismaticrystal"] = 0,
    ["Cracked Novacrystal"] = 0,
    ["Echoes in the Distance Orchestri..."] = 0, --Echoes in the Distance Orchestrion Roll
    ["Close in the Distance (Instrumen..."] = 0, --Close in the Distance (Instrumental) Orchestrion Roll
    ["Stargazers Orchestrion Roll"] = 0,
    ["Crafter's Delineation"] = 0,
    ["Drafting Table"] = 0,
    ["Cosmotable"] = 0,
    ["Cosmolamp"] = 0,
    ["Cordial "] = 0,
    ["Magicked Prism (Cosmic Explorat..."] = 0 --Magicked Prism (Cosmic Exploration)
}
local npc = { name = "Orbitingway", x = 17, y = -1, z = -16 }

local function calculateTotalWeight()
    local itemsInFirstWheel = {}
    local itemsInSecondWheel = {}
    local weightFirstWheel = 0
    local weightSecondWheel = 0

    for i = 1, 7 do
        if IsNodeVisible("WKSLottery", 1, 30, 38 - i) then
            local itemName = GetNodeText("WKSLottery", 29 + i, 6)

            if itemsInFirstWheel[itemName] then
                itemsInFirstWheel[itemName] = itemsInFirstWheel[itemName] + 1
            else
                itemsInFirstWheel[itemName] = 1
            end
        end

        if IsNodeVisible("WKSLottery", 1, 40, 48 - i) then
            local itemName = GetNodeText("WKSLottery", 19 + i, 6)

            if itemsInSecondWheel[itemName] then
                itemsInSecondWheel[itemName] = itemsInSecondWheel[itemName] + 1
            else
                itemsInSecondWheel[itemName] = 1
            end
        end
    end

    for itemName, count in pairs(itemsInFirstWheel) do
        local itemWeight = itemsWanted[itemName]

        if itemWeight and itemWeight > 0 then
            weightFirstWheel = weightFirstWheel + (itemWeight * count)
        end
    end

    for itemName, count in pairs(itemsInSecondWheel) do
        local itemWeight = itemsWanted[itemName]

        if itemWeight and itemWeight > 0 then
            weightSecondWheel = weightSecondWheel + (itemWeight * count)
        end
    end

    return weightFirstWheel, weightSecondWheel
end

if not IsAddonVisible("WKSLottery") then
    -- Thanks to pot0to for some of this script

    while GetDistanceToPoint(npc.x, npc.y, npc.z) > 3 do
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(npc.x, npc.y, npc.z)
        end

        yield("/wait 1")
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
    end

    yield("/target " .. npc.name)
    yield("/wait 0.5")
    yield("/interact")

    while not IsAddonVisible("SelectString") do
        yield("/wait 0.5")
    end

    yield("/wait 0.5")
    yield("/callback SelectString true 0")
    yield("/wait 1")
    yield("/callback SelectString true 0")
end

repeat
    local weightFirstWheel, weightSecondWheel = calculateTotalWeight()

    if weightFirstWheel > weightSecondWheel then
        yield("First wheel is better with total weight: " .. weightFirstWheel)
        -- yield("/callback WKSLottery true 1 0")
        -- yield("/wait 0.1")
        -- yield("/callback WKSLottery true 0 0")
    elseif weightSecondWheel > weightFirstWheel then
        yield("Second wheel is better with total weight: " .. weightSecondWheel)
        -- yield("/callback WKSLottery true 1 1")
        -- yield("/wait 0.1")
        -- yield("/callback WKSLottery true 0 0")
    else
        yield("Both wheels are equal in weight.")
        -- yield("/callback WKSLottery true 0 0")
        -- yield("/wait 0.1")
        -- yield("/callback WKSLottery true 1 0")
    end

    repeat
        yield("/wait 0.5")
    until not (IsNodeVisible("WKSLottery", 1, 30) or IsNodeVisible("WKSLottery", 1, 40))

    yield("/wait 1")
    yield("/callback WKSLottery true 0 0")
    yield("/wait 0.1")
    yield("/callback WKSLottery true 1 0")
    yield("/wait 0.1")
    yield("/callback WKSLottery true 2 0")
    yield("/wait 0.5")

    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    end

    yield("/wait 1")
until GetItemCount(45691) < 1000
