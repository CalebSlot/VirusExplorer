
local font = {}

font.sheetMap = 
{
	["A"] = 1,
	["B"] = 2,
	["C"] = 3,
	["D"] = 4,
	["E"] = 5,
	["F"] = 6,
	["G"] = 7,
	["H"] = 8,
	["I"] = 9,
	["J"] = 10,

  ["K"] = 11,
	["L"] = 12,
	["M"] = 13,
	["N"] = 14,
	["O"] = 15,
	["P"] = 16,
	["Q"] = 17,
	["R"] = 18,
	["S"] = 19,
	["T"] = 20,

    ["U"] = 21,
	["V"] = 22,
	["W"] = 23,
	["X"] = 24,
	["Y"] = 25,
	["Z"] = 26,
	["!"] = 27,
	["."] = 28,
	["'"] = 29,
	[" "] = 30,
}

font.sheetOptions =
{
    frames =
    {
        {   
            x = 0,
            y = 0,
            width = 43,
            height = 50
		},
		
        {   
            x = 0 + 43 * 1,
            y = 0,
            width = 43,
            height = 50
		},

        {   
            x = 0 + 43 * 2,
            y = 0,
            width = 43,
            height = 50
		},
		
       	
        {   
            x = 0 + 43 * 3,
            y = 0,
            width = 43,
            height = 50
		},
		
       	
        {   
            x = 0 + 43 * 4,
            y = 0,
            width = 43,
            height = 50
		},

		
        {   
            x = 0 + 43 * 5,
            y = 0,
            width = 43,
            height = 50
		},

        {   
            x = 0 + 43 * 6,
            y = 0,
            width = 43,
            height = 50
		},

        {   
            x = 0 + 43 * 7,
            y = 0,
            width = 43,
            height = 50
		},

        {   
            x = 0 + 43 * 8,
            y = 0,
            width = 43,
            height = 50
		},

        {   
            x = 0 + 43 * 9,
            y = 0,
            width = 43,
            height = 50
		},
		--
		        {   
            x = 0,
            y = 51,
            width = 43,
            height = 50
		},
		
        {   
            x = 0 + 43 * 1,
            y = 51,
            width = 43,
            height = 50
		},

        {   
            x = 0 + 43 * 2,
            y = 51,
            width = 43,
            height = 50
		},
		
       	
        {   
            x = 0 + 43 * 3,
            y = 51,
            width = 43,
            height = 50
		},
		
       	
        {   
            x = 0 + 43 * 4,
            y = 51,
            width = 43,
            height = 50
		},

		
        {   
            x = 0 + 43 * 5,
            y = 51,
            width = 43,
            height = 50
		},

        {   
            x = 0 + 43 * 6,
            y = 51,
            width = 43,
            height = 50
		},

        {   
            x = 0 + 43 * 7,
            y = 51,
            width = 43,
            height = 50
		},

        {   
            x = 0 + 43 * 8,
            y = 51,
            width = 43,
            height = 50
		},

        {   
            x = 0 + 43 * 9,
            y = 51,
            width = 43,
            height = 50
		},
				--
		        {   
            x = 0,
            y = 52 * 2,
            width = 43,
            height = 49
		},
		
        {   
            x = 0 + 43 * 1,
            y = 52 * 2,
            width = 43,
            height = 49
		},

        {   
            x = 0 + 43 * 2,
            y = 52 * 2,
            width = 43,
            height = 49
		},
		
       	
        {   
            x = 0 + 43 * 3,
            y = 52 * 2,
            width = 43,
            height = 49
		},
		
       	
        {   
            x = 0 + 43 * 4,
            y = 52 * 2,
            width = 43,
            height = 49
		},

		
        {   
            x = 0 + 43 * 5,
            y = 52 * 2,
            width = 43,
            height = 49
		},

        {   
            x = 0 + 43 * 6,
            y = 52 * 2,
            width = 43,
            height = 49
		},

        {   
            x = 0 + 43 * 7,
            y = 52 * 2,
            width = 43,
            height = 49
		},

        {   
            x = 0 + 43 * 8,
            y = 52 * 2,
            width = 43,
            height = 49
		},

        {   
            x = 0 + 43 * 9,
            y = 52 * 2,
            width = 43,
            height = 49
		},
    },
}

font.FONT_WIDTH = 43
font.FONT_SCALE = 0.7
font.fontSheet  = nil

function font:showString(var,sg,x,y)

   local retChars = {}
   
	 local strl     =  var:len()
	 local halfPos  =  math.round((strl * self.FONT_WIDTH * self.FONT_SCALE) / 2)
	 local halfC    =  math.round((self.FONT_WIDTH * self.FONT_SCALE) / 2)

     if (self.fontSheet == nil)
           then
            self.fontSheet = graphics.newImageSheet("imgs/alphabet.png",self.sheetOptions)
          end

	 for i = 1, strl,1 do

          local charAt = var:sub(i,i)
          local  idx   = self.sheetMap[charAt]
          local  img   = display.newImageRect(sg,self.fontSheet,idx,43*self.FONT_SCALE,52*self.FONT_SCALE)
          if(img ~= nil) then
           img.x = x - halfPos + halfC + math.round((i - 1) * self.FONT_WIDTH * self.FONT_SCALE) 
           img.y = y
           retChars[i] = img
          end
	 end

   return retChars
   
end

function font:showStringMultiline(var,sg,charsForLine,x,y,yI)
  
  local retChars  = {}
  local strl      =  var:len()
  local line      = 0
  local charIndex
  local retIndex  = 1
  
  for charIndex = 0, strl,charsForLine do
      
      if(charIndex > 0 and math.mod(charIndex,charsForLine) == 0) then
        y               = y + yI
        line            = line + 1
      end  
      
      local startL = line * charsForLine + 1
      local endL   = startL + charsForLine - 1
      
      if(startL > strl) then
        startL = 1
      end  
      
      if(endL > strl) then
        endL = strl
      end  
      
      local mySubstring = var:sub(startL, endL)
      
      local newString    = self:showString(mySubstring,sg,x,y)
      local newStringLen = #newString
    
      
      for newChar = 1, newStringLen,1 do
        retChars[retIndex] = newString[newChar]
        retIndex = retIndex + 1
      end
      
      
  end
      
  return retChars
    
end

return font
