global CoordsAreaX1 := 225
global CoordsAreaY1 := 578
global CoordsAreaX2 := 396
global CoordsAreaY2 := 595

WrapDigit(d, delta) {
    return Mod(d + delta + 10, 10)
}

TryAdjustX(&x) {
    last := Mod(x, 10)
    ; try -1,+1 first, then -2,+2
    for _, delta in [-1, 1, -2, 2, -3, 3, -4, 4,] {
        d := WrapDigit(last, delta)

        ; if we are looking for a 3, but actually an 8 exists (3's pixels fits inside 8), then 3 will falsely pass (in such cases we should fail!)
        if (d == 3) {
            if ImageSearch(&fx,&fy, CoordsAreaX1,CoordsAreaY1,CoordsAreaX2,CoordsAreaY2, "*TransBlack images\coord_images\comma\8c.png") {
                continue
            }
        }

        if ImageSearch(&fx,&fy, CoordsAreaX1,CoordsAreaY1,CoordsAreaX2,CoordsAreaY2
            , "*TransBlack images\coord_images\comma\" d "c.png")
        {
            x += delta
            return true
        }
    }
    return false
}

TryAdjustY(&y) {
    last := Mod(y, 10)
    for _, delta in [-1, 1, -2, 2, -3, 3, -4, 4] {
        d := WrapDigit(last, delta)

        ; if we are looking for a 3, but actually an 8 exists (3's pixels fits inside 8), then 3 will falsely pass (in such cases we should fail!)
        if (d == 3) {
            if ImageSearch(&fx,&fy, CoordsAreaX1,CoordsAreaY1,CoordsAreaX2,CoordsAreaY2, "*TransBlack images\coord_images\paren\8p.png") {
                continue
            }
        }

        if ImageSearch(&fx,&fy, CoordsAreaX1,CoordsAreaY1,CoordsAreaX2,CoordsAreaY2
            , "*TransBlack images\coord_images\paren\" d "p.png")
        {
            y += delta
            return true
        }
    }
    return false
}

CalculatePlayerCoordinates() {
    global playerGameCoords

    if (miniMapCoords[1] == "" || miniMapCoords[2] == "")
        return false

    x := Integer(miniMapCoords[1])
    y := Integer(miniMapCoords[2])

    TryAdjustX(&x)
    TryAdjustY(&y)

    playerGameCoords := [x, y]
    return true
}

UpdatePlayerCoords() {
    if !WinActive(WinTitle) {
        return
    }

    UpdateMiniMapCoords()
    CalculatePlayerCoordinates()
}

SetTimer(UpdatePlayerCoords, 250)