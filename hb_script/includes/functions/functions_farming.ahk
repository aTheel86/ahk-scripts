/*
Usage:
you should have to begin

staff in 8?
4 hoes, one in each spot: 1, 2, 3, 4
Seeds in slot 12

inventory must be in default position (unlock it restart game), lock it

Things To Do:

MAJOR:
can get into a loop if bag is full (was trying to pickup produce over and over)

Make a clean up function to pickup all produce and sow all the crops, before ending/recalling sowFields()
add check for summon creatures
add check for players
add random messages
add check for "hello" "are you there" (maybe just check for "h" and "u")


test tampering
improve shop entrance logic
improve plot locations

*/



; Inventory position helper
; 14 13 12 11 10 9  8
;
; 1  2  3  4  5  6  7

global FarmingState := ""
global farmingActive := false  ; Initialize the farming status as inactive
global bNeedSeeds := false
global FarmedSeed := ""
global SeedInvSlot := 12
global sellSpot := [CtPixel(33.3, "X"),CtPixel(33.3, "Y")]
global FarmingIndicator := ""

class FARM_STATE {
    static FARM_RECALL            := "FARM_RECALL"
    static TRAVEL_FARM_PLOT       := "TRAVEL_FARM_PLOT"
    static GET_IN_FARM_PLOT       := "GET_IN_FARM_PLOT"
    static CHANGE_TOOLS           := "CHANGE_TOOLS"
    static SOW_FIELDS             := "SOW_FIELDS"
    static MOVE_TO_SHOP_WP1       := "MOVE_TO_SHOP_WP1"
    static MOVE_TO_SHOP           := "MOVE_TO_SHOP"
    static ENTER_SHOP             := "ENTER_SHOP"
    static REST_AND_SHOP          := "REST_AND_SHOP"
    static EXIT_SHOP              := "EXIT_SHOP"
    static MOVE_TO_BLACKSMITH_WP1 := "MOVE_TO_BLACKSMITH_WP1"
    static MOVE_TO_BLACKSMITH     := "MOVE_TO_BLACKSMITH"
    static ENTER_BLACKSMITH       := "ENTER_BLACKSMITH"
    static REPAIR_ALL             := "REPAIR_ALL"
    static MOVE_TO_WAREHOUSE      := "MOVE_TO_WAREHOUSE"
    static ENTER_WAREHOUSE        := "ENTER_WAREHOUSE"
    static MAIL_PRODUCE           := "MAIL_PRODUCE"
    static EXIT_WAREHOUSE         := "EXIT_WAREHOUSE"
    static EXIT_WAREHOUSE_WP1     := "EXIT_WAREHOUSE_WP1"
    static SET_FARM_PLOT          := "SET_FARM_PLOT"
    static END_FARMING            := "END_FARMING"
}

DefaultFarmSequence := [
    FARM_STATE.FARM_RECALL,
    FARM_STATE.MOVE_TO_SHOP_WP1,
    FARM_STATE.MOVE_TO_SHOP,
    FARM_STATE.ENTER_SHOP,
    FARM_STATE.REST_AND_SHOP,
    FARM_STATE.EXIT_SHOP,
    FARM_STATE.MOVE_TO_BLACKSMITH_WP1,
    FARM_STATE.MOVE_TO_BLACKSMITH,
    FARM_STATE.ENTER_BLACKSMITH,
    FARM_STATE.REPAIR_ALL,
    FARM_STATE.FARM_RECALL,
    FARM_STATE.TRAVEL_FARM_PLOT,
    FARM_STATE.GET_IN_FARM_PLOT,
    FARM_STATE.CHANGE_TOOLS,
    FARM_STATE.SOW_FIELDS
]

GinsengSaveSequence := [
    FARM_STATE.FARM_RECALL,
    FARM_STATE.MOVE_TO_SHOP_WP1,
    FARM_STATE.MOVE_TO_WAREHOUSE,
    FARM_STATE.ENTER_WAREHOUSE,
    FARM_STATE.MAIL_PRODUCE,
    FARM_STATE.EXIT_WAREHOUSE,
    FARM_STATE.MOVE_TO_SHOP,
    FARM_STATE.ENTER_SHOP,
    FARM_STATE.REST_AND_SHOP,
    FARM_STATE.EXIT_SHOP,
    FARM_STATE.MOVE_TO_BLACKSMITH_WP1,
    FARM_STATE.MOVE_TO_BLACKSMITH,
    FARM_STATE.ENTER_BLACKSMITH,
    FARM_STATE.REPAIR_ALL,
    FARM_STATE.FARM_RECALL,
    FARM_STATE.TRAVEL_FARM_PLOT,
    FARM_STATE.GET_IN_FARM_PLOT,
    FARM_STATE.CHANGE_TOOLS,
    FARM_STATE.SOW_FIELDS
]

