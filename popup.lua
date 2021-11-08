local font             = require("font")
local popup = {}

popup.fontTimerOptions =
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
}

function popup:create(background,width,height,sound,speed,wait,uiGroup,message,charsForLine)
  self.fontTimerOptions.speed       = speed
  self.fontTimerOptions.wait        = wait
  
  self.fontTimerOptions.popup            = display.newImageRect(uiGroup,background,width,height)  
  self.fontTimerOptions.popup.isVisibile = false
  self.fontTimerOptions.sound            = audio.loadSound(sound)
  self.fontTimerOptions.len              = message:len()
  self.fontTimerOptions.fontChars = font:showStringMultiline(message,uiGroup,charsForLine,display.contentCenterX,display.contentCenterY - self.fontTimerOptions.popup.height / 2 + 60,40);
  
    for cI = 1,#self.fontTimerOptions.fontChars do
        self.fontTimerOptions.fontChars[cI].isVisible = false
    end
  
  
end

function popup:show()
 if(self.fontTimerOptions.popped == false)
    then
    self.fontTimerOptions.popup.x            = (display.contentWidth - display.viewableContentWidth) / 2 + display.actualContentWidth / 2
    self.fontTimerOptions.popup.y            = display.actualContentHeight / 2
    self.fontTimerOptions.popup.isVisible    = true
    self.fontTimerOptions.active             = true
    self.fontTimerOptions.popped             = true
    
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
        end
        self.fontTimerOptions.fontChars = {}
        display.remove(self.fontTimerOptions.popup)
        timer.cancel(self.fontTimerOptions.tm)
       end
       
       self.fontTimerOptions.tm = timer.performWithDelay(self.fontTimerOptions.wait,remover)
       
      return
  end
      

      self.fontTimerOptions.fontChars[self.fontTimerOptions.idx + 1].alpha = 1
      audio.play(self.fontTimerOptions.sound,{duration = self.fontTimerOptions.speed})
      self.fontTimerOptions.idx = self.fontTimerOptions.idx + 1
      
      
    end
    
    
    
    self.fontTimerOptions.tm = timer.performWithDelay(self.fontTimerOptions.speed,showStringDelayed,-1)
   end
end
function popup:destroy()
  audio.dispose( popup.fontTimerOptions.sound)
end

return popup