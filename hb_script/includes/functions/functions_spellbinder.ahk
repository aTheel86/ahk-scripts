global SpellBinderGUI

UpdateSpells(newFile) {
    global ConfigFile

    ; Store just the filename
    FileNameOnly := RegExReplace(newFile, "^.*\\", "")

    ; Update global
    ConfigFile := ConfigDir "\" FileNameOnly

    ; Persist choice in UserSettings.ini
    IniWrite(FileNameOnly, ConfigFile, "Configs", "ControlFile")

    ; Reload spells immediately
    LoadSpellsFromConfig(ControlFile)
}

OpenSpellBinder() {
    global SpellBinderGUI

    ; --- Create independent GUI ---
    SpellBinderGUI := Gui("+AlwaysOnTop +ToolWindow -Caption", "Overlay")
    SpellBinderGUI.SetFont("s7","Segoe UI")

    ; --- Add a background color ---
    SpellBinderGUI.Add("Text", "w400 h200 Background cFFFFFF")  ; white background

    ; --- Add some controls ---
    SpellBinderGUI.Add("Text", "x5 y10", "Spell Name: ")
    editSpell := SpellBinderGUI.Add("Edit", "x70 y5 w350 vSpellName")

    SpellBinderGUI.Add("Text", "x5 y50", "yCoord: ")
    editY := SpellBinderGUI.Add("Edit", "x70 y45 w350 vYCoord")
    editY.Value := "MouseY position for spell shown at bottom"

    SpellBinderGUI.Add("Text", "x5 y75", "Magic Circle: ")
    editCircle := SpellBinderGUI.Add("Edit", "x70 y70 w350 vMagicCircle")

    SpellBinderGUI.Add("Text", "x5 y100", "Hotkey: ")
    hotkeyCtrl := SpellBinderGUI.Add("Hotkey", "x70 y95 w350 vChosenHotkey")

    ; --- Save button ---
    btnSave := SpellBinderGUI.Add("Button", "x5 y150 w100 h25", "Save")
    btnSave.OnEvent("Click", (*) => SaveSpell(editSpell, editY, editCircle, hotkeyCtrl))

    ; --- Cancel button ---
    btnSave := SpellBinderGUI.Add("Button", "x160 y150 w100 h25", "Cancel")
    btnSave.OnEvent("Click", (*) => SpellBinderGUI.Destroy())

    ; --- Show GUI ---
    SpellBinderGUI.Show("x50 y100 NoActivate")
}

SaveSpell(editSpell, editY, editCircle, hotkeyCtrl) {
    global SpellBinderGUI, ControlFile
    ; --- Get values from controls ---
    SpellName := editSpell.Value
    YCoord := editY.Value
    Circle := editCircle.Value
    Hotkey := hotkeyCtrl.Value

    IniWrite(YCoord, ControlFile, SpellName, "yCoord")
    IniWrite(Circle, ControlFile, SpellName, "Circle")
    IniWrite(SpellName, ControlFile, "SpellBinds", Hotkey)

    MsgBox("Saved spell: " SpellName)

    ; --- Close GUI ---
    SpellBinderGUI.Destroy()
    LoadSpellsFromConfig(ControlFile)
}

ListSpells() {
    global ControlFile

    ; Read the entire [SpellBinds] section
    try hotkeyMap := IniRead(ControlFile, "SpellBinds")
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
        circle    := IniRead(ControlFile, spellName, "Circle", "N/A")
        yCoord    := IniRead(ControlFile, spellName, "yCoord", "N/A")
        img       := IniRead(ControlFile, spellName, "EffectImg", "")
        duration  := IniRead(ControlFile, spellName, "EffectDur", "")

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

    Loop Files, ControlDir "\*.ini" {
        ConfigFiles[A_LoopFileName] := A_LoopFileFullPath
        displayList.Push(A_LoopFileName)
    }

    if (displayList.Length = 0) {
        MsgBox("No config files found")
        return
    }

    ddl := SpellBinderGUI.Add("DropDownList", "w250 vChosenCfg", displayList)

    ; --- preselect currently active config ---
    if (ControlFile) {
        ; strip path -> filename only
        ActiveFile := RegExReplace(ControlFile, "^.*\\", "")
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
        UpdateSpells(ConfigFiles[ddl.Text]),
        MsgBox("Loaded config:`n" ConfigFiles[ddl.Text]),
        SpellBinderGUI.Destroy()
    ))

    SpellBinderGUI.Show("NA")
}
