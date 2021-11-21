local font             = require("font")
local popup = {}
popup.__index = popup



function popup:create(background,width,height,sound,speed,wait,uiGroup,message,charsForLine)
  
  local pop = {}             -- our new object
  setmetatable(pop,popup)  -- make popup handle lookup
 
  pop.fontTimerOptions =
{
   popped = false,
   active = false,
   popup,
   tm     = nil,
   idx    = 0,
   speed  = 150,
   wait   = 300,
   sound,
   fontChars = {},
   len,
   onEnter,
   onExit,
}
  pop.fontTimerOptions.speed       = speed
  pop.fontTimerOptions.wait        = wait
  
  pop.fontTimerOptions.popup            = display.newImageRect(uiGroup,background,width,height)  
  pop.fontTimerOptions.popup.isVisible  = false
  pop.fontTimerOptions.sound            = audio.loadSound(sound)
  pop.fontTimerOptions.len              = message:len()
  pop.fontTimerOptions.fontChars = font:showStringMultiline(message,uiGroup,charsForLine,display.contentCenterX,display.contentCenterY - pop.fontTimerOptions.popup.height / 2 + 60,40);
  
    for cI = 1,#pop.fontTimerOptions.fontChars do
        pop.fontTimerOptions.fontChars[cI].isVisible = false
    end
  
  return pop
end

function popup:show(onEnter,onExit,effects)
 if(self.fontTimerOptions.popped == false)
    then
    self.fontTimerOptions.onEnter = onEnter
    self.fontTimerOptions.onExit  = onExit
    self.fontTimerOptions.popup.x            = (display.contentWidth - display.viewableContentWidth) / 2 + display.actualContentWidth / 2
    self.fontTimerOptions.popup.y            = display.actualContentHeight / 2
    self.fontTimerOptions.popup.alpha        = 0
    self.fontTimerOptions.popup.isVisible    = true
    self.fontTimerOptions.active             = true
    self.fontTimerOptions.popped             = true
   
 
    transition.fadeIn( self.fontTimerOptions.popup , { time=effects.fadeIn } )
    
    local showStringDelayed = function()
      
       if(self.fontTimerOptions.active == false)
  then
    return
  end

  if (self.fontTimerOptions.idx == self.fontTimerOptions.len) then
       self.fontTimerOptions.idx    = 0
       self.fontTimerOptions.active = false
   --    fontTimerOptions.tm     = 0
       timer.cancel(self.fontTimerOptions.tm)
       
       local remover = function()
        for cI = 1,#self.fontTimerOptions.fontChars do
         display.remove(self.fontTimerOptions.fontChars[cI])
         --todo: add recycle
        end
        self.fontTimerOptions.fontChars = {}
        self.fontTimerOptions.len = 0
        
        transition.fadeOut( self.fontTimerOptions.popup , { time=effects.fadeOut } )
        
        local removePopup = function()
        
        display.remove(self.fontTimerOptions.popup)
        timer.cancel(self.fontTimerOptions.tm)
   
        self.fontTimerOptions.popped  = false
        self.fontTimerOptions.onExit()
        
        end
      
        
        timer.performWithDelay(effects.fadeOut,removePopup)
       
       end
       
       self.fontTimerOptions.tm = timer.performWithDelay(self.fontTimerOptions.wait,remover)
       
      return
  end
      
      self.fontTimerOptions.fontChars[self.fontTimerOptions.idx + 1].isVisible = true
      self.fontTimerOptions.soundHandle = audio.play(self.fontTimerOptions.sound,{duration = self.fontTimerOptions.speed})
      self.fontTimerOptions.idx = self.fontTimerOptions.idx + 1

    end
    
    self.fontTimerOptions.onEnter()
    self.fontTimerOptions.tm = timer.performWithDelay(self.fontTimerOptions.speed,showStringDelayed,-1)
   end
end
function popup:destroy()
  if(self.fontTimerOptions.sound~=nil and self.fontTimerOptions.soundHandle~=nil) 
  then
   audio.stop(self.fontTimerOptions.soundHandle)
   audio.dispose( self.fontTimerOptions.sound)
   self.fontTimerOptions.soundHandle = nil;
   self.fontTimerOptions.sound = nil;
  end
  
end

return popup