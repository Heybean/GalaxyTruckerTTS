require("tileAdjacency")

playerBags_GUID = {
    Red = {astro='5f1261',battery='4a76a5'},
    Blue = {astro='bd9ab9',battery='4a76a5'},
    Orange = {astro='bad721',battery='debaff'},
    Yellow = {astro='03be93',battery='ee9e49'},
    Green = {astro='6865d9',battery='ee9e49'},
}

function onload()
    self.createButton({
        click_function = "placeTokensClick",
        function_owner = self,
        label = "Place Tokens",
        width = 1300,
        height = 400,
        font_size = 200,
        position = {0, 0.6, 0},
        rotation = {0, 180, 0}
    })
end

function placeTokensClick(owner, player)
    local zone = getObjectFromGUID(Global.getVar("updateZonePlayerMap")[player])

    if not zone then return end

    local astroBag = getObjectFromGUID(playerBags_GUID[player].astro)
    local batteryBag = getObjectFromGUID(playerBags_GUID[player].battery)

    for obj in iterAllShipObjects(player, zone.getGUID(), false) do
        if not obj.hasTag("Tile") then
            goto skip
        end

        if obj.hasTag("Cabin") or obj.hasTag("Stasis") then

            if obj.hasTag("Cabin") then
                local lifeSupports = getConnectedMatchingTiles(obj, "Life Support")
                -- make sure not connected to life support systems
                if not obj.hasTag("Start Tile") and #lifeSupports > 0 then
                    goto skip
                end
            end

            local sp = obj.getSnapPoints()
            for i=1, #sp do
                if hasTag("Human", sp[i].tags) then
                    astroBag.takeObject({
                        position = obj.positionToWorld({sp[i].position.x, 1, sp[i].position.z}),
                        rotation = {0, obj.hasTag("Stasis") and (obj.getRotation().y + sp[i].rotation.y) or math.random() * 360, 0}
                    })
                end
            end
        else
            -- something else, probably batteries
            local sp = obj.getSnapPoints()
            for i=1, #sp do
                if hasTag("Battery Token", sp[i].tags) then
                    batteryBag.takeObject({
                        position = obj.positionToWorld({sp[i].position.x, 1, sp[i].position.z}),
                        rotation = {0, obj.getRotation().y + sp[i].rotation.y, 0}
                    })
                end
            end
        end

        ::skip::
    end
end

function hasTag(tagName, tbl)
    for _, tag in pairs(tbl) do
        if tagName == tag then
            return true
        end
    end

    return false
end