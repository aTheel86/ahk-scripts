CastSpellByName(name) {
    global SpellInfoInstances

    for s in SpellInfoInstances
        if (s.SpellName == name)
            return (s.CastSpell(), true)
    return false
}

Global SpellSlot1 := IniRead(ControlFile, "SpellSlots", "Slot1")
Global SpellSlot2 := IniRead(ControlFile, "SpellSlots", "Slot2")

CastSpellSlot1(*) {
    CastSpellByName(SpellSlot1)
    IniWrite(SpellSlot1, ControlFile, "SpellSlots", "Slot1")
}

CastSpellSlot2(*) {
    CastSpellByName(SpellSlot2)
    IniWrite(SpellSlot2, ControlFile, "SpellSlots", "Slot2")
}

ChangeSpellSlot1(*) {
    Global SpellSlot1

    OptionsMenu(
        ["1. Energy B.", "2. Triple B", "3. Ice S", "4. Energy S.", "5. Lightning S.", "6. FuryOfThor", "7. Hellfire", "8. Mass FS", "9. Bloody SW"],
        [
            [&SpellSlot1, "EnergyBolt"],
            [&SpellSlot1, "TripleBolt"],
            [&SpellSlot1, "IceStrike"],
            [&SpellSlot1, "EnergyStrike"],
            [&SpellSlot1, "LightningStrike"],
            [&SpellSlot1, "FuryOfThor"],
            [&SpellSlot1, "Hellfire"],
            [&SpellSlot1, "MassFireStrike"],
            [&SpellSlot1, "BloodyShockwave"]
        ]
    )
}

ChangeSpellSlot2(*) {
    Global SpellSlot2

    OptionsMenu(
        ["1. Energy B.", "2. Triple B", "3. Ice S", "4. Energy S.", "5. Lightning S.", "6. FuryOfThor", "7. Hellfire", "8. Mass FS", "9. Bloody SW"],
        [
            [&SpellSlot1, "EnergyBolt"],
            [&SpellSlot1, "TripleBolt"],
            [&SpellSlot1, "IceStrike"],
            [&SpellSlot1, "EnergyStrike"],
            [&SpellSlot1, "LightningStrike"],
            [&SpellSlot1, "FuryOfThor"],
            [&SpellSlot1, "Hellfire"],
            [&SpellSlot1, "MassFireStrike"],
            [&SpellSlot1, "BloodyShockwave"]
        ]
    )
}