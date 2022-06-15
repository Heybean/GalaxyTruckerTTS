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

-- checks if value1 is close to value2, in degrees. Theta is the offset
function nearAngle(value1, value2, theta)
    local diff = (value1 - value2 + 180 + 360) % 360 - 180
    return math.abs(diff) <= theta
end

function quickCheckTag(tbl, name)
    if not tbl then
         return false
    end
    for _, v in pairs(tbl) do
         if v == name then
              return true
         end
    end

    return false
end