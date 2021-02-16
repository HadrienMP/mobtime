module UserPreferences exposing (..)

import Json.Decode
import Json.Encode


type alias Model =
    { volume : Int
    }


decode : Json.Encode.Value -> Model
decode value =
    Json.Decode.decodeValue (Json.Decode.field "volume" Json.Decode.int) value
        |> Result.withDefault 50
        |> Model


encode : Model -> Json.Encode.Value
encode model =
    Json.Encode.object
        [ ( "volume", Json.Encode.int model.volume ) ]
