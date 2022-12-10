module Pages.Profile.Page exposing (..)

import Components.Volume.Field as Volume
import Css
import Effect exposing (Effect)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Pages.Profile.View
import Routing
import Shared exposing (Shared)
import UserPreferences
import View exposing (View)


type Msg
    = ToggleSeconds
    | VolumeMsg Volume.Msg
    | Join


update : Msg -> Shared -> Effect Shared.Msg Msg
update msg shared =
    case msg of
        ToggleSeconds ->
            Effect.fromShared <| Shared.PreferencesMsg <| UserPreferences.ToggleSeconds

        VolumeMsg subMsg ->
            Effect.fromShared <| Shared.PreferencesMsg <| UserPreferences.VolumeMsg subMsg

        Join ->
            case shared.mob of
                Just mob ->
                    Effect.batch
                        [ Shared.pushUrl shared <| Routing.Mob mob
                        , Effect.fromShared <| Shared.SoundOn
                        ]

                Nothing ->
                    Shared.pushUrl shared <| Routing.Login


view : Shared -> View Msg
view shared =
    { title = "Profile"
    , modal = Nothing
    , body =
        Html.div [ Attr.css [ Css.paddingTop <| Css.rem 1 ] ]
            [ Pages.Profile.View.view
                { mob = shared.mob
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
