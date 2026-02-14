; --- Enemy AMP Snapshot Tracker ---
; Hotkey/command: TrackAmpSnapshot()
; Reads the in-game top-left numeric countdown (0-60) and displays that number at top-center for 60 seconds.
; Multiple presses create multiple independent timers (stacked horizontally).

global AmpReadAreaX1 := 0
global AmpReadAreaY1 := 0
global AmpReadAreaX2 := 140
global AmpReadAreaY2 := 260

; Uses dedicated AMP digit templates (0.png .. 9.png) with black background (treated as transparent).
ReadTopLeftNumber() {
    ; Reads the top-left in-game numeric overlay (0-60).
    ; Robust to repeated digits (e.g. 11, 44, 55) by doing a second pass to the right.

    local bestX := 1000000, bestY := 0, d1 := "", fx := 0, fy := 0, d2 := "", secondX := 1000000, secondY := 0, startX := 0

    ; Pass 1: find the leftmost digit in the scan box.
    Loop 10 {
        d := A_Index - 1
        if ImageSearch(&fx, &fy
            , AmpReadAreaX1, AmpReadAreaY1, AmpReadAreaX2, AmpReadAreaY2
            , "*30 *Trans0xFF00FF images\amp_digits\" d ".png")
        {
            if (fx < bestX) {
                bestX := fx
                bestY := fy
                d1 := d
            }
        }
    }

    if (d1 = "")
        return ""

    ; Post-detection verification: disambiguate 3 vs 8 when ImageSearch returns 3 for an 8.
    ; Only runs when a digit is detected as 3 (applies to both digits).
    ;
    ; Method: Probe a handful of pixels that exist in the "8" template but not in the "3" template.
    ; Templates are 8x11 with a 1px magenta padding border, so probes are offset by +1 in X.
    ;
    ; This is intentionally small and local (no tolerance/scan/timer/GUI changes).

    if (d1 = 3) {
        local hits := 0
        local rel := [[1,3],[1,4],[2,5],[1,6],[1,7]]  ; pixels present on 8, absent on 3

        ; Adaptive verification to survive bright/variable backgrounds:
        ; We estimate local background brightness from a few pixels just left of the glyph,
        ; then count a probe as a hit if it's either sufficiently brighter than that background
        ; OR very neutral/white (low saturation) and high brightness.
        local bgSum := 0
        local bgCount := 0
        for by in [2,5,8] {
            local bx := bestX - 3
            local py := bestY + by
            if (bx < 0)
                bx := 0
            if (py < 0)
                py := 0
            local cbg := PixelGetColor(bx, py, "RGB")
            local br := (cbg >> 16) & 0xFF, bg := (cbg >> 8) & 0xFF, bb := cbg & 0xFF
            bgSum += (br + bg + bb)
            bgCount += 1
        }
        local bgAvg := (bgCount > 0) ? Round(bgSum / bgCount) : 0

        ; Tunables (kept local, only affects the 3->8 verification path)
        local deltaMin := 55          ; required brightness above bgAvg
        local whiteMin := 640         ; absolute "very bright" fallback
        local satLimit := 60          ; max channel divergence for "neutral/white"
        local satTight := 35          ; tighter neutrality when using whiteMin fallback

        for r in rel {
            local ix := bestX + r[1]
            local iy := bestY + r[2]
            local ci := PixelGetColor(ix, iy, "RGB")
            local ir := (ci >> 16) & 0xFF, ig := (ci >> 8) & 0xFF, ib := ci & 0xFF

            local iSum := ir + ig + ib
            local sat := Abs(ir - ig) + Abs(ig - ib)

            ; Hit if clearly above background, or if it's extremely bright + neutral.
            if ( (iSum >= (bgAvg + deltaMin) && sat <= satLimit)
              || (iSum >= whiteMin && sat <= satTight) )
                hits += 1
        }

        ; Require strong confirmation to flip 3 -> 8 (avoid false flips like 30 -> 80).
        if (hits >= 4)
            d1 := 8
    }


    ; Pass 2: find the next digit to the right (if any).
    d2 := "", secondX := 1000000, secondY := 0, startX := bestX + 6

    if (startX < AmpReadAreaX2) {
        Loop 10 {
            d := A_Index - 1
            if ImageSearch(&fx, &fy
                , startX, AmpReadAreaY1, AmpReadAreaX2, AmpReadAreaY2
                , "*30 *Trans0xFF00FF images\amp_digits\" d ".png")
            {
                if (fx < secondX) {
                    secondX := fx
                    secondY := fy
                    d2 := d
                }
            }
        }
    }
    ; Apply the same 3-vs-8 verification to the second digit.

    if (d2 = 3) {
        local hits := 0
        local rel := [[1,3],[1,4],[2,5],[1,6],[1,7]]  ; pixels present on 8, absent on 3

        ; Adaptive verification to survive bright/variable backgrounds:
        ; We estimate local background brightness from a few pixels just left of the glyph,
        ; then count a probe as a hit if it's either sufficiently brighter than that background
        ; OR very neutral/white (low saturation) and high brightness.
        local bgSum := 0
        local bgCount := 0
        for by in [2,5,8] {
            local bx := secondX - 3
            local py := secondY + by
            if (bx < 0)
                bx := 0
            if (py < 0)
                py := 0
            local cbg := PixelGetColor(bx, py, "RGB")
            local br := (cbg >> 16) & 0xFF, bg := (cbg >> 8) & 0xFF, bb := cbg & 0xFF
            bgSum += (br + bg + bb)
            bgCount += 1
        }
        local bgAvg := (bgCount > 0) ? Round(bgSum / bgCount) : 0

        ; Tunables (kept local, only affects the 3->8 verification path)
        local deltaMin := 55          ; required brightness above bgAvg
        local whiteMin := 640         ; absolute "very bright" fallback
        local satLimit := 60          ; max channel divergence for "neutral/white"
        local satTight := 35          ; tighter neutrality when using whiteMin fallback

        for r in rel {
            local ix := secondX + r[1]
            local iy := secondY + r[2]
            local ci := PixelGetColor(ix, iy, "RGB")
            local ir := (ci >> 16) & 0xFF, ig := (ci >> 8) & 0xFF, ib := ci & 0xFF

            local iSum := ir + ig + ib
            local sat := Abs(ir - ig) + Abs(ig - ib)

            ; Hit if clearly above background, or if it's extremely bright + neutral.
            if ( (iSum >= (bgAvg + deltaMin) && sat <= satLimit)
              || (iSum >= whiteMin && sat <= satTight) )
                hits += 1
        }

        ; Require strong confirmation to flip 3 -> 8 (avoid false flips like 30 -> 80).
        if (hits >= 4)
            d2 := 8
    }

    if (d2 = "")

        return d1

    return (d1 * 10) + d2
}

TrackAmpSnapshot(*) {
    val := ReadTopLeftNumber()

    if (val = "") {
        ; fail silently (no popups), but you can uncomment the next line for debugging:
        ; ToolTip "AMP read failed", 20, 20
        return
    }

    ; Sanity clamp: the game should be 0-60
    if (val < 0)
        val := 0
    if (val > 60)
        val := 60

    AmpSnapIndicator(val, 60)
}