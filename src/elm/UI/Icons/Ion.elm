module UI.Icons.Ion exposing (back, check, clock, close, code, copy, delete, error, github, home, musicNote, mute, paperAirplane, people, play, plus, rotate, settings, share, shuffle, stop, success, user, volumeHigh, volumeLow)

import Ionicon
import Ionicon.Android
import Ionicon.Ios
import Ionicon.Social
import Svg as Unstyled
import Svg.Styled as Svg
import UI.Color as Color
import UI.Icons.Common exposing (Icon)
import UI.Rem as Rem


code : Icon msg
code =
    display Ionicon.code


settings : Icon msg
settings =
    display Ionicon.gearB


user : Icon msg
user =
    display Ionicon.person


copy : Icon msg
copy =
    display Ionicon.clipboard


back : Icon msg
back =
    display Ionicon.chevronLeft


check : Icon msg
check =
    display Ionicon.checkmark


paperAirplane : Icon msg
paperAirplane =
    display Ionicon.paperAirplane


volumeLow : Icon msg
volumeLow =
    display Ionicon.volumeLow


volumeHigh : Icon msg
volumeHigh =
    display Ionicon.volumeHigh


github : Icon msg
github =
    display Ionicon.Social.github


musicNote : Icon msg
musicNote =
    display Ionicon.Ios.musicalNote


error : Icon msg
error =
    display Ionicon.closeCircled


success : Icon msg
success =
    display Ionicon.checkmarkCircled


share : Icon msg
share =
    display Ionicon.Android.shareAlt


clock : Icon msg
clock =
    display Ionicon.Android.alarmClock


home : Icon msg
home =
    display Ionicon.home


delete : Icon msg
delete =
    display Ionicon.close


close : Icon msg
close =
    display Ionicon.close


rotate : Icon msg
rotate =
    display Ionicon.refresh


shuffle : Icon msg
shuffle =
    display Ionicon.shuffle


plus : Icon msg
plus =
    display Ionicon.plus


play : Icon msg
play =
    display Ionicon.play


stop : Icon msg
stop =
    display Ionicon.stop


mute : Icon msg
mute =
    display Ionicon.Android.volumeOff


people : Icon msg
people =
    display Ionicon.personStalker


display :
    (Int
     ->
        { red : Float
        , green : Float
        , blue : Float
        , alpha : Float
        }
     -> Unstyled.Svg msg
    )
    -> Icon msg
display icon { size, color } =
    icon
        (Rem.toPixelsFake size)
        (Color.toIonIconRgba color)
        |> Svg.fromUnstyled
