module Model.Mobber exposing (Mobber, MobberId, idAsString, idFromString, jsonDecoder, toJson)

import Json.Decode as Decode
import Json.Encode as Json


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
    , isOn : Bool
    }



-- JSON


jsonDecoder : Decode.Decoder Mobber
jsonDecoder =
    Decode.map3 Mobber
        (Decode.field "id" (Decode.string |> Decode.map MobberId))
        (Decode.field "name" Decode.string)
        (Decode.maybe (Decode.field "isOn" Decode.bool) |> Decode.map (Maybe.withDefault True))


toJson : Mobber -> Json.Value
toJson mobber =
    Json.object
        [ ( "id", mobber.id |> idAsString |> Json.string )
        , ( "name", Json.string mobber.name )
        , ( "isOn", Json.bool mobber.isOn )
        ]
