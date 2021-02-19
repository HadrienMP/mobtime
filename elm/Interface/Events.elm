port module Interface.Events exposing (..)


port events : EventPort msg

type alias EventMsg msg = (Name, Value -> msg)

map : (msg -> msg2) -> List (EventMsg msg) -> List (EventMsg msg2)
map msgWrapper eventsMsg =
    List.map (Tuple.mapSecond <| (<<) msgWrapper) eventsMsg

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
