
local composer         = require( "composer" )
local scene            = composer.newScene()
--if false jump to monster
local build_release    = false
--usefull for debug, invincible
local ship_body_active = false
local physics          = require("physics")
local font             = require("font")
local popup            = require("popup")

physics.start()
physics.setGravity(0,0)


local fieldRadius = 120
local fieldPower  = 0.4

local fontTimerOptions =
{
   active = false,
   tm     = nil,
   idx    = 0,
   speed  = 150,
   wait   = 300,
   fontChars = {},
   len,
}


--TODO: finish this data type.....
local sheetSyringes =
{
  frames = 
  {
    { --1) INFECTED
      x      = 95,
      y      = 4,
      width  = 28,
      height = 67
      
    },
    { --2) NOT INFECTED
      x      = 95,
      y      = 132,
      width  = 28,
      height = 67
      
    },
  },
}


local bossLifeUI =
{
  INFECTED,
  NOT_INFECTED,
}
local sheetCommons =
{
    frames =
    {
        {   -- 1) CV
            x = 0,
            y = 0,
            width = 173,
            height = 172
        },
		
        {   -- 2) laser
            x = 173,
            y = 0,
            width = 10,
            height = 38
		    },
		
        {   -- 3) missile
            x      = 183,
            y      = 0,
            width  = 131,
            height = 300
		},
		
        {   -- 4) flying missile
            x = 314,
            y = 0,
            width = 138,
            height = 517
		},
		
        {   -- 5) burner
            x      = 0,
            y      = 517,
            width  = 51,
            height = 161
		},

		{   -- 6) starship
		x      = 51,
		y      = 517,
		width  = 340,
		height = 258
	    },
    },
}

local sheetAnimationOptionsLaserExplosion =
{
    width     = 300,
    height    = 300,
    numFrames = 36,
    sheetContentWidth = 1800,
    sheetContentHeight = 1800
}

local sequences_laserExplosion =
 {
    -- consecutive frames sequence
    {
        name          = "normalExplosion",
        start         = 1,
        count         = 36,
        time          = 800,
        loopCount     = 1,
        loopDirection = "forward"
    }
}

local sheetAnimationOptionsShipExplosion =
{
    width     = 128,
    height    = 128,
    numFrames = 3,
    sheetContentWidth = 384,
    sheetContentHeight = 128
}
local sequences_shipExplosion =
 {
    -- consecutive frames sequence
    {
        name          = "normalExplosion",
        start         = 1,
        count         = 3,
        time          = 500,
        loopCount     = 1,
        loopDirection = "forward"
    }
}
local sequences_shield =
{
	{
		name          = "normalShield",
		start         = 1,
		count         = 5,
		time          = 800,
		loopCount     = 0,
		loopDirection = "forward"
	}
}

local sheetAnimationOptionsShield =
{
    width              = 280,
    height             = 280,
    numFrames          = 5,
    sheetContentWidth  = 1400,
    sheetContentHeight = 280
}

local sheetAnimationOptionsMissileExplosion =
{
    width              = 200,
    height             = 125,
    numFrames          = 12,
    sheetContentWidth  = 600,
    sheetContentHeight = 538
}

local sequences_missileExplosion =
 {
    -- consecutive frames sequence
    {
        name          = "normalExplosion",
        start         = 1,
        count         = 12,
        time          = 1200,
        loopCount     = 1,
        loopDirection = "forward"
    }
}

local gameplayTime


local previousTime
local newTime
local deltaTime
local sheet_laserExplosion
local sheet_shipExplosion
local sheet_missileExplosion

local PATHS =
{
 path_laserExplosion    = "imgs/explosion/explosion_laser.png",
 path_missileExplosion  = "imgs/explosion/explosion_missile.png",
 path_background        = "imgs/background.png",
 path_sheet_commons     = "imgs/gameObjects.png",
 path_sheet_syringes    = "imgs/Syringe.png",
 path_shipExplosion     = "imgs/explosion/explosion_ship.png",
 path_shipAcceleration  = "imgs/flame_sheet.png",
 path_shield            = "imgs/shield_sheet.png",
 path_plasma            = "imgs/plasma_red.png",
 path_score             = "imgs/score_little.png",
 path_pickup            = "imgs/pickup_beam.png",
 path_explosion         = "audio/explosion.wav",
 path_fire              = "audio/fire.wav",
 path_keystroke         = "audio/typewriter-key-1.wav",
 path_track             = "audio/80s-Space-Game_Looping.wav",
 path_hourglass         = "imgs/clessidra.png",
 path_heart             = "imgs/heart.png",
 path_avatar            = "imgs/esplorando-il-corpo-umano.png",
 path_boss              = "imgs/CV_boss.png",
 path_popup             = "imgs/popup_menu_backgrounded.png",

}
--load the sheets  
local objectSheet            = graphics.newImageSheet(PATHS.path_sheet_commons,sheetCommons)
local syringeSheet           = graphics.newImageSheet(PATHS.path_sheet_syringes,sheetSyringes)

--global game variables, game states
local GAME_VARS =
{
 lives = 1,
 score = 0,
 died      = false,
 survived  = false
}
--array di virus
local virusesTable   = {}
local boss
local STATIC_IMGS =
{
   avatar,
   scorePrefix,
   heart,
	 hourglass,
}
--array di laser
local lasersTable    = {}

local SCALE_MISSILE

local gameEnded

local ship
local leftMissileShip
local rigthMissileShip
local leftMissileFlying
local rigthMissileiFlyng
local leftMissileDestroyed
local firingLeftMissile
local rigthMissileDestroyed
local firingRigthMissile
local gameLoopTimer
local livesText
local scoreText
local antivirusText
--local scorePrefix
local timeText
local backGroup
local mainGroup
local uiGroup
--local heart
--local hourglass
local shield


local GAME_SOUNDS =
{
  enemyDeadSound,
  playerDeadSound,
  fireLaserSound,
  musicTrack,
}
--fire variable
local lastFireSide
local shieldVisible = true
local bossInfo =
{
  BOSS_WIDTH  = 140,
  BOSS_HEIGTH = 140,
  bossLife    = 10,
  bossDamage  = 0
}
local FIRE_OPTIONS =
 {
  FIRE_RIGTH,
  FIRE_LEFT,
  FIRE_ALTERNATE,
  FIRE_CENTER,
  FIRE_BOTH,
  OPT_FIRE_BOTH_OFFSET,
  LASER_X_SPEED,
  LASER_Y_SPEED
}


local SECONDS_TRANSITION_BOSS = 6
local SECONDS_TO_GAMEOVER     = 19
local thresholdSpawning       = SECONDS_TO_GAMEOVER - SECONDS_TRANSITION_BOSS

local g_fireMode
local halfShipBoundsX
local halfShipBoundsY
local SCALE_TIME
local laser_event          = "tap"
local missile_event        = "tap"
local move_event           = "touch"
local ship_name_1          = "ship"
local missile_name_left_1  = "missile_left"
local missile_name_rigth_1 = "missile_rigth"
local message_live_rip     = "R.I.P"
local message_live_1       = "Lives: "
local message_score_1      = "Score: "
local message_time_1       = "  "
local message_time_2       = " 0"
local menu_scene           = "menu"
local gameover_scene       = "gameover"
local game_scene           = "game"
local laser_name_1         = "laser1"
local laser_name_2         = "laser2"
local enemy_name_1         = "virus"
local enemy_boss_name_1    = "COVID_BOSS_1"
local enemy_laser_name_1   = "laser3"

