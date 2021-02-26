port module Out.Commands exposing (..)


port commands : OutCommand -> Cmd msg


type Command
    = CopyInPasteBin String
    | ChangeSound String
    | SoundPlay
    | SoundStop
    | ChangeVolume Int
    | StoreVolume Int


type alias OutCommand =
    { name : String
    , value : String
    }


send : Command -> Cmd msg
send command =
    commands <|
        case command of
            CopyInPasteBin toCopy ->
                OutCommand "CopyInPasteBin" toCopy

            SoundPlay ->
                OutCommand "SoundPlay" ""

            SoundStop ->
                OutCommand "SoundStop" ""

            ChangeVolume volume ->
                OutCommand "ChangeVolume" <| String.fromInt volume

            StoreVolume volume ->
                OutCommand "StoreVolume" <| String.fromInt volume

            ChangeSound sound ->
                OutCommand "ChangeSound" sound

