module Model.Role exposing (Role, decoder, encode, fromString, print)

import Json.Decode as Decode
import Json.Encode as Json


type Role
    = Role String



-- Private


open : Role -> String
open role =
    case role of
        Role value ->
            value



-- Public


fromString : String -> Role
fromString =
    Role


print : Role -> String
print =
    open



-- Json


encode : Role -> Json.Value
encode role =
    role |> open |> Json.string


decoder : Decode.Decoder Role
decoder =
    Decode.string |> Decode.map fromString
