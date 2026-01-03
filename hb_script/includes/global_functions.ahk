Lerp(Start, End, Alpha) {
    return Start + (End - Start) * Alpha
}

Clamp(val, min, max) {
    return (val < min) ? min : (val > max ? max : val)
}

; Function to shuffle an array
RandomizeArray(&arr) {
	for i, _ in arr {
        rndIndex := Random(1, arr.Length) ; Generate a random index between 1 and the length of the array
        ; Swap the current element with the random one
        temp := arr[i]
        arr[i] := arr[rndIndex]
        arr[rndIndex] := temp
    }
}

AreArraysEqual(arr1, arr2) {
    if (arr1.Length != arr2.Length)
        return false

    for index, value in arr1 {
        if (value != arr2[index])
            return false
    }

    return true
}

CalculateFontSize(percentOfHeight) {
    ScreenHeight := ScreenResY + 0  ; Get the screen height
    return Round((percentOfHeight / 100) * ScreenHeight)  ; Calculate font size as a percentage of height
}

CtPixel(percent, axis) {
    ; Validate input
    if (percent == "" || !IsNumber(percent)) {
        MsgBox("CtPixel error: 'percent' is missing or not a number")
        return 0
    }

    axis := StrUpper(axis)
    if !(axis == "X" || axis == "Y") {
        MsgBox("CtPixel error: invalid axis '" axis "'. Must be X or Y.")
        return 0
    }

    ; Clamp percent to 0-100
    percent := Clamp(percent, 0, 100)

    if (axis = "X")
        return Round((percent / 100) * ScreenResX)
    else
        return Round((percent / 100) * ScreenResY)
}

CtPercent(pixel, axis) {
    ; Validate input
    if (pixel == "" || !IsNumber(pixel)) {
        MsgBox("CtPercent error: 'pixel' is missing or not a number")
        return 0
    }

    axis := StrUpper(axis)
    if !(axis == "X" || axis == "Y") {
        MsgBox("CtPercent error: invalid axis '" axis "'. Must be X or Y.")
        return 0
    }

    if (axis = "X")
        return (pixel / ScreenResX) * 100
    else
        return (pixel / ScreenResY) * 100
}

; CctPixels function: Converts percentage coordinates to pixel coordinates
CctPixels(x, y) {
    pixelX := CtPixel(x, "X")  ; Convert x percentage to pixels
    pixelY := CtPixel(y, "Y")  ; Convert y percentage to pixels
    return [pixelX, pixelY]    ; Return array with both pixel values
}

; add this function to the beginning of functions that will often be used in combat
RemoveHolds(*) {
    Send("{Ctrl up}")
    Send("{Alt up}")
    Send("{Shift up}")
}

HelloWorld(*) {
    
}