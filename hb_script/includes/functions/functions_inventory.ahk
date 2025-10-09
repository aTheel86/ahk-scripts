EatFood(*) {
	BlockInput "MouseMove"
    MouseGetPos &begin_x, &begin_y ; Get the position of the mouse

    if (GetKeyState("LButton", "P")) { ; If we're holding down M1 (left mouse button), release it
        Send("{LButton up}")
    }
    if (GetKeyState("RButton", "P")) { ; if we are holding down m2
        Send("{RButton up}")
    }    

	Send "{F6}"
	Sleep 10
    MouseClick("L", 744, 331, 2, 0)
	Sleep 10
    MouseMove begin_x, begin_y, 0 ; Move mouse back to original position
	Send "{F6}"
	BlockInput "MouseMoveOff"
}

EquipItem(items) {
    ; If a single value was passed, wrap it in an array
    if !IsObject(items)
        items := [items]

    BlockInput "MouseMove"
    MouseGetPos &begin_x, &begin_y

    if (GetKeyState("LButton", "P")) { ; If we're holding down M1 (left mouse button), release it
        Send("{LButton up}")
    }
    if (GetKeyState("RButton", "P")) { ; if we are holding down m2
        Send("{RButton up}")
    }    

    Send "{F6}"
    Sleep 10
    Send "{Ctrl Down}"

    for index in items {
        MouseClick("L", InventorySlotPos[index][1], InventorySlotPos[index][2],, 0)
    }

    Send "{Ctrl up}"
    Sleep 10
    Send "{F6}"
    Sleep 10
    MouseMove begin_x, begin_y, 0
    BlockInput "MouseMoveOff"
}