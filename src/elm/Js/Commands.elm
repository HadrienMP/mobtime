port module Js.Commands exposing (..)

import Json.Encode
import Sounds


port commands : OutCommand -> Cmd msg


type Command
    = SoundAlarm
    | SetAlarm  Sounds.Sound
    | StopAlarm
    | ChangeTitle String
    | CopyInPasteBin String
    | ChangeVolume Int
    | Join String
    | GetSocketId
    | TestTheSound


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

            ChangeVolume volume ->
                OutCommand "ChangeVolume" <| Json.Encode.string <| String.fromInt volume

            Join mobName ->
                OutCommand "Join" <| Json.Encode.string mobName

            GetSocketId ->
                OutCommand "GetSocketId" Json.Encode.null

            TestTheSound ->
                OutCommand "TestTheSound" Json.Encode.null

            ChangeTitle title ->
                OutCommand "ChangeTitle" <| Json.Encode.string title