GinsengSaveSowFirstSequence := [
    FARM_STATE.FARM_RECALL,
    FARM_STATE.TRAVEL_FARM_PLOT,
    FARM_STATE.GET_IN_FARM_PLOT,
    FARM_STATE.CHANGE_TOOLS,
    FARM_STATE.SOW_FIELDS,
    FARM_STATE.FARM_RECALL,
    FARM_STATE.MOVE_TO_SHOP_WP1,
    FARM_STATE.MOVE_TO_WAREHOUSE,
    FARM_STATE.ENTER_WAREHOUSE,
    FARM_STATE.MAIL_PRODUCE,
    FARM_STATE.EXIT_WAREHOUSE,
    FARM_STATE.MOVE_TO_SHOP,
    FARM_STATE.ENTER_SHOP,
    FARM_STATE.REST_AND_SHOP,
    FARM_STATE.EXIT_SHOP,
    FARM_STATE.MOVE_TO_BLACKSMITH_WP1,
    FARM_STATE.MOVE_TO_BLACKSMITH,
    FARM_STATE.ENTER_BLACKSMITH,
    FARM_STATE.REPAIR_ALL
]

SowThenRecallSequence := [
    FARM_STATE.SET_FARM_PLOT,
    FARM_STATE.CHANGE_TOOLS,
    FARM_STATE.SOW_FIELDS,
    FARM_STATE.FARM_RECALL,
    FARM_STATE.END_FARMING
]

TestSequence := [
    FARM_STATE.TRAVEL_FARM_PLOT,
    FARM_STATE.GET_IN_FARM_PLOT,
    FARM_STATE.CHANGE_TOOLS,
    FARM_STATE.SOW_FIELDS
]

FarmSequences := Map()
FarmSequences["Default"] := DefaultFarmSequence
FarmSequences["GinsengSave"] := GinsengSaveSequence
FarmSequences["GinsengSowFirst"] := GinsengSaveSowFirstSequence
FarmSequences["SowThenRecall"] := SowThenRecallSequence
FarmSequences["Test"] := TestSequence

FarmPositionsLtR := [directions.LeftDown, directions.Down, directions.RightDown]

MessageDialogueBoxPixel := [CtPixel(0.1, "X"),CtPixel(88.75, "Y")]
MessageDialogueBoxColor := 0x8C715A

;NoItemImage := "images\node_images\NoItemImage.png"
SellListAlreadyImage := "images\node_images\SellListAlready.png"
Okay_Menu_Prompt := NodeInfo("Okay_Menu", "images\node_images\Okay_Menu_Prompt.png",,,[8,6])
Okay_Menu_Prompt.SetSearchCoords(CtPixel(23, "X"), CtPixel(63, "Y"), CtPixel(52, "X"), CtPixel(82, "Y"))

; Nodes for farming
;NodeInfo(1:NodeTitle, 2:Imagepath, 3:AltImagepath, 4:WorldCoordinates, 5:ClickOffset; 6:Value, 7:ConnectedNodes)

; Farm Navigation to Farm Plots
farmPlotIndex := 0

; Waypoints
North_FarmWagon_WP1 := NodeInfo("North_FarmWagon_WP1",,, [90,95])
North_FarmWagon_WP2 := NodeInfo("North_FarmWagon_WP2",,, [83,82])
SW_BigFarm_WP1 := NodeInfo("SW_BigFarm_WP1",,, [110,125])

FarmPlotGroup1 := []
FarmPlotGroup1.Push(NodeInfo("North_FarmWagon_Slot1",,, [75, 79],,,[North_FarmWagon_WP1, North_FarmWagon_WP2]))
FarmPlotGroup1.Push(NodeInfo("North_FarmWagon_Slot3",,, [83, 82],,,[North_FarmWagon_WP1, North_FarmWagon_WP2]))
FarmPlotGroup1.Push(NodeInfo("SW_BigFarm_Slot1",,, [77, 113],,,[SW_BigFarm_WP1]))
FarmPlotGroup1.Push(NodeInfo("SW_BigFarm_Slot5",,, [55, 98],,,[SW_BigFarm_WP1]))
FarmPlotGroup1.Push(NodeInfo("SW_BigFarm_Slot10",,, [93, 110],,,[SW_BigFarm_WP1]))
FarmPlotGroup1.Push(NodeInfo("East_BigFarm_Slot7",,, [199, 141]))
FarmPlotGroup1.Push(NodeInfo("East_BigFarm_Slot3",,, [170, 180]))
FarmPlotGroup1.Push(NodeInfo("East_BigFarm_Slot4",,, [178, 168]))
FarmPlotGroup1.Push(NodeInfo("East_BigFarm_Slot5",,, [180, 154]))
FarmPlotGroup1.Push(NodeInfo("East_BigFarm_Slot1",,, [157, 169]))

FarmPlotGroup2 := []
FarmPlotGroup2.Push(NodeInfo("North_FarmWagon_Slot2",,, [81, 79],,,[North_FarmWagon_WP1, North_FarmWagon_WP2]))
FarmPlotGroup2.Push(NodeInfo("SW_BigFarm_Slot2",,, [71, 108],,,[SW_BigFarm_WP1]))
FarmPlotGroup2.Push(NodeInfo("SW_BigFarm_Slot3",,, [64, 105],,,[SW_BigFarm_WP1]))
FarmPlotGroup2.Push(NodeInfo("SW_BigFarm_Slot7",,, [73, 93],,,[SW_BigFarm_WP1]))
FarmPlotGroup2.Push(NodeInfo("East_BigFarm_Slot6",,, [198, 151]))
FarmPlotGroup2.Push(NodeInfo("East_BigFarm_Slot8",,, [187, 141]))
FarmPlotGroup2.Push(NodeInfo("SW_BigFarm_Slot4",,, [60, 102],,,[SW_BigFarm_WP1]))
FarmPlotGroup2.Push(NodeInfo("SW_BigFarm_Slot6",,, [54, 92],,,[SW_BigFarm_WP1]))
FarmPlotGroup2.Push(NodeInfo("SW_BigFarm_Slot8",,, [81, 94],,,[SW_BigFarm_WP1]))
FarmPlotGroup2.Push(NodeInfo("SW_BigFarm_Slot9",,, [87, 97],,,[SW_BigFarm_WP1]))
FarmPlotGroup2.Push(NodeInfo("East_BigFarm_Slot2",,, [159, 186]))

