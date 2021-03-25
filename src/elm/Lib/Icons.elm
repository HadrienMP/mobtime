module Lib.Icons exposing (..)

import Html exposing (i)
import Html.Attributes exposing (class)
import Ionicon
import Ionicon.Android
import Svg exposing (Svg)

info : Svg msg
info =
    display Ionicon.informationCircled

error : Svg msg
error =
    display Ionicon.closeCircled

warning : Svg msg
warning =
    display Ionicon.alertCircled

success : Svg msg
success =
    display Ionicon.checkmarkCircled

sound : Svg msg
sound =
    display Ionicon.musicNote

share : Svg msg
share =
    display Ionicon.Android.shareAlt

clock : Svg msg
clock =
    display Ionicon.Android.alarmClock

home : Svg msg
home =
    display Ionicon.home

delete : Svg msg
delete =
    display Ionicon.close

rotate : Svg msg
rotate =
    display Ionicon.refresh

shuffle : Svg msg
shuffle =
    display Ionicon.shuffle

plus : Svg msg
plus =
    display Ionicon.plus

play : Svg msg
play =
    display Ionicon.play

stop : Svg msg
stop =
    display Ionicon.stop

mute : Svg msg
mute =
    display Ionicon.Android.volumeOff

people : Svg msg
people =
    display Ionicon.personStalker

display : (Int -> RGBA -> Svg msg) -> Svg msg
display icon =
    i [ class "icon" ] [ icon 32 (RGBA 0 0 0 0) ]

type alias RGBA =
    { red : Float
    , green : Float
    , blue : Float
    , alpha : Float
    }