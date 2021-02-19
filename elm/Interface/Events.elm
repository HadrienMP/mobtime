port module Interface.Events exposing (..)


port eventsPort : EventPort msg


type alias EventMessage msg =
    { name : Name
    , messageFunction : Value -> msg
    }


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