FarmPlotGroups := Map()
FarmPlotGroups["FarmPlotGroup1"] := FarmPlotGroup1
FarmPlotGroups["FarmPlotGroup2"]  := FarmPlotGroup2

farmPlots := []

; Farm Navigation to Shop
ShopEntrance := NodeInfo("ShopEntrance",,, [93,178])
ShopEntrance2 := NodeInfo("ShopEntrance2",,, [89,181])
ShopEntrance3 := NodeInfo("ShopEntrance3",,, [91,180])
ShopEntrance4 := NodeInfo("ShopEntrance4",,, [90,178])
Shop_WP1 := NodeInfo("Shop_WP1",,, [126,164])

; Recall Landing Spot
RecallLandingSpot := NodeInfo("RecallLandingSpot",,,[125, 151])

; Farm Navigation to Blacksmith
BlackSmithEntrance := NodeInfo("BlacksmithEntrance",,, [111,193])
BM_WP1 := NodeInfo("BM_WP1",,, [108,196])

; Shop Interior (for selling, buying, resting)
ShopExit := NodeInfo("ShopExit", "images\node_images\Shop_Exit.png",,,[16,102])
ShopKeeper := NodeInfo("ShopKeeper", "images\node_images\ShopKeeper.png",,,[40,66])
BuyMiscButton := NodeInfo("BuyMiscButton", "images\node_images\Buy_Misc.png",,,[16,6])
QuantitySelect := NodeInfo("QuantitySelect", "images\node_images\Quantity.png",,,[90,7])
PurchaseButton := NodeInfo("PurchaseButton", "images\node_images\Purchase_Button.png",,,[37,10])
RestButton := NodeInfo("RestButton", "images\node_images\RestButton.png",,,[16,6])
SellMaximum := NodeInfo("SellMaximum", "images\node_images\SellMaximum.png")
SellItemsButton := NodeInfo("SellButton", "images\node_images\SellItems_Button.png",,,[29,6])
SellDialogueBox := NodeInfo("SellQuantityBox", "images\node_images\quantityBoxImage.png")
SellConfirmButton := NodeInfo("SellConfirm", "images\node_images\Sell_Confirm_Button.png",,,[29,7])
SellListMenu := NodeInfo("SellListMenu", "images\node_images\SellListMenu.png")
InventoryMenu := NodeInfo("InventoryMenu", "images\node_images\InventoryMenu.png")
ItemsForSaleMenu := NodeInfo("ItemsForSale", "images\node_images\ItemsForSale.png",,,[16,0])

; Blacksmith Interior (for repairing)
Blacksmith := NodeInfo("Blacksmith", "images\node_images\Blacksmith.png",,,[15,81])
RepairAllButton := NodeInfo("RepairAllButton", "images\node_images\Repair_All.png",,,[22,7])
RepairButton := NodeInfo("RepairButton", "images\node_images\Repair.png",,,[12,7])
Already_Repaired := NodeInfo("Already_Repaired", "images\node_images\Already_Repaired.png")

; Warehouse Nav
WHEntrance := NodeInfo("WHEntrance",,, [72,197])
WH_WP1 := NodeInfo("WH_WP1",,, [75,200])

; Warehouse Interior
William := NodeInfo("William", "images\node_images\William.png",,,[14,34])
WH_Exit := NodeInfo("WH_Exit", "images\node_images\WH_Exit.png",,,[14,34])

; Mailbox
Mailbox := NodeInfo("Mailbox", "images\node_images\Mailbox.png",,,[8,4])
Send_Mail := NodeInfo("Send_Mail", "images\node_images\Send_Mail.png",,,[50,2])
Send_Btn := NodeInfo("Send_Btn", "images\node_images\Send.png",,,[8,4])
Recipient := NodeInfo("Recipient", "images\node_images\Recipient.png",,,[8,4])
Title := NodeInfo("Title", "images\node_images\Title.png",,,[8,4])
Mail_Box_Menu := NodeInfo("Mail_Box_Menu", "images\node_images\Mail_Box_Menu.png",,,[0,0])
No_Items_Attached := NodeInfo("No_Items_Attached", "images\node_images\Attach_Items_0.png",,,[0,0])

