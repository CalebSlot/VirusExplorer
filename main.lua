local composer = require("composer")
local require_debug = true

display.setStatusBar(display.HiddenStatusBar)
math.randomseed(os.time())
-- Reserve channel 1 for background music
audio.reserveChannels( 1 )
-- Reduce the overall volume of the channel
audio.setVolume( 0.5, { channel=1 } )

if(require_debug == true) 
 then
 require("mobdebug").start()
end

composer.gotoScene("story")

