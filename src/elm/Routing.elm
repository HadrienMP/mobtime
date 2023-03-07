module Routing exposing (Route(..), parse, toUrl)

import Model.MobName exposing (MobName(..))
import Pages.Mob.Routing
import Url
import Url.Builder
import Url.Parser as UrlParser exposing ((</>), Parser, map, oneOf, s, top)


type Route
    = Home
    | Mob Pages.Mob.Routing.Route
    | Share MobName
    | Profile MobName


parse : Url.Url -> Route
parse url =
    UrlParser.parse parser url
        |> Maybe.withDefault Home


parser : Parser (Route -> c) c
parser =
    oneOf
        [ map Home top
        , map Mob (s "mob" </> Pages.Mob.Routing.parser)
        , map (MobName >> Share) (s "mob" </> UrlParser.string </> s "share")
        , map (MobName >> Profile) (s "mob" </> UrlParser.string </> s "me")
        ]


toUrl : Route -> String
toUrl route =
    case route of
        Home ->
            Url.Builder.absolute [ "" ] []

        Mob subRoute ->
            Url.Builder.absolute [ "mob", Pages.Mob.Routing.toUrl subRoute ] []

        Share mobname ->
            Url.Builder.absolute [ "mob", Model.MobName.print mobname, "share" ] []

        Profile mobname ->
            Url.Builder.absolute [ "mob", Model.MobName.print mobname, "me" ] []
