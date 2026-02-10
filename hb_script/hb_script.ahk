#Requires AutoHotkey v2.0

; AHK settings
Persistent
CoordMode "Mouse", "Window" ; Client / Window / Screen (Client might be best)
CoordMode "ToolTip", "Window"
SendMode "Event"
SetMouseDelay 30 ; 10 is default (this adds more delay to help mouseclick commands to work better)
SetDefaultMouseSpeed 4 ; 2 is default 

DoNothing(*) => { } ; A function used when a method is required, but no action is needed.

#Include includes\global_variables.ahk
#Include includes\global_functions.ahk

; Run this before we force WinWaitActive
#Include includes\functions\functions_launcher.ahk

; AHK initiatives
WinWaitActive WinTitle ;Script waits until HB window is active/front
HotIfWinActive WinTitle ;Attempt to make Hotkeys only work inside the HB window
SetWorkingDir A_InitialWorkingDir ;Forces the script to use the folder it was initially launched from as its working directory

#Include includes\load_from_ini.ahk
#Include includes\classes\class_GUIManager.ahk
#Include includes\classes\class_commandinfo.ahk
#Include includes\classes\class_hotkeyunbind.ahk
#Include includes\classes\class_optionsmenumanager.ahk
#Include includes\classes\class_spellinfo.ahk
#Include includes\classes\class_statuseffectindicator.ahk
#Include includes\classes\class_repbutton.ahk
#Include includes\classes\class_nodeinfo.ahk
#Include includes\functions\functions_minimap.ahk
#Include includes\functions\functions_inventory.ahk
#Include includes\functions\functions_autopot.ahk
#Include includes\functions\functions_leveling.ahk
#Include includes\functions\functions_screenreading.ahk
#Include includes\functions\functions_farming.ahk
#Include includes\functions\functions_messages.ahk
#Include includes\functions\functions_traderep.ahk
#Include includes\functions\functions_spellbinder.ahk
#Include includes\functions\functions_spells.ahk
#Include includes\functions\functions_enchanting.ahk

; GUI (cannot reside in global_variables as thes require all includes)
Global HUD := GUIManager()
Global RepButtonInst := RepButton(60) ; in minutes

#SuspendExempt
!K::ExitApp ; Kill the app (useful if mouse gets locked or program is not responding)

; F1 should only be used to suspend or unsuspend the script, the * designates this (aka it prevents the HB F1 help menu from popping up)
*F1:: A_IsSuspended ? Suspend(false) : Suspend(true)

~LButton:: ; ~ means the button should behave as normal in addition to this code
{
	Global CastingEffectSpell, Effects

	if (CastingEffectSpell != "") 
	{
		Effects.Push(StatusEffectIndicator(CastingEffectSpell[1], CastingEffectSpell[2], ""))

		for (i, indicator in Effects)
		{
			if (!indicator.IsActive())
			{
				Effects.RemoveAt(i) ; Remove the expired instance from the array 
			}
		}
	}

	CastingEffectSpell := ""
}

~RButton::
{
	Global CastingEffectSpell

	CastingEffectSpell := ""
}

RemoveToolTip(*) {
	Tooltip ""
}

EscapeGUI(*)
{
	global stopFlag, activeMenuManager

	stopFlag := true

    if (activeMenuManager != "") {
        activeMenuManager.DestroyOptionsGUI()
    }	
}

;ToggleSuspendScript(*) => Send("{F1}") ; unused, consider removing?
SuspendScript(*) => Suspend(true)
ResumeScript(*) => Suspend(false)

#SuspendExempt false
; ══════════════════════════════════════════════════════  Timer Assist (manual sync) ══════════════════════════════════════════════════════ ;
; You press F8 when the in-game top-left timer hits 0/60. Script cues HP timing at 15/30/45.
; Shows a 3-second tooltip warning (12-14, 27-29, 42-44) and plays a WAV on the exact tick.

global gTimerAssistEnabled := false
global gTimerAssistSyncTick := 0
global gTimerAssistCycleSec := 60
global gTimerAssistSchedule := "WARR15"
global gTimerAssistLastSecond := -1
global gTimerAssistLastCueSecond := 0
global gTimerAssistTooltipId := 20
global gTimerAssistMouseTipId := 2
global gTimerAssistTickSound := A_ScriptDir "\sounds\softalert2.wav"
global gTimerAssistPrewarnSound := A_ScriptDir "\sounds\softalert1.wav"

; Play WAV reliably (avoids MCI/SoundPlay failures on some systems)
PlayWav(filePath) {
    try {
        if !FileExist(filePath)
            return false
        ; SND_ASYNC (0x1) | SND_FILENAME (0x20000) | SND_NODEFAULT (0x2)
        return DllCall("winmm\PlaySoundW", "str", filePath, "ptr", 0, "uint", 0x0001 | 0x0002 | 0x20000)
    } catch {
        return false
    }
}