; Seeds 
Seed_Img := "images\node_images\Seed_Img.png"
seedIndex := 0
seedList := []
seedList.Push(NodeInfo("Watermelon", "images\node_images\Seed_Watermelon.png",,,[0,7], 4))
seedList.Push(NodeInfo("Pumpkin", "images\node_images\Seed_Pumpkin.png",,,[0,7], 4))
seedList.Push(NodeInfo("Garlic", "images\node_images\Seed_Garlic.png",,,[0,7], 4))
seedList.Push(NodeInfo("Barley", "images\node_images\Seed_Barley.png",,,[0,7], 4))
seedList.Push(NodeInfo("Carrot", "images\node_images\Seed_Carrot.png",,,[0,7], 4))
seedList.Push(NodeInfo("Radish", "images\node_images\Seed_Radish.png",,,[0,7], 4))
seedList.Push(NodeInfo("Corn", "images\node_images\Seed_Corn.png",,,[0,7], 4))
seedList.Push(NodeInfo("Chinese", "images\node_images\Seed_Chinese.png",,,[0,7], 4))
seedList.Push(NodeInfo("Melon", "images\node_images\Seed_Melon.png",,,[0,7], 4))
seedList.Push(NodeInfo("Tomato", "images\node_images\Seed_Tomato.png",,,[0,7], 4))
seedList.Push(NodeInfo("Grapes", "images\node_images\Seed_Grapes.png",,,[0,7], 4))
seedList.Push(NodeInfo("BlueGrapes", "images\node_images\Seed_BlueGrapes.png",,,[0,7], 4))
seedList.Push(NodeInfo("Mushroom", "images\node_images\Seed_Mushroom.png",,,[0,7], 4))
seedList.Push(NodeInfo("Ginseng", "images\node_images\Seed_Ginseng.png",,,[0,7], 7))

; Pickup
PickupHandImg := "images\node_images\Pickup_Hand.png"
CropBarImg := "images\node_images\Crop_bar.png"
;BagFullImg := "images\node_images\bag_full.png"
BagFullImg := "images\node_images\BagFull.png"

Test() {
    RepairAll()
}

StartFarming() {
    farmGui := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000 +OwnDialogs")
    farmGui.BackColor := "9b908d" ; Makes the GUI transparent
    WinSetAlwaysOnTop(1, farmGui.Hwnd)    

    ; Add the UpDown control and other components to the GUI
    farmGui.Add("Text",, "Select Seed To Farm:")
        seedNames := []
        for index, seed in seedList
            seedNames.Push(seed.GetNodeTitle())

        farmGui.Add("ListBox", "vSeedChoice Choose1 r" 5, seedNames)

    farmGui.Add("Text",, "Select Plot Group:")
        plotGroupNames := []
        for name, _ in FarmPlotGroups
            plotGroupNames.Push(name)

        farmGui.Add("ListBox", "vPlotChoice Choose1 r" 5, plotGroupNames)

    farmGui.Add("Text",, "Select sequence:")
        SequenceNames := []
        for name, _ in FarmSequences
            SequenceNames.Push(name)

        farmGui.Add("ListBox", "vFarmingSequence Choose1 r" 5, SequenceNames)
    
    farmGui.Submit()

    OKButton := farmGui.Add("Button", "Default vOKButton", "OK")
    OKButton.OnEvent("Click", (*) => FarmingButtonSubmit(farmGui))

    ; Show the GUI
    farmGui.Show("Center NA NoActivate")
}

FarmingButtonSubmit(farmGui) {
    global seedIndex, farmPlotIndex, farmPlots, FarmingIndicator

    results := farmGui.Submit()

    for i, node in seedList {
        if (node.GetNodeTitle() == results.SeedChoice) {
            seedIndex := i
            break
        }
    }

    farmPlots := FarmPlotGroups[results.PlotChoice]

    selectedSequence := FarmSequences[results.FarmingSequence]

    if (FarmingIndicator == "") {
        FarmingIndicator := gGUI.Add("Text", "x" CtPixel(0, "X") " y" CtPixel(97, "Y") " cWhite", "Farming " seedList[seedIndex].GetNodeTitle())
        FarmingIndicator.SetFont("s" CalculateFontSize(1) " bold", "Segoe UI")
    }
    else {
        FarmingIndicator.Visible := true
    }

    FarmingCycle(selectedSequence)
    farmGui.Destroy()
}