local spawn_X_1            = -60
local spawn_Y_2            = -60
local spawn_X_3            = 60
local spawn_Y_RANGE_3      = 500
local spawn_Y_RANGE_1      = 500
local speed_X_RANGE_FROM_1 = 40
local speed_X_RANGE_TO_1   = 120
local speed_Y_RANGE_FROM_1 = 20
local speed_Y_RANGE_TO_1   = 60
local speed_X_RANGE_FROM_2 = -40
local speed_X_RANGE_TO_2   = 40
local speed_Y_RANGE_FROM_2 = 40
local speed_Y_RANGE_TO_2   = 120
local speed_X_RANGE_FROM_3 = -120
local speed_X_RANGE_TO_3   = -40
local speed_Y_RANGE_FROM_3 = 20
local speed_Y_RANGE_TO_3   = 60
local torque_x             = -6
local torque_y             = 6

local bg1
local bg2
local scroll
local scrool_speedUp
 
local doUpdatePlayTime        = true
local doUpdatePlayerMovements = true
local doUpdateFire            = true


local BOSS_FIRE_OPTIONS =
{
	BOSS_BULLETS_WAVE   = 10,
	BOSS_BULLETS_LINE   = 5,
	BOSS_BULLETS_SPHERE = 10,
	BOSS_FIRE_LINE      = 1,
	BOSS_FIRE_WAVE      = 2,
  BOSS_FIRE_SPHERE    = 3
}

local BOSS_FIRE_MODE      = BOSS_FIRE_OPTIONS.BOSS_FIRE_SPHERE

local fireDirection       = 1
local power               = 400
local SPAWN_RANDOM = 4

local missileRadius = 300
local MidX
local MidY

local function setDebugOptions()
 shieldVisible     = true
 gameplayTime      = thresholdSpawning
 SCALE_TIME        = 0.2
 ship.isBodyActive = ship_body_active
end

local function pausePlayerMovements()
  doUpdatePlayerMovements = false
end
local function playPlayerMovements()
  doUpdatePlayerMovements = true
end
local function pauseTime()
  doUpdatePlayTime = false
end

local function playTime()
 doUpdatePlayTime  = true
end

local function pauseFire()
 doUpdateFire      = false
end

local function playFire()
 doUpdateFire      = true
end

local function addScore(iScore)
  GAME_VARS.score = GAME_VARS.score + iScore
  scoreText.text = string.format("%07d",GAME_VARS.score)
 end

local function bgScroll (event)


    bg1.y = bg1.y + scroll + scrool_speedUp
    bg2.y = bg2.y + scroll + scrool_speedUp
 
    if bg1.y >= display.contentHeight * 1.5 then
        bg1.y = display.contentHeight * -.5
    end
 
    if bg2.y >= display.contentHeight * 1.5 then
        bg2.y = display.contentHeight * -.5
    end
end
 
 

-- place ship
local function placeShip()
  ship.x = display.contentCenterX
  ship.y = display.contentHeight - 100
end

local function placeShield()
  if(shieldVisible == true)
  	then
       shield.x = ship.x
       shield.y = ship.y
    end
end

local function loadAudio()
	GAME_SOUNDS.enemyDeadSound  = audio.loadSound(PATHS.path_explosion)
	GAME_SOUNDS.playerDeadSound = audio.loadSound(PATHS.path_explosion)
	GAME_SOUNDS.fireLaserSound  = audio.loadSound(PATHS.path_fire)
	GAME_SOUNDS.musicTrack      = audio.loadStream(PATHS.path_track)
  GAME_SOUNDS.keyStrokeSound  = audio.loadSound(PATHS.path_keystroke)
end
-- place missiles
local function placeMissiles()
	leftMissileFlying.x  = ship.x - 38
	rigthMissileFlying.x = ship.x + 38
	leftMissileFlying.y  = ship.y + 12
	rigthMissileFlying.y = ship.y + 12
	leftMissileShip.x    = ship.x - 38
	rigthMissileShip.x   = ship.x + 38
	leftMissileShip.y    = ship.y + 12
	rigthMissileShip.y   = ship.y + 12
end

local function createLittleVirus()
 --get an image from the sheet and resize it
 newVirus = display.newImageRect(mainGroup,objectSheet,1,51,51)
 --add to the array 
 table.insert(virusesTable,newVirus) 
 physics.addBody(newVirus,"dynamic",{radius=25.5,bounce=0.8})
 newVirus.myName = enemy_name_1

  newVirus.x = spawn_X_1
  newVirus.y = math.random(spawn_Y_RANGE_1)
  newVirus:setLinearVelocity(math.random(speed_X_RANGE_FROM_1,speed_X_RANGE_TO_1),math.random(speed_Y_RANGE_FROM_1,speed_Y_RANGE_TO_1))
   --apply a rotation
  newVirus:applyTorque(math.random(torque_x,torque_y))
end

local function createMediumVirus()
		 	 --get an image from the sheet and resize it
  newVirus = display.newImageRect(mainGroup,objectSheet,1,60,60)
 --add to the array 
 table.insert(virusesTable,newVirus) 
 physics.addBody(newVirus,"dynamic",{radius=30,bounce=0.8})
 newVirus.myName = enemy_name_1
    --spawn from top side all width
    newVirus.x = math.random(display.contentWidth)
    newVirus.y = spawn_Y_2
    newVirus:setLinearVelocity(math.random(speed_X_RANGE_FROM_2,speed_X_RANGE_TO_2),math.random(speed_Y_RANGE_FROM_2,speed_Y_RANGE_TO_2))
      --apply a rotation
  newVirus:applyTorque(math.random(torque_x,torque_y))
end

local function createBigVirus()
 	 --get an image from the sheet and resize it
  newVirus = display.newImageRect(mainGroup,objectSheet,1,70,70)
 --add to the array 
 table.insert(virusesTable,newVirus) 
 physics.addBody(newVirus,"dynamic",{radius=35,bounce=0.8})
 newVirus.myName = enemy_name_1
    --spawn from right side 
    newVirus.x = display.contentWidth + 60
    newVirus.y = math.random(spawn_Y_RANGE_3)
    newVirus:setLinearVelocity(math.random(speed_X_RANGE_FROM_3,speed_X_RANGE_TO_3),math.random(speed_Y_RANGE_FROM_3,speed_Y_RANGE_TO_3))
    newVirus:applyTorque(math.random(torque_x,torque_y))
end

local function createBossWithTransition(where,seconds,actionBefore,actionAfter)
 boss = display.newImageRect(mainGroup,PATHS.path_boss,bossInfo.BOSS_WIDTH,bossInfo.BOSS_HEIGTH)
 boss:rotate( -60 )
 physics.addBody(boss,"static",{radius=bossInfo.BOSS_WIDTH/2,bounce = 0.0})
 boss.myName = enemy_boss_name_1
 
 boss.x = display.contentCenterX
 boss.y = -bossInfo.BOSS_HEIGTH

 actionBefore()
 boss.alpha = 0
 transition.to( boss, {y=where,alpha = 1, time = seconds,onComplete=actionAfter})

end

local function hideViruses(seconds)

  for i =  #virusesTable,1,-1 do
  	  local thisVirus = virusesTable[i]
  	  transition.to(thisVirus,{alpha=0,time=seconds})
  end

end
local function moveVirusesCenterTop(seconds)

  for i =  #virusesTable,1,-1 do
  	  local thisVirus = virusesTable[i]
      thisVirus.isBodyActive = false
  	  transition.to(thisVirus,{x=display.contentCenterX,y=-40,time=seconds})
  end

end

