module Mob exposing (..)

import Json.Decode as D
import Json.Encode as E
import NEString exposing (NEString)

type alias MobberId = String
type alias MobName = NEString
type alias Mobber = { name : NEString, id : MobberId }
type alias Mobbers = List Mobber

mobbersDecoder : D.Decoder Mobbers
mobbersDecoder = D.list mobberDecoder

mobberDecoder : D.Decoder Mobber
mobberDecoder = D.map2 Mobber (D.field "name" NEString.decoder) (D.field "id" D.string)

mobberEncoder : Mobber -> E.Value
mobberEncoder mobber =
    E.object
    [ ("name", NEString.toString mobber.name |> E.string)
    , ("id", E.string mobber.id)
    ]