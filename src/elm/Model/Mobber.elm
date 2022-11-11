module Model.Mobber exposing (Mobber, MobberId, idFromString, jsonDecoder, toJson)

import Json.Decode
import Json.Encode


type MobberId
    = MobberId String


idFromString : String -> MobberId
idFromString =
    MobberId


idAsString : MobberId -> String
idAsString id =
    case id of
        MobberId value ->
            value


type alias Mobber =
    { id : MobberId
    , name : String
    }



-- JSON


jsonDecoder : Json.Decode.Decoder Mobber
jsonDecoder =
    Json.Decode.map2 Mobber
        (Json.Decode.field "id" (Json.Decode.string |> Json.Decode.map MobberId))
        (Json.Decode.field "name" Json.Decode.string)


toJson : Mobber -> Json.Encode.Value
toJson mobber =
    Json.Encode.object
        [ ( "id", mobber.id |> idAsString |> Json.Encode.string )
        , ( "name", Json.Encode.string mobber.name )
        ]
