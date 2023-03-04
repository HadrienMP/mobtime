module Lib.Keyboard exposing (Keystroke, decode)

import Json.Decode as Decode


type alias Keystroke =
    { key : String
    , ctrl : Bool
    , alt : Bool
    , shift : Bool
    }


decode : Decode.Decoder Keystroke
decode =
    Decode.map4 Keystroke
        (Decode.field "key" Decode.string)
        (Decode.field "ctrlKey" Decode.bool)
        (Decode.field "altKey" Decode.bool)
        (Decode.field "shiftKey" Decode.bool)
