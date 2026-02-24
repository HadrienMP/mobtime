module Model.Roles exposing (Roles, decoder, default, encode, parse, toString)

import Json.Decode as Decode
import Json.Encode as Json
import Model.Role as Role exposing (Role)


type alias Roles =
    List Role


default : Roles
default =
    [ Role.driver, Role.navigator ]


parse : String -> Roles
parse raw =
    raw
        |> String.split ","
        |> List.map (String.trim >> Role.fromString)


toString : Roles -> String
toString roles =
    roles |> List.map .name |> String.join ", "



-- Json


encode : Roles -> Json.Value
encode roles =
    Json.list Role.encode roles


decoder : Decode.Decoder Roles
decoder =
    Decode.list Role.decoder
