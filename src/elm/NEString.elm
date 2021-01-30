module NEString exposing (NEString, from, toString, encoder, decoder)

import Json.Decode
import Json.Encode
type NEString = NEString String
from string =
    if string |> String.trim |> String.isEmpty
    then Nothing
    else Just <| NEString <| String.trim string
toString nes = case nes of NEString string -> string

encoder : NEString -> Json.Encode.Value
encoder = Json.Encode.string << toString
decoder =
    Json.Decode.map from Json.Decode.string
    |> Json.Decode.andThen
        (\maybeName ->
            case maybeName of
                Just name -> Json.Decode.succeed name
                Nothing -> Json.Decode.fail "Expected a non empty string"
        )