; 3-second pre-warning for Timer Assist (WAV-only, no tooltip)
; Plays a single WAV when the next mark is 3 seconds away.
; Uses the same tick sound by default (gTimerAssistTickSound).
TimerAssist_PlayCountdown(n) {
    global gTimerAssistPrewarnSound
    if (n != 3)
        return
    if FileExist(gTimerAssistPrewarnSound)
        PlayWav(gTimerAssistPrewarnSound)
}


Left::TimerAssist_ToggleSchedule() ; toggle TimerAssist schedule (WARR15 <-> MAGE20)
Up::TimerAssist_Sync()     ; sync to the in-game timer boundary (press at 0/60)
Down::TimerAssist_Toggle()   ; enable/disable the assist (keeps sync if re-enabled)
F12::TypePassword()     ; type saved account password

TimerAssist_Sync(*) {
    global gTimerAssistEnabled, gTimerAssistSyncTick, gTimerAssistLastSecond, gTimerAssistLastCueSecond, gTimerAssistSchedule
    gTimerAssistEnabled := true
    gTimerAssistSyncTick := A_TickCount
    gTimerAssistLastSecond := -1
    gTimerAssistLastCueSecond := -1
    SetTimer(TimerAssist_Tick, 50)
    if FileExist(gTimerAssistTickSound)
        PlayWav(gTimerAssistTickSound) ; confirmation
    TimerAssist_MouseTip("Synced: " . (( gTimerAssistSchedule = "MAGE20") ? "MP (20s)" : "HP (15s)"))
}

TimerAssist_Toggle(*) {
    global gTimerAssistEnabled
    gTimerAssistEnabled := !gTimerAssistEnabled
    if (!gTimerAssistEnabled) {
        SetTimer(TimerAssist_Tick, 0)
        TimerAssist_ClearTooltip()
        if FileExist(gTimerAssistTickSound)
            PlayWav(gTimerAssistTickSound)
    } else {
        SetTimer(TimerAssist_Tick, 50)
        if FileExist(gTimerAssistTickSound)
            PlayWav(gTimerAssistTickSound)
    }
}

TimerAssist_ToggleSchedule(*) {
    global gTimerAssistSchedule, gTimerAssistLastSecond, gTimerAssistLastCueSecond
    ; Flip between warrior 15s marks and mage 20s marks (both within a 60s cycle).
    if (gTimerAssistSchedule = "MAGE20")
        gTimerAssistSchedule := "WARR15"
    else
        gTimerAssistSchedule := "MAGE20"

    ; Reset guards so the next cue after switching can fire cleanly.
    gTimerAssistLastSecond := -1
    gTimerAssistLastCueSecond := -1
    TimerAssist_MouseTip("Timer: " . (( gTimerAssistSchedule = "MAGE20") ? "MP (20s)" : "HP (15s)"))
}



TimerAssist_ClearTooltip(*) {
    global gTimerAssistTooltipId
    ToolTip("", , , gTimerAssistTooltipId)
}

TimerAssist_MouseTip(msg, durationMs := 900) {
    global gTimerAssistMouseTipId
    MouseGetPos &mx, &my
    ToolTip(msg, mx + 14, my + 18, gTimerAssistMouseTipId)
    SetTimer(() => ToolTip("", , , gTimerAssistMouseTipId), -durationMs)
}

TimerAssist_ShowTooltip(msg, durationMs := 650) {
    ; Tooltips disabled (audio countdown used instead)
    return
}