StateHandler(state) {
    if (!farmingActive) {
        return
    }

    switch state {
        case FARM_STATE.FARM_RECALL:
            return FarmingRecall()

        case FARM_STATE.TRAVEL_FARM_PLOT:
            farmPlots[farmPlotIndex].MoveToLocation()
            return true

        case FARM_STATE.GET_IN_FARM_PLOT:
            return GetInFarmSpot()

        case FARM_STATE.CHANGE_TOOLS:
            return CycleTool()

        case FARM_STATE.SOW_FIELDS:
            SowFields()
            return true

        case FARM_STATE.MOVE_TO_SHOP_WP1:
            Shop_WP1.MoveToLocation()
            return true

        case FARM_STATE.MOVE_TO_SHOP:
            ShopEntrance.MoveToLocation()
            return true

        case FARM_STATE.ENTER_SHOP:
            if (EnterShop()) {
                return true
            }

        case FARM_STATE.REST_AND_SHOP:
            return RestAndShop()

        case FARM_STATE.EXIT_SHOP:
            if (ExitShop()) {
                return true
            }

        case FARM_STATE.MOVE_TO_BLACKSMITH_WP1:
            BM_WP1.MoveToLocation()
            return true

        case FARM_STATE.MOVE_TO_BLACKSMITH:
            BlackSmithEntrance.MoveToLocation()
            return true

        case FARM_STATE.ENTER_BLACKSMITH:
            if (EnterBlackSmith()) {
                return true
            }

        case FARM_STATE.REPAIR_ALL:
            return RepairAll()

        case FARM_STATE.MOVE_TO_WAREHOUSE:
            return WHEntrance.MoveToLocation()

        case FARM_STATE.ENTER_WAREHOUSE:
            return EnterWH()

        case FARM_STATE.MAIL_PRODUCE:
            return MailProduce()

        case FARM_STATE.EXIT_WAREHOUSE:
            return ExitWareHouse()

        case FARM_STATE.EXIT_WAREHOUSE_WP1:
            WH_WP1.MoveToLocation()
            return true

        case FARM_STATE.SET_FARM_PLOT:
            farmPlotIndex := farmPlots.Push(NodeInfo("Current_Pos",,, [playerGameCoords[1], playerGameCoords[2]]))
            return true

        case FARM_STATE.END_FARMING:
            return false
    }
}

FarmingCycle(sequence) {
    global farmingActive, farmPlotIndex

    farmingActive := true
    currentStateIndex := 1
    currentPlotIndex := 1

    EnableShiftPickup()
    Sleep 10

    Loop {
        if stopFlag {
            break
        }

        currentState := sequence[currentStateIndex]

        ; Randomzie plots
        if (currentState = FARM_STATE.TRAVEL_FARM_PLOT) {
            farmPlotIndex := Random(1, farmPlots.Length)
        }

        success := StateHandler(currentState)

        if !success
            break

        currentStateIndex++
        if (currentStateIndex > sequence.Length)
            currentStateIndex := 1
    }

    StopFarming()
}

StopFarming() {
    global farmingActive, stopFlag, FarmingIndicator

    DisableShiftPickup()
    farmingActive := false
    stopFlag := false
    FarmingIndicator.Visible := false
    RemoveHolds()
    ReturnInputs()
}

MailProduce() {
    Loop 2 {
        if (!farmingActive) {
            return false
        }

        if (William.IsOnScreen()) {
            William.Click()
        }
        Mailbox.Click()
        MouseMove(CenterX, CenterY, 0)
        Send_Mail.Click()
        MouseMove(CenterX, CenterY, 0)
        Recipient.Click()
        MouseMove(CenterX, CenterY, 0)
        SendText("Rhunlen") 
        MouseMove(CenterX, CenterY, 0)
        Title.Click()
        MouseMove(CenterX, CenterY, 0)
        SendText(seedList[seedIndex].GetNodeTitle()) 
        MouseMove(CenterX, CenterY, 0)
        OpenBag()
        Sleep 100
        MouseClick("L", DefaultItemLandingPos[1], DefaultItemLandingPos[2], 21, 0) ;21 because 1 click then 20 'double-clicks'
        OpenBag()
        if (!No_Items_Attached.IsOnScreen()) {
            Send_Btn.Click() ; Only send if we actualy have an attachment!
        }
        Sleep 100
        Mail_Box_Menu.Click("R", 1, false)
        Sleep 100
    }

    ; extra attempt to close the screen
    MouseMove(CenterX, CenterY, 0)
    if Mail_Box_Menu.IsOnScreen() {
        Mail_Box_Menu.Click("R", 1, false)
    }

    return true
}

ExitWareHouse() {
    Loop 10 {
        WH_Exit.Click()
        Sleep 500
        MouseMove(CenterX, CenterY, 0)
        if (WHEntrance.IsPlayerNearby()) {
            if (WH_WP1.MoveToLocation()) {
                return true
            }            
        }
        Sleep 100
    }
    return false
}

EnterWH() {
    Loop 5 {
        WHEntrance.Click()
        Sleep 500
        MouseMove(CenterX, CenterY, 0)
        if (William.IsOnScreen()) {
            return true
        }
        Sleep 100
    }
    return false
}

EnterShop() {
    ShopEntrances := [ShopEntrance, ShopEntrance2, ShopEntrance3, ShopEntrance4]  ; Array of shop entrances

    Loop 5 {
        for each, entrance in ShopEntrances {
            entrance.Click()
            Sleep 500
            MouseMove(CenterX, CenterY, 0)
            if (ShopKeeper.IsOnScreen()) {
                return true
            }
            Sleep 100
        }
    }
    return false
}

ExitShop() {
    Loop 10 {
        ShopExit.Click()
        Sleep 500
        MouseMove(CenterX, CenterY, 0)
        if (ShopEntrance.IsPlayerNearby()) {
            return true
        }
        Sleep 100
    }
    return false
}

EnterBlackSmith() {
    Loop 10 {
        BlackSmithEntrance.Click()
        Sleep 500
        MouseMove(CenterX, CenterY, 0)
        if (Blacksmith.IsOnScreen()) {
            return true
        }
        Sleep 100
    }
    return false
}

