class HotkeyUnbindClass {
	; Unbind keys to prevent unintended typing during combat.
	; Rebind keys for spells (e.g., q to a spell) later in script or from config.
	; Unbind shift+keys to avoid issues with sprint and spell casting.
	; Caution: Binding shift+keys while sprinting may interrupt your run.
	; Note: Disabled hotkeys must be re-enabled (e.g., Hotkey("1", "Off")) when defined as such "Hotkey::".

    keys := ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "+1", "2", "+2", "3", "+3", "4", "+4", "5", "+5", "6", "+6", "7", "+7", "8", "+8", "9", "+9", "0", "+0", "-", "=", "Space", ",", ".", "/", "'", "[", "]", "\", "+-", "{", "}", "+=", "+q", "+w", "+e", "+r", "+t", "+y", "+u", "+i", "+o", "+p", "+a", "+s", "+d", "+f", "+g", "+h", "+j", "+k", "+l", "+z", "+x", "+c", "+v", "+b", "+n", "+m", "+Space", "+CapsLock", "+,", "+.", "+/", ";", "+;", "+'", "+[", "+]", "+\", "Volume_Up", "Volume_Down", "Volume_Mute"]

    __New() {
        ; Assign hotkeys using a loop
        for key in this.keys
		{
			Hotkey(key, DoNothing)
		}
    }
}