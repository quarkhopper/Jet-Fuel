#include "script/Utils.lua"
#include "script/Defs.lua"
#include "script/Types.lua"
#include "script/GameOptions.lua"
#include "script/Init.lua"
#include "script/Simulation.lua"

function draw()
	if not canInteract(false, true) then return end

	if editingOptions == true then
		drawOptionModal()
	end

	if selectedOption ~= nil then 
		enteredValue = drawValueEntry()
	end

	drawLegend()
end

function drawLegend()
	local infuseString = 'off'
	if infuseMode then infuseString = 'on' end
	local singleString = 'off'
	if singleMode then singleString = 'on' end
	local stickyString = 'off'
	if stickyMode then stickyString = 'on' end
	local orderString = 'normal'
	if reverseMode then orderString = 'reverse' end

	UiFont("bold.ttf", UI.LEGEND_TEXT_SIZE)
	UiTextOutline(0,0,0,1,0.5)
	UiColor(1,1,1)

	UiPush()
		UiTranslate(0, UI.LEGEND_TEXT_SIZE + 2)

		UiPush()
			UiAlign("left")
			for i=1, #keybind_options do
				option = keybind_options[i]
				local keybindString = "["..option.key.." "..option.name.."]"
				local textWidth = UiGetTextSize(keybindString)
				UiText(keybindString, true)
				-- UiTranslate(textWidth + 5, 0)
			end
		UiPop()

		UiPush()
			UiAlign("right")
			UiTranslate(UiWidth() - 5, 0)
			UiText("[INFUSE: "..infuseString.."]", true)
			UiText("[SINGLE: "..singleString.."]", true)
			UiText("[ORDER: "..orderString.."]", true)
			UiText("[STICKY: "..stickyString.."]", true)
		UiPop()
	UiPop()

	UiPush()
		UiTranslate(0, UiHeight() - 2)
		UiAlign("left")
		UiText("Total sparks: "..#allSparks, true)
	UiPop()

	UiPush()
		UiTranslate(UiWidth() - 5, UiHeight() - UI.LEGEND_TEXT_SIZE - 2)
		UiAlign("right")
	UiText("Explosive count: "..(#bombs + #toDetonate), true)
	UiText("Jet count: "..(#jets + #activeJets))
UiPop()

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
				UiTranslate(UiCenter(), 200)
				UiFont("bold.ttf", 24)
				UiTextOutline(0,0,0,1,0.5)
				UiColor(1,1,1)
				UiAlign("center middle")
				UiText("Jet Fuel", true)
				UiFont("bold.ttf", 18)
				UiText("Click a number to change it")
			UiPop()
			UiPush()
				-- options
				UiTranslate(200, 300)
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
				UiTranslate(UiCenter(), UiMiddle() + (box.height / 2 - 50))
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
				if selectedOption.type == option_type.color or selectedOption.type == option_type.vec then 
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

function drawOption(option, borderColor)
	borderColor = borderColor or Vec()
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
		elseif option.type == option_type.vec then
			UiPush()
			local label = "(X,Y,Z)"
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
			UiPop()
			UiTranslate(95 + labelWidth,0)
			UiWordWrap(UI.OPTION_CONTROL_WIDTH - 95)
		else
			UiPush()
				UiPush()
					UiTranslate(20,-4)
					local doHighlight = option.key == "bombSparks" or option.key == "bombEnergy" or option.key == "sparksSimulation"
					drawBorder(60,20,4,doHighlight)
				UiPop()
				if UiTextButton(round_to_place(option.value, 4), 35, 20) then 
					selectedOption = option
					editingValue = option.value
				end
			UiPop()
			UiTranslate(55,0)
			UiWordWrap(UI.OPTION_CONTROL_WIDTH - 50)
		end
		UiText(" = "..option.friendly_name)
	UiPop()
end

function drawBorder(width, height, thickness, doHighlight)
	UiPush()
	UiAlign("center middle")
	if doHighlight then 
		UiColor(1, 1, 0)
	else
		UiColor(0.5,0.5,0.5)
	end
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
			UiText("Press [S] to save, [Q] to cancel")
		UiPop()

		if InputPressed("S") then 
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


