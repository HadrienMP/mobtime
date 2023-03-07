module Routing exposing (Route(..), parse, toUrl)

import Pages.Mob.Routing
import Url
import Url.Builder
import Url.Parser as UrlParser exposing ((</>), Parser, map, oneOf, s, top)


type Route
    = Home
    | Mob Pages.Mob.Routing.Route


parse : Url.Url -> Route
parse url =
    UrlParser.parse parser url
        |> Maybe.withDefault Home


parser : Parser (Route -> c) c
parser =
    oneOf
        [ map Home top
        , map Mob (s "mob" </> Pages.Mob.Routing.parser)
        ]


toUrl : Route -> String
toUrl route =
    case route of
        Home ->
            Url.Builder.absolute [ "" ] []

        Mob subRoute ->
            Url.Builder.absolute [ "mob", Pages.Mob.Routing.toUrl subRoute ] []
