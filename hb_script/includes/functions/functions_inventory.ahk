; ══════════════════════════════════════════════════════  Armor Set Swaps (PA/MA/HP)  ══════════════════════════════════════════════════════ ;
; Helbreath inventory/item layering makes screen-reading unreliable, so this module never uses ImageSearch to
; infer "what you're wearing". Instead, PA/MA changes go through script commands and we track the current set
; in a variable (CurrentArmorSet).
;
; Features:
;   • EquipPASet / EquipMASet: manual set switching (updates CurrentArmorSet)
;   • HoldHPDown / HoldHPUp: temporary HP swap while key is held, then return to prior set
;     (includes left-click movement preservation logic)
;
; Configure set slot indexes in your user config INI (e.g. configs\user\hb_script_config_chris.ini):
;   [ArmorSets]
;   PA=1,2,3,4
;   MA=5,6,7,8
;   HP=9,10,11,12
;
; Bind keys in your control config (e.g. configs\controls\control_cfg_*.ini) under [Commands]:
;   r=EquipPASet
;   t=EquipMASet
;   f=HoldHPDown
;   f Up=HoldHPUp
;
global CurrentArmorSet := "PA"
global HoldHP_Active := false
global HoldHP_Running := false
global HoldHP_PrevSet := "PA"
global HoldMP_Active := false
global HoldMP_Running := false
global HoldMP_PrevSet := "PA"
global ArmorSets := Map(
    "PA", [],
    "MA", [],
    "HP", [],
    "MP", [],
    "DR", [],
    "WAND", []
)

; Read once on include so commands are ready.
ArmorSets["PA"] := __ReadArmorSetFromIni("PA")
ArmorSets["MA"] := __ReadArmorSetFromIni("MA")
ArmorSets["HP"] := __ReadArmorSetFromIni("HP")
ArmorSets["MP"] := __ReadArmorSetFromIni("MP")
ArmorSets["DR"] := __ReadArmorSetFromIni("DR")

ArmorSets["WAND"] := __ReadArmorSetFromIni("WAND")
; Combat inputs (Ctrl/Alt/Shift/LButton) can be held while a swap occurs.
; If we synthesize Ctrl Down/Up while the user is also holding keys, Windows can
; end up in a "stuck modifier" state. The fix is:
;  1) Snapshot the PHYSICAL modifier state.
;  2) Force-release mouse + modifiers.
;  3) Run the swap.
;  4) Force-release again and restore modifiers to match the PHYSICAL state.
; After we close the bag, re-issue a click at the last known mouse location so
; left-click movement continues smoothly through the swap.
; Auto monitor: if HP is not full, ensure swap is enabled; if full, ensure disabled.
; Uses FindHealthPercentage() from functions_autopot.ahk.
__ReadArmorSetFromIni(setName) {
    global ConfigFile

    try {
        raw := IniRead(ConfigFile, "ArmorSets", setName, "")
    } catch {
        raw := ""
    }

    raw := Trim(raw)
    if (raw = "")
        return []

    parts := StrSplit(raw, ",")
    out := []
    for , p in parts {
        p := Trim(p)
        if (p = "")
            continue
        ; InventorySlotPos is 1-based; enforce integer.
        if IsNumber(p)
            out.Push(p + 0)
    }
    return out
}

EquipArmorSet(setName, preserveMouse := false) {
    global ArmorSets, CurrentArmorSet

    if !ArmorSets.Has(setName) {
        Tooltip "Unknown armor set: " setName
        SetTimer(() => Tooltip(""), -1200)
        return
    }

    items := ArmorSets[setName]
    if (!IsObject(items) || items.Length = 0) {
        Tooltip "Armor set '" setName "' not configured. Add [ArmorSets] " setName "=... to your user INI."
        SetTimer(() => Tooltip(""), -2500)
        return
    }

    EquipItem(items, preserveMouse)
    CurrentArmorSet := setName
}

; Commands callable from control config
global EquipSet_Locks := Map()  ; per-set lock to prevent key-hold auto-repeat spam

; Commands callable from control config
EquipPASet(*) => EquipArmorSet_SafeOnce("PA", true)
EquipMASet(*) => EquipArmorSet_SafeOnce("MA", true)
EquipDRSet(*) => EquipArmorSet_SafeOnce("DR", true)
EquipHPSet(*) => EquipArmorSet("HP") ; leave HP manual swap unchanged (HoldHP has its own logic)
EquipWANDSet(*) => EquipArmorSet_SafeOnce("WAND", true)

EquipArmorSet_SafeOnce(setName, preserveMouse := false) {
    global EquipSet_Locks
    if !EquipSet_Locks.Has(setName)
        EquipSet_Locks[setName] := false

    ; If Windows auto-repeats while the key is held, ignore re-entries.
    if (EquipSet_Locks[setName])
        return

    EquipSet_Locks[setName] := true
    try {
        EquipArmorSet(setName, preserveMouse)
    } finally {
        EquipSet_Locks[setName] := false
    }

    ; Wait for the triggering hotkey to be released so a held key can't spam the command.
    __WaitForTriggerKeyRelease()
}

