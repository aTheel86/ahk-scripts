Global RepCoolDownTime := 3600000
Global RepMessageInterval := 600000
Global TopLeftPos := []
Global TopRightPos := []
Global BottomLeftPos := []
Global BottomRightPos := []
Global PeaceModeTR_Pixel := []
Global PeaceModeBL_Pixel := []

TopLeftPos.Push(CtPixel(38.7, "X"))
TopLeftPos.Push(CtPixel(52.1, "Y"))

TopRightPos.Push(CtPixel(69.7, "X"))
TopRightPos.Push(CtPixel(52.1, "Y"))

BottomLeftPos.Push(CtPixel(38.7, "X"))
BottomLeftPos.Push(CtPixel(64.9, "Y"))

BottomRightPos.Push(CtPixel(69.7, "X"))
BottomRightPos.Push(CtPixel(64.9, "Y"))

PeaceModeBL_Pixel.Push(CtPixel(57, "X"))
PeaceModeBL_Pixel.Push(CtPixel(97.2, "Y"))

PeaceModeTR_Pixel.Push(CtPixel(58.3, "X"))
PeaceModeTR_Pixel.Push(CtPixel(94.3, "Y"))

; Example color codes to match
Global ExpectedColors := ["0x7B7352", "0x8C7329", "0x7B7352", "0x9C8439"]
Global PeaceModeColors := ["0x272727", "0x3D3D3D"]

DelayStartUpDown := ""
   
CheckPixelColors() { ; Function to check if the specified pixels match the given colors
    ActualColors := []
    ActualColors.Push(PixelGetColor(TopLeftPos[1], TopLeftPos[2])) ; Get the actual colors from the specified positions
    ActualColors.Push(PixelGetColor(TopRightPos[1], TopRightPos[2]))
    ActualColors.Push(PixelGetColor(BottomLeftPos[1], BottomLeftPos[2]))
    ActualColors.Push(PixelGetColor(BottomRightPos[1], BottomRightPos[2]))

    ; Check if all colors match
    for index, color in ExpectedColors {
        if (color != ActualColors[index]) {
            return false
        }
    }
    return true
}

ActivateAutoTradeRep() {
    SwitchToPeaceMode() ; Make sure we are in peace mode
    Sleep 100

    myGui := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000 -Border")

    ; Add the UpDown control and other components to the GUI
    myGui.Add("Text",, "Set Delay Time (seconds):")
    UpDownButton := myGui.Add("UpDown", "Range1-3000", 5)
    OKButton := myGui.Add("Button", "Default vOKButton", "OK")
    OKButton.OnEvent("Click", (*) => BeginTradeButtonSubmit(myGui, UpDownButton))

    ; Show the GUI
    myGui.Show("x" ScreenResX / 2 " y" ScreenResY / 2 " NA NoActivate")
    
    ; Ensure the window stays on top and non-interactive
    WinSetAlwaysOnTop(1, myGui.Hwnd)
    WinSetExStyle("+0x80000", myGui.Hwnd)  ; WS_EX_NOACTIVATE
}

BeginTradeButtonSubmit(myGui, UpDownButton) {
    global bAutoTradeRepping

    bAutoTradeRepping := true   
    DelayTime := UpDownButton.Value  ; Accessing UpDown control's value directly
    myGui.Destroy()

    if (DelayTime >= 1) { ; Check if the delay time is valid and proceed
        Sleep DelayTime * 1000  ; Convert seconds to milliseconds
        SetTimer(AutoTradeRep, 1000)
    } 
}

SwitchToPeaceMode()
{
    Actual_BLColor := PixelGetColor(PeaceModeBL_Pixel[1], PeaceModeBL_Pixel[2])
    Actual_TRColor := PixelGetColor(PeaceModeTR_Pixel[1], PeaceModeTR_Pixel[2])

    ; If both colors do not match, then click the peace mode button to switch to it
    if (Actual_BLColor != PeaceModeColors[1] && Actual_TRColor != PeaceModeColors[2]) {
        BlockInput "MouseMove"
        MouseGetPos &begin_x, &begin_y ; Get the position of the mouse
        Sleep 10
        MouseClick("L", CtPixel(58, "X"), CtPixel(96, "Y"))
        Sleep 10
        MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
        BlockInput "MouseMoveOff"        
    }
}

