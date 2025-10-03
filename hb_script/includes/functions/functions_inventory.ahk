EatFood(*) {
	BlockInput true
	Send "{F6}"
	Sleep 10
	MouseClick "left", 744, 331, 2
	Sleep 10
	Send "{F6}"
	BlockInput false
}

EquipItem(index) {
    if (GetKeyState("LButton", "P")) { ; If we're holding down M1 (left mouse button), release it
        Send("{LButton up}")
    }

    BlockInput("MouseMove")
    MouseGetPos(&begin_x, &begin_y)
    Send("{F6}")
    Sleep(10)
    Send("{Ctrl Down}{Click " InventorySlotPos[index][1] " " InventorySlotPos[index][2] "}{Ctrl up}") ; Click on the inventory slot specified by the index
    Sleep(10)
    Send("{F6}")
    ;Send("{Click right}")
    Sleep(10)
    MouseMove(begin_x, begin_y, 0)
    BlockInput("MouseMoveOff")
}

Item1(*) { 
    EquipItem(1)
}
Item2(*) { 
    EquipItem(2) 
}
Item3(*) { 
    EquipItem(3) 
}
Item4(*) { 
    EquipItem(4) 
}
Item5(*) { 
    EquipItem(5) 
}
Item6(*) { 
    EquipItem(6) 
}
Item7(*) { 
    EquipItem(7) 
}
Item8(*) { 
    EquipItem(8) 
}
Item9(*) { 
    EquipItem(9) 
}
Item10(*) { 
    EquipItem(10) 
}
