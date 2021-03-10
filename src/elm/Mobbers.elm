module Mobbers exposing (..)

import Json.Decode
import Json.Encode


type alias Mobber =
    { name : String
    , index : Int
    }


type alias Mobbers =
    List Mobber


create : String -> Mobbers -> Mobber
create name mobbers =
    mobbers
        |> List.map .index
        |> List.maximum
        |> Maybe.withDefault -1
        |> (\lastIndex -> Mobber name (lastIndex + 1))


rotate : Mobbers -> Mobbers
rotate mobbers =
    mobbers
        |> List.map (next mobbers)


next : Mobbers -> Mobber -> Mobber
next mobbers mobber =
    { mobber | index = rotateIndex mobber.index (List.length mobbers) }


rotateIndex : Int -> Int -> Int
rotateIndex current length =
    current
        + 1
        |> modBy length



-- JSON


jsonDecoder : Json.Decode.Decoder Mobber
jsonDecoder =
    Json.Decode.map2 Mobber
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "index" Json.Decode.int)


toJson : Mobber -> Json.Encode.Value
toJson mobber =
    Json.Encode.object
        [ ( "name", Json.Encode.string mobber.name )
        , ( "index", Json.Encode.int mobber.index )
        ]
