------------------------------------------------------------------------
--            IV Menu exemple By LeChapellierFou              	      --
--                 Created for HappinessMP                     	      -- 
--            Check My Github for more informations           	      --
--                      19/02/2025                                    --
--		      Parts of IVMenu				      --					  --
------------------------------------------------------------------------

function Print(text, time)
	Game.ClearPrints()
    if (time == nil) then 
	    Game.PrintStringWithLiteralStringNow("STRING", text, 1000, 1)
    else
	    Game.PrintStringWithLiteralStringNow("STRING", text, time, 1)
    end
end

-- From Red Rp Converted to HappinessMP
IsCursorInAreaLeftTopCenter = function(x, y, width, height)
    local mouseX,mouseY = Game.GetMousePosition()
	local point1x = x
	local point1y = y
	local point2x = x + width
	local point2y = y + height
	if(mouseX>=point1x and mouseX<=point2x and mouseY>=point1y and mouseY<=point2y) then
		return true
	else
		return false
	end
end

-- From Red Rp Converted to HappinessMP
function DrawRectLeftTopCenter(x, y, width, height, r, g, b, a)
	Game.DrawRect(x+width/2, y+height/2, width, height, r, g, b, a)
end

-- From Red Rp Converted to HappinessMP
GetStringWithoutSpaces = function(text)
	local newstring = ""
	for i=1,#text,1 do
		local tempchar = text:sub(i, i)
		if(tempchar == " ") then
			newstring = "" .. newstring .. "_"
		else
			newstring = "" .. newstring .. "" .. tempchar
		end
	end
	return newstring
end
