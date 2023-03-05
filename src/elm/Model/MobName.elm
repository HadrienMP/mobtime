module Model.MobName exposing (MobName(..), encode, print)

import Json.Encode as Json


type MobName
    = MobName String


print : MobName -> String
print (MobName value) =
    value


encode : MobName -> Json.Value
encode (MobName value) =
    Json.string value