local function movePlayerCenterBottom(seconds)

  transition.to(ship,{x=display.contentCenterX,y=display.contentHeight - ship.height/2 - 20,time=seconds})
  transition.to(leftMissileShip,{x=display.contentCenterX - 38,y=display.contentHeight - ship.height/2 - 20 + 12,time=seconds})
  transition.to(leftMissileFlying,{x=display.contentCenterX - 38,y=display.contentHeight - ship.height/2 - 20 + 12,time=seconds})
  transition.to(rigthMissileShip,{x=display.contentCenterX + 38,y=display.contentHeight - ship.height/2 - 20 + 12,time=seconds})
  transition.to(rigthMissileFlying,{x=display.contentCenterX + 38,y=display.contentHeight - ship.height/2 - 20 + 12,time=seconds})

end

--spawn asteroids
local function createVirus(randomize)

  local  newVirus 
  local  whereFrom = randomize
 --spawn positions
 if(randomize == SPAWN_RANDOM)
 	then
      whereFrom = math.random(3) 
    else
      whereFrom = randomize
    end

 if(whereFrom == 1) then
 	createLittleVirus()
 elseif (whereFrom == 2) then
    createMediumVirus()
 elseif(whereFrom == 3) then
 	createBigVirus()
 end
 
end

local function createViruses()
	createVirus(SPAWN_RANDOM)
 for i = 0, math.floor(gameplayTime / 3), 1 do
	createVirus(SPAWN_RANDOM)
 end 
end
--remove viruses offscreen
local function removeViruses()
	for i  = #virusesTable, 1, -1 do
		local thisVirus = virusesTable[i]
		if(
			thisVirus.x < -100 or thisVirus.x > display.contentWidth + 100 
			or thisVirus.y < -100 or thisVirus.y > display.contentHeight + 100
		)
		then
			--remove the object from the display
			display.remove(thisVirus)
			--remove from array
			table.remove(virusesTable,i)
		end
	 end
end
local removed = 0;
local function removeLasers()
	for i  = #lasersTable, 1, -1 do
		local thisLaser = lasersTable[i]
		if(
			thisLaser.x < -100 or thisLaser.x > display.contentWidth + 100 
			or thisLaser.y < -100 or thisLaser.y > display.contentHeight + 100
		)
		then
			display.remove(thisLaser)
			table.remove(lasersTable,i)
			removed = removed + 1;
			if(removed > 1000)
			 then
				removed = 0
			end
			--scoreText.text = "removed " .. removed
		end
	 end
end
--spawn laser
local function fireLaser()

    if(doUpdateFire == false) 
    	then
    	 return
    	end


	--load the laser
    -- Play fire sound!
    audio.play( GAME_SOUNDS.fireLaserSound )

	local newLaser = display.newImageRect(mainGroup,objectSheet,2,14,40)
	table.insert(lasersTable,newLaser) 
	--add the laser as sensor, it can read events 
	physics.addBody(newLaser,"dynamic",{isSensor=true})
	
	newLaser.isBullet = true
	newLaser.myName   = laser_name_1

	local newlaser2

	if(g_fireMode == FIRE_OPTIONS.FIRE_ALTERNATE)
	 then
		if(lastFireSide == FIRE_OPTIONS.FIRE_LEFT)
		 then
		   lastFireSide = FIRE_OPTIONS.FIRE_RIGTH
		  else
		  lastFireSide = FIRE_OPTIONS.FIRE_LEFT
		end
	    newLaser.x = ship.x + FIRE_OPTIONS.OPT_FIRE_BOTH_OFFSET * lastFireSide
	    newLaser.y = ship.y
	elseif (g_fireMode == FIRE_OPTIONS.FIRE_CENTER)
	 then
		newLaser.x = ship.x
		newLaser.y = ship.y
	elseif (g_fireMode == FIRE_OPTIONS.FIRE_BOTH)
		then
				
		newLaser2 = display.newImageRect(mainGroup,objectSheet,2,14,40)
		table.insert(lasersTable,newLaser2) 
		--add the laser as sensor, it can read events 
		physics.addBody(newLaser2,"dynamic",{isSensor=true})	
	    newLaser2.isBullet = true
		newLaser2.myName   = laser_name_2
		
		   newLaser.x  = ship.x - FIRE_OPTIONS.OPT_FIRE_BOTH_OFFSET
		   newLaser.y  = ship.y
		   newLaser2.x = ship.x + FIRE_OPTIONS.OPT_FIRE_BOTH_OFFSET
		   newLaser2.y = ship.y
		
	     else
		
		   newLaser.x = ship.x
		   newLaser.y = ship.y
	end
	--put the laser backside
	newLaser:toBack()
	--move the laser forward to the end position
	--transition.to(newLaser, {y=-40,time=500,
	-- onComplete = function() display.remove(newLaser) end
	--})
	newLaser:setLinearVelocity(FIRE_OPTIONS.LASER_X_SPEED,FIRE_OPTIONS.LASER_Y_SPEED);

	if(g_fireMode == FIRE_OPTIONS.FIRE_BOTH) 
	 then
		    --put the laser backside
		    newLaser2:toBack()
			--move the laser forward to the end position
	       -- transition.to(newLaser2, {y=-40,time=500,
	       --   onComplete = function() display.remove(newLaser2) end
			--})
			newLaser2:setLinearVelocity(FIRE_OPTIONS.LASER_X_SPEED,FIRE_OPTIONS.LASER_Y_SPEED);
	 end
  end

  local function fireLeftMissile()
    
      if(doUpdateFire == false) 
    	then
    	 return
    	end

	if(firingLeftMissile == true) then
	 return
	end

	firingLeftMissile = true
    leftMissileShip.alpha = 0
    leftMissileFlying.alpha = 1
    transition.to(leftMissileFlying, {y=-40,time=500,
		onComplete = function()
			 display.remove(leftMissileFlying)
			 leftMissileDestroyed = true
			 firingLeftMissile    = false
		end
	})

	leftMissileFlying.isBodyActive = true
  end

  local function fireRigthMissile()

  if(doUpdateFire == false) 
    	then
    	 return
    	end

	if(firingRigthMissile == true) then
		return
	   end

	   firingRigthMissile = true
