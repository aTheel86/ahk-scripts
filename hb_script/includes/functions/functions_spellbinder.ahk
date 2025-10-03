global SpellBinderGUI

ChangeSpellConfig(newFile) {
    global SpellsCfgFile

    ; Store just the filename
    FileNameOnly := RegExReplace(newFile, "^.*\\", "")

    ; Update global
    SpellsCfgFile := SpellBindsDir "\" FileNameOnly

    ; Persist choice in UserSettings.ini
    IniWrite(FileNameOnly, ConfigFile, "Configs", "SpellsCfgFile")

    ; Reload spells immediately
    LoadSpellsFromConfig(SpellsCfgFile)
}

OpenSpellBinder() {
    global SpellBinderGUI

    ; --- Create independent GUI ---
    SpellBinderGUI := Gui("+AlwaysOnTop", "Spell Binder")
    SpellBinderGUI.SetFont("s10","Segoe UI")

    ; --- Add a background color ---
    SpellBinderGUI.Add("Text", "w300 h200 Background cFFFFFF")  ; white background

    ; --- Add some controls ---
    SpellBinderGUI.Add("Text", "x10 y5", "Spell Name: ")
    editSpell := SpellBinderGUI.Add("Edit", "x120 y5 w150 vSpellName")

    SpellBinderGUI.Add("Text", "x10 y50", "yCoord: ")
    editY := SpellBinderGUI.Add("Edit", "x120 y50 w150 vYCoord")

    MouseGetPos(&MouseX, &MouseY)
    editY.Value := CtPercent(MouseY, "Y")  ; <-- your function returns Y position

    SpellBinderGUI.Add("Text", "x10 y75", "Magic Circle: ")
    editCircle := SpellBinderGUI.Add("Edit", "x120 y75 w150 vMagicCircle")

    SpellBinderGUI.Add("Text", "x10 y100", "Hotkey: ")
    hotkeyCtrl := SpellBinderGUI.Add("Hotkey", "x120 y100 w150 vChosenHotkey")

    ; --- Save button ---
    btnSave := SpellBinderGUI.Add("Button", "x10 y150 w100 h25", "Save")
    btnSave.OnEvent("Click", (*) => SaveSpell(editSpell, editY, editCircle, hotkeyCtrl))

    ; --- Show GUI ---
    SpellBinderGUI.Show("NA")
}

SaveSpell(editSpell, editY, editCircle, hotkeyCtrl) {
    global SpellBinderGUI, SpellsCfgFile
    ; --- Get values from controls ---
    SpellName := editSpell.Value
    YCoord := editY.Value
    Circle := editCircle.Value
    Hotkey := hotkeyCtrl.Value

    IniWrite(YCoord, SpellsCfgFile, SpellName, "yCoord")
    IniWrite(Circle, SpellsCfgFile, SpellName, "Circle")
    IniWrite(SpellName, SpellsCfgFile, "SpellBinds", Hotkey)

    MsgBox("Saved spell: " SpellName)

    ; --- Close GUI ---
    SpellBinderGUI.Destroy()
    LoadSpellsFromConfig(SpellsCfgFile)
}

ListSpells() {
    global SpellsCfgFile

    ; Read the entire [SpellBinds] section
    try hotkeyMap := IniRead(SpellsCfgFile, "SpellBinds")
    catch {
        MsgBox("No SpellBinds section found in config.")
        return
    }

    spellList := ""
    Loop Parse, hotkeyMap, "`n", "`r" {
        if (A_LoopField = "")
            continue

        parts := StrSplit(A_LoopField, "=")
        if (parts.Length < 2)
            continue

        hotkey := parts[1]        ; left side (q, w, e…)
        spellName := parts[2]     ; right side (Paralyze, Berserk…)

        ; Read that spell’s details
        circle    := IniRead(SpellsCfgFile, spellName, "Circle", "N/A")
        yCoord    := IniRead(SpellsCfgFile, spellName, "yCoord", "N/A")
        img       := IniRead(SpellsCfgFile, spellName, "EffectImg", "")
        duration  := IniRead(SpellsCfgFile, spellName, "EffectDur", "")

        ; Build formatted entry
        spellList .= (hotkey " → " spellName "`n")
        spellList .= ("    (Circle " circle ", Y=" yCoord ")`n")

        ; Optional extra info on a new line
        extra := ""
        if (img != "")
            extra .= "[Img: " img "]"
        if (duration != "")
            extra .= "[Dur: " duration "s]"
        if (extra != "")
            spellList .= "    " extra "`n"

        ; Blank line after each entry
        spellList .= "`n"
    }

    ShowSpellsGUI(spellList)
}

ShowSpellsGUI(spellList) {
    SpellListGUI := Gui("+AlwaysOnTop", "Spell List")
    SpellListGUI.SetFont("s10", "Segoe UI")

    ; Add a multi-line, read-only Edit control with scrollbars
    SpellListGUI.Add("Edit", "w500 h600 vSpellText ReadOnly Vertical", spellList)

    ; Add a close button
    btn := SpellListGUI.Add("Button", "x10 y610 w100 h30", "Close")
    btn.OnEvent("Click", (*) => SpellListGUI.Destroy())

    SpellListGUI.Show()
}

ChooseConfig() {
    global SpellBinderGUI

    SpellBinderGUI := Gui("+AlwaysOnTop", "Choose Config")
    SpellBinderGUI.SetFont("s10", "Segoe UI")

    ConfigFiles := Map()   ; maps filename -> full path
    displayList := []

    Loop Files, SpellBindsDir "\*.ini" {
        ConfigFiles[A_LoopFileName] := A_LoopFileFullPath
        displayList.Push(A_LoopFileName)
    }

    if (displayList.Length = 0) {
        MsgBox("No config files found")
        return
    }

    ddl := SpellBinderGUI.Add("DropDownList", "w250 vChosenCfg", displayList)

    ; --- preselect currently active config ---
    if (SpellsCfgFile) {
        ; strip path -> filename only
        ActiveFile := RegExReplace(SpellsCfgFile, "^.*\\", "")
        ; find its position in the list
        for idx, name in displayList {
            if (name = ActiveFile) {
                ddl.Choose(idx) ; select it
                break
            }
        }
    }

    btnLoad := SpellBinderGUI.Add("Button", "x10 y50 w100", "Load")
    btnLoad.OnEvent("Click", (*) => (
        ChangeSpellConfig(ConfigFiles[ddl.Text]),
        MsgBox("Loaded config:`n" ConfigFiles[ddl.Text]),
        SpellBinderGUI.Destroy()
    ))

    SpellBinderGUI.Show("NA")
}
