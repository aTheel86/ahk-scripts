class AmpSnapIndicator {
    static instances := []

    __New(value, durationSeconds := 60) {
        this.value := value
        this._timeRemaining := durationSeconds - 1
        this._isActive := false

        this._countdownMode := false
        this.slotW := 34          ; fixed width allocation per indicator for layout
        this.slotH := 24
        this.gap := 6
        this.topY := 4            ; y position for the row at top of screen

        this.CreateGui()

        AmpSnapIndicator.instances.Push(this)
        AmpSnapIndicator.RepositionAll()

        this._isActive := true
        this.Show()

        ; tick once per second, used only for auto-expire
        SetTimer(this.UpdateTimer.Bind(this), 1000)
    }

    CreateGui() {
        this.Gui := Gui("+AlwaysOnTop +ToolWindow -Caption +E0x20", "AmpSnap")
        this.Gui.BackColor := "010203"
        WinSetTransColor("010203", this.Gui.Hwnd)

        ; Just the number (no countdown), keep readable
        this.txt := this.Gui.AddText("x0 y0 w" this.slotW " h" this.slotH " Center cFFFFFF +0x200", this.value)
        this.txt.SetFont("s16 w700", "Segoe UI")
    }

    Show() {
        x := this.GetX()
        this.Gui.Show("x" x " y" this.topY " w" this.slotW " h" this.slotH " NA NoActivate")
    }

    GetX() {
        idx := -1
        for i, instance in AmpSnapIndicator.instances {
            if (instance = this) {
                idx := i
                break
            }
        }
        if (idx < 1)
            return 0

        count := AmpSnapIndicator.instances.Length
        totalW := (count * this.slotW) + ((count - 1) * this.gap)
        startX := (A_ScreenWidth // 2) - (totalW // 2)

        return startX + ((idx - 1) * (this.slotW + this.gap))
    }

    static RepositionAll() {
        for _, instance in AmpSnapIndicator.instances {
            if instance && instance._isActive {
                try instance.Show()
            }
        }
    }

    UpdateTimer() {
        if (!this._isActive)
            return

        ; When the indicator is about to expire, show a 5..0 countdown
        if (this._timeRemaining <= 5) {
            ; Switch the countdown text to red once (leave normal indicators white)
            if (!this._countdownMode) {
                this._countdownMode := true
                try this.txt.Opt("cFF0000")
            }

            try this.txt.Value := this._timeRemaining

        }

        this._timeRemaining -= 1
        if (this._timeRemaining < 0) {
            this.Destroy()
        }
    }

    Destroy() {
        if (!this._isActive)
            return
        this._isActive := false

        ; remove self
        for i, instance in AmpSnapIndicator.instances {
            if (instance = this) {
                AmpSnapIndicator.instances.RemoveAt(i)
                break
            }
        }

        try this.Gui.Destroy()
        AmpSnapIndicator.RepositionAll()
    }
}
