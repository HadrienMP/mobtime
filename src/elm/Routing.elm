module Routing exposing (..)

import Model.MobName exposing (MobName(..))
import Url
import Url.Parser as UrlParser exposing ((</>), Parser, map, oneOf, s, top)


type Page
    = Login
    | Mob MobName


toPage : Url.Url -> Page
toPage url =
    UrlParser.parse route url
        |> Maybe.withDefault Login


route : Parser (Page -> c) c
route =
    oneOf
        [ map Login top
        , map (MobName >> Mob) (s "mob" </> UrlParser.string)
        ]