rigthMissileShip.alpha  = 0
rigthMissileFlying.alpha = 1
	transition.to(
	rigthMissileFlying,
	 {y=-40,time=500,
		onComplete = function()  
			display.remove(rigthMissileFlying) 
			rigthMissileDestroyed = true
			firingRigthMissile = false
		  end
	})
	rigthMissileFlying.isBodyActive = true
  end

  local function createLeftMissile()
  	if(leftMissileShip == nil)
  		then
	     leftMissileShip           = display.newImageRect( mainGroup,objectSheet,3,131 *    SCALE_MISSILE,300 *    SCALE_MISSILE)
        end
	leftMissileFlying         = display.newImageRect( mainGroup,objectSheet,4,138 *    SCALE_MISSILE,517 *    SCALE_MISSILE)
	leftMissileShip.alpha     = 1
	leftMissileFlying.alpha   = 0
	leftMissileDestroyed      = false
	firingLeftMissile         = false
	physics.addBody(leftMissileFlying,"dynamic",{isSensor=true})
	leftMissileFlying.myName        = missile_name_left_1
	leftMissileFlying.isBullet      = true
	leftMissileFlying.isBodyActive  = false
	leftMissileShip:addEventListener(missile_event,fireLeftMissile)
	leftMissileShip:toBack( )
	leftMissileFlying:toBack( )
  end

  local function createRigthMissile()
  
  if(rigthMissileShip == nil)
   then
	rigthMissileShip   = display.newImageRect( mainGroup,objectSheet,3,131 *    SCALE_MISSILE,300 *    SCALE_MISSILE)
   end

    rigthMissileFlying = display.newImageRect( mainGroup,objectSheet,4,138 *    SCALE_MISSILE,517 *    SCALE_MISSILE)
	rigthMissileShip.alpha   = 1
	rigthMissileFlying.alpha = 0
	rigthMissileDestroyed = false
	firingRigthMissile = false
	physics.addBody(rigthMissileFlying,"dynamic",{isSensor=true})
	rigthMissileFlying.myName = missile_name_rigth_1
	rigthMissileFlying.isBullet = true
	rigthMissileFlying.isBodyActive = false
	rigthMissileShip:addEventListener(missile_event,fireRigthMissile)

	rigthMissileShip:toBack( )
	rigthMissileFlying:toBack()
  end


  --ship movement
  local function dragShip(event)

    if(doUpdatePlayerMovements == false)
    	then
    	 return
        end

	local ship = event.target
	local phase = event.phase
   
	if("began" == phase) then

		
	 	   display.currentStage:setFocus(ship)
		   ship.touchOffsetX = event.x - ship.x
	   	   ship.touchOffsetY = event.y - ship.y
		  
	elseif ("moved" == phase) then

		local shipx = event.x - ship.touchOffsetX
		local shipy = event.y - ship.touchOffsetY
         if(
			shipx < display.contentWidth - halfShipBoundsX*2  and shipx > halfShipBoundsX*2 and
		    shipy < display.contentHeight - halfShipBoundsY and shipy > halfShipBoundsY
		  )
		  then

	  ship.x = shipx
	  ship.y = shipy

	  placeMissiles()
	  placeShield()

		  end
	elseif ("ended" == phase) then

	  display.currentStage:setFocus(nil)

	end
	return true
   end

      --recreate a new ship and weapons
   local function effectRestoreShipAndWeapons()

	ship.isBodyActive = false 
    
	placeShip()
	
	if(leftMissileDestroyed==true) then
      createLeftMissile()
	end
	if(rigthMissileDestroyed==true) then
	  createRigthMissile()
	end
	
	
	placeMissiles()

	transition.to(ship, {alpha=1,time=3000,onComplete = function() 
	 leftMissileShip.alpha = 1
	 rigthMissileShip.alpha = 1
	 ship.isBodyActive = true
	 GAME_VARS.died = false
	end
	})
   end

local function effectDeadShipAndWeapons()
	
	 ship.alpha         = 0
	 
	 if(leftMissileDestroyed == false and firingLeftMissile == false) then
	   leftMissileShip.alpha  = 0
	 end
	 if(rigthMissileDestroyed == false and firingRigthMissile == false) then
	 rigthMissileShip.alpha = 0
	 end

        
           local shipExplosion = display.newSprite( mainGroup,sheet_shipExplosion, sequences_shipExplosion)
           shipExplosion:setSequence( "normalExplosion")

           shipExplosion.x      = ship.x
           shipExplosion.y      = ship.y
         
           shipExplosion:play()
         
          local function mySpriteListener( event )
             if ( event.phase == "ended" ) then
              shipExplosion:removeSelf()
              shipExplosion = nil
            end
         end

         shipExplosion:addEventListener( "sprite", mySpriteListener )         		  		   
           -- Play explosion sound!
		 audio.play( GAME_SOUNDS.enemyDeadSound )

end

local function explodeLaserAndRemove(obj1,obj2)


           local midX           = (obj1.x + obj2.x)/2
           local midY           = (obj2.y + obj2.y)/2

if obj1.myName == enemy_name_1 or obj1.myName == laser_name_1 or obj1.myName == enemy_laser_name_1
then
           display.remove(obj1)  
end
if obj2.myName == enemy_name_1 or obj2.myName == laser_name_1 or obj2.myName == enemy_laser_name_1
then
           display.remove(obj2)  
end

           local laserExplosion = display.newSprite( mainGroup,sheet_laserExplosion, sequences_laserExplosion)
           laserExplosion:setSequence( "normalExplosion")

           laserExplosion.x     = midX
           laserExplosion.y     = midY
         
           laserExplosion:play()
         
          local function mySpriteListener( event )
             if ( event.phase == "ended" ) then
              laserExplosion:removeSelf()
              laserExplosion = nil
            end
         end

         laserExplosion:addEventListener( "sprite", mySpriteListener )         		  		   
           -- Play explosion sound!
		 audio.play( GAME_SOUNDS.enemyDeadSound )
end
local shieldPower = 4

local function explodeShieldAndRemove(obj1,obj2)

   local midX 
   local midY

if(obj1.myName == enemy_name_1)
	then
	       midX = obj1.x
	       midY = obj1.y 
           display.remove(obj1) 
    end
if(obj2.myName == enemy_name_1)
	then
	       midX = obj2.x
	       midY = obj2.y 
           display.remove(obj2) 
    end

              shieldPower = shieldPower - 1

              if(shieldPower <= 0)
              	then
                  if(obj1.myName == "shield")
	                then
                      display.remove(obj1) 
                    end
                  if(obj2.myName == "shield")
	                then
                      display.remove(obj2) 
                    end
                end

           local shieldExplosion = display.newSprite( mainGroup,sheet_laserExplosion, sequences_laserExplosion)
           shieldExplosion:setSequence( "normalExplosion")

           shieldExplosion.x     = midX
           shieldExplosion.y     = midY
         
           shieldExplosion:play()
         
          local function mySpriteListener( event )
             if ( event.phase == "ended" ) then
              shieldExplosion:removeSelf()
              shieldExplosion = nil
            end
         end

         shieldExplosion:addEventListener( "sprite", mySpriteListener )         		  		   
           -- Play explosion sound!
		 audio.play( GAME_SOUNDS.enemyDeadSound )
end

local function explodeAndRemove(obj)

           display.remove(obj)  

           local laserExplosion = display.newSprite( mainGroup,sheet_laserExplosion, sequences_laserExplosion)
           laserExplosion:setSequence( "normalExplosion")

           laserExplosion.x     = obj.x
           laserExplosion.y     = obj.y
         
           laserExplosion:play()
         
          local function mySpriteListener( event )
             if ( event.phase == "ended" ) then
              laserExplosion:removeSelf()
              laserExplosion = nil
            end
         end

         laserExplosion:addEventListener( "sprite", mySpriteListener )         		  		   
           -- Play explosion sound!
		 audio.play( GAME_SOUNDS.enemyDeadSound )
end

local function explodeBlastAndRemoveEnemies(obj1,obj2)

           if(obj1.myName == enemy_name_1)
           	then
             display.remove(obj1)  
            end

             if(obj2.myName == enemy_name_1)
           	then
             display.remove(obj2)  
            end

           local blastExplosion = display.newSprite( mainGroup,sheet_laserExplosion, sequences_laserExplosion)
           blastExplosion:setSequence( "normalExplosion")
            
           if(obj1.myName == enemy_name_1)
           	 then
              laserExplosion.x     = obj1.x
              laserExplosion.y     = obj1.y
             end
           if(obj2.myName == enemy_name_1)
           	 then
              laserExplosion.x     = obj2.x
              laserExplosion.y     = obj2.y
             end

           blastExplosion:play()
      		  		   
           -- Play explosion sound!
		   audio.play( GAME_SOUNDS.enemyDeadSound )
end


local function explodeMissileAndRemove(obj1,obj2)

           local midX           = (obj1.x + obj2.x)/2
           local midY           = (obj2.y + obj2.y)/2
           MidX = midX
           MidY = midY

           display.remove(obj1)  
           display.remove(obj2)

           local missileExplosion = display.newSprite( mainGroup,sheet_missileExplosion, sequences_missileExplosion)
           missileExplosion:setSequence( "normalExplosion")

           missileExplosion.x     = midX
           missileExplosion.y     = midY
         
           missileExplosion:play()

          local function mySpriteListener( event )
             if ( event.phase == "ended" )
             then
              missileExplosion:removeSelf()
              missileExplosion = nil
            end
         end

         missileExplosion:addEventListener( "sprite", mySpriteListener )         		  		   
           -- Play explosion sound!
		 audio.play( GAME_SOUNDS.enemyDeadSound )
