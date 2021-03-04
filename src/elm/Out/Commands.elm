port module Out.Commands exposing (..)

import Json.Encode
import Sound.Library


port commands : OutCommand -> Cmd msg


type Command
    = SoundAlarm
    | SetAlarm Sound.Library.Sound
    | StopAlarm


type alias OutCommand =
    { name : String
    , value : Json.Encode.Value
    }


send : Command -> Cmd msg
send command =
    commands <|
        case command of
            SoundAlarm ->
                OutCommand "SoundAlarm" Json.Encode.null

            SetAlarm sound ->
                OutCommand "SetAlarm" <| Json.Encode.string sound

            StopAlarm ->
                OutCommand "StopAlarm" Json.Encode.null