__WaitForTriggerKeyRelease() {
    ; Works for typical Hotkey() callbacks where A_ThisHotkey contains something like:
    ;   "r", "t", "f", "f up", "^r", "~r", etc.
    hk := A_ThisHotkey
    if (hk = "")
        return

    key := RegExReplace(hk, "i)^[\*\~\$\!\^\+#<>]*") ; strip modifiers/prefixes
    key := StrReplace(key, " up")
    key := Trim(key)

    if (key != "")
        KeyWait key
}


; Hold-to-HP swap (press-and-hold key).
; Bind in your control config like:
;   X=HoldHPDown
;   X Up=HoldHPUp
; While held: equips HP set. On release: returns to previous set.
HoldHPDown(*) {
    global HoldHP_Active, HoldHP_Running, HoldHP_PrevSet, CurrentArmorSet
    if HoldHP_Running
        return
    ; If already active, ignore repeated downs.
    if HoldHP_Active
        return

    HoldHP_Running := true
    try {
        HoldHP_PrevSet := CurrentArmorSet
        EquipArmorSet("HP")
        ; If the player is physically holding LButton (left-click move), re-assert it
        ; without generating an up event. This helps movement continue after equip clicks.
        if GetKeyState("LButton", "P")
            Send("{LButton down}")
        ; Mirror the same behavior for RButton (right-click hold use cases).
        if GetKeyState("RButton", "P")
            Send("{RButton down}")
        HoldHP_Active := true
    } finally {
        HoldHP_Running := false
    }
}

HoldHPUp(*) {
    global HoldHP_Active, HoldHP_Running, HoldHP_PrevSet
    if HoldHP_Running
        return
    if !HoldHP_Active
        return

    HoldHP_Running := true
    try {
        ; Return to the set that was active when the hold began.
        EquipArmorSet(HoldHP_PrevSet)
        if GetKeyState("LButton", "P")
            Send("{LButton down}")
        if GetKeyState("RButton", "P")
            Send("{RButton down}")
        HoldHP_Active := false
    } finally {
        HoldHP_Running := false
    }
}

; HoldMPDown / HoldMPUp
; While held: equips MP set. On release: returns to previous set.
HoldMPDown(*) {
    global HoldMP_Active, HoldMP_Running, HoldMP_PrevSet, CurrentArmorSet
    if HoldMP_Running
        return
    if HoldMP_Active
        return

    HoldMP_Running := true
    try {
        HoldMP_PrevSet := CurrentArmorSet
        EquipArmorSet("MP")
        if GetKeyState("LButton", "P")
            Send("{LButton down}")
        if GetKeyState("RButton", "P")
            Send("{RButton down}")
        HoldMP_Active := true
    } finally {
        HoldMP_Running := false
    }
}

HoldMPUp(*) {
    global HoldMP_Active, HoldMP_Running, HoldMP_PrevSet
    if HoldMP_Running
        return
    if !HoldMP_Active
        return

    HoldMP_Running := true
    try {
        EquipArmorSet(HoldMP_PrevSet)
        if GetKeyState("LButton", "P")
            Send("{LButton down}")
        if GetKeyState("RButton", "P")
            Send("{RButton down}")
        HoldMP_Active := false
    } finally {
        HoldMP_Running := false
    }
}

; One pulse: swap into HP just before the server tick, then return after HoldMs.
; Schedule the next pulse aligned to server :00/:15/:30/:45 (using local clock + configured offset)
; Get local seconds + milliseconds using Windows API (stable, not based on A_TickCount)
; Hard-block user keyboard/mouse input during the swap window so clicks/inputs
; can't desync equipment actions. Send/Click from the script still works.
EatFood(*) {
    BlockInput "MouseMove"
    MouseGetPos &begin_x, &begin_y ; Get the position of the mouse

    ; Snapshot physical mouse button state so we can restore it after closing the bag.
    wasLDown := GetKeyState("LButton", "P")
    wasRDown := GetKeyState("RButton", "P")

    if (wasLDown) {
        Send("{LButton up}")
    }
    if (wasRDown) {
        Send("{RButton up}")
    }

    Send "{F6}"
    Sleep 10
    MouseClick("L", 744, 331, 2, 0)
    Sleep 10
    MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
    Send "{F6}"
    Sleep 10

    ; If the player is still physically holding the button, "stitch" the hold back together.
    if (wasLDown) {
        MouseClick("L", begin_x, begin_y, 1, 0)
        if (GetKeyState("LButton", "P"))
            Send("{LButton down}")
    }
    if (wasRDown) {
        MouseClick("R", begin_x, begin_y, 1, 0)
        if (GetKeyState("RButton", "P"))
            Send("{RButton down}")
    }

    BlockInput "MouseMoveOff"
}
DetectInvisScroll(*) {
    BlockInput "MouseMove"
    MouseGetPos &begin_x, &begin_y ; Get the position of the mouse

    ; Snapshot physical mouse button state so we can restore it after closing the bag.
    wasLDown := GetKeyState("LButton", "P")
    wasRDown := GetKeyState("RButton", "P")

    if (wasLDown) {
        Send("{LButton up}")
    }
    if (wasRDown) {
        Send("{RButton up}")
    }

    local clickX := CtPixel(86.5, "X")
    local clickY := CtPixel(55, "Y")

    Send "{F6}"
    Sleep 10
    MouseClick("L", clickX, clickY, 2, 0)
    Sleep 10
    MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
    Send "{F6}"
    Sleep 10

    ; If the player is still physically holding the button, "stitch" the hold back together.
    if (wasLDown) {
        MouseClick("L", begin_x, begin_y, 1, 0)
        if (GetKeyState("LButton", "P"))
            Send("{LButton down}")
    }
    if (wasRDown) {
        MouseClick("R", begin_x, begin_y, 1, 0)
        if (GetKeyState("RButton", "P"))
            Send("{RButton down}")
    }

    BlockInput "MouseMoveOff"
}

