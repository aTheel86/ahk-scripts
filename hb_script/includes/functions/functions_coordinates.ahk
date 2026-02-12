global CoordsAreaX1 := 225
global CoordsAreaY1 := 578
global CoordsAreaX2 := 396
global CoordsAreaY2 := 595

CalculatePlayerCoordinates() {
    global playerGameCoords

    if (miniMapCoords[1] == "" || miniMapCoords[2] == "")
        return false

    x := Integer(miniMapCoords[1])
    y := Integer(miniMapCoords[2])

    lastX := Mod(x, 10)
    lastY := Mod(y, 10)

    ; ---- X (comma)
    a := Mod(lastX + 9, 10) ; -1
    b := Mod(lastX + 1, 10) ; +1

    if ImageSearch(&fx,&fy, CoordsAreaX1,CoordsAreaY1,CoordsAreaX2,CoordsAreaY2, "*TransBlack images\coord_images\comma\" a "c.png")
    {
        x := x - 1
    }
    else if ImageSearch(&fx,&fy, CoordsAreaX1,CoordsAreaY1,CoordsAreaX2,CoordsAreaY2, "*TransBlack images\coord_images\comma\" b "c.png")
    {
        x := x + 1
    }

    ; ---- Y (paren)
    a := Mod(lastY + 9, 10) ; -1
    b := Mod(lastY + 1, 10) ; +1

    if ImageSearch(&fx,&fy, CoordsAreaX1,CoordsAreaY1,CoordsAreaX2,CoordsAreaY2, "*TransBlack images\coord_images\paren\" a "p.png")
    {
        y := y - 1
    }
    else if ImageSearch(&fx,&fy, CoordsAreaX1,CoordsAreaY1,CoordsAreaX2,CoordsAreaY2, "*TransBlack images\coord_images\paren\" b "p.png")
    {
        y := y + 1
    }

    playerGameCoords := [x, y]
}

UpdatePlayerCoords() {
    if !WinActive(WinTitle) {
        return
    }

    UpdateMiniMapCoords()
    CalculatePlayerCoordinates()
}

SetTimer(UpdatePlayerCoords, 200)