end
--make the transition back tyo the menu and call the hide callback removing all looping stuffs
local function endGame()
	--set a global variable
	composer.setVariable( "finalScore", GAME_VARS.score )
    composer.gotoScene( gameover_scene, { time=800, effect="crossFade" } )
end
   --manage  collisione betwenn objects
local function onCollision(event)
  
	if(event.phase == "began") then

	   local obj1 = event.object1
	   local obj2 = event.object2
   
	   if(((obj1.myName == laser_name_1 or obj1.myName == laser_name_2) and obj2.myName == enemy_name_1) or 
		  (obj1.myName == enemy_name_1 and (obj2.myName == laser_name_1 or obj1.myName == laser_name_2)))
	   then
           
       
           explodeLaserAndRemove(obj1,obj2)
		   
		   for i = #virusesTable, 1, -1 do

			 if(virusesTable[i] == obj1 or virusesTable[i] == obj2) then
			   table.remove(virusesTable,i)
			   addScore(100)
			   break
			end
		  end	  
			for i = #lasersTable,1,-1 do
			  if(lasersTable[i] == obj1 or lasersTable[i] == obj2) then
				table.remove(lasersTable,i)
				break
			   end
			end
      
elseif(((obj1.myName == missile_name_left_1 or obj1.myName == missile_name_rigth_1) and obj2.myName == enemy_name_1) or 
		  (obj1.myName == enemy_name_1 and (obj2.myName == missile_name_left_1 or obj2.myName == missile_name_rigth_1)))
	   then
           
           explodeMissileAndRemove(obj1,obj2)
		 
		   for i = #virusesTable, 1, -1 do
			 if(virusesTable[i] == obj1 or virusesTable[i] == obj2) 
			  then
			   table.remove(virusesTable,i)
			   addScore(100)
			  -- break
			  else
			   local distanceFromX = math.abs(MidX - virusesTable[i].x)
               local distanceFromY = math.abs(MidY - virusesTable[i].y)

               if(math.sqrt(distanceFromX^2+distanceFromY^2) < missileRadius)
               	 then
                   explodeAndRemove(virusesTable[i])
                   table.remove(virusesTable,i)
			       addScore(100)
                 end

		      end
		  end
	elseif((obj1.myName == "shield" and obj2.myName == enemy_name_1) or 
		  (obj1.myName == enemy_name_1 and obj2.myName == "shield"))
	   then
           explodeShieldAndRemove(obj1,obj2)
		   
		   for i = #virusesTable, 1, -1 do

			 if(virusesTable[i] == obj1 or virusesTable[i] == obj2) then
			   table.remove(virusesTable,i)
			   addScore(100)
			   break
			end
   end
		  elseif(((obj1.myName == laser_name_1 or obj1.myName == laser_name_2) and obj2.myName == enemy_boss_name_1) or 
		  (obj1.myName == enemy_boss_name_1 and (obj2.myName == laser_name_1 or obj1.myName == laser_name_2)))
      then
        if(GAME_VARS.survived == false and gameEnded == false) 
         then

        bossInfo.bossDamage = bossInfo.bossDamage+1
        explodeLaserAndRemove(obj1,obj2)
        
        addScore(10000)
        for i = #lasersTable,1,-1 do
			  if(lasersTable[i] == obj1 or lasersTable[i] == obj2) then
				table.remove(lasersTable,i)
				break
			   end
			end
      
       if(bossInfo.bossDamage >= bossInfo.bossLife)
                 then
                  GAME_VARS.survived  = true
                 end
      
      end
	   elseif((obj1.myName == ship_name_1 and obj2.myName == enemy_name_1) or (obj1.myName == enemy_name_1 and obj2.myName == ship_name_1))
	   then
		   if(GAME_VARS.died == false and gameEnded == false) then
			   GAME_VARS.died = true

			    -- Play explosion sound!
                audio.play( GAME_SOUNDS.playerDeadSound )

			   GAME_VARS.lives = GAME_VARS.lives - 1
			 --  livesText.text = message_live_1 .. lives
   
			   if(GAME_VARS.lives == 0) then
           effectDeadShipAndWeapons()
			   else
				   effectDeadShipAndWeapons()
				   timer.performWithDelay(1000,effectRestoreShipAndWeapons)
			   end
   
		   end
	   	   elseif((obj1.myName == ship_name_1 and obj2.myName == enemy_boss_name_1) or (obj1.myName == enemy_boss_name_1 and obj2.myName == ship_name_1))
	   then
		   if(GAME_VARS.died == false and gameEnded == false) then
			  GAME_VARS.died = true

      --   GAME_VARS.lives = GAME_VARS.lives - 1

			    -- Play explosion sound!
                audio.play( GAME_SOUNDS.playerDeadSound )
                 
			   livesText.text = message_live_1 .. lives
   
			   if(GAME_VARS.lives == 0) then

           effectDeadShipAndWeapons()
				  
			   else
				   effectDeadShipAndWeapons()
				   timer.performWithDelay(1000,effectRestoreShipAndWeapons)
			   end
   
		   end
     	   	   elseif((obj1.myName == ship_name_1 and obj2.myName == enemy_laser_name_1) or (obj1.myName == enemy_laser_name_1 and obj2.myName == ship_name_1))
	   then
		   if(GAME_VARS.died == false and gameEnded == false) then
			   GAME_VARS.died = true

			    -- Play explosion sound!
                audio.play( GAME_SOUNDS.playerDeadSound )
                explodeLaserAndRemove(obj1,obj2)
                
                for i = #lasersTable,1,-1 do
			            if(lasersTable[i] == obj1 or lasersTable[i] == obj2) then
				           table.remove(lasersTable,i)
                  break
                 end
		          	end
			   GAME_VARS.lives = GAME_VARS.lives - 1
			   livesText.text = message_live_1 .. lives
   
			   if(GAME_VARS.lives == 0) then

           effectDeadShipAndWeapons()
				  
			   else
				   effectDeadShipAndWeapons()
				   timer.performWithDelay(1000,effectRestoreShipAndWeapons)
			   end
   
		   end
    
	   end
	end
   
   end

local function setPlayerFireModeOnPlayTime()
 if(gameplayTime < 5)
    then
	    g_fireMode = FIRE_OPTIONS.FIRE_CENTER
	elseif(gameplayTime < 15) 
	then
		g_fireMode = FIRE_OPTIONS.FIRE_ALTERNATE
	else
		g_fireMode = FIRE_OPTIONS.FIRE_BOTH
	end
end

local function setBossFireModeOnPlayTime()
	  if(gameplayTime >=17)
     	then
        BOSS_FIRE_MODE      = BOSS_FIRE_OPTIONS.BOSS_FIRE_SPHERE
      elseif(gameplayTime >=16)
 		then
        BOSS_FIRE_MODE      = BOSS_FIRE_OPTIONS.BOSS_FIRE_LINE
      elseif(gameplayTime >=13)
 		then
        BOSS_FIRE_MODE      = BOSS_FIRE_OPTIONS.BOSS_FIRE_WAVE
      end
end

local function updateDeltaTime()
    newTime      = os.time()
	deltaTime    = newTime - previousTime
	previousTime = newTime
end

local function setScrollSpeed()
	scrool_speedUp = gameplayTime * 2
end
   
