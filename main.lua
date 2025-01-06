#include "ui.lua"
#include "input.lua"
#include "script/Utils.lua"
#include "script/Defs.lua"
#include "script/Types.lua"
#include "script/GameOptions.lua"
#include "script/Init.lua"
#include "script/Simulation.lua"

------------------------------------------------
-- INIT
-------------------------------------------------
infuseMode = false
singlemode = false
reverseMode = false
stickyMode = true

function init()
	RegisterTool(REG.TOOL_KEY, TOOL_NAME, nil, 5)
	SetBool("game.tool."..REG.TOOL_KEY..".enabled", true)
	SetFloat("game.tool."..REG.TOOL_KEY..".ammo", 1000)

	TOOL = createDefaultOptions()
	loadOptions(false)

	spawn_sound = LoadSound("MOD/snd/AddGroup.ogg")
end

-------------------------------------------------
-- TICK 
-------------------------------------------------

function tick(dt)
	handleInput(dt)
	scanBombsTick(dt)
	detonationTick(dt)
	jetTick(dt)
	fireballCalcTick(dt)
	smokeTick(dt)
	simulationTick(dt)
	impulseTick(dt)
	if not canInteract(true, false) then 
		-- anytime the tool is not available or interactable
		plantTimer = 0.1
	end

	if GetString("game.player.tool") == REG.TOOL_KEY then 
		-- events that can happen only in the tool, 
		-- but possibly in a vehicle
		if infuseMode then 
			for i=1, #bombs do
				DrawShapeOutline(bombs[i].shape, 1, 1, 0, 1)
			end
			for i=1, #toDetonate do
				DrawShapeOutline(toDetonate[i].shape, 1, 0, 0, 1)
			end
		end
	end
end

function loadOptions(reset)
	if reset == true then 
		option_set_reset()
	end
	
	TOOL = load_option_set()
	if TOOL == nil then
		TOOL = createDefaultOptions()
		save_option_set(TOOL)
	end
	if TOOL.version ~= CURRENT_VERSION then TOOL = createDefaultOptions() end
end

function canInteract(checkCanUseTool, checkInVehicle)
	return GetString("game.player.tool") == REG.TOOL_KEY 
	and (not checkCanUseTool or GetBool("game.player.canusetool"))  
	and (not checkInVehicle or GetPlayerVehicle() == 0)
end


