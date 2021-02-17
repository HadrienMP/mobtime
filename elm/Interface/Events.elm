port module Interface.Events exposing (..)


port events : EventPort msg


type alias Event =
    { name : String
    , value : String
    }


type alias EventPort msg =
    (Event -> msg) -> Sub msg
