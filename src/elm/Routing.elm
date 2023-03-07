module Routing exposing (MobRoute, MobSubRoute(..), Route(..), parse, toUrl)

import Model.MobName exposing (MobName(..))
import Url
import Url.Builder
import Url.Parser as UrlParser exposing ((</>), Parser, map, oneOf, s, top)


type Route
    = Home
    | Mob MobRoute
    | Share MobName
    | Profile MobName


type alias MobRoute =
    { subRoute : MobSubRoute, name : MobName }


type MobSubRoute
    = MobHome
    | MobSettings


parse : Url.Url -> Route
parse url =
    UrlParser.parse route url
        |> Maybe.withDefault Home


route : Parser (Route -> c) c
route =
    oneOf
        [ map Home top
        , map (MobName >> MobRoute MobHome >> Mob) (s "mob" </> UrlParser.string)
        , map (MobName >> Share) (s "mob" </> UrlParser.string </> s "share")
        , map (MobName >> Profile) (s "mob" </> UrlParser.string </> s "me")
        , map (MobName >> MobRoute MobSettings >> Mob) (s "mob" </> UrlParser.string </> s "settings")
        ]


toUrl : Route -> String
toUrl page =
    case page of
        Home ->
            Url.Builder.absolute [ "" ] []

        Mob { subRoute, name } ->
            case subRoute of
                MobHome ->
                    Url.Builder.absolute [ "mob", Model.MobName.print name ] []

                MobSettings ->
                    Url.Builder.absolute [ "mob", Model.MobName.print name, "settings" ] []

        Share mobname ->
            Url.Builder.absolute [ "mob", Model.MobName.print mobname, "share" ] []

        Profile mobname ->
            Url.Builder.absolute [ "mob", Model.MobName.print mobname, "me" ] []