TimerAssist_Tick() {
    global gTimerAssistEnabled, gTimerAssistSyncTick, gTimerAssistCycleSec, gTimerAssistSchedule
    global gTimerAssistLastSecond, gTimerAssistLastCueSecond, gTimerAssistTickSound

    if (!gTimerAssistEnabled)
        return

    elapsed := A_TickCount - gTimerAssistSyncTick
    sec := Floor(elapsed / 1000)

    ; only update once per second
    if (sec = gTimerAssistLastSecond)
        return
    gTimerAssistLastSecond := sec

    cycleSec := Mod(sec, gTimerAssistCycleSec)

    ; 3-second warnings before marks (WAV-only)
    ; WARR15 marks: 0/15/30/45  => prewarn at 57,12,27,42
    ; MAGE20 marks: 0/20/40     => prewarn at 57,17,37
    if (cycleSec >= 57 && cycleSec <= 59) {
        TimerAssist_PlayCountdown(60 - cycleSec)
    } else if (gTimerAssistSchedule = "MAGE20") {
        if (cycleSec >= 17 && cycleSec <= 19) {
            TimerAssist_PlayCountdown(20 - cycleSec)
        } else if (cycleSec >= 37 && cycleSec <= 39) {
            TimerAssist_PlayCountdown(40 - cycleSec)
        }
    } else {
        if (cycleSec >= 12 && cycleSec <= 14) {
            TimerAssist_PlayCountdown(15 - cycleSec)
        } else if (cycleSec >= 27 && cycleSec <= 29) {
            TimerAssist_PlayCountdown(30 - cycleSec)
        } else if (cycleSec >= 42 && cycleSec <= 44) {
            TimerAssist_PlayCountdown(45 - cycleSec)
        }
    }

    ; Tick cue on exact marks (once)
    if (gTimerAssistSchedule = "MAGE20") {
        if ((cycleSec = 0 || cycleSec = 20 || cycleSec = 40) && (cycleSec != gTimerAssistLastCueSecond)) {
            gTimerAssistLastCueSecond := cycleSec
            if FileExist(gTimerAssistTickSound)
                PlayWav(gTimerAssistTickSound)
        }
    } else {
        if ((cycleSec = 0 || cycleSec = 15 || cycleSec = 30 || cycleSec = 45) && (cycleSec != gTimerAssistLastCueSecond)) {
            gTimerAssistLastCueSecond := cycleSec
            if FileExist(gTimerAssistTickSound)
                PlayWav(gTimerAssistTickSound)
        }
    }
}



; ══════════════════════════════════════════════════════  Systems/Functions ══════════════════════════════════════════════════════ ;

CheckWindowState() {
	if !WinExist(WinTitle) {
		return
	}

	Style := WinGetStyle(WinTitle)
	WinState := WinGetMinMax(WinTitle)

	if (Style & 0x01000000)  ; WS_MAXIMIZE style
	{
		;gGUI.Maximize()
		gGUI.Show("x0 y0 w" ScreenResX " h" ScreenResY " NA NoActivate")
		WinSetAlwaysOnTop(1, gGUI.Hwnd)          
	} 
	else if (WinState == -1)  ; Minimized state
	{
		gGUI.Hide()
		;gGUI.Minimize()

		if (activeMenuManager != "") {
			activeMenuManager.DestroyOptionsGUI()
		}	

		ToolTip "HB Script is still running! Hit Alt+K to kill the script."
	} 
	else {
		WinMaximize(WinTitle)
	}
}

SetTimer(CheckWindowState, 1000)

ToggleDebugMode(*)
{
	Global bDebugMode

	bDebugMode := !bDebugMode
}

OptionsMenu(optionNames, optionFunctionNames) {
    global activeMenuManager

    if (activeMenuManager == "") {
        activeMenuManager := OptionsMenuManager(optionNames, optionFunctionNames)
        activeMenuManager.showOptionsDialog()
    } else {
        activeMenuManager.DestroyOptionsGUI()
    }
}

; ══════════════════════════════════════════════════════  Hotkeys and Game Actions ══════════════════════════════════════════════════════ ;

ToggleMap(*) => Send("^m")
OpenBag(*) => Send("{f6}")
OpenCharacter(*) => Send("{f5}")
ToggleRunWalk(*) => Send("^r")
OpenGameSettings(*) => Send("{F12}")
ItemActivation(*) => Send("{PgUp}")

;T::DialogTransparency

Input_Checked_Img := "images\node_images\Settings_Checked.png"

Dialog_T := NodeInfo("Dialog_T", "images\node_images\Dialog_T.png",,, [-2,0.8])
Menu_Graphics_Button := NodeInfo("Menu_Graphics_Button", "images\node_images\Options_Menu_Corner.png",,, [-9.5,-49.5])

DialogTransparency(bTurnOn := true) {
    BlockInput true
	MouseMove 0, 0, 0
    Send "{F12}"
    Sleep 50

	Menu_Graphics_Button.Click()
	Sleep 50	
	
	if (Settings_Location := Dialog_T.GetScreenLocation()) {
		X1 := Settings_Location[1] - CtPixel(2.9, "X")
		Y1 := Settings_Location[2] - CtPixel(0.5, "Y")
		X2 := X1 + CtPixel(1.9, "X")
		Y2 := Y1 + CtPixel(2.5, "Y")
	}
	else {
		Tooltip "Failed to find setting"
	}

	if (ImageSearch(&X, &Y, X1, Y1, X2, Y2, "*TransBlack " Input_Checked_Img) != bTurnOn) {
		Dialog_T.Click()
	}
    Sleep 50
    Send "{F12}"
    Sleep 10
    BlockInput false
}

EnableDialogTransparency() {
    DialogTransparency(true)
}

