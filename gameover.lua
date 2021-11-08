
local composer   = require( "composer" )

local scene      = composer.newScene()
local scores     = require("scores")

local path_track = "audio/Escape_Looping.wav"
local musicTrack
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function gotoGame()
  composer.gotoScene("game", {time=800,effect="crossFade"})
end
local function gotoMenu()
	composer.gotoScene("menu", {time=800,effect="crossFade"})
  end
local function gotoExit()
	native.requestExit()
end
local function loadAudio()
	musicTrack      = audio.loadStream( path_track)
end

local function updateFailed(error)
 print(error.errorMessage)
end
local function updateDone(score)
 print("updateDone : "..score)
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	scores:setUpdateRemoteOK(updateDone)
    scores:setUpdateRemoteFail(updateFailed)

    local score = composer.getVariable( "finalScore")
	scores:updateLocal(score)
	scores:updateRemote(score)
  
    composer.setVariable( "finalScore", 0 )

	local background = display.newImageRect(sceneGroup,"imgs/background.png",800,1400)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect(sceneGroup,"imgs/title_game_over.png",500,80)
	title.x = display.contentCenterX
	title.y = 200
	
	local score = display.newText(sceneGroup,"Score: " .. score,display.contentCenterX,400,native.systemFont,44)
	score:setFillColor(0.82,0.86,1)

	local survived = composer.getVariable( "Survived")

	if(survived == true) then
	   local ssurvived = display.newText(sceneGroup," You Are Alive\nEnjoy Your Life!",display.contentCenterX,500,native.systemFont,50)
	   ssurvived:setFillColor(144/255,238/255,144/255)
	else
	   local ssurvived = display.newText(sceneGroup,"You Died, Why?",display.contentCenterX,500,native.systemFont,50)
	   ssurvived:setFillColor(138/255,3/255,3/255)
	end
	local menuButton = display.newText(sceneGroup,"Menu",display.contentCenterX,700,native.systemFont,44)
	menuButton:setFillColor(0.82,0.86,1)

	local exitButton = display.newText(sceneGroup,"Exit",display.contentCenterX,810,native.systemFont,44)
	exitButton:setFillColor(0.82,0.86,1)
	
	local playButton = display.newText(sceneGroup,"Play", display.contentCenterX, 920, native.systemFont, 44)
	playButton:setFillColor(0.75,0.78,1)
	
	playButton:addEventListener("tap",gotoGame)
	menuButton:addEventListener("tap",gotoMenu)
	exitButton:addEventListener("tap",gotoExit)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
  -- Start the music!
  audio.play( musicTrack, { channel=1, loops=-1 } )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		audio.stop( 1 )
		composer.removeScene( "gameover" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  audio.dispose(musicTrack)
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