RepairAll() {
    Loop 10 {
        if (Blacksmith.IsOnScreen()) {
            Blacksmith.Click() 
        }
        Sleep 200
        if (RepairAllButton.IsOnScreen()) {
            RepairAllButton.Click()

            if (Already_Repaired.IsOnScreen()) {
                return true
            }
        }
        Sleep 200
        MouseMove(CenterX, CenterY, 0)
        if (RepairButton.IsOnScreen()) {
            RepairButton.Click()
            return true
        }
        Sleep 500
    }
    return false
}

RestAndShop() {
    Loop 10 {
        if (ShopKeeper.IsOnScreen()) {
            ShopKeeper.Click()
            Sleep 200
            RestButton.Click()
            Sleep 200

            ; Then lets sell produce
            SellProduce()
            Sleep 100
            ShopKeeper.Click()
            Sleep 200
            BuyMiscButton.Click()
            Sleep 200
            BuySeeds()
            Sleep 100
            MouseMove(0, 0, 0)
            Sleep 100
            Loop 10 {
                if (ItemsForSaleMenu.Click("right")) {
                    break
                }
                Sleep 1000
            }
            OpenBag()
            Sleep 100
            MoveSeedsToPosition()
            if (InventoryMenu.IsOnScreen()) {
                OpenBag() ; closes the opened inventory menu
            }
            return true
        }
        Sleep 1000
    }

    return false
}

MoveSeedsToPosition() {
    MouseMove(0, 0, 0)

    if (ImageSearch(&X, &Y, InventoryAreaBox[1], InventoryAreaBox[2], InventoryAreaBox[3], InventoryAreaBox[4], "*TransBlack " Seed_Img)) {
        Send("{Shift down}")
        MouseClickDrag("L", X+3, Y+3, InventorySlotPos[12][1]-5, InventorySlotPos[12][2]-5, 3)
        Send("{Shift up}")
        Sleep 300
    }
    else {
        StopFarming()
    }
}

BuySeeds() {
    global bNeedSeeds

    MouseMove(0, 0, 0)

    if (seedIndex == 0) {
        StopFarming()
        return
    }

    ; scroll down until we see our seed
    Loop {
        Send("{WheelDown}")
        Sleep 500
    } Until (seedList[seedIndex].IsOnScreen())

    Sleep 100
    seedList[seedIndex].Click()
    Sleep 100
    MouseMove(0, 0, 0)
    Sleep 200
    QuantitySelect.Click(, seedList[seedIndex].Value)
    Sleep 200
    PurchaseButton.Click()

    bNeedSeeds := false
}

SellProduce() {
    Loop {
        ShopKeeper.Click()
        Sleep 200
        SellItemsButton.Click()
        Sleep 200
    } Until (SellItemsOnDefaultSlot())

    if (SellListMenu.IsOnScreen()) {
        MouseClick("R", sellSpot[1], sellSpot[2], 1)
    }
}

SellItemsOnDefaultSlot() {
    local bHitMaximumItems := false

    PreSellSpotX := DefaultItemLandingPos[1] - CtPixel(7, "X")
    X1 := CtPixel(1, "X")
    Y1 := CtPixel(75, "Y")
    X2 := CtPixel(22, "X")
    Y2 := CtPixel(91, "Y")

    Loop 18 {
        MouseClick "left", DefaultItemLandingPos[1], DefaultItemLandingPos[2], 2       
        Sleep 50
        if (ImageSearch(&X, &Y, X1, Y1, X2, Y2, "*TransBlack " SellListAlreadyImage)) {  
            MouseClickDrag "L", DefaultItemLandingPos[1], DefaultItemLandingPos[2], PreSellSpotX, DefaultItemLandingPos[2], 2
            Sleep 50
        }

        if (SellDialogueBox.IsOnScreen() || PixelGetColor(MessageDialogueBoxPixel[1], MessageDialogueBoxPixel[2]) == MessageDialogueBoxColor) {
            Send("{Enter}")
        }

        if (!bHitMaximumItems && SellMaximum.IsOnScreen()) {
            bHitMaximumItems := true
        }
    }

    Loop 5 {
        if (SellConfirmButton.IsOnScreen()) {
            SellConfirmButton.Click()
            break
        }
        Sleep 100
    }

    if (InventoryMenu.IsOnScreen()) {
        OpenBag() ; closes the opened inventory menu
    }

    return !bHitMaximumItems
}

SowFields() {
    ClearEnemies()
    PlantInitialCrop()

    if !GetInFarmSpot() {
        StopFarming()
        return
    }
    
    HarvestCrops()
}

FarmingRecall() {
    TmpY := 0

    EquipItem(8) ; staff
    Sleep 100

    Loop 3 {
        if (A_Index = 3) {
            TmpY := YOffset
        }

        CastSpellByName("Recall")
        Sleep 100
        MouseMove(CenterX, CenterY - TmpY, 0)
        Sleep 1700
        MouseClick("L", CenterX, CenterY - TmpY)
        Sleep 500

        if (RecallLandingSpot.IsPlayerNearby()) {
            return true
        }
        else {
            ClearEnemies()
        }
    } 

    return false
}

CycleTool() {
    if (!farmingActive) {
        return false
    }

    Static Index := 1

    if (Index > 4) { ; Setup for 4 tools
        Index := 1
    }

    EquipItem(Index)
    BlockInput "MouseMove" ; Calling the equip item function will stop blocking mouse input, so we need to block it again here.
    Index++
    Sleep 250
    return true
}

