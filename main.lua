#include "script/Utils.lua"
#include "script/Defs.lua"
#include "script/Types.lua"
#include "script/GameOptions.lua"
#include "script/Init.lua"
#include "script/Explosion.lua"
#include "script/Mapping.lua"

------------------------------------------------
-- INIT
-------------------------------------------------
function init()
	RegisterTool(REG.TOOL_KEY, TOOL_NAME, nil, 5)
	SetBool("game.tool."..REG.TOOL_KEY..".enabled", true)
	SetFloat("game.tool."..REG.TOOL_KEY..".ammo", 1000)

	explosions = {}
	plantRate = 0.3
	plantTimer = 0

	TOOL = createDefaultOptions()
	loadOptions(false)
	editingOptions = false
	selectedOption = nil
	selectedIndex = nil
	newOptionValue = nil
	editingValue = ""
	enteredValue = nil
	keypadKeybinds = 
	{
		{"0", "0"},
		{"1", "1"},
		{"2", "2"},
		{"3", "3"},
		{"4", "4"},
		{"5", "5"},
		{"6", "6"},
		{"7", "7"},
		{"8", "8"},
		{"9", "9"},
		{"backspace", "<-"},
		{"delete", "X"},
		{".", "."}
	}

	set_spawn_area_parameters()
	
	spawn_sound = LoadSound("MOD/snd/AddGroup.ogg")
end

-------------------------------------------------
-- Drawing
-------------------------------------------------

