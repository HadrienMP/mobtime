module Components.Form.Volume.Type exposing (Volume(..), decoder, default, encode, open)

import Json.Decode as Decode
import Json.Encode as Json


type Volume
    = Volume Int


default : Volume
default =
    Volume 50


open : Volume -> Int
open (Volume raw) =
    raw



-- Json


encode : Volume -> Json.Value
encode =
    open >> Json.int


decoder : Decode.Decoder Volume
decoder =
    Decode.int |> Decode.map Volume
