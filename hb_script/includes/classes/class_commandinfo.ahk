class CommandInfo {
	; Member variables
	HotKeyName := ""
	InputCommand := ""

    __New(aKey, aCommand) { ; Constructor
        this.HotKeyName := aKey
        this.InputCommand := aCommand

		try
		{
			Hotkey(this.HotKeyName, DoNothing)
		}
		catch ValueError
		{
			return
		}
		else
		{
			if InStr(this.InputCommand, "{")
			{
				Hotkey(this.HotKeyName, this.SendCommand.Bind(this))
			}
			else
			{
				funcRef := %this.InputCommand%.Bind()

				if IsObject(funcRef) && funcRef.HasMethod("Call")
				{
					Hotkey(this.HotKeyName, funcRef) ; .call()
				}
			}
		}
    }

	SendCommand(*) {

		if WinActive(WinTitle) ; This supposedly stops the hotkey from working outside of the HB client
		{
			Send this.InputCommand
		}
	}
}