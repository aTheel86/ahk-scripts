Global RepCoolDownTime := 3610000
Global RepMessageInterval := 90000 ;90 seconds
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

TradeRepConfirmButton := NodeInfo("TradeRepConfirmButton", "images\node_images\TradeRepConfirmImage.png",,, [2,1])

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
    DisableDialogTransparency()
    Sleep 50

    myGui := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000 -Border")

    ; Add the UpDown control and other components to the GUI
    myGui.Add("Text",, "Set Delay Time in Seconds:")
    UpDownButton := myGui.Add("UpDown", "Range1-3000", 5)
    OKButton := myGui.Add("Button", "x7 y25 w40 h25", "Start")
    OKButton.OnEvent("Click", (*) => BeginTradeButtonSubmit(myGui, UpDownButton))
    CancelButton := myGui.Add("Button", "x53 y25 w46 h25", "Cancel")
    CancelButton.OnEvent("Click", (*) => myGui.Destroy())

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

    Static LastRepElapsedTime := RepCoolDownTime
    Static LastRepMessageElapsedTime := RepMessageInterval
    Static RepMessageAttempts := 0

    if (stopFlag) {
        bAutoTradeRepping := false
        stopFlag := false
        SetTimer(AutoTradeRep, 0)
        return
    }

    LastRepElapsedTime += 1000

    if (LastRepElapsedTime < RepCoolDownTime) {
        return ; Return if we are still on rep cooldown
    }
    else { ; Ready to rep
        if (LastRepMessageElapsedTime > RepMessageInterval + Random(0, 60000)) {
            SendTradeRepMessage()
            ;ToolTip "Trying to Send Rep Message"
            ;Sleep 5000
            ;ToolTip ""
            LastRepMessageElapsedTime := 0

            if (RepMessageAttempts >= 4) {
                ExitApp
            }
            RepMessageAttempts++
        }
        else {
            LastRepMessageElapsedTime += 1000
        }

        ; Lets check to see if we have a trade request dialog we should accept
        if (TradeRepConfirmButton.IsOnScreen()) {
            BlockInput "MouseMove"
            Sleep 20
			MouseGetPos &begin_x, &begin_y ; Get the position of the mouse
            TradeRepConfirmButton.Click()
			Sleep 100
			MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
			BlockInput "MouseMoveOff"

            LastRepMessageElapsedTime := RepMessageInterval
            LastRepElapsedTime := 0
            RepButtonInst.StartTiming()
            RepMessageAttempts := 0
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
        {msg: "trade rep", weight: 5},
        {msg: "rep tab", weight: 5},
        {msg: "trade rep tab", weight: 5}
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

CheckForRepMessage(*) {
    static sX1 := 0, sX2 := 0, sY1 := 0, sY2 := 0

    try {
        if (ImageSearch(&x, &y, 0, 0, 800, 600, "*TransBlack images\rep_images\chat_search.png")) {
            sX1 := x
            sX2 := x + 345 ;345 is roughly the width of default chat box
            sY1 := Max(y - 28, 0)
            sY2 := Min(y + 5, 600)

            ;MouseMove(sX1, sY1, 3)
            ;MouseMove(sX2, sY1, 3)
            ;MouseMove(sX2, sY2, 3)
            ;MouseMove(sX1, sY2, 3)
            ;MouseMove(sX1, sY1, 3)
        }
        else {
            ToolTip "No chat box"
            Send("{F9}")
            Sleep 1000
            ToolTip ""
            return false
        }
    } catch {
        return false
    }

    try { 
        if (ImageSearch(&x, &y, sX1, sY1, sX2, sY2, "*TransBlack images\rep_images\rep_blue_lc.png")) {
            return [x,y]
        }
    } catch {
    }

    try { 
        if (ImageSearch(&x, &y, sX1, sY1, sX2, sY2, "*TransBlack images\rep_images\rep_white_lc.png")) {
            return [x,y]
        }
    } catch {
    }

    return false
}

IsImagePresent(ImgString) {
    try {
        if (ImageSearch(&x, &y, 0, 0, 800, 600, "*TransBlack " ImgString)) {
            return true
        }
    } catch {
    }

    return false
}

CheckForSuccessfulRep(*) {
    try { 
        if (ImageSearch(&x, &y, 0, 528, 300, 546, "*TransBlack images\rep_images\rep_success.png")) {
            return true
        }
    } catch {
    }

    return false
}

StartAutoIncognitoRep(*)
{   
    SetTimer(AutoIncognitoRep, 250)
}

AutoIncognitoRep(*) {
    Global stopFlag, bAutoTradeRepping

    Static NextRepMonitorTime := 0
    Static RecentAttempts := 0
    static LastAttemptDecay := 0

    if (stopFlag) {
        bAutoTradeRepping := false
        stopFlag := false
        SetTimer(AutoIncognitoRep, 0)
        return
    }

    bAutoTradeRepping := true

    ; decay once every 10s
    if (A_TickCount - LastAttemptDecay >= 10000) {
        if (RecentAttempts > 0)
            RecentAttempts--

        LastAttemptDecay := A_TickCount
    }

    ; Success detected: reset attempts, start cooldown, close chat (once)
Static LastSuccessHandled := 0
if (CheckForSuccessfulRep()) {
    RecentAttempts := 0
    NextRepMonitorTime := A_TickCount + RepCoolDownTime + Random(5000,10000)
    RepButtonInst.StartTiming()

    ; If the success image lingers, don't spam this branch every 250ms
    if (A_TickCount - LastSuccessHandled > 3000) {
        ; Only toggle chat if it appears open
        try {
            if (IsImagePresent("images\rep_images\chat_search.png"))
                Send "{F9}"
        }
        LastSuccessHandled := A_TickCount
    }
    return
}

    if (NextRepMonitorTime > A_TickCount) {
        return
    }

    coords := CheckForRepMessage()

    ; Validate checks
    if (!coords || Type(coords) != "Array" || coords.Length < 2) {
        return
    }

    x := coords[1], y := coords[2]
    if !(x is Number) || !(y is Number) {
        return
    }

    ; Attempt to trade (bulletproof: block input, preserve mouse only)
try {
    ; Preserve mouse state
    MouseGetPos(&begin_x, &begin_y)
    lDown := GetKeyState("LButton", "P")
    rDown := GetKeyState("RButton", "P")

    ; Block ALL physical input during the incog action so clicks can't interfere
    BlockInput "On"

    Sleep 10
    MouseMove(x-20, y+3, 0)
    Sleep 10

    ; Do NOT preserve modifiers: we intentionally force a clean state
    Send "{Ctrl down}{Shift down}"
    Sleep 5
    Send "{t}"
    Sleep 10
}
finally { ; ALWAYS restore, even if something throws
    NextRepMonitorTime := A_TickCount + Random(5000,15000)

    ; Safety: never leave modifiers stuck
    Send "{Ctrl up}{Shift up}{Alt up}"
    Sleep 10

    ; Restore mouse position + button states
    MouseMove begin_x, begin_y, 0
    if (lDown)
        Send "{LButton down}"
    else
        Send "{LButton up}"

    if (rDown)
        Send "{RButton down}"
    else
        Send "{RButton up}"

    ; Re-enable input
    BlockInput "Off"

    RecentAttempts++
    Sleep 1000
}

    if (RecentAttempts > 3) {
        NextRepMonitorTime := A_TickCount + 120000 ; 2 min cooldown for too many attempts
    }
}
