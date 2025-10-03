PretendCorpseLeveling(*)
{
	static bIsFeigning := false

	bIsFeigning := !bIsFeigning

	if bIsFeigning {
		SetTimer(PretendCorpseFunction, 1000)
	}
	else {
		SetTimer(PretendCorpseFunction, 0)
	}
}

PretendCorpseFunction(*) ; Not really meant to be binded, but can be (will execute one time)
{
	MouseGetPos(&x, &y)

	Send "{Click, x, y}"
	Sleep 100
	Send "{F8}" ; toggle menu
	Sleep 100
}

ToggleMagicLeveling(*)
{	
	global MagicLevelingFuncBound

	static bIsLvling := false

	bIsLvling := !bIsLvling
	
	if (bIsLvling) {
		MouseMove(400, 290)
		Sleep 100
		MagicMissileSpell := SpellInfo("MagicMissile", 1, 35.67, "!F1")
		CreateFoodSpell := SpellInfo("CreateFood", 1, 41.5, "!F1")

		MagicLevelingFuncBound := MagicLeveling.Bind(400, 290, MagicMissileSpell, CreateFoodSpell)
		SetTimer(MagicLevelingFuncBound, 100)
	}
	else
		SetTimer(MagicLevelingFuncBound, 0)
}

MagicLeveling(begin_x := 0, begin_y := 0, MagicMissileSpell := "", CreateFoodSpell := "")
{
	static lastEatTime := 0
	static eatInterval := 360000   ; 6 minutes in milliseconds

	static lastCreateFoodTime := 0
	static createFoodInterval := 4320000   ; 72 minutes in milliseconds

	static lastMagicMissileTime := 0
	static magicMissileInterval := 1900  ; 1.9 seconds in milliseconds (lowest without fails)

	currentTime := A_TickCount

	MouseMove(400, 290)
	Sleep 100

    if (currentTime - lastEatTime >= eatInterval)
    {
        EatFood()
		MouseMove(begin_x, begin_y)
		Sleep 500
        lastEatTime := currentTime
        return
    }

	if (currentTime - lastCreateFoodTime >= createFoodInterval)
    {
        Loop 12 {
			CreateFoodSpell.CastSpell()
			Sleep 1500
			Send "{Click, begin_x, begin_y}"
		}

		Loop 12 {
			Sleep 1000	
			Send "{Click, begin_x, begin_y}"
		}
		
        lastCreateFoodTime := currentTime
        return
    }

    if (currentTime - lastMagicMissileTime >= magicMissileInterval) ; Default action is casting magic missile
    {
        MagicMissileSpell.CastSpell()
		Sleep 1000
		Send "{Click, begin_x, begin_y}"
        lastMagicMissileTime := currentTime
        return
    }
}

RandomAdjacent() {
	AdjacentSquares := [directions.RightDown, directions.LeftDown, directions.LeftUp, directions.RightUp, directions.Up, directions.Down, directions.Left, directions.Right]
    RandomIndex := Random(1, AdjacentSquares.Length)
    return AdjacentSquares[RandomIndex]
}

Chance(percentage) {
    return Random(1, 100) <= percentage
}

CheckPixelMovement(x, y) {
	pixelColor := PixelGetColor(x, y)
	Sleep(1)
	pixelColor2 := PixelGetColor(x, y)

	if (pixelColor != pixelColor2) {
		return true ; movement detected
	}
	return false ; no movement detected at pixel
}

FindAdjacentEnemy()
{
	AdjacentSquares := [directions.RightDown, directions.LeftDown, directions.LeftUp, directions.RightUp, directions.Up, directions.Down, directions.Left, directions.Right]
	RandomizeArray(&AdjacentSquares) ; Shuffle the AdjacentSquares array to randomize iteration order

	; Check each adjacent square for pixel changes
	for square in AdjacentSquares {
		MouseMove square[1], square[2], 0
		Sleep 2

		if (CanAttackCoord(square[1], square[2]))
		{
			Coords := [square[1], square[2]]
			return Coords
		}
	}
	return false
}

