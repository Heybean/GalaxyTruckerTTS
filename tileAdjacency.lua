require("util")

-- Queries tiles around it and checks to see if the connections are proper
function getConnected(tile)
    local queryPos = {{-1,0.5,0},{0,0.5,1},{1,0.5,0},{0,0.5,-1}}
    local results = {}
    local connections = tile.getVar("connect")

    if not connections then return {} end

    local rotIndex = isOrthogonal(tile)

    if rotIndex < 0 then return {} end

    for i=1, #queryPos do
        local hits = Physics.cast({
            origin = tile.positionToWorld(queryPos[i]),
            direction = {0, -1, 0},
            max_distance = 2,
        })

        for _, hit in pairs(hits) do
            local otherTile = hit.hit_object
            local otherConnections = otherTile.getVar("connect")

            if hit.hit_object.hasTag("Tile") and otherConnections then
                local otherRotIndex = isOrthogonal(otherTile)

                if otherRotIndex < 0 then break end

                local targetSide = (i + rotIndex + 1) % 4 + 1
                local otherConnector = getConnectorType(otherConnections, otherRotIndex, targetSide)
                local isConnected = connections[i] ~= 0 and otherConnector ~= 0 and (connections[i] == otherConnector or connections[i] == 3 or otherConnector == 3)
                    
                results[#results+1] = {tile=otherTile, connected=isConnected}
                break
            end
        end
    end

    return results
end

-- Checks if the tile is orthogonally rotated. Returns how many 90 degree CW rotations (with 0 being default). Returns -1 if not orthogonal.
function isOrthogonal(tile)
    local angle = (tile.getRotation().y) % 90

    if nearAngle(angle, 45, 40) == false then
        return math.floor((tile.getRotation().y / 90) + 0.5) % 4
    end

    return -1
end

-- side: 1=left, 2=top, 3=right, 4=bot
function getConnectorType(connectors, rotInd, side)
    return connectors[(side - (rotInd + 1) + 4) % 4 + 1]
end