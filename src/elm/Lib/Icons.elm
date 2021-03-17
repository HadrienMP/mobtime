module Lib.Icons exposing (..)

import Html exposing (i)
import Html.Attributes exposing (class)
import Ionicon
import Ionicon.Android
import Svg exposing (Svg)

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
    display Ionicon.Android.people

display : (Int -> RGBA -> Svg msg) -> Svg msg
display icon =
    i [ class "icon" ] [ icon 32 (RGBA 0 0 0 0) ]

type alias RGBA =
    { red : Float
    , green : Float
    , blue : Float
    , alpha : Float
    }