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

function iterAllShipObjects(player_color, zoneGUID, ignoreCertainItems)
     local boardSnapPointStartIndex = {
          ["IC"] = 0,
          ["IIA"] = 0,
          ["IIC"] = 0,
          ["IIIC"] = 0,
          ["IVC"] = 0,
     }
     local boardSnapPointMaxIndex = {
          ["IC"] = 0,
          ["IIA"] = 0,
          ["IIB"] = 0,
          ["IIC"] = 0,
          ["IIIA"] = 0,
          ["IIIB"] = 0,
          ["IIIC"] = 1,
          ["IVC"] = 1,
     }

     local ignores = {}
     local registered = Global.getVar("registered")
     local fb = getObjectFromGUID(registered.ships[player_color][1])

     if not fb then
          return
     end

     -- Register for ignores in the destroyed parts area
     -- By default, the two snap points before the last one should be the destroyed parts area
     local sp = fb.getSnapPoints()

     if not sp or #sp < 3 then
          return
     end

     local startIndex = boardSnapPointStartIndex[fb.getName()] or 1
     local maxIndex = boardSnapPointMaxIndex[fb.getName()] or 2

     for i=startIndex, maxIndex do
          local pos = fb.positionToWorld(sp[#sp-i].position)
          local hits = Physics.cast({
               origin = {pos[1], pos[2] - 1, pos[3]},
               direction = {0, 1, 0},
               max_distance = 4,
          })

          for _, hit in pairs(hits) do
               if hit.hit_object.hasTag("Tile") then
                    ignores[hit.hit_object.getGUID()] = true
               end
          end
     end

     local zone = getObjectFromGUID(zoneGUID)
     local objs = zone.getObjects()

     if ignoreCertainItems then
          for _, obj in pairs(objs) do
               if obj.hasTag("Stasis") then
                    local sz = obj.getBounds().size
                    local hits = Physics.cast({
                         origin = obj.getPosition(),
                         direction = {0, 1, 0},
                         max_distance = 4,
                         type = 3,
                         size = {sz[1], 0.1, sz[3]},
                    })
     
                    for _, hit in pairs(hits) do
                         if hit.hit_object.hasTag("Crew") then
                              ignores[hit.hit_object.getGUID()] = true
                         end
                    end
               elseif obj.hasTag("Cancel") then
                    local pos = obj.getPosition()
                    local hits = Physics.cast({
                         origin = {pos[1], pos[2] + 0.5, pos[3]},
                         direction = {0,-1,0},
                         max_distance = 1
                    })
     
                    for _, hit in pairs(hits) do
                         if hit.hit_object.hasTag("Tile") then
                              ignores[hit.hit_object.getGUID()] = true
                         end
                    end
               end
          end
     end

     local i = 0

     return function ()
          while i < #objs do
               i = i + 1

               while i <= #objs and ignores[objs[i].getGUID()] do
                    i = i + 1
               end

               if i <= #objs then
                    return objs[i]
               end
          end

          return nil
     end
end

function add(vector1, vector2)
     return {vector1[1] + vector2[1], vector1[2] + vector2[2], vector1[3] + vector2[3]}
end