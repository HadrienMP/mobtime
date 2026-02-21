port module Lib.Alarm exposing
    ( alarmChangeVolume
    , alarmTestVolume
    , checkSound
    , load
    , onFinished
    , onPlaying
    , play
    , stop
    )

import Playlist.Types exposing (Sound)


port alarmLoad : String -> Cmd msg


port alarmPlay : () -> Cmd msg


port alarmStop : () -> Cmd msg


port alarmChangeVolume : Int -> Cmd msg


port alarmTestVolume : () -> Cmd msg


port alarmPlaying : (String -> msg) -> Sub msg


port alarmFinished : (String -> msg) -> Sub msg


port checkSound : () -> Cmd msg


load : Sound -> Cmd msg
load =
    alarmLoad


play : Cmd msg
play =
    alarmPlay ()


stop : Cmd msg
stop =
    alarmStop ()


onPlaying : msg -> Sub msg
onPlaying msg =
    alarmPlaying <| always msg


onFinished : msg -> Sub msg
onFinished msg =
    alarmFinished <| always msg
