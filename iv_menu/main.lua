------------------------------------------------------------------------
--              IV Menu exemple By LeChapellierFou                    --
--                  Created for HappinessMP                           -- 
--               Check My Github for more informations                --
--                        13/05/2025                                  --
------------------------------------------------------------------------
-- Variables menu
local menu_posX = 0
local menu_posY = 0
local offsetToCenterX = 0.1950
local offsetToCenterY = -0.2640
local item_select = 1
local item_name = {}
local Submenu = {}
local typeM = {}
local InError = false
local MenuID = 0
local TimerA = 0
local ItemType = { -- tables type of items
    SubI = 1,
    ValI = 2,
    BoolI = 3,
    TitleI = 4
}
-- texture from gta iv files
local ComputerDict = nil
local NetworkDict = nil

-- scrolling système
local scroll_pos_y, const_scroll_pos_y -- default
local consts_start_scroll = 11 -- default
local item_start_scroll = 11 -- start scrolling
local scrolling = true -- lock scrolling items at value

--------------------------
--     Table IVMenu   --
-------------------------- 

IVMenu = {
    ItemCore = {
        isOpen = false,
        last_selected = {},
        menu_level = 0,
        menu_len = 0,
        footer = "",
        title = "",
        value = {}
    },

    ItemType = {
        -- display submenu
        add_submenu = function(text) 
            IVMenu.ItemCore.menu_len = IVMenu.ItemCore.menu_len + 1 -- item count
            item_name[IVMenu.ItemCore.menu_len] = text -- string text
            Submenu[IVMenu.ItemCore.menu_len] = false -- boolean submenu
            typeM[IVMenu.ItemCore.menu_len] = ItemType.SubI -- display item type
        end,

        -- Display item 
        add_item = function(text) 
            IVMenu.ItemCore.menu_len = IVMenu.ItemCore.menu_len + 1
            item_name[IVMenu.ItemCore.menu_len] = text
            Submenu[IVMenu.ItemCore.menu_len] = true
            typeM[IVMenu.ItemCore.menu_len] = 0
        end,

        -- display item with number
        add_value = function(text, val, max)
            IVMenu.ItemCore.menu_len = IVMenu.ItemCore.menu_len + 1
            item_name[IVMenu.ItemCore.menu_len] = text
            Submenu[IVMenu.ItemCore.menu_len] = true
            IVMenu.ItemCore.value[IVMenu.ItemCore.menu_len] = val
            typeM[IVMenu.ItemCore.menu_len] = 2
        end,

        -- Display item with boolean (ON/OFF)
        add_boolean = function(text, act) 
            IVMenu.ItemCore.menu_len = IVMenu.ItemCore.menu_len + 1
            item_name[IVMenu.ItemCore.menu_len] = text
            Submenu[IVMenu.ItemCore.menu_len] = true
            IVMenu.ItemCore.value[IVMenu.ItemCore.menu_len] = act
            typeM[IVMenu.ItemCore.menu_len] = 3 
        end,

        -- Display item Title
        add_title = function(text) 
            IVMenu.ItemCore.menu_len = IVMenu.ItemCore.menu_len + 1
            item_name[IVMenu.ItemCore.menu_len] = text
            Submenu[IVMenu.ItemCore.menu_len] = true
            typeM[IVMenu.ItemCore.menu_len] = 4
        end
    }
}

--------------------------
--  Functions menu      --
--------------------------

function Move_menu()

	Game.SetTextFont(0)
	Game.SetTextScale(0.35, 0.35)
	Game.SetTextColour(255, 0, 0, 255)
	Game.DisplayTextWithFloat(0.5, 0.80, "NUMBR", tonumber(offsetToCenterX), 4)

	Game.SetTextFont(0)
	Game.SetTextScale(0.35, 0.35)
	Game.SetTextColour(255, 0, 0, 255)
	Game.DisplayTextWithFloat(0.5, 0.85, "NUMBR", tonumber(offsetToCenterY), 4)

	if Game.IsGameKeyboardKeyPressed(203) then --left
		offsetToCenterX = offsetToCenterX - 0.001
	elseif Game.IsGameKeyboardKeyPressed(205) then -- right
		offsetToCenterX = offsetToCenterX + 0.001
	elseif Game.IsGameKeyboardKeyPressed(200) then -- up
		offsetToCenterY = offsetToCenterY - 0.001
	elseif Game.IsGameKeyboardKeyPressed(208) then -- down
		offsetToCenterY = offsetToCenterY + 0.001
	end
end