GetInFarmSpot() {
    if (!farmingActive || farmPlotIndex == 0) {
        return false
    }  

    Loop 3 {
        if (farmPlots[farmPlotIndex].IsPlayerOnWorldLocation()) {
            return true
        }

        farmPlots[farmPlotIndex].Click()
        MouseMove(CenterX, CenterY, 0)
        Sleep 2000
        MouseClick("R") ; stop moving
        Sleep 10
    } 

    ; try one more thing (move up and to the left pretty far)
    Loop 2 {
        DesiredPosition := [playerGameCoords[1] - 3, playerGameCoords[2] - 2]
        MoveToWorldCoord(DesiredPosition)
        Sleep 2000
        farmPlots[farmPlotIndex].Click()
        MouseMove(CenterX, CenterY, 0)
        Sleep 2000
        MouseClick("R") ; stop moving
        Sleep 10

        if (farmPlots[farmPlotIndex].IsPlayerOnWorldLocation()) {
            return true
        }
    }

    StopFarming()
    return false
}

ClearEnemies() {
    i := 0

    if (!farmingActive) {
        return
    }

    EnemyCoords := FindAdjacentEnemy()
    if (EnemyCoords) {
        Send("{RButton down}")
        Loop {
            i++
            if (i > 20) {
                Send("{Alt down}")
            }

            if (i > 100) {
                break
            }
            Sleep 100
        } Until !CanAttackCoord(EnemyCoords[1], EnemyCoords[2])
        Send("{Alt up}")
        Send("{RButton up}")
        MouseMove(CenterX, CenterY, 0)
        Sleep 1000
    }
}

CheckSeedsRemaining() {
    Global bNeedSeeds

    if (!farmingActive) {
        return
    }    

    x := InventorySlotPos[12][1]
    y := InventorySlotPos[12][2]

    X1 := x - 20, Y1 := y - 20, X2 := x + 20, Y2 := y + 20

    if (ImageSearch(&Px, &Py, X1, Y1, X2, Y2, "*TransBlack " Seed_Img)) {
        return true
    }
    else {
        bNeedSeeds := true
        return false
    }      
}

DoesSummonExist() {
    ; prob need to move mouse here temp

    X1 := CenterX, Y1 := CenterY
    X2 := CenterX + (2 * XOffset)
    Y2 := CenterY + (2 * YOffset)

    return PixelSearch(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, 0x00d700)
}

DoesProduceExist(square) {
    MouseMove(square[1], square[2], 0)

    X1 := square[1] - 30
    X2 := square[1] + 30
    Y1 := square[2] - 30
    Y2 := square[2] + 30

    Loop 5 {
        if (ImageSearch(&Px, &Py, X1, Y1, X2, Y2, "*TransBlack " PickupHandImg)) {
            return true
        }
        Sleep Random(25,50)
    }

    return false
}

DoesCropExist(square) {
    MouseMove(square[1], square[2], 0)

    X1 := square[1] - 40
    X2 := square[1] + 40
    Y1 := square[2] - 40
    Y2 := square[2] + 40

    Loop 5 {
        if (ImageSearch(&Px, &Py, X1, Y1, X2, Y2, "*TransBlack " CropBarImg)) {
            return true
        }
        Sleep Random(25,50)
    }
	return false
}

IsBagFull(*) {
    bIsFull := false

    OpenBag()
    Sleep 100
    if (ImageSearch(&Px, &Py, InventoryAreaBox[1], InventoryAreaBox[2], InventoryAreaBox[3], InventoryAreaBox[4], "*TransBlack " BagFullImg)) {
        bIsFull := true
    }
    OpenBag() ; close
    Sleep 250

	return bIsFull
}

PlantCropInSquare(square) {
    OpenBag()
    Sleep 250
    if (CheckSeedsRemaining()) {
        MouseClick("L", InventorySlotPos[SeedInvSlot][1]+10, InventorySlotPos[SeedInvSlot][2]+10, 2, 0)
        Sleep Random(100,500)
        MouseClick("L", square[1], square[2], 1, 0)
    }
    OpenBag() ;Close 
    Sleep 50
}

PlantInitialCrop() {
    for square in FarmPositionsLtR {
        if (!DoesCropExist(square)) {
            PlantCropInSquare(square)
        }
    }
}

HarvestSwingDown(direction := directions.Down, bDesiredClear := false) {
    static NextToolCycleTime := 0

    if (NextToolCycleTime = 0)
        NextToolCycleTime := A_TickCount + 40000

    if (DoesCropExist(direction)) {
        MouseMove(direction[1], direction[2], 0)
        Send("{RButton down}")

        extraTime := bDesiredClear ? 10000 : 0
        RandomLoopTime := A_TickCount + Random(5000, 10000) + extraTime

        Loop {
            Sleep 500
        } Until !DoesCropExist(direction) || (A_TickCount >= RandomLoopTime)

        Send("{RButton up}")

        if (NextToolCycleTime <= A_TickCount) {
            Sleep 10
            CycleTool()
            NextToolCycleTime := A_TickCount + 40000
        }
    }
}

