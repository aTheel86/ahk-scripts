; Directory locations
Global ConfigDir := A_ScriptDir "\configs\user"
Global SpellBindsDir := A_ScriptDir "\configs\spellbinds"

; Script config
Global LauncherConfig := A_ScriptDir "\configs\launcher_config.ini"  ; launcher INI
Global ConfigFile := ConfigDir "\" IniRead(LauncherConfig, "Settings", "UserConfigFile")
Global SpellsCfgFile := SpellBindsDir "\" IniRead(ConfigFile, "Configs", "SpellsCfgFile")

; GUI variables
Global gGUI := Gui("+AlwaysOnTop +ToolWindow -Caption E0x8000000") ;Disabled
gGUI.BackColor := "EEAA99" ; Makes the GUI transparent
WinSetTransColor(gGUI.BackColor, gGUI) ; " 150" Makes the GUI transparent
Global activeMenuManager := ""  ; Global variable to store the active MenuManager instance

; Script variables
Global WinTitle := "Helbreath Olympia 18.2" ; Title of the window
Global bDebugMode := false
Global CastingEffectSpell := ""
Global Effects := []
Global stopFlag := false  ; Flag to stop loops
Global SquarePercentageX := 4
Global SquarePercentageY := 5.35
Global SpellHorizontalPos := 62.5

; Auto Trade Rep
Global bAutoTradeRepping := false 

; From ConfigFile
Global ScreenResX := IniRead(ConfigFile, "Coords", "ScreenResolutionX")
Global ScreenResY := IniRead(ConfigFile, "Coords", "ScreenResolutionY")
Global CenterX := ScreenResX / 2
Global CenterY := ScreenResY / 2

; Calculate pixel offsets for square positions
GridSquaresX := 25
GridSquaresY := 17
XOffset := CtPixel(SquarePercentageX, "X")
YOffset := CtPixel(SquarePercentageY, "Y")
XOffsets := [-XOffset, 0, XOffset]
YOffsets := [-YOffset, 0, YOffset]
directions := Object() ; Define coordinates for each adjacent square using valid object literal syntax
directions.RightDown := [CenterX + XOffsets[3], CenterY + YOffsets[3]]
directions.LeftDown := [CenterX + XOffsets[1], CenterY + YOffsets[3]]
directions.LeftUp := [CenterX + XOffsets[1], CenterY + YOffsets[1]]
directions.RightUp := [CenterX + XOffsets[3], CenterY + YOffsets[1]]
directions.Up := [CenterX + XOffsets[2], CenterY + (YOffsets[1])]
directions.Down := [CenterX + XOffsets[2], CenterY + YOffsets[3]]
directions.Left := [CenterX + XOffsets[1], CenterY + YOffsets[2]]
directions.Right := [CenterX + XOffsets[3], CenterY + YOffsets[2]]

; Global AutoPot()
Global AutoPotLifeAtPercent := IniRead(ConfigFile, "AutoPot", "AutoPotLifeAtPercent")
Global AutoPotManaAtPercent := IniRead(ConfigFile, "AutoPot", "AutoPotManaAtPercent")
Global LowHPPos := [CtPixel(13.5, "X"), CtPixel(94.1, "Y")]
Global MidHPPos := [CtPixel(13.0 + (12.5 * (AutoPotLifeAtPercent * 0.01)), "X"), CtPixel(93.3, "Y")] 
Global HighHPPos := [CtPixel(25.0, "X"), CtPixel(94.1, "Y")]
Global LowManaPos := [CtPixel(13.5, "X"), CtPixel(97.8, "Y")]
Global MidManaPos := [CtPixel(13.0 + (12.5 * (AutoPotManaAtPercent * 0.01)), "X"), CtPixel(97.8, "Y")]
Global HighManaPos := [CtPixel(25.0, "X"), CtPixel(97.8, "Y")]
Global LifeRed := "0xd83c2b"
Global ManaBlue := "0x3e45d8"
Global EmptyGrey := "0x5e5b58"
Global bTryHPPotting := true ; Not to be confused with UseAutoPotting used in config file
Global bTryManaPotting := true

; Define the global array of inventory slot positions
Global InventorySlotPos := []  ; Initialize as an empty array
Global DefaultItemLandingPos := [CtPixel(71.6, "X"),CtPixel(61.9, "Y")]

; Player and Game Variables
Global playerGameCoords := [0,0]
GameCoords := [0,0]

; Populate the global array with coordinates
InventorySlotPos.Push([CtPixel(71.125, "X"), CtPixel(78.333, "Y")]) ; Item 1
InventorySlotPos.Push([CtPixel(74.75, "X"), CtPixel(78.333, "Y")])  ; Item 2
InventorySlotPos.Push([CtPixel(78.375, "X"), CtPixel(78.333, "Y")]) ; Item 3
InventorySlotPos.Push([CtPixel(82, "X"), CtPixel(78.333, "Y")])     ; Item 4
InventorySlotPos.Push([CtPixel(85.6255, "X"), CtPixel(78.333, "Y")]) ; Item 5
InventorySlotPos.Push([CtPixel(89.25, "X"), CtPixel(78.333, "Y")])  ; Item 6
InventorySlotPos.Push([CtPixel(92.875, "X"), CtPixel(78.333, "Y")]) ; Item 7
InventorySlotPos.Push([CtPixel(92.875, "X"), CtPixel(67.333, "Y")])  ; Item 8
InventorySlotPos.Push([CtPixel(89.25, "X"), CtPixel(67.333, "Y")])  ; Item 9
InventorySlotPos.Push([CtPixel(85.6255, "X"), CtPixel(67.333, "Y")])  ; Item 10
InventorySlotPos.Push([CtPixel(82.001, "X"), CtPixel(67.333, "Y")])  ; Item 11
InventorySlotPos.Push([CtPixel(78.3765, "X"), CtPixel(67.333, "Y")])  ; Item 12
InventorySlotPos.Push([CtPixel(74.752, "X"), CtPixel(67.333, "Y")])  ; Item 13
InventorySlotPos.Push([CtPixel(71.1275, "X"), CtPixel(67.333, "Y")])  ; Item 14


