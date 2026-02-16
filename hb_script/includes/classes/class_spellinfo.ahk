class SpellInfo {
	__Initialize() { ; Initialize instance variables *Important: will flag errors if omitted* TODO: perhaps these just need to be class variables
		MagicPage := ""
		YCoord := ""
		HotKeyName := ""
		SpellEffectImg := ""
		SpellEffectDuration := ""

		RequiredWandSlot := ""
	}

    __New(aSpellName, aMagicPage, aCoord, aHK, eImg := "", eDuration := "", requiredWandSlot := "") { ; Constructor
		this.SpellName := aSpellName
        this.MagicPage := aMagicPage
        this.YCoord := aCoord
		this.HotKeyName := aHK
		this.SpellEffectImg := eImg
		this.SpellEffectDuration := eDuration
		this.RequiredWandSlot := requiredWandSlot

		if (this.HotKeyName != "") {
			Hotkey(this.HotKeyName, this.CastSpell.Bind(this), "ON") ; Bind the hotkey so whenever it is struck it calls the CastSPell function
		}

		; Add to global tracking array
        global SpellInfoInstances
        SpellInfoInstances.Push(this)
    }

	Disable(*) {
		Hotkey(this.HotKeyName, DoNothing, "Off")
	}

	CastSpell(*) {
		Global CastingEffectSpell, LastCastspell

		if WinActive(WinTitle) ; This supposedly stops the hotkey from working outside of the HB client
		{
			BlockInput "MouseMove"
			MouseGetPos &begin_x, &begin_y ; Get the position of the mouse

			if (GetKeyState("LButton", "P")) ; if we are holding down m1, like when we are chasing someone, the cast should interrupt the run so the cast doesn't fail
			{
				Send("{LButton up}")
			}

			if (GetKeyState("RButton", "P")) ; if we are holding down m1, like when we are chasing someone, the cast should interrupt the run so the cast doesn't fail
			{
				Send("{RButton up}")
			}


			; Wand-required spells: equip ONLY when RequiredWandSlot is a positive integer (> 0).
			; Blank, missing, or 0 means: do NOT equip, just cast.
			wandSlot := 0
			wandSlotStr := Trim(this.RequiredWandSlot)
			if (wandSlotStr != "" && RegExMatch(wandSlotStr, "^\d+$"))
				wandSlot := Integer(wandSlotStr)
			if (wandSlot > 0) {
				EquipItem([wandSlot], true)
				Sleep 10
			}
			Send("^{" this.MagicPage "}") ; Open Magic menu tab ^{#}
			Sleep 10
			MouseClick("L", CtPixel(SpellHorizontalPos, "X"), CtPixel(this.YCoord, "Y"),, 0)
			Sleep 10
			MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
			BlockInput "MouseMoveOff"

			; Post-cast restore (one-shot): for specific wand-required spells, restore main wand + angel after the next cast click.
			if (this.SpellName = "MiM" || this.SpellName = "InhibitionCasting" || this.SpellName = "Cancel")
				PostCastRestore_Arm()

			LastCastspell := this.SpellName

			if (this.SpellEffectDuration != "")
			{	
				CastingEffectSpell := [] ; Must set the variable as an array to start.
				CastingEffectSpell.Push(this.SpellEffectImg)
				CastingEffectSpell.Push(this.SpellEffectDuration)
			}
		}
	}
}

; ───────────────────────────────────────────────────────────────────────────────
; Post-cast restore helper (MiM / InhibitionCasting / Cancel only)
; Arms after spell selection, then watches for the next physical LButton click
; (down → up). On that click, restores main wand (slot 2) + angel (slot 13).
; Does NOT affect IceStorm.
; ───────────────────────────────────────────────────────────────────────────────
global __PCR_Armed := false
global __PCR_ExpireAt := 0
global __PCR_PrevDown := false
global __PCR_SeenDown := false

PostCastRestore_Arm(timeoutMs := 3500) {
    global __PCR_Armed, __PCR_ExpireAt, __PCR_PrevDown, __PCR_SeenDown
    __PCR_Armed := true
    __PCR_ExpireAt := A_TickCount + timeoutMs
    __PCR_PrevDown := GetKeyState("LButton", "P")
    __PCR_SeenDown := false
    SetTimer(PostCastRestore_Tick, 10)
}

PostCastRestore_Disarm() {
    global __PCR_Armed
    __PCR_Armed := false
    SetTimer(PostCastRestore_Tick, 0)
}

PostCastRestore_Tick() {
    global __PCR_Armed, __PCR_ExpireAt, __PCR_PrevDown, __PCR_SeenDown

    if (!__PCR_Armed) {
        SetTimer(PostCastRestore_Tick, 0)
        return
    }

    if (A_TickCount >= __PCR_ExpireAt) {
        PostCastRestore_Disarm()
        return
    }

    down := GetKeyState("LButton", "P")

    ; Detect a fresh click cycle: transition up→down (start), then down→up (finish)
    if (!__PCR_SeenDown && !__PCR_PrevDown && down)
        __PCR_SeenDown := true

    if (__PCR_SeenDown && __PCR_PrevDown && !down) {
        ; Click completed: restore main wand + angel.
        try {
            EquipItem([2, 13], true)
        } catch {
            ; Fail silently (avoid breaking casting). If needed, we can add debug later.
        }
        PostCastRestore_Disarm()
        return
    }

    __PCR_PrevDown := down
}