function draw()
	if not canInteract(false, true) then return end

	if editingOptions == true then
		drawOptionModal()
	end

	if selectedOption ~= nil then 
		enteredValue = drawValueEntry()
	end

	UiTranslate(0, UiHeight() - UI.OPTION_TEXT_SIZE * 6)
	UiAlign("left")
	UiFont("bold.ttf", UI.OPTION_TEXT_SIZE)
	UiTextOutline(0,0,0,1,0.5)
	UiColor(1,1,1)
	UiText(KEY.PLANT_BOMB.key.." to plant bomb", true)
	UiText(KEY.PLANT_GROUP.key.." to plant 10 randomly around (now: "..#bombs+#toDetonate..")", true)
	UiText(KEY.DETONATE.key.." to detonate", true)
	UiText(KEY.OPTIONS.key.." for options", true)
	UiText(KEY.STOP_FIRE.key.." to stop all explosions")
end

function drawOptionModal()
	local options = TOOL
	UiMakeInteractive()
	UiPush()
		local margins = {}
		margins.x0, margins.y0, margins.x1, margins.y1 = UiSafeMargins()

		local box = {
			width = (margins.x1 - margins.x0) - 100,
			height = (margins.y1 - margins.y0) - 100
		}

		local optionsPerColumn = math.floor((box.height - 100) / 65)

		UiModalBegin()
			UiAlign("left top")
			UiPush()
				-- borders and background
				UiTranslate(UiCenter(), UiMiddle())
				UiAlign("center middle")
				UiColor(1, 1, 1)
				UiRect(box.width + 5, box.height + 5)
				UiColor(0.2, 0.2, 0.2)
				UiRect(box.width, box.height)
			UiPop()
			UiPush()
				UiTranslate(UiCenter(), 100)
				UiFont("bold.ttf", 24)
				UiTextOutline(0,0,0,1,0.5)
				UiColor(1,1,1)
				UiAlign("micenter middle")
				UiText("QBomb Options", true)
				UiFont("bold.ttf", 18)
				UiText("Click a number to change it")
			UiPop()
			UiPush()
				-- options
				UiTranslate(200, 180)
				UiFont("bold.ttf", UI.OPTION_TEXT_SIZE)
				UiTextOutline(0,0,0,1,0.5)
				UiColor(1,1,1)
				UiAlign("left top")
				UiPush()
				for i = 1, #options.options do
					local option = options.options[i]
					drawOption(option)
					if math.fmod(i, optionsPerColumn) == 0 then 
						UiPop()
						UiTranslate(UI.OPTION_CONTROL_WIDTH + 20, 0)
						UiPush()
					else
						UiTranslate(0, 50)
					end
				end
				UiPop()
			UiPop()
			UiPush()
				-- instructions
				UiAlign("center middle")
				UiTranslate(UiCenter(), UiHeight() - 180)
				UiFont("bold.ttf", 24)
				UiTextOutline(0,0,0,1,0.5)
				UiColor(1,1,1)
				UiText("Press [Return/Enter] to save, [Backspace] to cancel, [Delete] to reset to defaults")
			UiPop()

			if newOptionValue == "back" then 
				newOptionValue = nil
				selectedOption = nil
				selectedIndex = nil
			elseif newOptionValue ~= nil and 
				newOptionValue ~= "" and 
				newOptionValue ~= "." and
				newOptionValue ~= "-" and 
				newOptionValue ~= "-." and 
				newOptionValue ~= ".-" then 
				if selectedOption.type == option_type.color then 
					selectedOption.value[selectedIndex] = tonumber(newOptionValue)
				else
					selectedOption.value = tonumber(newOptionValue)
				end
				newOptionValue = nil
				selectedOption = nil
				selectedIndex = nil
			end

			if selectedOption == nil then 
				if InputPressed("return") then 
					save_option_set(options)
					load_option_set(options.name)
					editingOptions = false
				end
				if InputPressed("backspace") then
					load_option_set(options.name)
					editingOptions = false
				end
				if InputPressed("delete") then
					option_set_reset(options.name)
					loadOptions(true)
				end
			end
		UiModalEnd()
	UiPop()
end

function drawOption(option)
	UiPush()
		UiAlign("left")
		UiFont("bold.ttf", UI.OPTION_TEXT_SIZE)
		if option.type == option_type.color then
			UiPush()
			local label = "(H,S,V)"
			UiText(label)
			local labelWidth = UiGetTextSize(label)
			UiTranslate(labelWidth, 0)
			UiPush()
				UiTranslate(22,-4)
				drawBorder(30,20,4)
			UiPop()
			if UiTextButton(round_to_place(option.value[1],2)) then 
				selectedOption = option
				selectedIndex = 1
				editingValue = option.value[1]
			end
			UiTranslate(30,0)
			UiPush()
				UiTranslate(22,-4)
				drawBorder(30,20,4)
			UiPop()
			if UiTextButton(round_to_place(option.value[2],2)) then 
				selectedOption = option
				selectedIndex = 2
				editingValue = option.value[2]
			end
			UiTranslate(30,0)
			UiPush()
				UiTranslate(22,-4)
				drawBorder(30,20,4)
			UiPop()
			if UiTextButton(round_to_place(option.value[3],2)) then 
				selectedOption = option
				selectedIndex = 3
				editingValue = option.value[3]
			end
			UiTranslate(-60 - labelWidth, 5)
			local sampleColor = HSVToRGB(option.value) 
			UiColor(sampleColor[1], sampleColor[2], sampleColor[3])
			UiRect(UI.OPTION_CONTROL_WIDTH, 20)
			UiPop()
			UiTranslate(95 + labelWidth,0)
			UiWordWrap(UI.OPTION_CONTROL_WIDTH - 95)
		else
			UiPush()
				UiPush()
					UiTranslate(20,-4)
					drawBorder(50,20,4)
				UiPop()
				if UiTextButton(round_to_place(option.value, 3), 35, 20) then 
					selectedOption = option
					editingValue = option.value
				end
			UiPop()
			UiTranslate(45,0)
			UiWordWrap(UI.OPTION_CONTROL_WIDTH - 45)
		end
		UiText(" = "..option.friendly_name)
	UiPop()
end

function drawBorder(width, height, thickness)
	UiPush()
	UiAlign("center middle")
	UiColor(0.5,0.5,0.5)
	UiRect(width, height)
	UiColor(0.3, 0.3, 0.3)
	UiRect(width - thickness, height - thickness)
	UiColor(1,1,1)
	UiPop()
end

function drawValueEntry()
	UiMakeInteractive()
	UiPush()
	UiModalBegin()
		for kb=1, #keypadKeybinds do
			local keybind = keypadKeybinds[kb]
			if InputPressed(keybind[1]) then 
				enteredValue = keybind[2]
			end
		end
		UiAlign("left top")
		UiPush()
			-- borders and background
			UiTranslate(UiCenter(), UiMiddle())
			UiAlign("center middle")
			UiColor(1, 1, 1)
			UiRect(505, 505)
			UiColor(0.3, 0.3, 0.3)
			UiRect(500, 500)
		UiPop()
		UiPush()
			UiTranslate(UiCenter(), UiMiddle() - 185)
			UiFont("bold.ttf", 24)
			UiTextOutline(0,0,0,1,0.5)
			UiColor(1,1,1)
			UiAlign("center middle")
			UiText("Enter a new value", true)
		UiPop()
		UiPush()
			UiTranslate(UiCenter() - 50, UiMiddle() - 100)
			drawNumberPanel()

			if enteredValue ~= nil then 
				if enteredValue == "X" then
					editingValue = ""
				elseif enteredValue == "+/-" then
					if string.find(editingValue, "-") == nil then 
						editingValue = "-"..editingValue
					else
						editingValue = string.sub(editingValue, 2, string.len(editingValue))
					end
				elseif enteredValue == "." then
					if string.find(editingValue, "%.") == nil then 
						editingValue = editingValue.."."
					end
				elseif enteredValue == "<-"  then 
					local valueLength = string.len(editingValue)
					if valueLength == 1 then 
						editingValue = ""
					elseif valueLength > 1 then 
						editingValue = string.sub(editingValue, 1, valueLength - 1)
					end
				else
					editingValue = editingValue..enteredValue
				end
				enteredValue = nil
			end
		UiPop()
		UiPush()
			UiAlign("center middle")
			UiTranslate(UiCenter(), UiMiddle() + 160)
			UiFont("bold.ttf", 24)
			UiColor(0.9, 0.9, 0.9)
			UiRect(400, 30)
			UiColor(0, 0, 0)
			UiText(editingValue)
		UiPop()
		UiPush()
			-- instructions
			UiAlign("center middle")
			UiTranslate(UiCenter(), UiMiddle() + 200)
			UiFont("bold.ttf", 20)
			UiTextOutline(0,0,0,1,0.5)
			UiColor(1,1,1)
			UiText("Press [Return/Enter] to save, [Q] to cancel")
		UiPop()

		if InputPressed("return") then 
			newOptionValue = editingValue
			editingValue = ""
		end
		if InputPressed("Q") then
			newOptionValue = "back"
			editingValue = ""
		end


	UiModalEnd()
	UiPop()
end

function drawNumberPanel()
	UiPush()
		UiAlign("left top")
		UiFont("bold.ttf", 24)
		
		makeEntryButton("1")
		UiTranslate(50,0)

		makeEntryButton("2")
		UiTranslate(50,0)

		makeEntryButton("3")
		UiTranslate(-100,50)

		makeEntryButton("4")
		UiTranslate(50,0)

		makeEntryButton("5")
		UiTranslate(50,0)

		makeEntryButton("6")
		UiTranslate(-100,50)

		makeEntryButton("7")
		UiTranslate(50,0)

		makeEntryButton("8")
		UiTranslate(50,0)

		makeEntryButton("9")
		UiTranslate(-100,50)

		makeEntryButton("+/-")
		UiTranslate(50,0)

		makeEntryButton("0")
		UiTranslate(50,0)

		makeEntryButton(".")
		UiTranslate(-75,60)

		makeEntryButton("<-")
		UiTranslate(50,0)

		makeEntryButton("X")
	UiPop()


end

function makeEntryButton(value)
	UiPush()
		UiAlign("center middle")
		UiColor(0.5, 0.3, 0.3)
		UiRect(50, 50)

		UiColor(1, 1, 1)
		if UiTextButton(value, 50, 50) then 
			enteredValue = value
		end
	UiPop()
end

-------------------------------------------------
-- TICK 
-------------------------------------------------

function tick(dt)
	handleInput(dt)
	explosionTick(dt)
	if not canInteract(true, false) then 
		plantTimer = 0.5
	end
end

-------------------------------------------------
-- Input handler
-------------------------------------------------

function handleInput(dt)
	if editingOptions == true then return end
	plantTimer = math.max(plantTimer - dt, 0)

	if GetString("game.player.tool") == REG.TOOL_KEY then
		-- options menus
		if InputPressed(KEY.OPTIONS.key) 
		and GetPlayerVehicle() == 0 then 
			editingOptions = true
		else
			if GetPlayerVehicle() == 0 then 
				-- plant bomb
				if GetPlayerGrabShape() == 0 and
					plantTimer == 0 and
					InputDown(KEY.PLANT_BOMB.key) then
					local camera = GetPlayerCameraTransform()
					local shoot_dir = TransformToParentVec(camera, Vec(0, 0, -1))
					local hit, dist, normal, shape = QueryRaycast(camera.pos, shoot_dir, 100, 0, true)
					if hit then 
						local drop_pos = VecAdd(camera.pos, VecScale(shoot_dir, dist))
						local bomb = Spawn("MOD/prefab/Decoder.xml", Transform(drop_pos), false, true)[2]
						table.insert(bombs, bomb)
						plantTimer = plantRate
					end
				end

				if InputPressed(KEY.STOP_FIRE.key) then
					-- stop all explosions and cancel bomb
					for i=1, #explosions do
						local explosion = explosions[i]
						explosion.sparks = {} 
					end	
				end

				-- plant a group around the map
				if InputPressed(KEY.PLANT_GROUP.key) then 
					local player_trans = GetPlayerTransform()
					PlaySound(spawn_sound, player_trans.pos, 50)
					for i = 1, 10 do
						local spawnPos = find_spawn_location()
						if spawnPos ~= nil then 
							local trans = Transform(spawnPos) --, QuatEuler(math.random(0,359),math.random(0,359),math.random(0,359)))
							local bomb = Spawn("MOD/prefab/Decoder.xml", trans, false, true)[2]
							table.insert(bombs, bomb)
						end					
					end
				end
			end
		end
		
		-- detonate
		if InputPressed(KEY.DETONATE.key) and
		GetPlayerGrabShape() == 0 then
			detonateAll()
		end
	end
end

-------------------------------------------------
-- Support functions
-------------------------------------------------

function loadOptions(reset)
	if reset == true then 
		option_set_reset()
	end
	
	TOOL = load_option_set()
	if TOOL == nil then
		TOOL = createDefaultOptions()
		save_option_set(TOOL)
	end
end

function canInteract(checkCanUseTool, checkInVehicle)
	return GetString("game.player.tool") == REG.TOOL_KEY 
	and (not checkCanUseTool or GetBool("game.player.canusetool"))  
	and (not checkInVehicle or GetPlayerVehicle() == 0)
end


