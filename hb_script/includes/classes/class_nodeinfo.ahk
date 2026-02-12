class NodeInfo {
	; Member variables
    NodeTitle := ""
	Imagepath := ""
    AltImagepath := "" ; Useful for night variants
    WorldCoordinates := [0,0] ; In cases where we don't use an image we can apply world coordintes (useful for traveling)
	Location := [0,0] ; World location of the Image found
    ClickOffset := [0,0] ; If applicable, the offset from the location, useful for when we need to click an area offset from the image (converted to pixels in constructor)
    Value := ""
    StartX := 0
    StartY := 0
    EndX := ScreenResX
    EndY := ScreenResY
    
    ConnectedNodes := [] ; Array of NodeTitles that this node can navigate to

    ; Constructor
    __New(NodeTitle := "", Imagepath := "", AltImagepath := "", WorldCoordinates := [0, 0], ClickOffset := [0, 0], Value := "", ConnectedNodes := []) {
        ; Initialize member variables
        this.NodeTitle := NodeTitle
        this.Imagepath := Imagepath
        this.AltImagepath := AltImagepath
        this.WorldCoordinates := WorldCoordinates
        this.ClickOffset := [CtPixel(ClickOffset[1], "X"), CtPixel(ClickOffset[2], "Y")]
        this.Value := Value
        this.ConnectedNodes := ConnectedNodes
    }

    SetSearchCoords(StartX, StartY, EndX, EndY) {
        this.StartX := StartX
        this.StartY := StartY
        this.EndX := EndX
        this.EndY := EndY
    }

    IsPlayerNearby(NearbyThresholdX := 25, NearbyThresholdY := 17) {
        UpdatePlayerCoords() ; need to update player coords here

        XDiff := Abs(this.WorldCoordinates[1] - playerGameCoords[1])
        YDiff := Abs(this.WorldCoordinates[2] - playerGameCoords[2])

        return (XDiff <= NearbyThresholdX && YDiff <= NearbyThresholdY)
    }

    IsOnScreen() {
        if (this.Imagepath != "" && (ImageSearch(&X, &Y, this.StartX, this.StartY, this.EndX, this.EndY, "*TransBlack " this.Imagepath) || (this.AltImagepath != "" && ImageSearch(&X, &Y, this.StartX, this.StartY, this.EndX, this.EndY, "*TransBlack " this.AltImagepath))) ) {
            return true       
        }
        return false
    }

    GetNodeTitle() {
        return this.NodeTitle
    }

    GetScreenLocation() {
        ; Initialize variables to store found X and Y coordinates
        X := 0
        Y := 0

        ; Check if the main image is found
        if (this.Imagepath != "" && ImageSearch(&X, &Y, this.StartX, this.StartY, this.EndX, this.EndY, "*TransBlack " this.Imagepath) != false) {
            ; If the main image is found, return X and Y
            return [X, Y]
        }
        ; If the main image is not found, check for the alternative image
        else if (this.AltImagepath != "" && ImageSearch(&X, &Y, this.StartX, this.StartY, this.EndX, this.EndY, "*TransBlack " this.AltImagepath) != false) {
            ; If the alternative image is found, return X and Y
            return [X, Y]
        }

        ; Return false if no image is found
        return false
    }

    IsCenterOnWorldLocation() {
        ; Determine the boundaries of the square
        LeftBoundary := CenterX - XOffset
        RightBoundary := CenterX + XOffset
        TopBoundary := CenterY - YOffset
        BottomBoundary := CenterY + YOffset

        ; Check if the point (x, y) is within the boundaries
        return (this.WorldCoordinates[1] + this.ClickOffset[1] >= LeftBoundary && this.WorldCoordinates[1] + this.ClickOffset[1] <= RightBoundary && this.WorldCoordinates[2] + this.ClickOffset[2] >= TopBoundary && this.WorldCoordinates[2] + this.ClickOffset[2] <= BottomBoundary)
    }    

    Click(button := "left", clickTimes := 1, bUseOffset := true, CustomOffset := [0,0]) {
        ; Loop to attempt finding the image for a maximum of 5 tries
        Loop 5 {
            X := 0
            Y := 0

            ; Check for the primary image and, if necessary, the alternative image
            if (this.Imagepath != "" && ImageSearch(&X, &Y, this.StartX, this.StartY, this.EndX, this.EndY, "*TransBlack " this.Imagepath)
                || (this.AltImagepath != "" && ImageSearch(&X, &Y, this.StartX, this.StartY, this.EndX, this.EndY, "*TransBlack " this.AltImagepath))) {
                
                this.Location := [X, Y]

                ; Apply offset if bUseOffset is true, otherwise click the exact location
                offsetX := bUseOffset ? this.ClickOffset[1] : 0
                offsetY := bUseOffset ? this.ClickOffset[2] : 0

                ; Handle click
                Sleep 10
                MouseClick(button, this.Location[1] + offsetX, this.Location[2] + offsetY, clickTimes, 0)
                Sleep 10
                return true
            } 
            else if (this.Imagepath == "" && this.AltImagepath == "" && (this.WorldCoordinates[1] != 0 || this.WorldCoordinates[2] != 0)) {
                UpdatePlayerCoords() ; need to update player coords here
                Sleep 100

                if (playerGameCoords[1] == "" || playerGameCoords[2] == "") {
                    return false
                }

                CoordsToClick := this.CalculateClickScreenSpaceOffset(playerGameCoords[1], playerGameCoords[2], this.WorldCoordinates[1] + CustomOffset[1], this.WorldCoordinates[2] + CustomOffset[2])

                ; Handle click
                Sleep 10
                MouseClick(button, CoordsToClick[1], CoordsToClick[2], clickTimes, 0)
                Sleep 10
                return true
            }
            else {
                ; Wait before retrying
                Sleep 500
            }
        }

        ; Return false if image was not found after too many attempts
        return false
    }

    CalculateClickScreenSpaceOffset(playerX, playerY, targetX, targetY) {
        deltaX := targetX - playerX  ; Coord difference in X
        deltaY := targetY - playerY  ; Coord difference in Y
        ScreenSpaceOffsetX := CenterX + (XOffset * deltaX) ; Calcs the X offset from center
        ScreenSpaceOffsetY := CenterY + (YOffset * deltaY) ; Calcs the Y offset from center 
        return [ScreenSpaceOffsetX, ScreenSpaceOffsetY]
    }

    IsPlayerOnWorldLocation(Offset := [0,0]) {
        UpdatePlayerCoords()

        if ((playerGameCoords[1] == this.WorldCoordinates[1] + Offset[1]) && (playerGameCoords[2] == this.WorldCoordinates[2] + Offset[2])) {
            return true
        }
        return false
    }

    MoveToLocation() {
        ; prerequisites
        for node in this.ConnectedNodes
            node.MoveToLocation()

        targetX := this.WorldCoordinates[1]
        targetY := this.WorldCoordinates[2]

        endTime := A_TickCount + 30000
        tolerance := 3

        hPos := []
        hMax := 10
        hI := 1

        Loop {
            if (stopFlag)
                return false
            if (A_TickCount >= endTime)
                return false

            UpdatePlayerCoords()

            if (!IsObject(playerGameCoords) || playerGameCoords.Length < 2
                || playerGameCoords[1] == "" || playerGameCoords[2] == "")
            {
                Sleep 250
                continue
            }

            px := playerGameCoords[1]
            py := playerGameCoords[2]

            dx := targetX - px
            dy := targetY - py
            dist := Abs(dx) + Abs(dy)

            if (hPos.Length = 0 || hPos[hPos.Length][1] != px || hPos[hPos.Length][2] != py)
            {
                hPos.Push([px, py])

                if (hPos.Length > hMax)
                    hPos.RemoveAt(1)
            }

            unique := Map()

            for _, pos in hPos {
                key := pos[1] "," pos[2]

                if unique.Has(key) {
                    Tooltip "history has a duplicate"
                    hPos := []

                    ; juke
                    UpdatePlayerCoords()
                    px := playerGameCoords[1], py := playerGameCoords[2]
                    dx := targetX - px, dy := targetY - py

                    ; perpendicular sidestep is usually best
                    dist := Random(5, 9)
                    if (Abs(dx) >= Abs(dy)) {
                        sy := (Random(0,1) ? 1 : -1)
                        clickPos := this.CalculateClickScreenSpaceOffset(px, py, px, py + sy*dist)
                    } else {
                        sx := (Random(0,1) ? 1 : -1)
                        clickPos := this.CalculateClickScreenSpaceOffset(px, py, px + sx*dist, py)
                    }


                    MouseClick("L", clickPos[1], clickPos[2], 1, 0)
                    Sleep 3000

                    break
                }

                unique[key] := true
            }

            ; step: move 1 tile per click (stable)
            stepX := (dx > 0) ? 1 : (dx < 0) ? -1 : 0
            stepY := (dy > 0) ? 1 : (dy < 0) ? -1 : 0

            if (dist <= 3) {
                ThrowDist := 1
            }
            else {
                ThrowDist := Random(3,7)
            }

            stepX := (dx > 0) ? Min(dx, ThrowDist) : (dx < 0) ? Max(dx, -ThrowDist) : 0
            stepY := (dy > 0) ? Min(dy, ThrowDist) : (dy < 0) ? Max(dy, -ThrowDist) : 0

            clickPos := this.CalculateClickScreenSpaceOffset(px, py, px + stepX, py + stepY)

            MouseClick("L", clickPos[1], clickPos[2], 1, 0)
            Sleep 250

            if (Abs(dx) <= tolerance && Abs(dy) <= tolerance)
                return true
        }
    }
}