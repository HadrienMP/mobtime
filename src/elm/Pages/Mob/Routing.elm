module Pages.Mob.Routing exposing (Route, SubRoute(..), parser, toUrl)

import Model.MobName exposing (MobName(..))
import Url.Builder
import Url.Parser exposing ((</>))


type alias Route =
    { subRoute : SubRoute, mob : MobName }


type SubRoute
    = Home
    | Settings
    | Invite
    | Profile
    | Mobbers
    | Bug


toUrl : Route -> String
toUrl route =
    case route.subRoute of
        Home ->
            Url.Builder.relative [ Model.MobName.print route.mob ] []

        Settings ->
            Url.Builder.relative [ Model.MobName.print route.mob, "settings" ] []

        Invite ->
            Url.Builder.relative [ Model.MobName.print route.mob, "invite" ] []

        Profile ->
            Url.Builder.relative [ Model.MobName.print route.mob, "profile" ] []

        Mobbers ->
            Url.Builder.relative [ Model.MobName.print route.mob, "mobbers" ] []

        Bug ->
            Url.Builder.relative [ Model.MobName.print route.mob, "bug" ] []


parser : Url.Parser.Parser (Route -> c) c
parser =
    Url.Parser.oneOf
        [ Url.Parser.map (MobName >> Route Home) Url.Parser.string
        , Url.Parser.map (MobName >> Route Settings) (Url.Parser.string </> Url.Parser.s "settings")
        , Url.Parser.map (MobName >> Route Invite) (Url.Parser.string </> Url.Parser.s "invite")
        , Url.Parser.map (MobName >> Route Profile) (Url.Parser.string </> Url.Parser.s "profile")
        , Url.Parser.map (MobName >> Route Mobbers) (Url.Parser.string </> Url.Parser.s "mobbers")
        , Url.Parser.map (MobName >> Route Bug) (Url.Parser.string </> Url.Parser.s "bug")
        ]