local function updateHourglass()

    local newTime = math.floor(19 - gameplayTime)

     if(gameplayTime >= 18 and gameplayTime < 19) 
     then
    	newTime = 1
     end

    if(newTime < 0) 
     then
    	newTime = 0
     end

	if(gameplayTime < 10) then
	    timeText.text = message_time_1 .. newTime
	else
		timeText.text = message_time_2 .. newTime
	end
end

local function updatePlayTime()
	if(doUpdatePlayTime == true)
	  then
        gameplayTime = gameplayTime + deltaTime * SCALE_TIME
      end
end

local GAME_STATE =
{
  GAME_START_LOOP    = 1,
  GAME_PLAYING       = 2,
  GAME_SPAWNING      = 3,
  GAME_BOSS_SPAWNING = 4,
  GAME_BOSS          = 5,
  GAME_DIED          = 6,
  GAME_SURVIVED      = 7,
  GAME_TIMEOUT       = 8
}
local b_GAME_START_LOOP = false
local b_GAME_PLAYING    = false
local b_GAME_SPAWNING   = false
local b_GAME_BOSS       = false

local game_state = 0

local function verifyState(state)
  
  
  
  if(game_state == state) then
  	return true
  end

  if(state == GAME_STATE.GAME_PLAYING and gameplayTime<=thresholdSpawning)
  then
    return true
  end

  if(state == GAME_STATE.GAME_BOSS_SPAWNING and gameplayTime > thresholdSpawning and boss == nil)
   then
     return true
   end

  if(state == GAME_STATE.GAME_DIED and GAME_VARS.died == true)
   then
     return true
   end
   
   if(state == GAME_STATE.GAME_SURVIVED and GAME_VARS.survived == true)
   then
     return true
   end
   
   if(state == GAME_STATE.GAME_TIMEOUT and gameplayTime >= SECONDS_TO_GAMEOVER)
   then 
     return true
   end
   
  return false
end

local function updateStateOnce(state)
  if(verifyState(state) == true)
   then
  	return
   end

      if(state == GAME_STATE.GAME_START_LOOP and b_GAME_START_LOOP == false)
     	then
          b_GAME_START_LOOP = true
          game_state = state
          return
        end
      if(state == GAME_STATE.GAME_PLAYING and b_GAME_PLAYING == false)
     	then
   	      b_GAME_PLAYING = true
          game_state = state
          return
        end
      if(state == GAME_STATE.GAME_SPAWNING and b_GAME_SPAWNING == false)
   	    then
   	      b_GAME_SPAWNING  = true
          game_state = state
          return
        end
      if(state == GAME_STATE.GAME_BOSS and b_GAME_BOSS == false)
     	then
     	  b_GAME_BOSS  = true
          game_state = state
          return
        end
end



local function bossBefore()
 moveVirusesCenterTop(SECONDS_TRANSITION_BOSS * 1000)
 moveVirusesCenterTop(SECONDS_TRANSITION_BOSS * 1000)
 hideViruses(SECONDS_TRANSITION_BOSS * 1000)
 pausePlayerMovements()
 movePlayerCenterBottom(SECONDS_TRANSITION_BOSS * 1000)
 pauseTime()
 pauseFire()
end

local function bossAfter()
  playTime()
  playPlayerMovements()
  playFire()
end

local speed_rigth   = 80;
local speed_left    = -80;
local speed_x       = 80;
local speed_forward = 150;
local speed_y
local currentAngle  = 0


local function moveAndRotateBoss()
	

    speed_y = 0

    if(boss.x > display.contentWidth)
      then
       speed_x   = speed_left
       speed_y   = speed_forward
      end

   if(boss.x < 0)
      then
       speed_x   = speed_rigth
       speed_y   = speed_forward
      end

    boss:translate(speed_x,speed_y)
   	
    local xBoss = boss.x
	local yBoss = boss.y

	local xShip = ship.x
	local yShip = ship.y

    local vectorFacingX = xShip - xBoss
    local vectorFacingY = yShip - yBoss

    local facingAngle  = math.deg(math.atan2(vectorFacingY,vectorFacingX))
    boss.rotation = -90 - 60 + facingAngle

end


    
local function fireLaserWaveBoss()

if(gameEnded == true)
 then
  return
 end
 
    audio.play( GAME_SOUNDS.fireLaserSound )

    for i=1,BOSS_FIRE_OPTIONS.BOSS_BULLETS_WAVE,1 do

     local bossFire = display.newImageRect( mainGroup, "imgs/monster_fire.png",51*0.3,161*0.3)
     bossFire:toBack()

     table.insert(lasersTable,bossFire) 
     physics.addBody(bossFire,"dynamic",{isSensor=true,radius=161*0.3})
     bossFire.myName = enemy_laser_name_1
    -- bossFire.isBullet = true
     local bulletOffset  = (i - BOSS_FIRE_OPTIONS.BOSS_BULLETS_WAVE/2) * 10

     bossFire.x          = boss.x + bulletOffset
     bossFire.y          = boss.y

     fireDirection = 1
     if(ship.y < boss.y)
     	then
          fireDirection = -1
        end

     if(i < BOSS_FIRE_OPTIONS.BOSS_BULLETS_WAVE/2)
     	then
         bossFire.y          = bossFire.y + BOSS_FIRE_OPTIONS.BOSS_BULLETS_WAVE*i*fireDirection
        else
         bossFire.y          = bossFire.y + BOSS_FIRE_OPTIONS.BOSS_BULLETS_WAVE*(BOSS_FIRE_OPTIONS.BOSS_BULLETS_WAVE - i)*fireDirection
        end

     local vectorFacingX = ship.x - boss.x
     local vectorFacingY = ship.y - boss.y

     local facingAngle   = math.deg(math.atan2(vectorFacingY,vectorFacingX))

     bossFire.rotation   = 90 + facingAngle

     local magn          = math.sqrt(vectorFacingX * vectorFacingX + vectorFacingY * vectorFacingY)

     vectorFacingX       = vectorFacingX / magn
     vectorFacingY       = vectorFacingY / magn

     bossFire.y = bossFire.y + vectorFacingY * 20
     bossFire.x = bossFire.x + vectorFacingX * 20

     bossFire:setLinearVelocity(vectorFacingX * power,  vectorFacingY * power)

     end

end

local function fireLaserLineBoss()
if(gameEnded == true)
 then
  return
 end
    audio.play( GAME_SOUNDS.fireLaserSound )

    for i=1,BOSS_FIRE_OPTIONS.BOSS_BULLETS_LINE,1 do

     local bossFire = display.newImageRect( mainGroup, "imgs/monster_fire.png",51*0.3,80*0.3)
     bossFire:toBack()
     table.insert(lasersTable,bossFire) 

     physics.addBody(bossFire,"dynamic",{isSensor=true,radius=40*0.3})
     bossFire.myName = enemy_laser_name_1
  --   bossFire.isBullet = true
      
     local vectorFacingX = ship.x - boss.x
     local vectorFacingY = ship.y - boss.y
     
     local facingAngle   = math.deg(math.atan2(vectorFacingY,vectorFacingX))


     bossFire.rotation   = 90 + facingAngle

     local magn          = math.sqrt(vectorFacingX * vectorFacingX + vectorFacingY * vectorFacingY)

     vectorFacingX       = vectorFacingX / magn
     vectorFacingY       = vectorFacingY / magn

     bossFire.x = boss.x + vectorFacingX * 30 * i
     bossFire.y = boss.y + vectorFacingY * 30 * i

     bossFire:setLinearVelocity(vectorFacingX * power,  vectorFacingY * power)

    end
