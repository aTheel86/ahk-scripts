
; Define an empty list of images with their corresponding values
imageList := []

; Array to store the search results (x positions)
foundImages := []

; Function to add image information (image path, value, and optional xPos) to the list
AddImage(imagePath, Value, xPos := 0) {
    NewImage := []                 ; Create a new array
    NewImage.Push(imagePath)        ; Assign image path to index 1
    NewImage.Push(Value)            ; Assign value to index 2
    NewImage.Push(xPos)             ; Assign xPos to index 3 (default is 0)
    imageList.Push(NewImage)        ; Add the new image entry to the imageList
}

; Dynamically add images starting from 0
AddImage("images\coord_images\0_img.png", 0)
AddImage("images\coord_images\1_img.png", 1)
AddImage("images\coord_images\2_img.png", 2)
AddImage("images\coord_images\3_img.png", 3)
AddImage("images\coord_images\4_img.png", 4)
AddImage("images\coord_images\5_img.png", 5)
AddImage("images\coord_images\6_img.png", 6)
AddImage("images\coord_images\7_img.png", 7)
AddImage("images\coord_images\8_img.png", 8)
AddImage("images\coord_images\9_img.png", 9)

CoordinateIndicatorX1 := CtPixel(28, "X")
CoordinateIndicatorY1 := CtPixel(97, "Y")
CoordinateIndicatorX2 := CtPixel(50, "X")
CoordinateIndicatorY2 := CtPixel(99.3, "Y")

HasMoved() { ; working, though a bit slow, currently not used
    first := ReadCoordinates()
    sleep 100
    second := ReadCoordinates()

    if (AreArraysEqual(first, second)) {
        Tooltip "We have not moved"
    }
    else {
        Tooltip "We have moved!!!"
    }
}

; Function to read coordinates using ImageSearch
ReadCoordinates() {
    Global foundImages

    ScreenReadGui := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000 +OwnDialogs")
    ScreenReadGui.BackColor := "EEAA99"
    WinSetTransColor("EEAA99", ScreenReadGui.Hwnd)
    WinSetAlwaysOnTop(1, ScreenReadGui.Hwnd)

    foundImages := []

    X := 0
    Y := 0
    xCoord := 0
    yCoord := 0
    XStart := 0
    XEnd := 0

    PreviousX := 0

    ; Establish the location of the ( and the )
    if (ImageSearch(&X, &Y, CoordinateIndicatorX1, CoordinateIndicatorY1, CoordinateIndicatorX2, CoordinateIndicatorY2, "*TransBlack images\coord_images\leftpara_img.png"))
    {
        XStart := X
    }
    if (ImageSearch(&X, &Y, CoordinateIndicatorX1, CoordinateIndicatorY1, CoordinateIndicatorX2, CoordinateIndicatorY2, "*TransBlack images\coord_images\rightpara_img.png"))
    {
        XEnd := X
    }

    if (XStart == 0 && XEnd == 0)
    {
        return [0, 0]
    }

    Loop 6 {
        ; Loop through the imageList (we are trying to find the first number of the coords readout)
        for i, image in imageList {
            imagePath := image[1]     ; Get image path
            Value := image[2]         ; Get the value associated with the image

            ; Perform ImageSearch
            if (ImageSearch(&X, &Y, XStart, CoordinateIndicatorY1, XEnd, CoordinateIndicatorY2, "*TransBlack " imagePath)) {
                ; We found an image, let's add it to foundImages with the X position
                FoundImage := []
                FoundImage.Push(imagePath)   ; Image path
                FoundImage.Push(Value)       ; Image value
                FoundImage.Push(X)           ; X position
                foundImages.Push(FoundImage) ; Add found image to the results

                ; Now white it out so we don't find it again!
                ScreenReadGui.Add("Text", "x" X " y" Y, "0")
                ScreenReadGui.Show("x0 y0 w" ScreenResX " h" ScreenResY " NA NoActivate")
            }
        }
    }

    ScreenReadGui.Destroy()

    ; Sort the found images based on their xPos values
    if (foundImages.Length > 0) {
        BubbleSortFoundImagesByXPos(&foundImages)
    }

    ; Find the position of the comma based on the largest X difference
    commaPosition := FindCommaPosition(foundImages)

    ; Now we need to form a string of the values of foundImages
    coordinateString := ""
    for i, foundObj in foundImages {
        if (i = commaPosition + 1) {
            coordinateString .= "," ; Insert the comma after the X coordinate
        }
        coordinateString .= foundObj.Get(2) ; Append value from foundImages
    }    

    ; Split the string based on the comma
    if (coordinateString is String) {
        SplitString := StrSplit(coordinateString, ",")
        if (SplitString.Length >= 2) {
            xCoord := SplitString[1] + 0 ; First part of the string before the comma (X value)
            yCoord := SplitString[2] + 0 ; Second part of the string after the comma (Y value)
        }
    }

    return [xCoord, yCoord] ; Convert them to integers
}

; Custom bubble sort function for foundImages based on the xPos (index 3)
BubbleSortFoundImagesByXPos(&arr) {
    n := arr.Length
    while (n > 1) {
        newn := 0
        for j, _ in arr {
            if (j >= n) {
                break
            }
            ; Compare the xPos of two adjacent elements
            if arr[j][3] > arr[j + 1][3] {
                ; Swap the elements
                temp := arr[j]
                arr[j] := arr[j + 1]
                arr[j + 1] := temp
                newn := j
            }
        }
        n := newn
    }
}

; Function to find the comma position by checking the largest difference in X values
FindCommaPosition(images) {
    largestDiff := 0
    commaIndex := 0

    ; Loop through the sorted images and calculate the difference between consecutive X positions
    for i, img in images {
        if (i >= images.Length)  ; Make sure we're not accessing beyond the array length
            break

        ; Compare the current image's xPos with the next one
        nextImg := images[i + 1]  ; Get the next image
        diff := nextImg[3] - img[3]  ; Calculate the X position difference

        ; Check if this is the largest difference
        if diff > largestDiff {
            largestDiff := diff
            commaIndex := i  ; Index before which the comma should be placed
        }
    }

    return commaIndex  ; Return the index of where the comma should be placed
}