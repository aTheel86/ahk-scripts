





ES_Half_ES_Pixel := [297, 1290]
ES_Half_ES_Clr := "0x2a272a"
Snd_HeartbeatStress := "sounds\heartbeat_stress_01.wav"

Timed_ES_IsHalf_HeartBeatWarning()
{
    if WinFocused() {
        if IsColorInRange(ES_Half_ES_Pixel[1], ES_Half_ES_Pixel[2], ES_Half_ES_Clr, 15)
        {
            SoundPlay Snd_HeartbeatStress
            SetTimer(Timed_ES_IsHalf_HeartBeatWarning, -1764) ; duration of sound
            return
        }
    }

    SetTimer(Timed_ES_IsHalf_HeartBeatWarning, -200)
}





ES_PotIsLow_Pixel := [341, 1363]
ES_PotIsLow_Clr := "0x1f1811"
Snd_FlaskLow := "sounds\flask_slosh.mp3"

Timed_Life_Flask_Low_Warning()
{
    if WinFocused() {
        if IsColorInRange(ES_PotIsLow_Pixel[1], ES_PotIsLow_Pixel[2], ES_PotIsLow_Clr, 5)
        {
            SoundPlay Snd_FlaskLow
            SetTimer(Timed_Life_Flask_Low_Warning, -10000) ; remind again in 10 seconds
            return
        }
    }

    SetTimer(Timed_Life_Flask_Low_Warning, -200)
}




ES_DamageTaken_Pixel := [210, 1174]
ES_DamageTaken_Clr := "0x867d73"

ES_PotIsFresh_Pixel := [341, 1349]
ES_PotIsFresh_Clr := "0xc91d16"

Timed_Pot_OnDamageTaken()
{
    if WinFocused() {
        if IsColorInRange(ES_DamageTaken_Pixel[1], ES_DamageTaken_Pixel[2], ES_DamageTaken_Clr, 15) && IsColorInRange(ES_PotIsFresh_Pixel[1], ES_PotIsFresh_Pixel[2], ES_PotIsFresh_Clr, 15)
        {
            Send "{1}"
            SetTimer(Timed_Pot_OnDamageTaken, -2000) ; This should be length of flask duration
            return
        }
    }

    SetTimer(Timed_Pot_OnDamageTaken, -200)
}




ES_AutoLifePot_Pixel := [268, 1382]
ES_AutoLifePot_Clr := "0x1d1e20"

Timed_Emergency_LifePot()
{
    if WinFocused() {
        if IsColorInRange(ES_AutoLifePot_Pixel[1], ES_AutoLifePot_Pixel[2], ES_AutoLifePot_Clr, 15)
        {
            Send "{1}"
            SetTimer(Timed_Emergency_LifePot, -1000)
            return
        }
    }

    SetTimer(Timed_Emergency_LifePot, -200)
}