end
local function fireLaserSphereBoss()
if(gameEnded == true)
 then
  return
 end
    audio.play(GAME_SOUNDS.fireLaserSound)

    local firingSlice   = math.rad(180 / BOSS_FIRE_OPTIONS.BOSS_BULLETS_SPHERE)
    local vectorFacingX = ship.x - boss.x
    local vectorFacingY = ship.y - boss.y

    for i=1,BOSS_FIRE_OPTIONS.BOSS_BULLETS_SPHERE,1 do

     local bossFire = display.newImageRect( mainGroup, "imgs/monster_fire.png",65*0.3,65*0.3)
     bossFire:toBack()
     table.insert(lasersTable,bossFire) 

     physics.addBody(bossFire,"dynamic",{isSensor=true,radius=32.5*0.3})
     bossFire.myName = enemy_laser_name_1
   --  bossFire.isBullet = true
       
     local newVectorFacingX
     local newVectorFacingY

     if(i<BOSS_FIRE_OPTIONS.BOSS_BULLETS_SPHERE/2)
     	then
         newVectorFacingX = vectorFacingX * math.cos(-firingSlice * i) - vectorFacingY * math.sin(-firingSlice * i)
         newVectorFacingY = vectorFacingY * math.sin(-firingSlice * i) + vectorFacingY * math.cos(-firingSlice * i)
        else
         newVectorFacingX = vectorFacingX * math.cos(firingSlice * (i-(BOSS_FIRE_OPTIONS.BOSS_BULLETS_SPHERE/2))) - vectorFacingY * math.sin(firingSlice * (i-(BOSS_FIRE_OPTIONS.BOSS_BULLETS_SPHERE/2)))
         newVectorFacingY = vectorFacingY * math.sin(firingSlice * (i-(BOSS_FIRE_OPTIONS.BOSS_BULLETS_SPHERE/2))) + vectorFacingY * math.cos(firingSlice * (i-(BOSS_FIRE_OPTIONS.BOSS_BULLETS_SPHERE/2)))
        end

      local facingAngle   = math.deg(math.atan2(newVectorFacingY,newVectorFacingX))
     
      bossFire.rotation   = 90 + facingAngle

     local magn          = math.sqrt(newVectorFacingX * newVectorFacingX + newVectorFacingY * newVectorFacingY)

     newVectorFacingX  = newVectorFacingX / magn
     newVectorFacingY  = newVectorFacingY / magn

     bossFire.x = boss.x + newVectorFacingX * 30
     bossFire.y = boss.y + newVectorFacingY * 30

     bossFire:setLinearVelocity(newVectorFacingX * power,  newVectorFacingY * power)

    end
end
local function doBossFire()



 
   if(BOSS_FIRE_MODE == BOSS_FIRE_OPTIONS.BOSS_FIRE_WAVE)
     then
       fireLaserWaveBoss()
      -- timer.performWithDelay(300,fireLaserWaveBoss)
    elseif(BOSS_FIRE_MODE == BOSS_FIRE_OPTIONS.BOSS_FIRE_LINE)
     then
       fireLaserLineBoss()
    elseif(BOSS_FIRE_MODE == BOSS_FIRE_OPTIONS.BOSS_FIRE_SPHERE)
     then
       fireLaserSphereBoss()
    end
  
end

local function doGameOverSurvived()
       gameEnded = true
        
          physics.pause()
        
           display.remove(ship)
				   display.remove(STATIC_IMGS.heart)
				   display.remove(STATIC_IMGS.hourglass)
				   display.remove(STATIC_IMGS.avatar)

				   if(leftMissileDestroyed == false) then
				  	display.remove(leftMissileShip)
				   end

				   if(rigthMissileDestroyed == false) then
				    display.remove(rigthMissileShip)
				   end
display.remove(STATIC_IMGS.scorePrefix)
display.remove(livesText)
display.remove(scoreText)
--display.remove(scorePrefix)
display.remove(antivirusText)
display.remove(timeText)
display.remove(uiGroup)

				   composer.setVariable("Survived",true)

			     endGame()
end
local function doGameOverDied()
  
           gameEnded = true
        
          physics.pause()
        
           display.remove(ship)
				   display.remove(STATIC_IMGS.heart)
				   display.remove(STATIC_IMGS.hourglass)
				   display.remove(STATIC_IMGS.avatar)

				   if(leftMissileDestroyed == false) then
				  	display.remove(leftMissileShip)
				   end

				   if(rigthMissileDestroyed == false) then
				    display.remove(rigthMissileShip)
				   end
display.remove(STATIC_IMGS.scorePrefix)
display.remove(livesText)
display.remove(scoreText)
display.remove(antivirusText)
display.remove(timeText)
display.remove(uiGroup)
				   composer.setVariable("Survived",false)

			     endGame()
end

local function removeOffscreenGameObjects()
   removeViruses()
   removeLasers()
end


local options = {
   parent = uiGroup,
   text = "----------",
   x = display.contentCenterX,
   y = 50,
   fontSize = 25,
   width = 400,
   height = 0,
   align = "center"
}


local function updateAntivirus()
  
  --if(antivirusText == nil) 
  --then
  --  antivirusText  = display.newText(options)
  --  antivirusText:setFillColor( 0, 1, 1 )
  --end
   local bD = 0
   local halfLife      = bossInfo.bossLife / 2
   local width_syringe = bossLifeUI.NOT_INFECTED[1].contentWidth
   local pos = display.contentCenterX - halfLife * width_syringe - width_syringe / 2
  --local life = ""
  for i=1,bossInfo.bossDamage do
    --life = life .. "X"
    bD = bD + 1
    bossLifeUI.NOT_INFECTED[i].x = pos + bD * width_syringe
    bossLifeUI.NOT_INFECTED[i].y = 33
  end
  for i=1,bossInfo.bossLife - bossInfo.bossDamage do
   -- life = life .. "-"
    bD = bD + 1
    bossLifeUI.INFECTED[i].x = pos + bD * width_syringe
    bossLifeUI.INFECTED[i].y = 34
  end
 -- antivirusText.text = life
end


local function updateAI()

     updateStateOnce(GAME_STATE.GAME_PLAYING)

		 if (verifyState(GAME_STATE.GAME_PLAYING)) 
		 then
		     updateStateOnce(GAME_STATE.GAME_SPAWNING)
     end
     
     if(verifyState(GAME_STATE.GAME_SPAWNING))
     then
         createViruses() 
        
     end

    if(verifyState(GAME_STATE.GAME_BOSS_SPAWNING))
      then
         popup:show()
         updateStateOnce(GAME_STATE.GAME_BOSS)
     		 createBossWithTransition(bossInfo.BOSS_HEIGTH/2,SECONDS_TRANSITION_BOSS * 1000,bossBefore,bossAfter)
      end

    if(verifyState(GAME_STATE.GAME_BOSS))
       	 then
                updateAntivirus()
                moveAndRotateBoss()
                setBossFireModeOnPlayTime()
                if(gameplayTime > thresholdSpawning + SCALE_TIME)
                 then
                  doBossFire()
                 end
       	 end
       
       
     if(verifyState(GAME_STATE.GAME_SURVIVED))
       then
         doGameOverSurvived()
       end
       
     if(verifyState(GAME_STATE.GAME_DIED))
         then
            doGameOverDied()
      end 
                 
		if(verifyState(GAME_STATE.GAME_TIMEOUT)) 
		 then
			doGameOverSurvived()
		 end

	   removeOffscreenGameObjects()

    

end