EquipItem(items, preserveMouse := false) {
    ; If a single value was passed, wrap it in an array
    if !IsObject(items)
        items := [items]

    BlockInput "MouseMove"
    MouseGetPos &begin_x, &begin_y

    ; Snapshot physical mouse button state so we can restore it after closing the bag (optional).
    wasLDown := GetKeyState("LButton", "P")
    wasRDown := GetKeyState("RButton", "P")

    if (wasLDown) { ; If we're holding down M1 (left mouse button), release it
        Send("{LButton up}")
    }
    if (wasRDown) { ; if we are holding down m2
        Send("{RButton up}")
    }

    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}"

    for index in items {
        MouseClick("L", InventorySlotPos[index][1], InventorySlotPos[index][2],, 0)
    }

    Send "{Ctrl up}"
    Sleep 10
    Send "{F6}"
    Sleep 10
    MouseMove begin_x, begin_y, 0

    if (preserveMouse) {
        ; If the player is still physically holding the button, "stitch" the hold back together.
        if (wasLDown) {
            MouseClick("L", begin_x, begin_y, 1, 0)
            if (GetKeyState("LButton", "P"))
                Send("{LButton down}")
        }
        if (wasRDown) {
            MouseClick("R", begin_x, begin_y, 1, 0)
            if (GetKeyState("RButton", "P"))
                Send("{RButton down}")
        }
    }

    BlockInput "MouseMoveOff"
}

EquipAndActivateItem(item) {
    EquipItem(item, true)
    Sleep 250
    ItemActivation
}

PretendCorpse(*) {
    BlockInput "MouseMove"
    MouseClick "right"
    Sleep 10
    MouseClick "right"
    MouseGetPos &begin_x, &begin_y ; Get the position of the mouse

    RemoveHolds()

    if (GetKeyState("LButton", "P")) { ; If we're holding down M1 (left mouse button), release it
        Send("{LButton up}")
    }
    if (GetKeyState("RButton", "P")) { ; if we are holding down m2
        Send("{RButton up}")
    }

    Send "{F8}"
    Sleep 10
    PretendCorpseButtonCoords := GetPretendCorpCoords()
    if (PretendCorpseButtonCoords[1] != "" && PretendCorpseButtonCoords[2] != "") {
        MouseClick("L", PretendCorpseButtonCoords[1] + 10, PretendCorpseButtonCoords[2] + 5, 1, 0)
    Sleep 10
    }
    MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
    Send "{F8}"
    BlockInput "MouseMoveOff"
}
TakeInvisPot(*) {
    BlockInput "MouseMove"
    MouseGetPos &begin_x, &begin_y ; Get the position of the mouse

    ; Snapshot physical mouse button state so we can restore it after closing the bag.
    wasLDown := GetKeyState("LButton", "P")
    wasRDown := GetKeyState("RButton", "P")

    RemoveHolds()

    if (wasLDown) {
        Send("{LButton up}")
    }
    if (wasRDown) {
        Send("{RButton up}")
    }

    Send "{F6}"
    Sleep 10
    ;MouseClick("L", 744, 331, 2, 0)
    MouseClick("L", CtPixel(90, "X"), CtPixel(55.2, "Y"), 2, 0)
    Sleep 10
    MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
    Send "{F6}"
    Sleep 10

    ; If the player is still physically holding the button, "stitch" the hold back together.
    if (wasLDown) {
        MouseClick("L", begin_x, begin_y, 1, 0)
        if (GetKeyState("LButton", "P"))
            Send("{LButton down}")
    }
    if (wasRDown) {
        MouseClick("R", begin_x, begin_y, 1, 0)
        if (GetKeyState("RButton", "P"))
            Send("{RButton down}")
    }

    BlockInput "MouseMoveOff"

    Effects.Push(StatusEffectIndicator("images\Invis.png", 60, ""))
}