port module Out.Commands exposing (..)

import Json.Encode
import Lib.Duration as Duration exposing (Duration)
import Time


port commands : OutCommand -> Cmd msg


type Command
    = CopyInPasteBin String
    | ChangeSound String
    | SoundPlay
    | SoundStop
    | ChangeVolume Int
    | StoreVolume Int
    | JoinMob String
    | StartTurn Time.Posix Duration


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

            SoundPlay ->
                OutCommand "SoundPlay" Json.Encode.null

            SoundStop ->
                OutCommand "SoundStop" Json.Encode.null

            ChangeVolume volume ->
                OutCommand "ChangeVolume" <| Json.Encode.string <| String.fromInt volume

            StoreVolume volume ->
                OutCommand "StoreVolume" <| Json.Encode.string <| String.fromInt volume

            ChangeSound sound ->
                OutCommand "ChangeSound" <| Json.Encode.string sound

            JoinMob mobName ->
                OutCommand "JoinMob" <| Json.Encode.string mobName

            StartTurn now length ->
                OutCommand "StartTurn" <|
                    Json.Encode.object
                        [ ( "now", Json.Encode.int <| Time.posixToMillis now )
                        , ( "length", Json.Encode.int <| Duration.toSeconds length )
                        ]
