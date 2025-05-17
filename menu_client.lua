------------------------------------------------------------------------
--              IV Menu exemple By LeChapellierFou                    --
--                  Created for HappinessMP                           -- 
--               Check My Github for more informations                --
--                        18/05/2025                                  --
------------------------------------------------------------------------

--[[
    # Events
    Events.Call("Open_IVMenu", {MenuID})
    Events.Call("Close_IVMenu", {})

    # Public Variables 
    IVMenu.ItemCore.menu_level
    IVMenu.ItemCore.isOpen
    IVMenu.ItemCore.last_selected[lvl]
    IVMenu.ItemCore.menu_level
    IVMenu.ItemCore.menu_len
    IVMenu.ItemCore.footer
    IVMenu.ItemCore.title
    IVMenu.ItemCore.value

    # Public Function
    IVMenu.ItemType.add_item
    IVMenu.ItemType.add_value
    IVMenu.ItemType.add_boolean
    IVMenu.ItemType.add_title
    IVMenu.ItemType.add_submenu
]]

-- Variables
local boolean_Test = true
local Number_test = 10
local Float_test = 20.1234

-- Ganerate random Menu id
local MenuID = Game.GenerateRandomIntInRange(1, 10000)


Events.Subscribe("IVMenu_Setup_"..MenuID, function() 

    IVMenu.ItemCore.menu_len = 0
    
    IVMenu.ItemCore.title = "IVMenu v1.0"

    if (IVMenu.ItemCore.menu_level == 0) then
        IVMenu.ItemCore.footer = "Main"
        
        IVMenu.ItemType.add_item("Item")
        IVMenu.ItemType.add_value("Number", Number_test)
        IVMenu.ItemType.add_value("Float", Float_test)
        IVMenu.ItemType.add_boolean("Boolean", boolean_Test)
        IVMenu.ItemType.add_title("Title")
        IVMenu.ItemType.add_submenu("Submenu")
	IVMenu.ItemType.add_submenu("Credits")
    elseif (IVMenu.ItemCore.menu_level == 1) then
        if(IVMenu.ItemCore.last_selected[0] == 6) then -- Submenu level 1
            IVMenu.ItemCore.footer = "Submenu"
            
            IVMenu.ItemType.add_boolean("Boolean", true)
            IVMenu.ItemType.add_item("Test 2")
            IVMenu.ItemType.add_item("Test 3")
            IVMenu.ItemType.add_value("Number", 5)
            IVMenu.ItemType.add_item("Test 5")
            IVMenu.ItemType.add_item("Test 6")
            IVMenu.ItemType.add_boolean("Boolean", true)
            IVMenu.ItemType.add_submenu("Submenu") -- 8
            IVMenu.ItemType.add_item("Test 9")
            IVMenu.ItemType.add_item("Test 10")
            IVMenu.ItemType.add_item("Test 11")
            IVMenu.ItemType.add_title("Title")
            IVMenu.ItemType.add_item("Test 13")
            IVMenu.ItemType.add_boolean("Boolean", false)
            IVMenu.ItemType.add_item("Test 15")
            IVMenu.ItemType.add_boolean("Boolean", false)
            IVMenu.ItemType.add_item("Test 17")
            IVMenu.ItemType.add_value("Float", 1582.2548)
            IVMenu.ItemType.add_item("Test 19")
            IVMenu.ItemType.add_boolean("Boolean", true)
	elseif(IVMenu.ItemCore.last_selected[0] == 7) then -- credits
		IVMenu.ItemCore.footer = "Credits"

		IVMenu.ItemType.add_title("By LeChapellierFou")
        end
    elseif (IVMenu.ItemCore.menu_level == 2) then
        if(IVMenu.ItemCore.last_selected[0] == 6) then -- Submenu level 1
            if(IVMenu.ItemCore.last_selected[1] == 8) then -- Submenu level 2
                IVMenu.ItemType.add_item("Test 1")
                IVMenu.ItemType.add_item("Test 2")
                IVMenu.ItemType.add_item("Test 3")
            end
        end
    end
    
end, true)

Events.Subscribe("IVMenu_function_"..MenuID, function(I) 
    local RockstarId = Player.GetRockstarID()
    local playerId = Game.GetPlayerId()
    local playerChar = Game.GetPlayerChar(playerId)
    local name = Game.GetPlayerName(playerId)

    
    if (IVMenu.ItemCore.menu_level == 0) then
        if(I == 1) then -- add_item
            Game.PrintStringWithLiteralStringNow("STRING", "Test item", 2500, true)
        elseif(I == 2) then -- add_value
            Number_test = IVMenu.ItemCore.value[I]
            Game.PrintStringWithLiteralStringNow("STRING", "Number : "..Number_test, 2500, true)
        elseif(I == 3) then -- add_value
            Float_test = IVMenu.ItemCore.value[I]
            Game.PrintStringWithLiteralStringNow("STRING", "Float : "..Float_test, 2500, true)
        elseif(I == 4) then -- add_boolean
            --do_toggle(boolean_Test)
            if(not boolean_Test) then 
                boolean_Test = true
            else
                boolean_Test = false
            end
        end
    end
end, true)

Events.Subscribe("scriptInit", function()
	Thread.Create(function()
        while true do 
            Thread.Pause(0)
            
            if ( Game.IsGameKeyboardKeyJustPressed(63)) then -- F5
                Events.Call("Open_IVMenu", {MenuID})
            end 
        end
	end)
end)
