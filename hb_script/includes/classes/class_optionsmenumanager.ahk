class OptionsMenuManager {
    ; Member variables
    optionsGui := ""  ; Initialize as empty string
	optionMenuLabels := Array()
    optionFunctionNames := Array()

    __New(optionNames, functionNames) { ; Constructor
        maxLength := 16 ; Adjust this value based on your GUI constraints

        ; Validate parameters
        if (optionNames.Length != functionNames.Length || optionNames.Length > 9) {
            MsgBox("Error: optionMenuLabels and optionFunctionNames must have the same number of elements. And not exceed 9")
            return
        }

        ; Process each option name
        for index, optionName in optionNames {
            ; Clamp the option name if it exceeds the maximum length
            if StrLen(optionName) > maxLength {
                optionName := SubStr(optionName, 1, maxLength) . "..." ; Truncate and add ellipsis
            }

            this.optionMenuLabels.Push(optionName)
            this.optionFunctionNames.Push(functionNames[index])
        }
    }

	; Function to show the dialog
    showOptionsDialog() {
        if (this.optionsGui == "")
        {
            this.optionsGui := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000", "Select an Option")
            this.optionsGui.BackColor := 0xCCFFFFFF

			for index, optionName in this.optionMenuLabels
            {
				BoundFunc := ObjBindMethod(this, "CallFunction", index)
				btn := this.optionsGui.AddButton("w" CtPixel(11.5, "X") " h" CtPixel(1.75, "Y") " Left", optionName).OnEvent("Click", BoundFunc)
            }

            WinSetTransColor(this.optionsGui.BackColor " 150", this.optionsGui)

            ;MouseGetPos &xPos, &yPos ; Get the position of the mouse
            X := CenterX + (CtPixel(SquarePercentageX, "X") / 2)
            Y := CenterY + (CtPixel(SquarePercentageY, "Y") / 2)

            this.optionsGui.Show("x" X " y" Y " NA NoActivate")
        }
        else
        {
            this.DestroyOptionsGUI()
        }
    }

    ; Method to destroy this GUI
    DestroyOptionsGUI() {
		global activeMenuManager

        if this.HasProp("optionsGui") && IsObject(this.optionsGui) {
            this.optionsGui.Destroy()
            this.optionsGui := ""  ; reset the property
        }

		activeMenuManager := ""
    }

	; Method to call the function by index with validation
    CallFunction(index, *) {
        ; Validate index
        if (index < 1 || index > this.optionFunctionNames.Length || !WinActive(WinTitle))
		{
            return
        }

        funcName := this.optionFunctionNames[index]

        this.DestroyOptionsGUI()  

        ; Try to call the function and handle any errors
        try {
            %funcName%.Call()
        } catch as e {
            MsgBox("Error: Failed to execute function '" funcName "'.`n" e.Message)
        }
    }

    ; Method to get the callback function for an option
    GetOptionCallback(n) {
        return this.optionFunctionNames[n]
    }
}