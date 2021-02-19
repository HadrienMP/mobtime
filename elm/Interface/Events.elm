port module Interface.Events exposing (..)


port events : EventPort msg


type Event
    = SoundEnded
    | TextCopied


type alias InEvent =
    { name : String
    , value : String
    }


type alias EventPort msg =
    (InEvent -> msg) -> Sub msg