function IVMenu_startup(menuid)

	local sx, sy = Game.GetScreenResolution()
	menu_posX = (sx / 2) / sx + offsetToCenterX
	menu_posY = (sy / 2) / sy + offsetToCenterY
    
    IVMenu.ItemCore.menu_len = 0
    IVMenu.ItemCore.footer = ""
	item_select = 1
    scroll_pos_y = menu_posY
    const_scroll_pos_y = menu_posY
    Events.Call("IVMenu_Setup_"..menuid, {})
    if(ComputerDict == nil) then 
        ComputerDict = Game.LoadTxd("computer")
    end
    if(NetworkDict == nil) then 
        NetworkDict = Game.LoadTxd("network")
    end
    IVMenu.ItemCore.isOpen = true
    Game.SetCamActive(Game.GetGameCam(), false)
    Game.SetPlayerControl(Game.GetPlayerId(), false)
    Game.SetGameCameraControlsActive(false)
end

function IVMenu_shutdown()
    IVMenu.ItemCore.isOpen = false
    MenuID = 0

    for i=1, IVMenu.ItemCore.menu_len, 1 do 
        if(item_name[i] ~= nil) then 
            item_name[i] = nil
        end
        if(Submenu[i] ~= nil) then 
            Submenu[i] = nil
        end
        if(typeM[i] ~= nil) then 
            typeM[i] = nil
        end
    end

    IVMenu.ItemCore.menu_level = 0
    IVMenu.ItemCore.menu_len = 0
    IVMenu.ItemCore.footer = ""
    item_select = 1
    scroll_pos_y = const_scroll_pos_y
    item_start_scroll = consts_start_scroll

    if(ComputerDict ~= nil) then 
        Game.RemoveTxd(ComputerDict)
        ComputerDict = nil
    end

    if(NetworkDict ~= nil) then 
        Game.RemoveTxd(NetworkDict)
        NetworkDict = nil
    end
	
    TimerA = Game.GetGameTimer();
end

Events.Subscribe("Open_IVMenu", function(menuid)
    if (not IVMenu.ItemCore.isOpen) then
        if(menuid > 0) then 
            MenuID = menuid 
            IVMenu_startup(MenuID)
        end
    end
end, true)

Events.Subscribe("Close_IVMenu", function()
   
    if (IVMenu.ItemCore.isOpen) then
        IVMenu_shutdown()
    end
end, true)

--------------------------
--    Core menu         -- 
--------------------------

