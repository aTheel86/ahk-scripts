class SpellInfo {
	__Initialize() { ; Initialize instance variables *Important: will flag errors if omitted* TODO: perhaps these just need to be class variables
		MagicPage := ""
		YCoord := ""
		HotKeyName := ""
		SpellEffectImg := ""
		SpellEffectDuration := ""
	}

    __New(aSpellName, aMagicPage, aCoord, aHK, eImg := "", eDuration := "") { ; Constructor
		this.SpellName := aSpellName
        this.MagicPage := aMagicPage
        this.YCoord := aCoord
		this.HotKeyName := aHK
		this.SpellEffectImg := eImg
		this.SpellEffectDuration := eDuration

		Hotkey(this.HotKeyName, this.CastSpell.Bind(this), "ON") ; Bind the hotkey so whenever it is struck it calls the CastSPell function

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

			Send("^{" this.MagicPage "}") ; Open Magic menu tab ^{#}
			Sleep 10
			MouseClick("L", CtPixel(SpellHorizontalPos, "X"), CtPixel(this.YCoord, "Y"),, 0)
			Sleep 10
			MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
			BlockInput "MouseMoveOff"

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