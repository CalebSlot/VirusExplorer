
local composer                    = require( "composer" )

local scene                       = composer.newScene()

local path_track                  = "audio/Midnight-Crawlers_Looping.wav"
local musicTrack
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local font        = require("font")
local scores      = require("scores")

local loadText
local loadIcon
local loadingTimer
local sceneGroup

local function loadAudio()
	musicTrack      = audio.loadStream( path_track)
end

local function showScores(sceneGroup)

    local scoresTable = scores:getRemote()

     for i = 1, 10 
      do
        if ( scoresTable[i] )
         then
            local yPos        = 150 + ( i * 56 )
            local rankNum     = display.newText( sceneGroup, i .. ")", display.contentCenterX-50, yPos, native.systemFont, 36 )
            rankNum:setFillColor( 0.8 )
            rankNum.anchorX   = 1
 
            local thisScore   = display.newText( sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, native.systemFont, 36 )
            thisScore.anchorX = 0
        end
      end
end

local function gotoMenu()

    composer.gotoScene( "menu", { time = 800, effect = "crossFade" } )

end

local reverse = 0

local function rotateLoader()
    if ( reverse == 0 )
     then
        reverse = 1
        transition.to( loadIcon, { rotation=-180, time=500, transition=easing.inOutCubic } )
    else
        reverse = 0
        transition.to( loadIcon, { rotation=180, time=500, transition=easing.inOutCubic } )
    end
end

local function remoteLoadingOK()
	print("loading done") 
	timer.cancel(loadingTimer)
    display.remove(loadIcon)
    display.remove(loadText)
	local sg = sceneGroup
    showScores(sg)
end

local function remoteLoadingFail(error)
    print("Login Failed: " .. error.errorMessage) 
    loadText.text = "Error..." 
    timer.cancel(loadingTimer)
end

local function createLoader(sg)
     loadIcon       = display.newImageRect(sg,"imgs/hazard.png",50,50)
     loadIcon.x     = display.contentCenterX
     loadIcon.y     = 400
     loadText       = display.newText( sg, "Loading...", display.contentCenterX, 500, native.systemFont, 44 ,"center")
     loadingTimer   = timer.performWithDelay( 600, rotateLoader, 0 )
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	 sceneGroup = self.view

	 local background         = display.newImageRect( sceneGroup, "imgs/background.png", 800, 1400 )
	 background.x             = display.contentCenterX
	 background.y             = display.contentCenterY
	  
	 local title = "WORLD HIGH SCORES"
     font:showString(title,sceneGroup,display.contentCenterX,100)

	 local menuButton       = display.newText( sceneGroup, "Menu", display.contentCenterX, 810, native.systemFont, 44 )
     menuButton:setFillColor( 0.75, 0.78, 1 )
     menuButton:addEventListener( "tap", gotoMenu )

     scores:setGetRemoteOK(remoteLoadingOK)
     scores:setGetRemoteFail(remoteLoadingFail)
 
     createLoader(sceneGroup)

     scores:loadRemote()

     loadAudio()


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
        if (loadingTimer~= nil) 
         then
			timer.cancel(loadingTimer)
    	 end
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
          -- Stop the music!
          audio.stop( 1 )
          composer.removeScene( "nethighscores" )
    end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

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
