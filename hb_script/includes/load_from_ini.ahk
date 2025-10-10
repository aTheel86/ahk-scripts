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
    global SpellInfoInstances

    try {
        SpellBindsList := IniRead(cfgFile, "SpellBinds")
    } catch {
        MsgBox("Error: 'SpellBinds' section not found in " cfgFile)
        return
    }

    ; Destroy all current spell instances as we are going to reload
    for spell in SpellInfoInstances {
        spell.Disable()
        spell := ""
    }

    SpellInfoInstances := []  ; clear references → garbage collection

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

        ; Reset used variables so previous loop isn't stored.
        SpellCircle := ""
        yCoord      := ""
        Img         := ""
        Dur         := ""

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

        ; Replace the fake keyword "Equals" with the real key
        Hk := StrReplace(Hk, "Equals", "=")

        if (SpellCircle != "" && yCoord != "") {
            SpellInfoInstances.Push(SpellInfo(SpellName, SpellCircle, yCoord, Hk, Img, Dur))
        }
    }
}

LoadCommandsFromConfig(SectionName) {
    Section := IniRead(ControlFile, SectionName)

    if (Section) {
        Loop Parse, Section, "`n", "`r" {
            line := Trim(A_LoopField)

            ; Skip empty lines or full-line comments
            if (line = "" || SubStr(line, 1, 1) = ";")
                continue

            ; Strip inline comments
            pos := InStr(line, ";")
            if (pos)
                line := Trim(SubStr(line, 1, pos - 1))  ; Keep only part before the comment

            ; Split key=value
            SplitLine := StrSplit(line, "=", , 2)
            if (SplitLine.Length < 2)
                continue  ; skip malformed lines

            Key := Trim(SplitLine[1])
            Command := Trim(SplitLine[2])

            if (Key == "" || Command == "")
                continue

            ; Replace the fake keyword "Equals" with the real key
            Key := StrReplace(Key, "Equals", "=")

            CommandInstance := CommandInfo(Key, Command)
        }
    }
}

LoadSpellsFromConfig(ControlFile)
LoadCommandsFromConfig("Commands")