Global bIsEnchantingMode := false

ValueImgs := Map()

InitValueImgs(dir := "images\enchanting\values\") {
    global ValueImgs
    ValueImgs.Clear()
    Loop 100 {
        v := A_Index - 1   ; 0..99
        ValueImgs[v] := dir v ".png"
    }
}

InitValueImgs()

StatImgDir := "images\enchanting\"  ; change to your folder

ShardFragData := Map(
    "Cast Prob",     Map("Img", StatImgDir "CastProb.png",     "Inc",1, "L2",[10,11], "L3",[14,15], "L4",[19]),
    "Crush Chance",  Map("Img", StatImgDir "CrushChance.png",  "Inc",1, "L2",[4,5],   "L3",[6,7],   "L4",[9]),
    "Endurance",     Map("Img", StatImgDir "Endurance.png",    "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    ;"Experience",    Map("Img", StatImgDir "Experience.png",   "Inc",1, "L2",[7,8],   "L3",[10,11], "L4",[14]),
    ;"Gold",          Map("Img", StatImgDir "Gold.png",         "Inc",1, "L2",[10,11], "L3",[14,15], "L4",[19]),
    "Light",         Map("Img", StatImgDir "Light.png",        "Inc",1, "L2",[10,11], "L3",[14,15], "L4",[19]),
    "Mana Conv",     Map("Img", StatImgDir "ManaConv.png",     "Inc",1, "L2",[4,5],   "L3",[6,7],   "L4",[9]),
    "Poisoning",     Map("Img", StatImgDir "Poisoning.png",    "Inc",1, "L2",[10,11], "L3",[14,15], "L4",[19]),
    "Crush Damage",  Map("Img", StatImgDir "CrushDamage.png",  "Inc",1, "L2",[7,8],   "L3",[10,11], "L4",[14]),
    "Def Ratio",     Map("Img", StatImgDir "DefRatio.png",     "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    "Experience",    Map("Img", StatImgDir "Experience.png",   "Inc",2, "L2",[11,14], "L3",[16,19], "L4",[23,24]),
    "Gold",          Map("Img", StatImgDir "Gold.png",         "Inc",2, "L2",[14,17], "L3",[20,23], "L4",[28,29]),
    "Hit Ratio",     Map("Img", StatImgDir "HitRatio.png",     "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    "HP Rec",        Map("Img", StatImgDir "HPRec.png",        "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    "Magic Abs",     Map("Img", StatImgDir "MagicAbs.png",     "Inc",1, "L2",[7,8],   "L3",[10,11], "L4",[14]),
    "Magic Res",     Map("Img", StatImgDir "MagicRes.png",     "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    "MP Rec",        Map("Img", StatImgDir "MPRec.png",        "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    "Phys Abs",      Map("Img", StatImgDir "PhysAbs.png",      "Inc",1, "L2",[7,8],   "L3",[10,11], "L4",[14]),
    "Poison Res",    Map("Img", StatImgDir "PoisonRes.png",    "Inc",1, "L2",[7,8],   "L3",[10,11], "L4",[14]),
    "SP Rec",        Map("Img", StatImgDir "SPRec.png",        "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34])
)

/*
ShardData := Map(
    "Cast Prob",     Map("Img", StatImgDir "CastProb.png",     "Inc",1, "L2",[10,11], "L3",[14,15], "L4",[19]),
    "Crush Chance",  Map("Img", StatImgDir "CrushChance.png",  "Inc",1, "L2",[4,5],   "L3",[6,7],   "L4",[9]),
    "Endurance",     Map("Img", StatImgDir "Endurance.png",    "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    "Experience",    Map("Img", StatImgDir "Experience.png",   "Inc",1, "L2",[7,8],   "L3",[10,11], "L4",[14]),
    "Gold",          Map("Img", StatImgDir "Gold.png",         "Inc",1, "L2",[10,11], "L3",[14,15], "L4",[19]),
    "Light",         Map("Img", StatImgDir "Light.png",        "Inc",1, "L2",[10,11], "L3",[14,15], "L4",[19]),
    "Mana Conv",     Map("Img", StatImgDir "ManaConv.png",     "Inc",1, "L2",[4,5],   "L3",[6,7],   "L4",[9]),
    "Poisoning",     Map("Img", StatImgDir "Poisoning.png",    "Inc",1, "L2",[10,11], "L3",[14,15], "L4",[19])
)

FragData := Map(
    "Crush Damage",  Map("Img", StatImgDir "CrushDamage.png",  "Inc",1, "L2",[7,8],   "L3",[10,11], "L4",[14]),
    "Def Ratio",     Map("Img", StatImgDir "DefRatio.png",     "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    "Experience",    Map("Img", StatImgDir "Experience.png",   "Inc",2, "L2",[11,14], "L3",[16,19], "L4",[23,24]),
    "Gold",          Map("Img", StatImgDir "Gold.png",         "Inc",2, "L2",[14,17], "L3",[20,23], "L4",[28,29]),
    "Hit Ratio",     Map("Img", StatImgDir "HitRatio.png",     "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    "HP Rec",        Map("Img", StatImgDir "HPRec.png",        "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    "Magic Abs",     Map("Img", StatImgDir "MagicAbs.png",     "Inc",1, "L2",[7,8],   "L3",[10,11], "L4",[14]),
    "Magic Res",     Map("Img", StatImgDir "MagicRes.png",     "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    "MP Rec",        Map("Img", StatImgDir "MPRec.png",        "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34]),
    "Phys Abs",      Map("Img", StatImgDir "PhysAbs.png",      "Inc",1, "L2",[7,8],   "L3",[10,11], "L4",[14]),
    "Poison Res",    Map("Img", StatImgDir "PoisonRes.png",    "Inc",1, "L2",[7,8],   "L3",[10,11], "L4",[14]),
    "SP Rec",        Map("Img", StatImgDir "SPRec.png",        "Inc",2, "L2",[17,20], "L3",[24,27], "L4",[33,34])
)
*/

GetStatLevel(statName, value, dataMap) {
    if !dataMap.Has(statName)
        return ""

    info := dataMap[statName]

    if !(IsInteger(value) && value >= 0 && value <= 99) {
        Tooltip "Value is: " value
        Sleep 1000
        Tooltip ""
        return ""
    }

    ; Check L4 first (highest)
    if (value = info["L4"][1])
        return "L4"

    ; Check L3 range
    if (value >= info["L3"][1] && value <= info["L3"][2])
        return "L3"

    ; Check L2 range
    if (value >= info["L2"][1] && value <= info["L2"][2])
        return "L2"

    return ""   ; Not in any range
}

IsItemWorthUpgrading(statName, value, dataMap) {
    return GetStatLevel(statName, value, dataMap) != ""
}

FindValueInBoxDesc(x1, y1, x2, y2, variation := 20) {
    global ValueImgs
    local img, v, fallback := ""

    ; 34..10
    Loop 25 {
        v := 35 - A_Index   ; 34..10
        img := ValueImgs[v]
        if ImageSearch(&x, &y, x1, y1, x2, y2, "*" variation " *TransBlack " img)
            return v
    }

    ; 9..4 (store fallback digit)
    Loop 6 {
        v := 10 - A_Index   ; 9..4
        img := ValueImgs[v]
        if ImageSearch(&x, &y, x1, y1, x2, y2, "*" variation " *TransBlack " img) {
            fallback := v
            break
        }
    }

    ; If we found 4..9, only search that decade (e.g., 4 -> 49..40)
    if (fallback != "") {
        start := (fallback * 10) + 9   ; 49,59,69,79,89,99
        stop  := (fallback * 10)       ; 40,50,60,70,80,90

        Loop 10 {
            v := start - (A_Index - 1) ; 49..40 (or 59..50 etc)
            img := ValueImgs[v]
            if ImageSearch(&x, &y, x1, y1, x2, y2, "*" variation " *TransBlack " img)
                return v
        }

        return fallback
    }

    return ""
}

ReadValue(x, y) {
    X1 := x
    X2 := X1+50

    Y1 := y-4
    Y2 := Y1+12

    ;Dbg.ShowRect(X1, Y1, X2, Y2)  ; <-- live ROI box

    value := FindValueInBoxDesc(X1, Y1, X2, Y2)

    return value
}

GetItemStats(*) {
    found := []  ; array of {name, value, x, y}

    MouseGetPos(&MouseX, &MouseY)

    X1 := MouseX-8
    X2 := X1+185

    Y1 := MouseY
    Y2 := Y1+130

    for statName, info in ShardFragData {
        img := info["Img"]
        if ImageSearch(&x, &y, X1, Y1, X2, Y2, "*TransBlack " img) {
            if ImageSearch(&x, &y, x, y, x+180, y+12, "*TransBlack images\enchanting\values\plus.png") {
                
                value := ReadValue(x, y)

                ; validate 0..99
                if !(IsInteger(value) && value >= 0 && value <= 99)
                    continue

                found.Push({name: statName, value: value, x: x, y: y})

                if (found.Length >= 2)
                    break
            }
        }
    }

    return found
}

EnchantingLoop(*) {
    global bIsEnchantingMode

    Static bStatsGathered := false

    if !ImageSearch(&x, &y, 0, 0, 800, 600, "*TransBlack images\enchanting\Enchanting.png") {
        SetTimer(EnchantingLoop, 0)
        bIsEnchantingMode := false
    }

    if GetKeyState("LButton", "P") {
        if (!bStatsGathered) {
            stats := GetItemStats()

            for _, s in stats {
                if IsItemWorthUpgrading(s.name, s.value, ShardFragData) {
                    icon := "images\enchanting\Upgrade.png"
                }
                else {
                    icon := "images\enchanting\Disenchant.png"
                }

                MarkIndicators.ShowEnchantIcon(icon)
            }
        }

        bStatsGathered := true
    }
    else {
        MarkIndicators.HideAll()
        bStatsGathered := false
    }
}

~^e::{
    global bIsEnchantingMode

    bIsEnchantingMode := !bIsEnchantingMode

    if (!bIsEnchantingMode) {
        ; do something here?
    }

    Sleep 100
    SetTimer(EnchantingLoop, 500)
}
    