CanAttackCoord(x, y)
{
	Offsets := [PixelGetColor(x + 1, y + 1, "RGB"), PixelGetColor(x + 1, y + 2, "RGB"), PixelGetColor(x + 2, y + 1, "RGB"), PixelGetColor(x + 2, y + 2, "RGB")]

	if (Offsets[1] == "0xF7F7F7" && Offsets[2] == "0xEFEFEF" && Offsets[3] == "0xFFFFFF" && Offsets[4] == "0xEFEFEF") {
		return true
	}
	return false
}

FindAndMove(distance := 3) {
	TempGui := Gui()
	TempGui.Opt("+AlwaysOnTop +ToolWindow -Caption Disabled E0x8000000") ;E0x8000000 makes it so you cannot click the GUI stuff (Disabled might be unnecessary)
	TempGui.BackColor := "EEAA99"

    ; Initialize an empty array for the coordinates
    coords := []

    ; Calculate the pixel offset for the given distance
    XOffset := CtPixel(SquarePercentageX * distance, "X")
    YOffset := CtPixel(SquarePercentageY * distance, "Y")

    ; Top and Bottom sides
    x := -distance
    while (x <= distance) {
        coords.Push([CenterX + CtPixel(SquarePercentageX * x, "X"), CenterY - YOffset]) ; Top side
        coords.Push([CenterX + CtPixel(SquarePercentageX * x, "X"), CenterY + YOffset]) ; Bottom side
        x++
    }

    ; Left and Right sides
    y := -(distance - 1)
    while (y <= (distance - 1)) {
        coords.Push([CenterX - XOffset, CenterY + CtPixel(SquarePercentageY * y, "Y")]) ; Left side
        coords.Push([CenterX + XOffset, CenterY + CtPixel(SquarePercentageY * y, "Y")]) ; Right side
        y++
    }

    ; Create a text control for each coordinate in coords
    for coord in coords {
        TempGui.Add("Text", "x" coord[1] " y" coord[2] " w15 h15 Center cFuchsia", " .")
    }

	WinSetTransColor(TempGui.BackColor " 200", TempGui)
    TempGui.Show("x0 y0 w" ScreenResX " h" ScreenResY " NA NoActivate") ; Show the GUI without activating it

    ; Check each square for pixel changes
    for coord in coords {
		MouseMove coord[1], coord[2], 0
		Sleep 2

		if (CanAttackCoord(coord[1], coord[2])) {
			MouseClick("L", coord[1], coord[2])
			Sleep 200
            MouseMove CenterX, CenterY
            Loop distance {
				Sleep 300
			}

			TempGui.Destroy()
            return true
		}
    }

	TempGui.Destroy()
	return false
}

MoveNearby(distance := 3, direction := "any") {
	; Calculate pixel offsets for each direction
	XOffset := CtPixel(SquarePercentageX * distance, "X")
	YOffset := CtPixel(SquarePercentageY * distance, "Y")

	; Create offset arrays (AHK arrays start from index 1)
	XOffsets := [-XOffset, 0, XOffset]
	YOffsets := [-YOffset, 0, YOffset]

	; Define coordinates for each direction using valid object literal syntax
	directions := Object()
	directions.RightDown := [CenterX + XOffsets[3], CenterY + YOffsets[3]]
	directions.LeftDown := [CenterX + XOffsets[1], CenterY + YOffsets[3]]
	directions.LeftUp := [CenterX + XOffsets[1], CenterY + YOffsets[1]]
	directions.RightUp := [CenterX + XOffsets[3], CenterY + YOffsets[1]]
	directions.Up := [CenterX + XOffsets[2], CenterY + YOffsets[1]]
	directions.Down := [CenterX + XOffsets[2], CenterY + YOffsets[3]]
	directions.Left := [CenterX + XOffsets[1], CenterY + YOffsets[2]]
	directions.Right := [CenterX + XOffsets[3], CenterY + YOffsets[2]]

	Coords := []
	Squares := [directions.RightDown, directions.LeftDown, directions.LeftUp, directions.RightUp, directions.Up, directions.Down, directions.Left, directions.Right]

    ; Handle 'any' direction by randomizing adjacent squares
    if (direction == "any") {	
		RandomizeArray(&Squares) ; Shuffle the array to randomize the order
		Coords := Squares.Pop()
    } else {
        Coords := directions.%direction% ; Handle specific direction
    }

	MoveToPosition(Coords[1], Coords[2], distance)
}

