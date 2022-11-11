module Model.Roles exposing (..)

import Json.Decode as Decode
import Json.Encode as Json
import Model.Role exposing (Role)


type alias Roles =
    { default : Role
    , special : List Role
    }


default : Roles
default =
    { special = [ "Driver", "Navigator", "Next Up" ] |> List.map Model.Role.fromString
    , default = Model.Role.fromString "Mobber"
    }


inverse : Roles
inverse =
    { special = [ "Navigator", "Driver", "Next" ] |> List.map Model.Role.fromString
    , default = Model.Role.fromString "Mobber"
    }



-- Json


encode : Roles -> Json.Value
encode roles =
    Json.object
        [ ( "default", Model.Role.encode roles.default )
        , ( "special", Json.list Model.Role.encode roles.special )
        ]


decoder : Decode.Decoder Roles
decoder =
    Decode.map2 Roles
        (Decode.field "default" Model.Role.decoder)
        (Decode.field "special" (Decode.list Model.Role.decoder))