IsCropMissing() {
    for idx, square in FarmPositionsLtR {
        i := idx - 2 ; 1→-1, 2→0, 3→1

        if (!DoesCropExist(square)) {
            return true
        }
    }

    return false
}

ProduceNeedsPicked() {
    for idx, square in FarmPositionsLtR {
        i := idx - 2 ; 1→-1, 2→0, 3→1

        if (DoesProduceExist(square)) {
            return true
        }
    }

    return false
}

PickUpProduce() {
    for idx, square in FarmPositionsLtR {
        i := idx - 2   ; 1→-1, 2→0, 3→1

        if (DoesProduceExist(square)) {
            curPos := farmPlots[farmPlotIndex].WorldCoordinates
            DesiredPosition := [curPos[1] + i, curPos[2] + 1]
            MoveToWorldCoord(DesiredPosition)
            Sleep 250
            PickUp()
            MoveToWorldCoord(farmPlots[farmPlotIndex].WorldCoordinates)
            Sleep 500
            GetInFarmSpot()
            Sleep 100
        }
    }
}

PlantCropSquares() {
    for idx, square in FarmPositionsLtR {
        i := idx - 2   ; 1→-1, 2→0, 3→1

        if (!DoesCropExist(square)) {
            PlantCropInSquare(square)
        }
    }
}

ClearSideCrops() {
    if (DoesCropExist(directions.Left)) {
        HarvestSwingDown(directions.Left, true)
    }

    if (DoesCropExist(directions.Right)) {
        HarvestSwingDown(directions.Right, true)
    }
}

HarvestCrops() {
    global bNeedSeeds

    NextClearEnemiesTime := A_TickCount
    NextPickUpTime := A_TickCount

    Loop {
        if (!farmingActive) {
            return
        }

        if (!WinActive(WinTitle)) {
            return
        }
        
        if (stopFlag) {
            StopFarming()
            Break
        }

        Send("{RButton up}")

        if (NextClearEnemiesTime <= A_TickCount) {
            ClearEnemies()
            NextClearEnemiesTime := A_TickCount + 25000 ;25 secs
        }

        if (NextPickUpTime <= A_TickCount) {
            PickUp()
            
            NextPickUpTime := A_TickCount + 30000
        }
        
        ; If no crops are missing, lets harvest middle!
        if (!IsCropMissing()) { 
            HarvestSwingDown()
        }       
        else {
            if (!IsBagFull() && ProduceNeedsPicked()) {
                PickUpProduce()
            }
            else {
                PlantCropSquares()

                ; If we have a crop missing, we failed to plant for some reason (clear enemies) and check for anti-bot
                Sleep 100
                if (IsCropMissing()) {
                    ClearSideCrops() ; Clear out side crops (this should not be needed, but is useful in case someone is messing with us or we are for some reason off position
                    ClearEnemies()
                }
            }
        }

        if (DoesSummonExist()) { ;Some assholes summon creatures to stop the bot, lets detect if this has occurred and change course
            bNeedSeeds := true
            Send("{RButton up}")
            return
        }
    } Until (bNeedSeeds)

    ;HarvestSwingDown(directions.RightDown)
    ;HarvestSwingDown(directions.LeftDown)

    Send("{RButton up}")
}

PickUp() {
    MouseMove(CenterX, CenterY, 0)
    Sleep 100
    Send("{Shift down}")
    Send("{RButton down}")
    Sleep 150
    Send("{RButton up}")
    Send("{Shift up}")
    Sleep 500
}

MoveToWorldCoord(WorldCoordinates) {
    global playerGameCoords

    ; validate input
    if (!IsObject(WorldCoordinates) || WorldCoordinates.Length < 2)
        return false

    if (WorldCoordinates[1] == "" || WorldCoordinates[2] == "")
        return false

    UpdatePlayerCoords()
    Sleep 10

    if (!IsObject(playerGameCoords) || playerGameCoords.Length < 2
        || playerGameCoords[1] == "" || playerGameCoords[2] == "")
        return false

    px := playerGameCoords[1], py := playerGameCoords[2]
    tx := WorldCoordinates[1], ty := WorldCoordinates[2]

    ; throw distance clamp (prevents crazy clicks)
    dx := tx - px
    dy := ty - py
    maxThrow := 8
    dx := (dx > 0) ? Min(dx, maxThrow) : Max(dx, -maxThrow)
    dy := (dy > 0) ? Min(dy, maxThrow) : Max(dy, -maxThrow)

    ; if CalcClickScreenSpaceOffset is a method, use this.
    click := CalcClickScreenSpaceOffset(px, py, px + dx, py + dy)

    MouseClick("L", click[1], click[2], 1, 0)
    return true
}

CalcClickScreenSpaceOffset(playerX, playerY, targetX, targetY) {
    deltaX := targetX - playerX  ; Coord difference in X
    deltaY := targetY - playerY  ; Coord difference in Y
    ScreenSpaceOffsetX := CenterX + (XOffset * deltaX) ; Calcs the X offset from center
    ScreenSpaceOffsetY := CenterY + (YOffset * deltaY) ; Calcs the Y offset from center 
    return [ScreenSpaceOffsetX, ScreenSpaceOffsetY]
}