global LaunchGUI

ChangeConfig(newFile) {
    global ConfigFile, ConfigDir, LauncherConfig

    ; new selection (filename only)
    NewName := RegExReplace(newFile, "^.*\\", "")

    ; current active (filename only)
    CurName := ConfigFile ? RegExReplace(ConfigFile, "^.*\\", "") : ""

    ; If same config, do nothing (prevents reload loop)
    if (NewName = CurName) {
        return false
    }

    ; Update global + persist
    ConfigFile := ConfigDir "\" NewName
    IniWrite(NewName, LauncherConfig, "Settings", "UserConfigFile")

    Reload
    return true
}

LaunchSelectConfig() {
    global LaunchGUI, ConfigFile, ConfigDir, WinTitle

    if WinActive(WinTitle) {
        ;return
    }

    LaunchGUI := Gui("+AlwaysOnTop", "Choose Config")
    LaunchGUI.SetFont("s10", "Segoe UI")

    ConfigFiles := Map()
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

    ; preselect current config
    if (ConfigFile) {
        ActiveFile := RegExReplace(ConfigFile, "^.*\\", "")
        for idx, name in displayList {
            if (name = ActiveFile) {
                ddl.Choose(idx)
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
