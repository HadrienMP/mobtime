module Pages.Mob.Routing exposing (Route, SubRoute(..), parser, toUrl)

import Model.MobName exposing (MobName(..))
import Url.Builder
import Url.Parser exposing ((</>))


type alias Route =
    { subRoute : SubRoute, name : MobName }


type SubRoute
    = MobHome
    | MobSettings
    | Invite


toUrl : Route -> String
toUrl route =
    case route.subRoute of
        MobHome ->
            Url.Builder.relative [ Model.MobName.print route.name ] []

        MobSettings ->
            Url.Builder.relative [ Model.MobName.print route.name, "settings" ] []

        Invite ->
            Url.Builder.relative [ Model.MobName.print route.name, "invite" ] []


parser : Url.Parser.Parser (Route -> c) c
parser =
    Url.Parser.oneOf
        [ Url.Parser.map (MobName >> Route MobHome) Url.Parser.string
        , Url.Parser.map (MobName >> Route MobSettings) (Url.Parser.string </> Url.Parser.s "settings")
        , Url.Parser.map (MobName >> Route Invite) (Url.Parser.string </> Url.Parser.s "invite")
        ]