MoveToPosition(x, y, distance := 1)
{
	MouseClick("L", x, y)
	Sleep 10
	MouseMove CenterX, CenterY	
	Sleep 300 * distance
}

MoveCastBerserk()
{
	MoveNearby(distance := 6, direction := "Right")
	CastBerserk()
	MoveNearby(distance := 6, direction := "Left")
}

CastInvis(*)
{
	Global Effects

	Send "^{4}" ; Open Magic menu tab
	Sleep 10
	MouseClick("L", CtPixel(SpellHorizontalPos, "X"), CtPixel(41.73, "Y"))
	Sleep 10
	MouseMove CenterX, CenterY
	Sleep 1800
	MouseClick("L", CenterX, CenterY)
	Sleep 500

	Effects.Push(StatusEffectIndicator("images\Invis.png", 60, ""))
}

CastPFM(*)
{
	Global Effects

	Send "^{4}" ; Open Magic menu tab
	Sleep 10
	MouseClick("L", CtPixel(SpellHorizontalPos, "X"), CtPixel(44.72, "Y"))
	Sleep 10
	MouseMove CenterX, CenterY
	Sleep 1800
	MouseClick("L", CenterX, CenterY)
	Sleep 500

	Effects.Push(StatusEffectIndicator("images\PFM.png", 60, ""))
}

CastBerserk(*)
{
	Global Effects

	Send "^{6}" ; Open Magic menu tab
	Sleep 10
	MouseClick("L", CtPixel(SpellHorizontalPos, "X"), CtPixel(35.7638, "Y"))
	Sleep 10
	MouseMove CenterX, CenterY
	Sleep 1800
	MouseClick("L", CenterX, CenterY)
	Sleep 500

	Effects.Push(StatusEffectIndicator("images\Berserk.png", 60, ""))
}

CastRecall(*)
{
	Send "^{2}" ; Open Magic menu tab
	Sleep 10
	MouseClick("L", CtPixel(SpellHorizontalPos, "X"), CtPixel(41.8055, "Y"))
	Sleep 10
	MouseMove CenterX, CenterY
	Sleep 1800
	MouseClick("L", CenterX, CenterY)
	Sleep 500
}

RandomBehavior(x1 := 80, x2 := 10, x3 := 30, x4:= 0) {
    ; Define the odds for each case
    odds := [x1, x2, x3, x4]

    ; Calculate the total odds
    totalOdds := 0
    for each, odd in odds
        totalOdds += odd

    ; Generate a random number between 1 and totalOdds
    rand := Random(1, totalOdds)

    ; Determine which case to execute based on the random number
    cumulativeOdds := 0
    for index, odd in odds {
        cumulativeOdds += odd
        if (rand <= cumulativeOdds) {
            Switch index {
                Case 1:
					AttackInCircles()
                    return
                Case 2:
                    RunInCircles()
                    return
                Case 3:
                    LookBackAndForth()
                    return
                Case 4:
                    GoInvisibleAndWait()
                    return
            }
        }
    }
}

RunInCircles() {
    patterns := [
        ["RightDown", "RightUp", "LeftUp", "LeftDown"],
        ["Right", "Down", "Left", "Up"],
        ["Left", "RightUp", "RightDown"],
		["Right", "LeftUp", "LeftDown"]
    ]
    
    ; Choose a random pattern
    selectedPattern := patterns[A_Index := Random(1, patterns.Length)]

    ; Execute the selected pattern
    for _, direction in selectedPattern {
        MoveNearby(2, direction)
    }
}

