class CommandInfo {
	; Member variables
	HotKeyName := ""
	InputCommand := ""

    __New(aKey, aCommand) { ; Constructor
        this.HotKeyName := aKey
        this.InputCommand := aCommand

        try {
            Hotkey(this.HotKeyName, DoNothing)
        } catch ValueError {
            return
        }

		if (this.InputCommand == "") {
			return
		}

        ; Detect if it looks like a function call (e.g. "EquipItem([1,2])")
        if RegExMatch(this.InputCommand, "^(?<func>\w+)\((?<args>.*)\)$", &match) {
			funcName := match.func
			argsRaw := Trim(match.args)

			args := this.ParseArgs(argsRaw)
			Hotkey(this.HotKeyName, (*) => %funcName%(args*))
		} else {
            ; Treat as Send command
            if InStr(this.InputCommand, "{") {
				Hotkey(this.HotKeyName, this.SendCommand.Bind(this))
			}
			else {
				funcRef := %this.InputCommand%.Bind()

				if IsObject(funcRef) && funcRef.HasMethod("Call")
				{
					Hotkey(this.HotKeyName, funcRef) ; .call()
				}
			}
        }
    }

    SendCommand(*) {
        if WinActive(WinTitle) {
            Send(this.InputCommand)
        }
    }

	ParseArgs(argString) {
		argString := Trim(argString)
		if (argString = "")
			return []

		; If wrapped in [ ], treat as an array list
		if (SubStr(argString, 1, 1) = "[" && SubStr(argString, -1) = "]") {
			inner := SubStr(argString, 2, StrLen(argString)-2)  ; <-- correct length
			out := []
			for v in StrSplit(inner, ",")
				out.Push(Trim(v))
			return [out]
		}

		; Otherwise, normal comma-separated list
		out := []
		for v in StrSplit(argString, ",")
			out.Push(Trim(v))
		return out
	}
}