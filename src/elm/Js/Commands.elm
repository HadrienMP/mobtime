port module Js.Commands exposing (..)

import Json.Encode
import Sound.Library


port commands : OutCommand -> Cmd msg


type Command
    = SoundAlarm
    | SetAlarm Sound.Library.Sound
    | StopAlarm
    | CopyInPasteBin String


type alias OutCommand =
    { name : String
    , value : Json.Encode.Value
    }


send : Command -> Cmd msg
send command =
    commands <|
        case command of
            CopyInPasteBin toCopy ->
                OutCommand "CopyInPasteBin" <| Json.Encode.string toCopy

            SoundAlarm ->
                OutCommand "SoundAlarm" Json.Encode.null

            SetAlarm sound ->
                OutCommand "SetAlarm" <| Json.Encode.string sound

            StopAlarm ->
                OutCommand "StopAlarm" Json.Encode.null
