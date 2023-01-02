module Model.MobName exposing (..)

import Json.Decode as Decode
import Json.Encode as Json


type MobName
    = MobName String


print : MobName -> String
print (MobName value) =
    case String.toList value of
        [] ->
            ""

        first :: tail ->
            Char.toUpper first :: tail |> String.fromList


encode : MobName -> Json.Value
encode (MobName value) =
    Json.string value


decoder : Decode.Decoder MobName
decoder =
    Decode.string |> Decode.map MobName
