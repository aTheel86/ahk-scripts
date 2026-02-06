global LaunchGUI

ChangeConfig(newFile) {
    global ConfigFile

    ; Store just the filename
    FileNameOnly := RegExReplace(newFile, "^.*\\", "")

    ; Update global
    ConfigFile := ConfigDir "\" FileNameOnly

    ; Persist choice in Launcher.ini
    IniWrite(FileNameOnly, LauncherConfig, "Settings", "UserConfigFile")

    ; Reload spells immediately (is this needed???)
    ;LoadSpellsFromConfig(ControlCfgFile)
}

LaunchSelectConfig() {
    global LaunchGUI

    if WinActive(WinTitle) {
        ;return
    }

    LaunchGUI := Gui("+AlwaysOnTop", "Choose Config")
    LaunchGUI.SetFont("s10", "Segoe UI")

    ConfigFiles := Map()   ; maps filename -> full path
    displayList := []

    Loop Files, ConfigDir "\*.ini" {
        ConfigFiles[A_LoopFileName] := A_LoopFileFullPath
        displayList.Push(A_LoopFileName)
    }

    if (displayList.Length = 0) {
        MsgBox("No config files found")
        return
    }

    ddl := LaunchGUI.Add("DropDownList", "w250 vChosenCfg", displayList)

    ; --- preselect currently active config ---
    if (ConfigFile) {
        ; strip path -> filename only
        ActiveFile := RegExReplace(ConfigFile, "^.*\\", "")
        ; find its position in the list
        for idx, name in displayList {
            if (name = ActiveFile) {
                ddl.Choose(idx) ; select it
                break
            }
        }
    }

    btnLoad := LaunchGUI.Add("Button", "x10 y50 w100", "Select")
    btnLoad.OnEvent("Click", (*) => (
        ChangeConfig(ConfigFiles[ddl.Text]),
        LaunchGUI.Destroy()
    ))

    LaunchGUI.Show("NA")
}

LaunchSelectConfig()