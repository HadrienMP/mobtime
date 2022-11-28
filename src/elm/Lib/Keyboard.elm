module Lib.Keyboard exposing (..)

import Json.Decode


type alias Keystroke =
    { key : String
    , ctrl : Bool
    , alt : Bool
    , shift : Bool
    }


decode : Json.Decode.Decoder Keystroke
decode =
    Json.Decode.map4 Keystroke
        (Json.Decode.field "key" Json.Decode.string)
        (Json.Decode.field "ctrlKey" Json.Decode.bool)
        (Json.Decode.field "altKey" Json.Decode.bool)
        (Json.Decode.field "shiftKey" Json.Decode.bool)
