port module Pages.Mob.Share.Page exposing (Msg(..), subscriptions, update, view)

import Effect exposing (Effect)
import Lib.Toaster
import Model.MobName exposing (MobName)
import Pages.Mob.Routing
import Pages.Mob.Share.PageView
import Routing
import Shared exposing (Shared)
import Url
import View exposing (View)


port copyShareLink : String -> Cmd msg


port shareLinkCopied : (String -> msg) -> Sub msg


type Msg
    = Copy String
    | Copied
    | Back


update : Shared -> Msg -> MobName -> Effect Shared.Msg Msg
update shared msg mob =
    case msg of
        Copy text ->
            Effect.fromCmd <| copyShareLink <| text

        Copied ->
            Shared.toast <| Lib.Toaster.success "The link has been copied to your clipboard"

        Back ->
            Shared.pushUrl shared <|
                Routing.Mob <|
                    { subRoute = Pages.Mob.Routing.MobHome, name = mob }


subscriptions : Sub Msg
subscriptions =
    shareLinkCopied <| always Copied


view : Shared -> MobName -> View Msg
view shared mob =
    { title = "Share"
    , modal = Nothing
    , body =
        Pages.Mob.Share.PageView.view
            { url = shared.url |> Url.toString
            , copy = Copy
            , mob = mob
            , onBack = Back
            }
    }
