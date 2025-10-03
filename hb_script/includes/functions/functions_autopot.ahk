; 12.5 is roughly the horizontal % of screen the healthbar takes up, 13% is where it starts, 25.5% is where it ends
; 93.3 may need tweaking depending on res (we can't use the middle value as "poisoned" status can get in the way!)

AutoPot() {
	Global bTryHPPotting, bTryManaPotting, LifeRed, ManaBlue, EmptyGrey

	static LowHPDuration := 0
	static LowManaDuration := 0

	if WinActive(WinTitle)
	{
		;ToolTip "HP_Start: " . PixelGetColor(StartAutoPotManaPos[1], StartAutoPotManaPos[2]) . " HP_High: " . PixelGetColor(HighManaPos[1], HighManaPos[2])
		;A_Clipboard := PixelGetColor(StartAutoPotManaPos[1], StartAutoPotManaPos[2]) . " " . PixelGetColor(HighManaPos[1], HighManaPos[2])

		; Check to make sure the low HP area is actually red (this can help prevent the system from randomly drinking pots, esp after minimize)
		if IsColorInRange(LowHPPos[1], LowHPPos[2], LifeRed, 35) 
		{	; Now make sure we are not on full health && we don't have health at desired %
			if IsColorInRange(HighHPPos[1], HighHPPos[2], EmptyGrey, 35) && !IsColorInRange(MidHPPos[1], MidHPPos[2], LifeRed, 35)
			{
				if (bTryHPPotting)
				{
					Send "{Insert}"
					Sleep 20
				}

				if (LowHPDuration >= 3000) ; Check if we've been at Low HP for a long time (more than 2 seconds)
				{
					bTryHPPotting := false
				}

				LowHPDuration += 100 ;milliseconds
			}
		}
		else
		{
			LowHPDuration := 0
			bTryHPPotting := true
		}

		; Check low Mana
		if IsColorInRange(LowManaPos[1], LowManaPos[2], ManaBlue, 35) 
		{	; Now make sure we are not on full mana && we don't have mana at desired %
			if IsColorInRange(HighManaPos[1], HighManaPos[2], EmptyGrey, 35) && !IsColorInRange(MidManaPos[1], MidManaPos[2], ManaBlue, 35)
			{
				if (bTryManaPotting)
				{
					Send "{Delete}"
					Sleep 20
				}

				if (LowManaDuration >= 3000) ; Check if we've been at Low Mana for a long time (more than 2 seconds)
				{
					bTryManaPotting := false
				}

				LowManaDuration += 100 ;milliseconds
			}
		}
		else
		{
			LowManaDuration := 0
			bTryManaPotting := true
		}
	}
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