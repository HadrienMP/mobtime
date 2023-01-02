port module Js.Commands exposing (..)

import Json.Encode
import Sounds


port commands : OutCommand -> Cmd msg


type Command
    = SoundAlarm
    | SetAlarm Sounds.Sound
    | StopAlarm
    | ChangeTitle String
    | GetSocketId


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

            GetSocketId ->
                OutCommand "GetSocketId" Json.Encode.null

            ChangeTitle title ->
                OutCommand "ChangeTitle" <| Json.Encode.string title
