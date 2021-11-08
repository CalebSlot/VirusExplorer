
local composer = require( "composer" )

local scene = composer.newScene()

local paths =
{
   track        = "audio/Escape_Looping.wav",
   background   = "imgs/background.png",
   text         = "imgs/background_text.png",
}

local sceneObjects =
{
	musicTrack,
	background_text,
	skipButton,
}

local menuRequested = false
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function gotoMenu()

  if(menuRequested == true) 
   then
  	return
  end

  menuRequested = true 
  composer.gotoScene("menu", {time=800,effect="crossFade"})
end

local function loadAudio()
	sceneObjects.musicTrack      = audio.loadStream( paths.track)
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background1 = display.newImageRect(sceneGroup,paths.background,800,1400)
	background1.x     = display.contentCenterX
	background1.y     = display.contentCenterY

	sceneObjects.background_text   = display.newImageRect(sceneGroup,paths.text,display.contentWidth - 100,display.contentHeight)
	sceneObjects.background_text.x = display.contentCenterX
	sceneObjects.background_text.y = display.contentHeight * 2
  
    sceneObjects.skipButton = display.newText(sceneGroup,"Skip...", 550, 30, native.systemFont, 36 )
    sceneObjects.skipButton:addEventListener("tap",gotoMenu)

	loadAudio()
end

function scrollStory()

    transition.to( sceneObjects.background_text.path, { time=30000, x1=450, x2=0, y2=0, x4=-450, y4=0 } )
    transition.to( sceneObjects.background_text, { x= display.contentCenterX, y = - display.contentHeight,time = 30000,
      onComplete = function () gotoMenu() end} )

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
        audio.play( sceneObjects.musicTrack, { channel=1, loops=-1 } )
        scrollStory()
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
        -- Stop the music!
		audio.stop( 1 )
		composer.removeScene( "story" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  audio.dispose( sceneObjects.musicTrack)
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