local function gameLoop()
	
  updateStateOnce(GAME_START_LOOP)

	updateDeltaTime()
        
  updatePlayTime()

	setScrollSpeed()

	setPlayerFireModeOnPlayTime()
	
  updateHourglass()

	updateAI()


   end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	--load all need objects(not the asteroids or laser, but o think i can load them)
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause()
	-- first level of visibility
	backGroup = display.newGroup()  -- Display group for the background image
  sceneGroup:insert( backGroup )  -- Insert into the scene's view group
    -- second level of visibility
  mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
  sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
    -- third level of visibility
  uiGroup = display.newGroup()    -- Display group for UI objects like the score
  sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

    --old style image loading, i can put a group, a path, and w h
	--local background = display.newImageRect( backGroup,path_background,800,1400)
	
   

	bg1    = display.newImageRect(backGroup,PATHS.path_background, 800,1400)
  bg1.x  = display.contentCenterX
  bg1.y  = display.contentCenterY
 
  bg2    = display.newImageRect(backGroup,PATHS.path_background, 800,1400)
  bg2.x  = display.contentCenterX
  bg2.y  = display.contentCenterY - display.contentHeight
 
	scroll = 2
    --where 
    --background.x = display.contentCenterX
    --background.y = display.contentCenterY

  SCALE_MISSILE = 0.3

	--get the ship image from the objectsheet and place it  in the display
	--ship         = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
	ship = display.newImageRect( mainGroup, objectSheet,6,98,79)
  

  bossLifeUI.INFECTED     = {}
  bossLifeUI.NOT_INFECTED = {}
  local img = nil
  for i=0,bossInfo.bossLife - 1 do
        img = display.newImageRect( uiGroup,syringeSheet,1,29,29*2.39)
              table.insert(bossLifeUI.INFECTED,img)
        img = display.newImageRect( uiGroup,syringeSheet,2,29,29*2.39)
              table.insert(bossLifeUI.NOT_INFECTED,img)
  end
  
 -- print(#bossLifeUI.INFECTED)
  
	createLeftMissile()
	createRigthMissile()

	lastFireSide                      = 1

  FIRE_OPTIONS.FIRE_RIGTH           = 1
  FIRE_OPTIONS.FIRE_LEFT            = -1
  FIRE_OPTIONS.FIRE_ALTERNATE       = 1
  FIRE_OPTIONS.FIRE_CENTER          = 0
  FIRE_OPTIONS.FIRE_BOTH            = 2
  FIRE_OPTIONS.OPT_FIRE_BOTH_OFFSET = 17
	FIRE_OPTIONS.LASER_X_SPEED        = 0
	FIRE_OPTIONS.LASER_Y_SPEED        = -1600

	g_fireMode                        = FIRE_OPTIONS.FIRE_CENTER
	
	halfShipBoundsX = 44
	halfShipBoundsY = 35

	gameplayTime     = 0
  previousTime     = 0
  newTime          = 0
	deltaTime        = 0
	--place the ship on the display
	placeShip()
	--place the missiles on the display
    placeMissiles()
	--place a bit from the bottom , remember that 0,0 start from the upleft
    local displayOffset = (display.contentWidth - display.viewableContentWidth) / 2
    local startX        = 0 + displayOffset
    local marginX       = 20
    local marginY       = 20
    local endX          = display.contentWidth  - displayOffset
	--add the ship to the phisics engine
	--the collider box is a sphere of 30 radius
	--sensor true receive collision events
	physics.addBody( ship, "static",{ radius=30, isSensor=true } )
	ship.myName = ship_name_1
    ship.touchOffsetX = 0
    ship.touchOffsetY = 0
	--livesText = display.newText( uiGroup, message_live_1 .. lives, 200, 30, native.systemFont, 36 )
	timeText  = display.newText( uiGroup, message_time_1 .. 19 - gameplayTime,  200, 80, native.systemFont, 36 )
	--scorePrefix = display.newText( uiGroup,message_score_1, display.contentWidth - 250, 80, native.systemFont, 36 )
	
	STATIC_IMGS.scorePrefix = display.newImageRect(uiGroup,PATHS.path_score,35,35)
	STATIC_IMGS.heart       = display.newImageRect(uiGroup,PATHS.path_heart,35,29)
	STATIC_IMGS.hourglass   = display.newImageRect(uiGroup,PATHS.path_hourglass,37,37)
	STATIC_IMGS.avatar      = display.newImageRect(uiGroup,PATHS.path_avatar,57*1.5,43*1.5)

    --shield      = display.newImageRect(uiGroup,PATHS.path_shield,170,170)
           sheet_shield            = graphics.newImageSheet( PATHS.path_shield, sheetAnimationOptionsShield)
           shield = display.newSprite( mainGroup,sheet_shield, sequences_shield)
           shield:setSequence( "normalShield")
           shield.myName = "shield"
           shield:play()
           physics.addBody( shield, "static",{ radius=140, isSensor=true } )

    placeShield()
    
    local message = "HELLO! I'M THECHIEF OF YOUR ANTIVIRUS SYSTEM. LET'S KILL THEM ALL!"
    popup:create(PATHS.path_popup,260*2,135*2,PATHS.path_keystroke,150,300,uiGroup,message,14)
    
    
    STATIC_IMGS.avatar.x           = endX - (STATIC_IMGS.avatar.width / 2)
    STATIC_IMGS.avatar.y           = 30
    STATIC_IMGS.scorePrefix.x      = endX - (STATIC_IMGS.scorePrefix.width / 2 + marginX)
    STATIC_IMGS.scorePrefix .y     = STATIC_IMGS.avatar.y + STATIC_IMGS.avatar.height / 2 + marginY

	scoreText = display.newText(  uiGroup,string.format("%07d",GAME_VARS.score), 540 - STATIC_IMGS.scorePrefix.width / 2, STATIC_IMGS.scorePrefix .y, native.systemFont, 36, "right")

	STATIC_IMGS.heart.x            = startX + marginX + STATIC_IMGS.heart.width / 2
	STATIC_IMGS.heart.y            = 30
	STATIC_IMGS.hourglass.x        = startX + marginX + STATIC_IMGS.hourglass.width / 2
	STATIC_IMGS.hourglass.y        = 80

	ship:addEventListener(laser_event,fireLaser)
	ship:addEventListener(move_event,dragShip)
	
	loadAudio()

    sheet_laserExplosion    = graphics.newImageSheet( PATHS.path_laserExplosion, sheetAnimationOptionsLaserExplosion)
    sheet_shipExplosion     = graphics.newImageSheet( PATHS.path_shipExplosion, sheetAnimationOptionsShipExplosion)
    sheet_missileExplosion  = graphics.newImageSheet( PATHS.path_missileExplosion, sheetAnimationOptionsMissileExplosion)
  
	gameEnded      = false

	scrool_speedUp = 0
    SCALE_TIME     = 0.2

if(build_release == false) 
 then
    setDebugOptions()
 end

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		
		physics.start()
		--register the collision event
		Runtime:addEventListener("collision",onCollision)
		Runtime:addEventListener("enterFrame", bgScroll)

		previousTime = os.time()
		--start a loop function each half second
		gameLoopTimer = timer.performWithDelay(500,gameLoop,0)
		 -- Start the music!
		 audio.play( GAME_SOUNDS.musicTrack, { channel=1, loops=-1 } )
	end
end

-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		--timer.cancel(gameLoopTimer)
		if (gameLoopTimer~= nil) then
			timer.cancel(gameLoopTimer)
    	end
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener("enterFrame",bgScroll)
        Runtime:removeEventListener("collision",onCollision)
		physics.pause()
		--Stop the music!
		audio.stop( 1 )
		--destroy all object reeferences
		composer.removeScene(game_scene)

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
 -- Dispose audio!
 audio.dispose( GAME_SOUNDS.playerDeadSound )
 audio.dispose( GAME_SOUNDS.enemyDeadSound )
 audio.dispose( GAME_SOUNDS.fireLaserSound )
 audio.dispose( GAME_SOUNDS.musicTrack)
 popup:destroy()
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
