module Pages.Profile.Page exposing (Msg(..), update, view)

import Components.Form.Volume.Field as Volume
import Css
import Effect exposing (Effect)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Model.MobName exposing (MobName)
import Pages.Profile.View
import Routing
import Shared exposing (Shared)
import UserPreferences
import View exposing (View)


type Msg
    = ToggleSeconds
    | VolumeMsg Volume.Msg
    | Join


update : Msg -> Shared -> MobName -> Effect Shared.Msg Msg
update msg shared mob =
    case msg of
        ToggleSeconds ->
            Effect.fromShared <| Shared.PreferencesMsg <| UserPreferences.ToggleSeconds

        VolumeMsg subMsg ->
            Effect.fromShared <| Shared.PreferencesMsg <| UserPreferences.VolumeMsg subMsg

        Join ->
            Effect.batch
                [ Shared.pushUrl shared <| Routing.Mob mob
                , Effect.fromShared <| Shared.SoundOn
                ]


view : Shared -> MobName -> View Msg
view shared mob =
    { title = "Profile"
    , modal = Nothing
    , body =
        Html.div [ Attr.css [ Css.paddingTop <| Css.rem 1 ] ]
            [ Pages.Profile.View.view
                { mob = mob
                , secondsToggle =
                    { value = shared.preferences.displaySeconds
                    , onToggle = ToggleSeconds
                    }
                , volume =
                    { onChange = VolumeMsg << Volume.Change
                    , onTest = VolumeMsg Volume.Test
                    , volume = shared.preferences.volume
                    }
                , onJoin = Join
                }
            ]
    }
