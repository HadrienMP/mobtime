module Model.MobName exposing (..)

import Json.Decode as Decode
import Json.Encode as Json


type MobName
    = MobName String


print : MobName -> String
print (MobName it) =
    it


encode : MobName -> Json.Value
encode (MobName it) =
    Json.string it


decoder : Decode.Decoder MobName
decoder =
    Decode.string |> Decode.map MobName
