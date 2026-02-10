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