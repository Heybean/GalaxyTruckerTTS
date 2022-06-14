function wait(time)
    local start = os.time()
    repeat
        coroutine.yield(0)
    until os.time() > start + time
end

function shuffle(tbl)
     for i = #tbl, 2, -1 do
          local j = math.random(i)
          tbl[i], tbl[j] = tbl[j], tbl[i]
     end
     return tbl
end

function getSeatedPlayersWithHands()
     local results = {}
     local players = getSeatedPlayers()

     for i=1, #players do
          if Player[players[i]].getHandCount() > 0 then
               results[#results + 1] = players[i]
          end
     end
     return results
end

function checkInRegion(pos, regionBounds)
    local rect = {
         ['left'] = regionBounds.center[1] - regionBounds.size[1] / 2,
         ['top'] = regionBounds.center[3] + regionBounds.size[3] / 2,
         ['right'] = regionBounds.center[1] + regionBounds.size[1] / 2,
         ['bottom'] = regionBounds.center[3] - regionBounds.size[3] / 2
    }

    if pos[1] < rect.left or pos[1] > rect.right or pos[3] > rect.top or pos[3] < rect.bottom then
         return false
    end

    return true
end

-- checks if value1 is close to value2, in degrees. Theta is the offset
function nearAngle(value1, value2, theta)
    local diff = (value1 - value2 + 180 + 360) % 360 - 180
    return math.abs(diff) <= theta
end