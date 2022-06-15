require("util")
require("tileAdjacency")

cyanManagerCard_GUID = "66a7c4"

-- From perspective of player red, 0 is considered pointing 'forward' and then goes CW
cannonsForward = {['2a0a03'] = 0,['88a3d9'] = 90,['a48ef9'] = 270,['572829'] = 270,['f8c137'] = 0,['a4ebf8'] = 90,['5b2674'] = 90,['6c53a9'] = 270,['ce4aaa'] = 180,['2180f1'] = 270,['8cd959'] = 180,
     ['f52c16'] = 180,['033d4c'] = 270,['9ed669'] = 180,['3e40b0'] = 0,['9693c8'] = 180,['d26133'] = 90,['e10e12'] = 180,['8ecec8'] = 90,['08953a'] = 270,['d426bb'] = 270,['fece56'] = 0,['93cfb6'] = 180,
     ['4de31a'] = 180,['c0223e'] = 270,['2fda13'] = 180,['b89d43'] = 0,['8f66dc'] = 90,['f6f2f0'] = 90,['8c32d0'] = 180,['ed8a51'] = 270,['dde14f'] = 270,['c6986b'] = 270,['4dae77'] = 180
}

biCannonsForward = {['1c8f57'] = {0, 270},['166606'] = {0, 90}}

updateTimeStart = 0
queueUpdate = false

function onload()
    for i=1, 3 do
         self.createButton({
              click_function = "none",
              function_owner = self,
              label = "0",
              width = 0,
              height = 0,
              font_size = 150,
              font_color = "White",
              position = {.3, 0.1, -0.6 + (i-1) * 0.58}
         })
    end

    self.createButton({
     click_function = "lockTilesClick",
     function_owner = self,
     label = "Lock Tiles",
     width = 900,
     height = 300,
     font_size = 150,
     scale = {0.5,0.5,0.5},
     position = {-0.5, 0.1, 1.2},
    })
    self.createButton({
     click_function = "unlockTilesClick",
     function_owner = self,
     label = "Unlock Tiles",
     width = 900,
     height = 300,
     font_size = 150,
     scale = {0.5,0.5,0.5},
     position = {0.5, 0.1, 1.2},
    })
end

function onUpdate()
     if queueUpdate and os.clock() > updateTimeStart + 0.1 then
          queueUpdate = false
          startLuaCoroutine(self, "updateStatsCo")
     end
end

function updateLabels(crewN, cannonN, engineN)
     self.editButton({index = 0, label = crewN})
     self.editButton({index = 1, label = cannonN})
     self.editButton({index = 2, label = engineN})
end

function updateStats()
     queueUpdate = true
     updateTimeStart = os.clock()
end

function updateStatsCo()
     local zone = getObjectFromGUID(zoneGuid)
     local ignoresADS = {}
     local crew = 0
     local plusCrew = 0
     local cannon = 0
     local plusCannon = 0
     local engine = 0
     local plusEngine = 0
     local connectedADS = 0
     local hasCyanAlien = false
     local hasBrownAlien = false
     local hasPinkAlien = false
     local registered = Global.getVar("registered")

     local fb = getObjectFromGUID(registered.ships[player][1])

     if not fb then
          return
     end

     local objs = zone.getObjects()

     local hand = Player[player].getHandTransform(1)
     if not hand then
          return
     end

     local forward = hand.rotation[2]

     for obj in iterAllShipObjects(player, zoneGuid, true) do
          if obj.hasTag("Crewbots") then
               plusCrew = plusCrew + 4
          end

          if obj.hasTag("Crew") then
               if not hasBrownAlien and obj.getName() == "Brown Alien" then
                    hasBrownAlien = true
               elseif not hasPinkAlien and obj.getName() == "Pink Alien" then
                    hasPinkAlien = true
               elseif not hasCyanAlien and obj.getName() == "Cyan Alien" then
                    hasCyanAlien = true
               end
               crew = crew + 1
          end

          if obj.hasTag("Auto Defense System") and not ignoresADS[obj.getGUID()] then
               local matchingTiles = getConnectedMatchingTiles(obj, "Auto Defense System")
               if #matchingTiles > 0 then
                    connectedADS = connectedADS + 1
                    ignoresADS[obj.getGUID()] = true
                    for _, match in pairs(matchingTiles) do
                         if not ignoresADS[match.getGUID()] then
                              ignoresADS[match.getGUID()] = true
                              connectedADS = connectedADS + 1
                         end
                    end
               end
          end

          if obj.hasTag("Cannon1") then
               local offset = cannonsForward[obj.getGUID()]
               local str = 1
               if not nearAngle(obj.getRotation()[2], forward + offset, 20) then
                    str = 0.5
               end
               cannon = cannon + str
          elseif obj.hasTag("Cannon2") then
               local offset = cannonsForward[obj.getGUID()]
               local str = 2
               if not nearAngle(obj.getRotation()[2], forward + offset, 20) then
                    str = 1
               end
               plusCannon = plusCannon + str
          elseif obj.hasTag("BiCannon") then
               local str = 1.5
               if not nearAngle(obj.getRotation()[2], forward + biCannonsForward[obj.getGUID()][1], 20) and
                    not nearAngle(obj.getRotation()[2], forward + biCannonsForward[obj.getGUID()][2], 20) then
                    str = 1
               end
               plusCannon = plusCannon + str
          end

          if obj.hasTag("Engine1") then
               engine = engine + 1
          elseif obj.hasTag("Engine2") then
               plusEngine = plusEngine + 2
          end
     end

     cannon = cannon + math.floor(connectedADS / 2)

     local value = 2

     if hasCyanAlien and getObjectFromGUID(registered.cyanCards[player]) and registered.cyanCards[player] == cyanManagerCard_GUID then
          value = 3
     end

     if hasPinkAlien then
          if cannon >= 1 then
               cannon = cannon + value
          elseif plusCannon >= 1 then
               plusCannon = plusCannon + value
          end
     end

     if hasBrownAlien then
          if engine >= 1 then
               engine = engine + value
          elseif plusEngine >= 1 then
               plusEngine = plusEngine + value
          end
     end

     updateLabels(statLabelFormatter(crew, plusCrew), statLabelFormatter(cannon, plusCannon), statLabelFormatter(engine, plusEngine))
     return 1
end

function statLabelFormatter(baseValue, bonusValue)
     local bonus = baseValue + bonusValue
     local str = ""
     local half = "½"

     if baseValue == math.floor(baseValue) then
          str = tostring(baseValue)
     elseif baseValue >= 1 then
          str = tostring(math.floor(baseValue)) .. half
     else
          str = half
     end

     if bonusValue > 0 then
          local bonusStr = ""
          if bonus == math.floor(bonus) then
               bonusStr = tostring(bonus)
          else
               bonusStr = tostring(math.floor(bonus)) .. half
          end
          str = str .. "-" .. bonusStr
     end
     return str
end

function lockTilesClick(owner, player_color)
     for obj in iterAllShipObjects(player, zoneGuid, false) do
          if obj.hasTag("Tile") then
               obj.setLock(true)
          end
     end

     broadcastToColor("Ship tiles have been locked.", player_color, "White")
end

function unlockTilesClick(owner, player_color)
     for obj in iterAllShipObjects(player, zoneGuid, false) do
          if obj.hasTag("Tile") then
               obj.setLock(false)
          end
     end

     broadcastToColor("Ship tiles have been unlocked.", player_color, "White")
end