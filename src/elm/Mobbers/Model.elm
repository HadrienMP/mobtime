module Mobbers.Model exposing (..)

import Json.Decode
import Json.Encode


type alias Mobber =
    { name : String
    }


type alias Mobbers =
    List Mobber


create : String -> Mobber
create name =
    Mobber name



-- JSON


jsonDecoder : Json.Decode.Decoder Mobber
jsonDecoder =
    Json.Decode.map Mobber
        (Json.Decode.field "name" Json.Decode.string)


toJson : Mobber -> Json.Encode.Value
toJson mobber =
    Json.Encode.object
        [ ( "name", Json.Encode.string mobber.name )
        ]
