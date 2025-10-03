#Requires AutoHotkey v2.0

Persistent  ; Keeps the script running
CoordMode "Mouse", "Window" ; Client / Window / Screen (Client might be best)
CoordMode "ToolTip", "Window"
SendMode "Event"
SetMouseDelay 30 ; 10 is default (this adds more delay to help mouseclick commands to work better)
SetDefaultMouseSpeed 4 ; 2 is default 

#Include includes\global_variables.ahk

; AHK initiatives
WinWaitActive WinTitle ;Script waits until HB window is active/front
HotIfWinActive WinTitle ;Attempt to make Hotkeys only work inside the HB window
SetWorkingDir A_InitialWorkingDir ;Forces the script to use the folder it was initially launched from as its working directory

#Include includes\functions\functions_common.ahk
#Include includes\functions\functions_autopot.ahk
#Include includes\functions\functions_plague_ready.ahk

#SuspendExempt
!K::ExitApp ; Kill the app (useful if mouse gets locked or program is not responding)
#SuspendExempt false

;Timed_CheckPlagueReady()
;Timed_ES_IsHalf_HeartBeatWarning()
Timed_Life_Flask_Low_Warning()
;Timed_Pot_OnDamageTaken()
Timed_Emergency_LifePot()

/*
ES_PotOnDamageTaken := IniRead(ConfigFile, "Settings", "ES_PotOnDamageTakenIfFreshFlask")

if (IniRead(ConfigFile, "Settings", "CheckForPlagueReady") == "true")
{
	Timed_CheckPlagueReady()
}

if (IniRead(ConfigFile, "Settings", "ES_HeartbeatWarning") == "true")
{
	Timed_ESHeartBeatWarning()
}

if (IniRead(ConfigFile, "Settings", "ES_AutoLifePot") == "true")
{
	Timed_ESAutoLifePot()
}
*/
