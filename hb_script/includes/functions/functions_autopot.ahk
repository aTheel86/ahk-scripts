AutoPot() {
	Global bTryHPPotting, bTryManaPotting

	static LowHPDuration := 0
	static LowManaDuration := 0

	if WinActive(WinTitle)
	{
		if (FindHealthPercentage() <= AutoPotLifeAtPercent) {
			if (bTryHPPotting) {
				Send "{Insert}"
				Sleep 20
			}
			; Check if we've been at Low HP for a long time (more than 2 seconds)
			if (LowHPDuration >= 3000) {
				bTryHPPotting := false
			}

			LowHPDuration += 100 ;milliseconds
		}
		else {
			LowHPDuration := 0
			bTryHPPotting := true
		}

		if (FindManaPercentage() <= AutoPotManaAtPercent) {
			if (bTryManaPotting) {
				Send "{Delete}"
				Sleep 20
			}

			if (LowManaDuration >= 3000) {
				bTryManaPotting := false
			}

			LowManaDuration += 100 ;milliseconds
		}
		else {
			LowManaDuration := 0
			bTryManaPotting := true
		}
	}
}

FindHealthPercentage() {
	i := HealthBarXArray.Length
	while (i >= 1) {
		x := HealthBarXArray[i]
		y := HealthBarYArray[i]

		if !IsColorInRange(x, y, EmptyGrey, 35)
			return (i - 1) * (100 / 12)

		i--
	}
	return 0  ; if all are empty
}

FindManaPercentage() {
	i := ManaBarXArray.Length

	while (i >= 1) {
		x := ManaBarXArray[i]
		y := ManaBarYArray[i]

		if !IsColorInRange(x, y, EmptyGrey, 35)
			return (i - 1) * (100 / 12)

		i--
	}
	return 0  ; if all are empty
}

IsColorInRange(x, y, targetColor, tolerance := 10) {
    ; Get the color of the pixel at (x, y)
    pixelColor := PixelGetColor(x, y, "RGB")

    ; Extract RGB components of the pixel color
    pixelR := (pixelColor >> 16) & 0xFF
    pixelG := (pixelColor >> 8) & 0xFF
    pixelB := pixelColor & 0xFF

    ; Extract RGB components of the target color
    targetR := (targetColor >> 16) & 0xFF
    targetG := (targetColor >> 8) & 0xFF
    targetB := targetColor & 0xFF

    ; Check if the pixel color is within the tolerance range of the target color
    if (Abs(pixelR - targetR) <= tolerance && Abs(pixelG - targetG) <= tolerance && Abs(pixelB - targetB) <= tolerance) {
        return true
    } else {
        return false
    }
}