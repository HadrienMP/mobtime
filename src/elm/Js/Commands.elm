port module Js.Commands exposing (Command(..), OutCommand, send)

import Json.Encode as Json
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
    , value : Json.Value
    }


send : Command -> Cmd msg
send command =
    commands <|
        case command of
            SoundAlarm ->
                OutCommand "SoundAlarm" Json.null

            SetAlarm sound ->
                OutCommand "SetAlarm" <| Json.string sound

            StopAlarm ->
                OutCommand "StopAlarm" Json.null

            GetSocketId ->
                OutCommand "GetSocketId" Json.null

            ChangeTitle title ->
                OutCommand "ChangeTitle" <| Json.string title
