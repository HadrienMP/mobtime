module Pages.Mob.Mobbers.Mobber exposing (..)

import Dict exposing (Dict)
import Json.Decode
import Json.Encode
import Uuid exposing (Uuid)


type alias MobberId =
    Uuid


type alias Mobber =
    { id : Uuid
    , name : String
    }



-- JSON


jsonDecoder : Json.Decode.Decoder Mobber
jsonDecoder =
    Json.Decode.map2 Mobber
        (Json.Decode.field "id" Uuid.decoder)
        (Json.Decode.field "name" Json.Decode.string)


toJson : Mobber -> Json.Encode.Value
toJson mobber =
    Json.Encode.object
        [ ( "id", Uuid.encode mobber.id )
        , ( "name", Json.Encode.string mobber.name )
        ]