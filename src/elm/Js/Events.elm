port module Js.Events exposing (Event, EventMessage, Name, Value, events)


port events : (Event -> msg) -> Sub msg


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