function IVMenuDraw(items, title, title2)
    local correction_x
	--[[ Add this for move menu, use only offsetToCenterX & offsetToCenterY
		Move_menu()
		local sx, sy = Game.GetScreenResolution()
		menu_posX = (sx / 2) / sx + offsetToCenterX
		menu_posY = (sy / 2) / sy + offsetToCenterY
		scroll_pos_y = menu_posY
		const_scroll_pos_y = menu_posY
	]]

    -- titre
    Game.SetTextScale(0.200000,  0.300000)
    Game.SetTextDropshadow(0, 0, 0, 0, 0)
    Game.SetTextFont(3)
    Game.SetTextColour(255, 255, 255, 255)
    Game.DisplayTextWithLiteralString(menu_posX + 0.0500, menu_posY - 0.0760, "STRING", GetStringWithoutSpaces(""..title))    

    -- titre submenu
    Game.SetTextScale(0.200000,  0.3500000)
    Game.SetTextDropshadow(0, 0, 0, 0, 0)
    Game.SetTextFont(3)
    Game.SetTextColour(255, 255, 255, 255)
    Game.DisplayTextWithLiteralString(menu_posX+0.005, menu_posY - 0.0260, "STRING", GetStringWithoutSpaces(""..title2))

    -- nombre d'item / item max
    Game.SetTextScale(0.200000,  0.2500000)
    Game.SetTextDropshadow(0, 0, 0, 0, 0)
    Game.SetTextFont(3)
    Game.SetTextColour(255, 255, 255, 255)
    if(IVMenu.ItemCore.menu_len > 9) then 
        correction_x = 0.1630
    elseif(IVMenu.ItemCore.menu_len > 99) then 
        correction_x = 0.1530
    else
        correction_x = 0.1730
    end
    Game.DisplayTextWithLiteralString(menu_posX+correction_x, menu_posY - 0.0210, "STRING", ""..item_select.."/"..IVMenu.ItemCore.menu_len)
                    
    DrawRectLeftTopCenter(menu_posX, menu_posY - 0.1060, 0.2, 0.0770, 0, 0, 100, 255)-- blue
    DrawRectLeftTopCenter(menu_posX, menu_posY - 0.0290, 0.2, 0.3/10, 0, 0, 0, 255)

    for i=1,IVMenu.ItemCore.menu_len,1 do
        if (i <= item_start_scroll and (scroll_pos_y+0.3/10*(i-1)+0.005 > const_scroll_pos_y) ) then 
            local item_text = items[i]

            if(IsCursorInAreaLeftTopCenter(menu_posX, scroll_pos_y+0.3/10*(i-1), 0.2, 0.3/10) and not InError and typeM[i] ~= ItemType.TitleI) then
                DrawRectLeftTopCenter(menu_posX, scroll_pos_y+0.3/10*(i-1), 0.2, 0.3/10, 255, 255, 255, 255)
                item_select = i
                Game.SetTextColour(0, 0, 0, 255)

                if(typeM[i] ~= ItemType.ValI) then
                    scrolling = true
                else
                    scrolling = false
                end

                if(Game.IsMouseButtonJustPressed(1)) then
                    if Submenu[i] then
                        Events.Call("IVMenu_function_"..MenuID, {i})
                        Events.Call("IVMenu_Setup_"..MenuID, {})
                    else
                        -- next level
                        IVMenu.ItemCore.last_selected[IVMenu.ItemCore.menu_level] = i
                        IVMenu.ItemCore.menu_level = IVMenu.ItemCore.menu_level + 1
                        -- reset scrolling
                        scroll_pos_y = const_scroll_pos_y
                        item_start_scroll = consts_start_scroll
                        item_select = 1
                        Events.Call("IVMenu_Setup_"..MenuID, {})
                    end
                end
            else
                DrawRectLeftTopCenter(menu_posX, scroll_pos_y+0.3/10*(i-1), 0.2, 0.3/10, 0, 0, 0, 150)
                Game.SetTextColour(255, 255, 255, 255)
            end
            
            Game.SetTextFont(3)
            Game.SetTextScale(0.1700000,  0.3000000)
            Game.SetTextDropshadow(0, 0, 0, 0, 0)
            Game.DisplayTextWithLiteralString(menu_posX+0.005, scroll_pos_y+0.3/10*(i-1)+0.005, "STRING", "" .. item_text)

            
            if(typeM[i] == ItemType.SubI) then -- display submenu
                Game.SetTextFont(3)
                Game.SetTextScale(0.1500000,  0.3000000)
                Game.SetTextDropshadow(0, 0, 0, 0, 0)
                if(IsCursorInAreaLeftTopCenter(menu_posX, scroll_pos_y+0.3/10*(i-1), 0.2, 0.3/10) and not InError) then
                    Game.SetTextColour(0, 0, 0, 255)
                else
                    Game.SetTextColour(255, 255, 255, 255)
                end
                Game.DisplayTextWithLiteralString(menu_posX+0.1910, scroll_pos_y+0.3/10*(i-1)+0.0050, "STRING", ">")
            elseif(typeM[i] == ItemType.ValI) then -- display value
                Game.SetTextFont(3)
                Game.SetTextScale(0.1500000,  0.3000000)
                Game.SetTextDropshadow(0, 0, 0, 0, 0)
                if(IsCursorInAreaLeftTopCenter(menu_posX, scroll_pos_y+0.3/10*(i-1), 0.2, 0.3/10) and not InError) then
                    Game.SetTextColour(0, 0, 0, 255)
                else
                    Game.SetTextColour(255, 255, 255, 255)
                end

                if(IVMenu.ItemCore.value[i] == math.floor(IVMenu.ItemCore.value[i])) then
                    Game.DisplayTextWithNumber(menu_posX+0.1800, scroll_pos_y+0.3/10*(i-1)+0.0070, "NUMBR", IVMenu.ItemCore.value[i]) -- number
                else
                    Game.DisplayTextWithFloat(menu_posX+0.1570, scroll_pos_y+0.3/10*(i-1)+0.0070, "NUMBR", IVMenu.ItemCore.value[i], 4) -- float
                end

                if(IsCursorInAreaLeftTopCenter(menu_posX, scroll_pos_y+0.3/10*(i-1), 0.2, 0.3/10) and not InError) then
                    if Game.GetMouseWheel() > 0 then
                        if(IVMenu.ItemCore.value[i] == math.floor(IVMenu.ItemCore.value[i])) then
                            IVMenu.ItemCore.value[i] = IVMenu.ItemCore.value[i] + 1
                        else
                            IVMenu.ItemCore.value[i] = IVMenu.ItemCore.value[i] + 0.1
                        end
                    end

                    if Game.GetMouseWheel() < 0 then
                        if(IVMenu.ItemCore.value[i] > 0) then 
                            if(IVMenu.ItemCore.value[i] == math.floor(IVMenu.ItemCore.value[i])) then
                                IVMenu.ItemCore.value[i] = IVMenu.ItemCore.value[i] - 1
                            else
                                IVMenu.ItemCore.value[i] = IVMenu.ItemCore.value[i] - 0.1
                            end
                        else
                            IVMenu.ItemCore.value[i] = 0
                        end
                    end
                end

            elseif(typeM[i] == ItemType.BoolI) then
                if(NetworkDict ~= nil) then 
                    local texture1 = Game.GetTexture(NetworkDict,"icon_w_notconnected")
                    local texture2 = Game.GetTexture(NetworkDict,"icon_w_tasks_completed")

                    if(IVMenu.ItemCore.value[i] == false) then 
                        Game.DrawSprite(texture1, menu_posX + 0.1880, scroll_pos_y + 0.3/10*(i-1) + 0.0140, 0.0180, 0.0180, 0, 255, 0, 0, 255) -- red
                    else
                        Game.DrawSprite(texture2, menu_posX + 0.1880, scroll_pos_y + 0.3/10*(i-1) + 0.0140, 0.0180, 0.0180, 0, 0, 255, 0, 255) -- green
                    end
                end
            end
        end
    end 
    
    -- fin du menu
    if (IVMenu.ItemCore.menu_len >= consts_start_scroll+1) then 
        if(NetworkDict ~= nil) then 
            DrawRectLeftTopCenter(menu_posX, const_scroll_pos_y + (0.3/10*11) , 0.2, 0.3/10, 0, 0, 0, 255)
            local texture = Game.GetTexture(NetworkDict,"icon_w_arrow_updown")
            Game.DrawSprite(texture, menu_posX + 0.0950, const_scroll_pos_y + (0.3/10*11) + 0.0140, 0.0140, 0.0230,0,255,255,255,255)
        end
    end
    
    -- back
    if(Game.IsMouseButtonJustPressed(2)) then
        if IVMenu.ItemCore.menu_level > 0 then
            IVMenu.ItemCore.menu_level = IVMenu.ItemCore.menu_level - 1
            scroll_pos_y = const_scroll_pos_y
            item_start_scroll = consts_start_scroll
            item_select = 1
            InError = false	
            Events.Call("IVMenu_Setup_"..MenuID, {})
        else
            IVMenu_shutdown()
        end
    end

    if (scrolling and not InError) then 
        if Game.GetMouseWheel() > 0 then
            if (IVMenu.ItemCore.menu_len > consts_start_scroll and item_start_scroll <= IVMenu.ItemCore.menu_len-1) then
                scroll_pos_y = scroll_pos_y - 0.0300
                item_start_scroll = item_start_scroll + 1
                --Print("Down")
            end			
        end
        
        if Game.GetMouseWheel() < 0 then
            if (IVMenu.ItemCore.menu_len > consts_start_scroll+1 and scroll_pos_y < const_scroll_pos_y) then
                scroll_pos_y = scroll_pos_y + 0.0300
                item_start_scroll = item_start_scroll - 1
                --Print("Up")
            end
        end
    end
