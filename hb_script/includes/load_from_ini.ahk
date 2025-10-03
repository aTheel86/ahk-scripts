; ══════════════════════════════════════════════════════  Optional Systems ══════════════════════════════════════════════════════ ;

if (IniRead(ConfigFile, "Settings", "UseAutoPotting") == "true")
{
	SetTimer(AutoPot, 200)
}

/*
if (IniRead(ConfigFile, "Settings", "UnbindKeys") == "true")
{
    ; Old, was useful for Helbreath Nemesis
	;UnbindKeys := HotkeyUnbindClass() ; Obj instance that unbinds a bunch of keys by setting hotkeys to do nothing
}
*/

; ══════════════════════════════════════════════════════  Load From Config ══════════════════════════════════════════════════════ ;

LoadSpellsFromConfig(cfgFile) {
    try {
        SpellBindsList := IniRead(cfgFile, "SpellBinds")
    } catch {
        MsgBox("Error: 'SpellBinds' section not found in " cfgFile)
        return
    }

    Loop Parse, SpellBindsList, "`n", "`r" {
        if (A_LoopField == "" || SubStr(A_LoopField, 1, 1) = ";")
            continue

        SpellBind := StrSplit(A_LoopField, "=")

        if (SpellBind.Length < 2) {
            MsgBox "Error in LoadSpellsFromConfig. An equals is missing from a line under SpellBinds."
            continue
        }

        Hk        := SpellBind[1]
        SpellName := SpellBind[2]

        if (SpellName = "") {
            Hk := RegExReplace(Trim(SpellBind[1]), "[`r`n]")
            if (Hk != "" && Hk ~= "^[a-zA-Z0-9`~!+#^]+$") {
                Hotkey(Hk, DoNothing) ; First make sure we assign the Hotkey, as it'll flag an error if one doesn't exist in the line below
                Hotkey(Hk, "Off") ; For some reason this must be done, the DoNothing is not good enough
            }
            continue
        }

        SpellCircle := IniRead(cfgFile, SpellName, "Circle", "")
        yCoord      := IniRead(cfgFile, SpellName, "yCoord", "")
        Img         := IniRead(cfgFile, SpellName, "EffectImg", "")
        Dur         := IniRead(cfgFile, SpellName, "EffectDur", "")

        SpellInstance := SpellInfo(SpellName, SpellCircle, yCoord, Hk, Img, Dur)
    }
}

LoadCommandsFromConfig(SectionName) {
	Section := IniRead(ConfigFile, SectionName)

	if (Section)
	{
		Loop Parse, Section, "`n", "`r"
		{
			; Split the line into its components using comma as delimiter
			SplitLine := StrSplit(A_LoopField, ",")

			; Extract individual components (1 is unused as it only helps the user know what they are reassigning)
			Command := SplitLine[2]
			Key := SplitLine[3]

			CommandInstance := CommandInfo(Key, Command)
		}
	}
}

LoadSpellsFromConfig(SpellsCfgFile)
LoadCommandsFromConfig("Script")
LoadCommandsFromConfig("Character")
LoadCommandsFromConfig("Leveling")
LoadCommandsFromConfig("Messages")
LoadCommandsFromConfig("Inventory")
LoadCommandsFromConfig("Other")
