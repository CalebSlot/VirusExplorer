-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
-- physics stuffs
local physics = require("physics")
-- oggetti fermi
physics.start()
-- setGravity... uso io la forza 
physics.setGravity(0,0)

--not needed in scene based game beacuse is called once in main.lua
math.randomseed(os.time())

--json sheet for image packed graphics

local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}

--load the sheets
local objectSheet = graphics.newImageSheet("imgs/gameObjects.png",sheetOptions)

--global game variables, game states
local lives = 3
local score = 0
local died  = false

--array di asteroidi
local asteroidsTable = {}
 
local ship
local gameLoopTimer
local livesText
local scoreText

local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
local uiGroup   = display.newGroup()  -- Display group for UI objects like the score

--old style image loading, i can put a group, a path, and w h
local background = display.newImageRect( backGroup, "imgs/background.png", 800, 1400 )
--where 
background.x = display.contentCenterX
background.y = display.contentCenterY
--get the ship image from the objectsheet and place it  in the display
ship   = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
--place the ship on the display
ship.x = display.contentCenterX
--place a bit from the bottom , remember that 0,0 start from the upleft
ship.y = display.contentHeight - 100

--add the ship to the phisics engine
--the collider box is a sphere of 30 radius
--sensor true receive collision events
physics.addBody( ship, { radius=30, isSensor=true } )
ship.myName = "ship"

--add score and lives to the ui
livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )

--remove the status bar
display.setStatusBar( display.HiddenStatusBar )

--function to update all texts
local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

local function createAsteroids()

    --get 1 ateroid
 local newAsteroid = display.newImageRect(mainGroup,objectSheet,1,102,85)
    --add to the array
 table.insert(asteroidsTable,newAsteroid) 
    --add to the phyics system, it can bounce with another asteroid
 physics.addBody(newAsteroid,"dynamic",{radius=40,bounce=0.8})
 newAsteroid.myName = "asteroid"
    --spawn positions
 local whereFrom = math.random(3)

 if(whereFrom == 1) then
    --spawn from left side 0 -- 499
  newAsteroid.x = -60
  newAsteroid.y = math.random(500)
  
  newAsteroid:setLinearVelocity(math.random(40,120),math.random(20,60))
 elseif (whereFrom == 2) then
    --spawn from top side all width
    newAsteroid.x = math.random(display.contentWidth)
    newAsteroid.y = -60
    newAsteroid:setLinearVelocity(math.random(-40,40),math.random(40,120))
 elseif(whereFrom == 3) then
    --spawn from right side 
    newAsteroid.x = display.contentWidth + 60
    newAsteroid.y = math.random(500)
    newAsteroid:setLinearVelocity(math.random(-120,-40),math.random(20,60))
 end
 
 --apply a rotation
 newAsteroid:applyTorque(math.random(-6,6))


end


local function fireLaser()
  --load the laser from the sheet
  local newLaser = display.newImageRect(mainGroup,objectSheet,5,14,40)
  --add the laser as sensor, it can read events 
  physics.addBody(newLaser,"dynamic",{isSensor=true})
  
  newLaser.isBullet = true
  newLaser.myName = "laser"
  newLaser.x = ship.x
  newLaser.y = ship.y
  --put the laser backside
  newLaser:toBack()
  --move the laser forward to the end position
  transition.to(newLaser, {y=-40,time=500,
   onComplete = function() display.remove(newLaser) end
  })
end

--add tapping event for laer firing
ship:addEventListener("tap",fireLaser)

local function dragShip(event)
 local ship = event.target
 local phase = event.phase

 if("began" == phase) then
     display.currentStage:setFocus(ship)
     ship.touchOffsetX = event.x - ship.x
     ship.touchOffsetY = event.y - ship.y
 elseif ("moved" == phase) then
   ship.x = event.x - ship.touchOffsetX
   ship.y = event.y - ship.touchOffsetY
 elseif ("ended" == phase) then
   display.currentStage:setFocus(nil)
 end
 return true
end

ship:addEventListener("touch",dragShip)

local function gameLoop()
 createAsteroids()
 for i  = #asteroidsTable, 1, -1 do
    local thisAsteroid = asteroidsTable[i]
    if(
        thisAsteroid.x < -100 or thisAsteroid.x > display.contentWidth + 100 
        or thisAsteroid.y < -100 or thisAsteroid.y > display.contentHeight + 100
    )
    then
        display.remove(thisAsteroid)
        table.remove(asteroidsTable,i)
    end
 end
end

gameLoopTimer = timer.performWithDelay(500,gameLoop,0)


local function restoreShip()
 ship.isBodyActive = false 
 ship.x = display.contentCenterX
 ship.y = display.contentHeight - 100

 transition.to(ship, {alpha=1,time=4000,onComplete = function() 
  ship.isBodyActive = true
  died = false
 end
 })
end

local function onCollision(event)
 if(event.phase == "began") then
    local obj1 = event.object1
    local obj2 = event.object2

    if((obj1.myName == "laser" and obj2.myName == "asteroid") or 
       (obj1.myName == "asteroid" and obj2.myName == "laser"))
    then
        display.remove(obj1)
        display.remove(obj2)

        for i = #asteroidsTable, 1, -1 do
          if(asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2) then
            table.remove(asteroidsTable,i)
            break
         end
        end

     score = score + 100
     scoreText.text = "Score: " .. score

    elseif((obj1.myName == "ship" and obj2.myName == "asteroid") or (obj1.myName == "asteroid" and obj2.myName == "ship"))
    then
        if(died == false) then
            died = true
            lives = lives - 1
            livesText.text = "Lives " .. lives


            if(lives == 0) then
                display.remove(ship)
            else
                ship.alpha = 0
                timer.performWithDelay(1000,restoreShip)
            end

        end
    
    end
 end

end

Runtime:addEventListener("collision",onCollision)