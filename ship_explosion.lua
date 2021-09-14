--
-- created with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:de14f4ea11e1b26c89a0bc189b384026:e42512f32628d9a0afe166ebb46dc20b:9c5fb3b1f6e1c7d6e8215568306651bf$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- explosion_0
            x=0,
            y=0,
            width=128,
            height=128,

        },
        {
            -- explosion_1
            x=128,
            y=0,
            width=128,
            height=128,

        },
        {
            -- explosion_2
            x=256,
            y=0,
            width=128,
            height=128,

        },
    },

    sheetContentWidth = 384,
    sheetContentHeight = 128
}

SheetInfo.frameIndex =
{

    ["explosion_0"] = 1,
    ["explosion_1"] = 2,
    ["explosion_2"] = 3,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
