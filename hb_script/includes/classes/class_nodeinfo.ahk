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
                if (playerGameCoords[1] == "" || playerGameCoords[2] == "") {
                    return false
                }

                UpdatePlayerCoords() ; need to update player coords here

                CoordsToClick := this.CalculateClickScreenSpaceOffet(playerGameCoords[1], playerGameCoords[2], this.WorldCoordinates[1] + CustomOffset[1], this.WorldCoordinates[2] + CustomOffset[2])

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

    CalculateClickScreenSpaceOffet(playerX, playerY, targetX, targetY) {
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
        ; Convert the game coordinates to minimap coordinates
        targetCoords := GameToMinimap(this.WorldCoordinates[1], this.WorldCoordinates[2])
        targetX := targetCoords[1]
        targetY := targetCoords[2]

        ; Initialize variables for tracking progress
        startDeltaX := ""
        startDeltaY := ""
        prevDeltaX := 0
        prevDeltaY := 0
        NoProgress_StartTime := 0
        NoProgress_ElapsedTime := 0
        MaxNoProgressDuration := 2000
        noProgressCounterForFail := 0

        ;First Lets call in order the attached node info's MoveToLocation()
        for node in this.ConnectedNodes {
            node.MoveToLocation()
        }

        loop {
            if stopFlag {
                break
            }

            ; Ensure that blueDotCoords array is valid and contains valid X and Y values
            if (!IsObject(blueDotCoords) || blueDotCoords.Length != 2 || blueDotCoords[1] == "" || blueDotCoords[2] == "") {
                Tooltip "Error: Blue dot coordinates not found!"
                break
            }

            if (startDeltaX == "" && startDeltaY == "") {
                startDeltaX := Abs(targetX - blueDotCoords[1])
                startDeltaY := Abs(targetY - blueDotCoords[2])
            }

            ; Calculate the difference between the current blue dot position and the target
            deltaX := targetX - blueDotCoords[1]
            deltaY := targetY - blueDotCoords[2]

            ; Stop when the blue dot is close enough to the target (within 2 coords)
            if (Abs(deltaX) < 2 && Abs(deltaY) < 2) {
                break
            }

            ProgressX := (startDeltaX * (Abs(prevDeltaX) - Abs(deltaX)))
            ProgressY := (startDeltaY * (Abs(prevDeltaY) - Abs(deltaY)))

            if (ProgressX <= 0 && ProgressY <= 0) {
                if (NoProgress_StartTime == 0) {
                    NoProgress_StartTime := A_TickCount
                }

                NoProgress_ElapsedTime := A_TickCount - NoProgress_StartTime

                if (NoProgress_ElapsedTime >= MaxNoProgressDuration) {
                    MoveNearby(3)
                    NoProgress_StartTime := 0
                    NoProgress_ElapsedTime := 0
                    noProgressCounterForFail++

                    if (noProgressCounterForFail > 5) {
                        Tooltip "Failed to move to location: " this.GetNodeTitle() 
                        Send "{LButton up}"
                        Send "{Escape}"
                        return
                    }
                }
            }
            else {
                NoProgress_StartTime := 0
                NoProgress_ElapsedTime := 0
            }
            
            if (Mod(A_Index, 2)) { ; This might not be needed
                prevDeltaX := deltaX
                prevDeltaY := deltaY
            }

             ; Normalize deltaX and deltaY to a range
            distanceX := Min(Abs(deltaX), 3)
            distanceY := Min(Abs(deltaY), 3)

            ; Prioritize straight movement if one delta is much larger than the other
            if (Abs(deltaX) > Abs(deltaY) * 2) {
                ; Prioritize horizontal movement
                if (deltaX > 0) {
                    this.MoveDirection("Right", distanceX)
                } else if (deltaX < 0) {
                    this.MoveDirection("Left", distanceX)
                }
            } else if (Abs(deltaY) > Abs(deltaX) * 2) {
                ; Prioritize vertical movement
                if (deltaY > 0) {
                    this.MoveDirection("Down", distanceY)
                } else if (deltaY < 0) {
                    this.MoveDirection("Up", distanceY)
                }
            } 
            ; Use diagonal movement if both deltaX and deltaY are close in value
            else {
                if (deltaX > 0 && deltaY > 0) {
                    this.MoveDirection("RightDown", Min(distanceX, distanceY))  ; Use the smaller of the two distances
                } else if (deltaX > 0 && deltaY < 0) {
                    this.MoveDirection("RightUp", Min(distanceX, distanceY))
                } else if (deltaX < 0 && deltaY > 0) {
                    this.MoveDirection("LeftDown", Min(distanceX, distanceY))
                } else if (deltaX < 0 && deltaY < 0) {
                    this.MoveDirection("LeftUp", Min(distanceX, distanceY))
                }
            }

            Sleep 200
            Send("{LButton down}")
        }

        Send("{LButton up}")
        Sleep 100
    }

    MoveDirection(direction, distance := 2) {
        ; Calculate pixel offsets for each direction based on the distance
        XOffset := CtPixel(SquarePercentageX * distance, "X")
        YOffset := CtPixel(SquarePercentageY * distance, "Y")

        ; Create offset arrays
        XOffsets := [-XOffset, 0, XOffset]
        YOffsets := [-YOffset, 0, YOffset]

        ; Define coordinates for each direction
        directions := Object()
        directions.RightDown := [CenterX + XOffsets[3], CenterY + YOffsets[3]]
        directions.LeftDown := [CenterX + XOffsets[1], CenterY + YOffsets[3]]
        directions.LeftUp := [CenterX + XOffsets[1], CenterY + YOffsets[1]]
        directions.RightUp := [CenterX + XOffsets[3], CenterY + YOffsets[1]]
        directions.Up := [CenterX + XOffsets[2], CenterY + YOffsets[1]]
        directions.Down := [CenterX + XOffsets[2], CenterY + YOffsets[3]]
        directions.Left := [CenterX + XOffsets[1], CenterY + YOffsets[2]]
        directions.Right := [CenterX + XOffsets[3], CenterY + YOffsets[2]]

        directions.Random := [CenterX + XOffsets[Random(1, 3)], CenterY + YOffsets[Random(1, 3)]]

        Coords := directions.%direction% ; Get coordinates for the specified direction
        MouseMove Coords[1], Coords[2], 0 ; Move the mouse to the calculated coordinates
    }
}