end

-- main IVMenu & display mouse
Events.Subscribe("scriptInit", function()

	Thread.Create(function()
		while true do
			Thread.Pause(0)

            if (IVMenu.ItemCore.isOpen and not Game.IsPauseMenuActive()) then
                
                IVMenuDraw(item_name, IVMenu.ItemCore.title, IVMenu.ItemCore.footer) 
                
                -- Display mouse on screen
                local mx, my = Game.GetMousePosition()
                local sx, sy = Game.GetScreenResolution()

				-- Vérifie si la souris est en dehors de l'écran (version adaptée à la résolution)
				if(mx * sx > sx - 1 or my * sy > sy - 1) then
                else
                    if(ComputerDict ~= nil) then 
						local scaleX = 0.04 * (sx / 1920) -- default 1080p
						local scaleY = 0.06 * (sy / 1080)
						
                        local texture = Game.GetTexture(ComputerDict,"mousepointer")
                        Game.DrawSprite(texture, mx, my, scaleX, scaleY,0,255,255,255,255)
                    end
                end
            end
			
			if (TimerA ~= 0) then 
                local TimerB = Game.GetGameTimer();
                if ((TimerB - TimerA) > 100) then 
                    Game.SetCamActive(Game.GetGameCam(), true)
                    Game.SetPlayerControl(Game.GetPlayerId(), true)
					Game.SetGameCameraControlsActive(true)
                    TimerA = 0
                end
            end
		end
	end)
end)
