class GUIManager {
    CoordText := ""
    StatusText := ""
    HealthPotText := ""
    ManaPotText := ""
    InvSlotHelpers := []

    __New() {
        this.InitializeGUI()
    }

    InitializeGUI() {
        this.CoordText := gGUI.Add(
            "Text",
            "x" CtPixel(28.3,"X")
            . " y" CtPixel(92.0,"Y")
            . " w" CtPixel(21.2,"X")
            . " h" CtPixel(4.0,"Y")
            . " cLime Center",
            "XXXXXXXX YYYYYYYY"
        )
        this.CoordText.SetFont("s" CalculateFontSize(2) " bold", "Segoe UI")

        this.StatusText := gGUI.Add("Text", "x" CtPixel(6.9, "X") " y" CtPixel(92.9166, "Y") " cWhite", "Script")
        this.StatusText.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")

        this.HealthPotText := gGUI.Add("Text", "x" CtPixel(10.31, "X") " y" CtPixel(93, "Y") " cWhite", "H")
        this.HealthPotText.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")

        this.ManaPotText := gGUI.Add("Text", "x" CtPixel(10.31, "X") " y" CtPixel(96.7, "Y") " cWhite", "M")
        this.ManaPotText.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")

        this.AutoTradeRepText := gGUI.Add("Text", "cWhite", "Auto Trade Repping")
        this.AutoTradeRepText.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")
        this.AutoTradeRepText.Move(CtPixel(90, "X"), CtPixel(91.75, "Y"))
        this.AutoTradeRepText.Visible := false

        this.OptionsMenuButton := gGUI.Add("Button", "x" CtPixel(1, "X") " y" CtPixel(94, "Y") " w30 h20", "Menu")
        this.OptionsMenuButton.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")
        this.OptionsMenuButton.OnEvent("Click", MainMenu)

        ;this.MyBtn := gGUI.Add("Button", "x400 y570 w30 h20", "TradeRep")
        ;this.MyBtn.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")
        ;this.MyBtn.OnEvent("Click", ToggleDebugMode)

        ; Create a text control for each coordinate in InventorySlotPos
        for index, coord in InventorySlotPos {
            if (coord.Length) {
                this.InvSlotHelpers.Push(gGUI.Add("Text", "x" coord[1] - 6 " y" coord[2] - 4 " w15 h15 Center cFuchsia", index))
            }
        }

        if (IniRead(ConfigFile, "Settings", "UseAutoPotting") != "true") {
            this.HealthPotText.Visible := false
            this.ManaPotText.Visible := false
        }
    
        SetTimer(this.UpdateOSD.Bind(this), 200)
    }

    UpdateOSD() {
        for control in this.InvSlotHelpers {
            if IsObject(control) {
                if (!bDebugMode) {
                    control.Visible := false
                }
                else {
                    control.Visible := true
                }
            }
        }

        if (bAutoTradeRepping) {
            this.AutoTradeRepText.Visible := true
        }
        else {
            this.AutoTradeRepText.Visible := false
        }
    
        ;MouseGetPos(&MouseX, &MouseY)
        ;this.CoordText.Value := Format("X: {:.2f}%, Y: {:.2f}%", CtPercent(MouseX, "X"), CtPercent(MouseY, "Y"))
        ;UpdatePlayerCoords()
        this.CoordText.Value := Format("({:d}, {:d})", playerGameCoords[1], playerGameCoords[2])
        this.StatusText.SetFont(A_IsSuspended ? "cff9c9c" : "c16ff58")
        this.HealthPotText.SetFont(bTryHPPotting ? "c16ff58" : "cff9c9c")
        this.ManaPotText.SetFont(bTryManaPotting ? "c16ff58" : "cff9c9c")
    }
}

class ImageOverlay {
    __New() {
        this.sfx1 := this._MakeIconGui()
        this.sfx2 := this._MakeIconGui()

        this.sfx1.busy := false
        this.sfx2.busy := false

        this.off1 := {x: -12, y: 40}
        this.off2 := {x: -12, y: 50}

        this.w1 := 8, this.h1 := 8
        this.w2 := 8, this.h2 := 8
    }

    _MakeIconGui() {
        g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        g.BackColor := "Fuchsia"
        WinSetTransColor("Fuchsia", g.Hwnd)
        pic := g.AddPicture("x0 y0 w8 h8", "")
        pic.Visible := false

        SetTimer(this.Update.Bind(this), 50)

        return {g:g, pic:pic}
    }

    ShowEnchantIcon(imgPath, w := 8, h := 8) {
        if (!this.sfx1.busy) {
            slot := this.sfx1, this.w1 := w, this.h1 := h
        } else if (!this.sfx2.busy) {
            slot := this.sfx2, this.w2 := w, this.h2 := h
        } else
            return

        slot.busy := true
        slot.pic.Value := imgPath
        slot.pic.Move(0, 0, w, h)
        slot.pic.Visible := true
        this._PositionSlot(slot, w, h)
    }

    Update() {
        if (this.sfx1.busy)
            this._PositionSlot(this.sfx1, this.w1, this.h1)
        if (this.sfx2.busy)
            this._PositionSlot(this.sfx2, this.w2, this.h2)
    }

    _PositionSlot(slot, w, h) {
        MouseGetPos(&mx, &my)
        off := (slot = this.sfx1) ? this.off1 : this.off2
        slot.g.Show("NA x" (mx + off.x) " y" (my + off.y) " w" w " h" h)
    }

    HideAll() {
        for _, slot in [this.sfx1, this.sfx2] {
            slot.pic.Visible := false
            slot.g.Hide()
            slot.busy := false
        }
    }
}

global MarkIndicators := ImageOverlay()

class DebugROI {
    __New(borderPx := 3, color := "Lime") {
        this.b := borderPx
        this.color := color

        this.g := Gui("+AlwaysOnTop -Caption +ToolWindow")
        this.g.BackColor := "Fuchsia"
        ;WinSetTransColor("Fuchsia", this.g.Hwnd)   ; make background transparent

        this.visible := false
    }

    ShowRect(x1, y1, x2, y2) {
        this.g.Show("NA x" x1 " y" y1 " w" x2-x1 " h" y2-y1)
        this.visible := true
    }

    Hide() {
        this.g.Hide()
        this.visible := false
    }

    Toggle() {
        this.visible := !this.visible
    }
}

;Global Dbg := DebugROI(3, "Lime")