AttackInCircles(_Speed := 250, _SpeedVariance := 200) {
	bHasStarted := false
	AdjacentSquares := [directions.RightDown, directions.Right, directions.RightUp, directions.Up, directions.LeftUp, directions.Left, directions.LeftDown, directions.Down]
	Send("{RButton down}")
	
	Loop Random(1,3) {
		for i, square in AdjacentSquares {
			if (!bHasStarted) {
				if (i <= Random(1, AdjacentSquares.Length)) {
					continue
				}
				else {
					bHasStarted := true
				}
			}
			else {
				MouseMove square[1], square[2], 0
				Sleep Max(0, _Speed + Random(-_SpeedVariance, _SpeedVariance))
				if (Chance(5)) {
					break
				}
			}
		}
	}

	MouseMove CenterX, CenterY

	Send("{RButton up}")
	Sleep 10
}

LookBackAndForth() {
    Sleep 10
	Send("{RButton down}")
	Loop Random(1,5)
	{
		MouseMove CtPixel((50 - SquarePercentageX), "X"), CtPixel(50, "Y")
		Sleep Random(50,300)
		MouseMove CtPixel((50 + SquarePercentageX), "X"), CtPixel(50, "Y")
		Sleep Random(50,300)
	}
	Send("{RButton up}")
	Sleep 10
}

; Function to go invisible and wait for an interval
GoInvisibleAndWait() {
}
  
BeginBasicLeveling()
{
    myGui := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000 -Border")

    ; Add the UpDown control and other components to the GUI
    myGui.Add("Text",, "Set Duration (minutes):")
    EditBox := myGui.Add("Slider", "ToolTipBottom Range1-180", 20)
    OKButton := myGui.Add("Button", "Default", "OK")
    OKButton.OnEvent("Click", (*) => BasicLeveling(myGui, EditBox.Value))

    ; Show the GUI
    myGui.Show("x" ScreenResX / 2 " y" ScreenResY / 2 " NA NoActivate")
    
    ; Ensure the window stays on top and non-interactive
    WinSetAlwaysOnTop(1, myGui.Hwnd)
    WinSetExStyle("+0x80000", myGui.Hwnd)  ; WS_EX_NOACTIVATE
}

BasicLeveling(myGUI, Duration)
{
    global stopFlag 

	myGui.Destroy()

	StopTime := A_TickCount + (Duration * 60 * 1000)
	
	LastAttackTime := A_TickCount
	StartTime_EatFood := A_TickCount
	Last_RandomBehavior := A_TickCount
	Interval_EatFood := 300000
	dist := 2

	if WinActive(WinTitle) ; This supposedly stops the hotkey from working outside of the HB client
	{
		BlockInput "MouseMove"
		MouseMove CenterX, CenterY  ;Move mouse to center screen
		SendTextMessage("/shiftpickup")

		Loop {
			i := 0
			ElapsedTime_EatFood := A_TickCount - StartTime_EatFood

			EnemyCoords := FindAdjacentEnemy()
			if (EnemyCoords) {
				Send("{RButton down}")
				Loop {
					i++
					if (i > 20) {
						Send("{Alt down}")
					}

					if (i > 100) {
						break
					}
					Sleep 100
				} Until !CanAttackCoord(EnemyCoords[1], EnemyCoords[2])
				Send("{Alt up}")
				Send("{RButton up}")
				dist := 2
				LastAttackTime := A_TickCount
			}
			else {
				MouseMove CenterX, CenterY

				if ((A_TickCount - LastAttackTime) >= 25000) {
					if (FindAndMove(dist)) {
						dist := 2
					}
					else {
						dist := Min(++dist, 6)
					}
					LastAttackTime := A_TickCount
				}

				if ((A_TickCount - Last_RandomBehavior) >= Random(10000,30000)) {
					RandomBehavior()
					Last_RandomBehavior := A_TickCount
				}

				if (ElapsedTime_EatFood >= Interval_EatFood) {
					EatFood()
					Sleep 100
					MouseMove CenterX, CenterY
					Sleep 100
					StartTime_EatFood := A_TickCount
				}

				if (A_TickCount > StopTime) {
					MoveNearby(10,"right")
					Sleep 1000
					CastRecall()
					Break
				}
			}
		
			if (stopFlag) {
				stopFlag := false
				Break
			}
		}

		SendTextMessage("/shiftpickup")
		Send("{RButton up}")
		BlockInput "MouseMoveOff"
	}
}