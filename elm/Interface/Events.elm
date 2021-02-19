port module Interface.Events exposing (..)


port events : EventPort msg

type alias EventMsg msg = List (Name, Value -> msg)

type alias Name =
    String


type alias Value =
    String


type alias Event =
    { name : Name
    , value : Value
    }


type alias EventPort msg =
    (Event -> msg) -> Sub msg
