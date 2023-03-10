module Pages.Mob.Routing exposing (Route, SubRoute(..), parser, toUrl)

import Model.MobName exposing (MobName(..))
import Url.Builder
import Url.Parser exposing ((</>))


type alias Route =
    { subRoute : SubRoute, name : MobName }


type SubRoute
    = Home
    | Settings
    | Invite
    | Profile
    | Mobbers


toUrl : Route -> String
toUrl route =
    case route.subRoute of
        Home ->
            Url.Builder.relative [ Model.MobName.print route.name ] []

        Settings ->
            Url.Builder.relative [ Model.MobName.print route.name, "settings" ] []

        Invite ->
            Url.Builder.relative [ Model.MobName.print route.name, "invite" ] []

        Profile ->
            Url.Builder.relative [ Model.MobName.print route.name, "profile" ] []

        Mobbers ->
            Url.Builder.relative [ Model.MobName.print route.name, "mobbers" ] []


parser : Url.Parser.Parser (Route -> c) c
parser =
    Url.Parser.oneOf
        [ Url.Parser.map (MobName >> Route Home) Url.Parser.string
        , Url.Parser.map (MobName >> Route Settings) (Url.Parser.string </> Url.Parser.s "settings")
        , Url.Parser.map (MobName >> Route Invite) (Url.Parser.string </> Url.Parser.s "invite")
        , Url.Parser.map (MobName >> Route Profile) (Url.Parser.string </> Url.Parser.s "profile")
        , Url.Parser.map (MobName >> Route Mobbers) (Url.Parser.string </> Url.Parser.s "mobbers")
        ]
