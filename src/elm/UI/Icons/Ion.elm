module UI.Icons.Ion exposing (..)

import Html.Styled exposing (i)
import Html.Styled.Attributes exposing (class)
import Ionicon
import Ionicon.Android
import Ionicon.Ios
import Ionicon.Social
import UI.Icons.Common exposing (Icon)
import Svg as Unstyled
import Svg.Styled as Svg exposing (Svg)


code : Icon msg
code =
    display Ionicon.code


batteryLow : Icon msg
batteryLow =
    display Ionicon.batteryLow


batteryFull : Icon msg
batteryFull =
    display Ionicon.batteryHalf


coffee : Icon msg
coffee =
    display Ionicon.coffee


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


info : Icon msg
info =
    display Ionicon.informationCircled


musicNote : Icon msg
musicNote =
    display Ionicon.Ios.musicalNote


error : Icon msg
error =
    display Ionicon.closeCircled


warning : Icon msg
warning =
    display Ionicon.alertCircled


success : Icon msg
success =
    display Ionicon.checkmarkCircled


sound : Icon msg
sound =
    display Ionicon.musicNote


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
    -> Svg msg
display icon =
    i [ class "icon" ]
        [ icon 32 { red = 0, green = 0, blue = 0, alpha = 0 }
            |> Svg.fromUnstyled
        ]