DisableDialogTransparency() {
    DialogTransparency(false)
}

Input_Button := NodeInfo("Input_Button", "images\node_images\Input_Button.png", "images\node_images\Input_Button_Clicked.png",, [2.6,1.3])
Shift_Pickup := NodeInfo("Shift_Pickup", "images\node_images\Shift_To_Pickup.png",,, [-2,0.8])

ShiftPickup(bTurnOn := true) {
    BlockInput true
	MouseMove 0, 0, 0
    Send "{F12}"
    Sleep 50
	Input_Button.Click()
	Sleep 50	
	if (Settings_Location := Shift_Pickup.GetScreenLocation()) {
		X1 := Settings_Location[1] - CtPixel(2.9, "X")
		Y1 := Settings_Location[2] - CtPixel(0.5, "Y")
		X2 := X1 + CtPixel(1.9, "X")
		Y2 := Y1 + CtPixel(2.5, "Y")
	}
	else {
		Tooltip "Failed to find setting"
		return
	}

	if (ImageSearch(&X, &Y, X1, Y1, X2, Y2, "*TransBlack " Input_Checked_Img) != bTurnOn) {
		Shift_Pickup.Click()
	}
    Sleep 50
    Send "{F12}"
    Sleep 10
    BlockInput false
}

EnableShiftPickup() {
    ShiftPickup(true)
}

DisableShiftPickup() {
    ShiftPickup(false)
}

MainMenu(*) {
    OptionsMenu(["1. Leveling", "2. Tools", "3. SpellBinding"],
                ["LevelingMenu", "UncommonCommands", "SpellBindTools"])
}

RequestMenu(*) {
    OptionsMenu(["1. AMP", "2. Zerk", "3. Invis", "4. Enemies!"],
                ["APFMMessage", "BerserkMessage", "InvisMessage", "EnemiesMessage"])
}

LevelingMenu(*) {
    OptionsMenu(["1. PretendCorpse", "2. MagicLeveling", "3. Basic Leveling", "4. Farming", "5. Test"],
                ["PretendCorpseLeveling", "ToggleMagicLeveling", "BeginBasicLeveling", "StartFarming", "Test"])
}

UncommonCommands(*) {
    OptionsMenu(["1. Toggle Debug", "2. Eat Food", "3. Sell Items", "4. Type PW"],
                ["ToggleDebugMode", "EatFood", "SellStackedItems", "TypePassword"])
}

ReputationMenu(*) {
	OptionsMenu(["1. Trade Rep", "2. Check Rep", "3. AFK Rep", "4. AFK Incog Rep"],
				["SendTradeRepMessage", "CheckRepMessage", "ActivateAutoTradeRep", "StartAutoIncognitoRep"])
}

SpellBindTools(*) {
	OptionsMenu(["1. Spell Binder", "2. Spell Binds", "3. Choose Config", "4. "],
				["OpenSpellBinder", "ListSpells", "ChooseConfig", ""])
}

; Type account password for ease of login
TypePassword(*)
{
	SendText(IniRead(ConfigFile, "Account", "Password"))
}

; Sell/deposit 12 items (use by putting inventory over sell/deposit window at the bottom, hold mouse over the items you want to deposit alt+s
; is this obsolete?
SellStackedItems(*)
{
	Loop 12 ; can only sell 12 items at a time
	{
		Click "Down"
		Send "{F6}" ; Toggle off the inventory menu
		Click "Up"
		Send "{F6}" ; Toggles on the inventory menu
	}
}

; ══════════════════════════════════════════════════════  Other/Conditional Hotkeys  ══════════════════════════════════════════════════════ ;

#HotIf (IsObject(activeMenuManager) && activeMenuManager.optionsGui != "")
    1::activeMenuManager.CallFunction(1)
    2::activeMenuManager.CallFunction(2)
    3::activeMenuManager.CallFunction(3)
	4::activeMenuManager.CallFunction(4)
	5::activeMenuManager.CallFunction(5)
	6::activeMenuManager.CallFunction(6)
	7::activeMenuManager.CallFunction(7)
	8::activeMenuManager.CallFunction(8)
	9::activeMenuManager.CallFunction(9)
#HotIf

; ══════════════════════════════════════════════════════  Debugging / WIP ══════════════════════════════════════════════════════ ;

/*
!C:: ; useful for debugging
{
	;WinMaximize(WinTitle)
	;pA_Clipboard := PixelGetColor(150, 571) . " " . PixelGetColor(163, 592)
}
*/

ReturnInputs(*)
{
	BlockInput false
	BlockInput "MouseMoveOff"
}

; Any hotkeys defined below this will work outside of HB
HotIfWinActive
;OnExit ReturnInputs()