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
        this.CoordText := gGUI.Add("Text", "x" CtPixel(28.3, "X") " y" CtPixel(95.1, "Y") " w" CtPixel(21.2, "X") " cLime Center", "XXXXXXXX YYYYYYYY")
        this.CoordText.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")

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
    
        MouseGetPos(&MouseX, &MouseY)
        this.CoordText.Value := Format("X: {:.2f}%, Y: {:.2f}%", CtPercent(MouseX, "X"), CtPercent(MouseY, "Y"))
        this.StatusText.SetFont(A_IsSuspended ? "cff9c9c" : "c16ff58")
        this.HealthPotText.SetFont(bTryHPPotting ? "c16ff58" : "cff9c9c")
        this.ManaPotText.SetFont(bTryManaPotting ? "c16ff58" : "cff9c9c")
    }
}