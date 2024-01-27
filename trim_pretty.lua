-- This script exports single layer for outlined pixel art
-- by Lorenzo Quaglieri

-- crops selection (needs a selection)
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

-- canvas size variables for resizing
local final_size = 50

-- fixed size to add 
local fixed_size = 15

-- outline width in pixels
local outl_width = 11

-- delta between most west point x and outline position.x
local delta_left = out_cel.position.x 

-- delta between most east point x and outline position.x
local delta_right = spr.bounds.width - delta_left - outl_width 

-- pixels to add left in new canvas size
local left_size = fixed_size - delta_left

-- pixels to add right in new canvas size
local right_size = final_size - left_size - delta_left - outl_width - delta_right

-- pixels to add top in new canvas size	
local c_deltay = final_size - spr.bounds.height

-- set canvas size
app.command.CanvasSize {
	  ui=false,
	  left=left_size,
	  top=c_deltay,
	  right=right_size,
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

final_img:drawImage(obj, cel.position)

parent = string.gsub(parent.name, "[^%S\n]+", "")
-- saveImage(final_img, layer.name)
saveImage(final_img, parent)
