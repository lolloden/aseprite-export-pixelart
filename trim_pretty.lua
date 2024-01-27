-- This script exports single layer for outlined pixel art
-- by Lorenzo Quaglieri

-- crops selection (needs a marquee selection)
app.command.CropSprite() 
 
-- trim to bounds
app.command.AutocropSprite() 

-- sprite
local spr = app.sprite
if not spr then return app.alert("There's no active sprite") end

-- layer
local layer = app.layer
if not layer then return app.alert("There's no active layer") end

-- parent
local parent = layer.parent

local function spriteBounds()
	app.alert("spriteBounds()->w/h=" .. spr.bounds.width .. "/" .. spr.bounds.height)
end

local function getLayerCel(layerName)
	local parent = layer.parent
	local allLayers = parent.layers
	
	for _, lay in ipairs(allLayers) do
		if lay.name == layerName then
			local outlinecel = lay:cel(app.frame)
			if not outlinecel then return app.alert("(getLayerCel) The layer has no cel in the current frame")
			else return outlinecel end
		end
	end
end

-- get outline cel (layer's name should be "outline")
local out_cel = getLayerCel("outline")
-- app.alert("outline cell X" .. out_cel.position.x)

-- canvas size (square) in pixels
local final_size = 50

-- let's choose a fixed size to add left
local fixed_size = 15

-- outline width in pixels
local outl_width = 11

-- Let's use outline's cel position x value as a fixed reference point. 
-- The actual canvas is trimmed at the largest object in the sketch and so its value depends on the x position of the current object (object to save).
-- It's zero if the object is inside the outline, positive if it's outside.
local outside_left = out_cel.position.x 

-- Let's check if some pixels are outside the outline, right side
local outside_right = spr.bounds.width - outside_left - outl_width 

-- pixels to add left side in new canvas size
local left_space = fixed_size - outside_left

-- pixels to add right side in new canvas size
local right_space = final_size - left_space - outside_left - outl_width - outside_right

-- pixels to add top in new canvas size	
local c_deltay = final_size - spr.bounds.height

-- set canvas size
app.command.CanvasSize {
	  ui=false,
	  left=left_space,
	  top=c_deltay,
	  right=right_space,
	  bottom=0, --bounds=Rectangle,
	  trimOutside=true
	}
	
-- set sprite size (scaling up)
app.command.SpriteSize {
  ui=true,
  -- width=spr.bounds.width,
  -- height=spr.bounds.height,
  scale=20,
  -- scaleX=1.0,
  -- scaleY=1.0,
  lockRatio=false,
  method="nearest"
}

-- re-assign sprite after re-size
spr = app.sprite
if not spr then return app.alert("There's no active sprite after re-size") end

-- alert sprite bounds
spriteBounds()

-- object cel
local cel = layer:cel(app.frame)
if not cel then return app.alert("Obj's layer has no cel in the current frame") end
-- app.alert("cel position=" .. cel.position.x .. "/" .. cel.position.y)

-- object cel image
local obj = cel.image:clone()

local function saveImage(myImage, imgName)
    local dlg = Dialog("Save Image")
    dlg:file{
        id = "filepath",
        title = "Save the image:",
        open = false,
        save = true,
        filetypes = { "png" },
        filename = imgName .. ".png"
    }
    dlg:button{
        text = "Save",
        onclick = function()
            local path = dlg.data.filepath
            if path then
                myImage:saveAs(path)
                dlg:close()
            end
        end
    }
    dlg:button{ text = "Cancel", onclick = function() dlg:close() end }
    dlg:show{ wait = false }
end

-- image
local final_img = Image(spr.bounds.width, spr.bounds.height, obj.colorMode)

-- draw
final_img:drawImage(obj, cel.position)

-- use the group name for the file name
-- local filename = string.gsub(parent.name, "[^%S\n]+", "")

-- save it
saveImage(final_img, layer.name)
-- saveImage(final_img, filename)