AutoTradeRep(*) {
    Global stopFlag, bAutoTradeRepping

    Static bTypedInTrade := false
    Static LastRepElapsedTime := RepCoolDownTime
    Static LastRepMessageElapsedTime := RepMessageInterval
    Static RandomTime := 0
    Static RandomDelay := 0

    if (stopFlag) {
        bAutoTradeRepping := false
        stopFlag := false
        SetTimer(AutoTradeRep, 0)
        return
    }

    LastRepElapsedTime += 1000

    if (LastRepElapsedTime < RepCoolDownTime + RandomDelay) {
        RandomDelay := Random(1, 300000)
        return ; Return if we are still on rep cooldown
    }
    else { ; Ready to rep
        if (LastRepMessageElapsedTime > RepMessageInterval + RandomTime) {
            RandomTime := Random(-300000, 300000)

            if (!bTypedInTrade)
            {
                SendTextMessage("%Trade rep") ; First one to make sure we are in % trade chat!
            }
            else
            {
                RandomTradeRepMessage := GetRandomTradeRep()
                SendTextMessage(RandomTradeRepMessage)
            }
            LastRepMessageElapsedTime := 0
        }
        else {
            LastRepMessageElapsedTime += 1000
        }

        ; Lets check to see if we have a trade request dialog we should accept
        if (CheckPixelColors()) {
            BlockInput "MouseMove"
            Sleep 20
			MouseGetPos &begin_x, &begin_y ; Get the position of the mouse
            MouseClick("L", CtPixel(45, "X"), CtPixel(63, "Y"))
			Sleep 700
			MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
			BlockInput "MouseMoveOff"

            LastRepMessageElapsedTime := RepMessageInterval
            LastRepElapsedTime := 0
            RepButtonInst.StartTiming()
        }
    }
}

SendTradeRepMessage() {
    RandomTradeRepMessage := GetRandomTradeRep()
    SendTextMessage("%" RandomTradeRepMessage)
}

GetRandomTradeRep() {
    ; Define the messages and their weights
    messages := [
        {msg: "Trade Rep", weight: 70},
        {msg: "Trade rep", weight: 50},
        {msg: "trad erep", weight: 10},
        {msg: "trade rep\", weight: 5},
        {msg: "trade rep", weight: 5},
        {msg: "traderep", weight: 5},
        {msg: "trader ep", weight: 5},
        {msg: "Trad rep", weight: 5},
        {msg: "Trade repp", weight: 5},
        {msg: "Trade rep pls", weight: 5},
        {msg: "TradE rep", weight: 5},
        {msg: "Trade REP", weight: 5},
        {msg: "TRADE REP", weight: 5},
        {msg: "trade repo", weight: 5},
        {msg: "Can I get a trade rep?", weight: 5},
        {msg: "Rep trade?", weight: 5},
        {msg: "TRade Rep", weight: 15},
        {msg: "rtRade Prep", weight: 1},
        {msg: "trade the rep", weight: 5},
        {msg: "trade reep", weight: 5},
        {msg: "tradee rep", weight: 1},
        {msg: "TRADE REP", weight: 5}
    ]

    totalWeight := 0
    weightedList := []
    
    ; Prepare a weighted list
    for message in messages {
        totalWeight += message.weight
        Loop message.weight {
            weightedList.Push(message.msg)
        }
    }

    ; Generate a random index based on the total weight
    randomIndex := Random(1, totalWeight)
    return weightedList[randomIndex]
}

/*
+C:: ; alt+c useful for debugging
{
    ;A_Clipboard := PixelGetColor(TopLeftPos[1], TopLeftPos[2]) " " PixelGetColor(TopRightPos[1], TopRightPos[2]) " " PixelGetColor(BottomLeftPos[1], BottomLeftPos[2]) " " PixelGetColor(BottomRightPos[1], BottomRightPos[2]) 
    A_Clipboard := PixelGetColor(PeaceModeBL_Pixel[1], PeaceModeBL_Pixel[2]) " " PixelGetColor(PeaceModeTR_Pixel[1], PeaceModeTR_Pixel[2])
}
*/