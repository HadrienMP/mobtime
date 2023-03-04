module Routing exposing (Page(..), toPage, toUrl)

import Model.MobName exposing (MobName(..))
import Url
import Url.Builder
import Url.Parser as UrlParser exposing ((</>), Parser, map, oneOf, s, top)


type Page
    = Login
    | Mob MobName
    | Share MobName
    | Profile MobName


toPage : Url.Url -> Page
toPage url =
    UrlParser.parse route url
        |> Maybe.withDefault Login


route : Parser (Page -> c) c
route =
    oneOf
        [ map Login top
        , map (MobName >> Mob) (s "mob" </> UrlParser.string)
        , map (MobName >> Share) (s "mob" </> UrlParser.string </> s "share")
        , map (MobName >> Profile) (s "mob" </> UrlParser.string </> s "me")
        ]


toUrl : Page -> String
toUrl page =
    case page of
        Login ->
            Url.Builder.absolute [ "" ] []

        Mob mobname ->
            Url.Builder.absolute [ "mob", Model.MobName.print mobname ] []

        Share mobname ->
            Url.Builder.absolute [ "mob", Model.MobName.print mobname, "share" ] []

        Profile mobname ->
            Url.Builder.absolute [ "mob", Model.MobName.print mobname, "me" ] []
