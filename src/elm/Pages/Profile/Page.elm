module Pages.Profile.Page exposing (..)

import Css
import Effect exposing (Effect)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Pages.Profile.Component
import Routing
import Shared exposing (Shared)
import UI.Layout
import UserPreferences
import View exposing (View)
import Volume.Field


type Msg
    = ToggleSeconds Bool
    | VolumeMsg Volume.Field.Msg
    | Join


update : Msg -> Shared -> Effect Shared.Msg Msg
update msg shared =
    case msg of
        ToggleSeconds value ->
            Effect.fromShared <| Shared.PreferencesMsg <| UserPreferences.ToggleSeconds value

        VolumeMsg subMsg ->
            Effect.fromShared <| Shared.PreferencesMsg <| UserPreferences.VolumeMsg subMsg

        Join ->
            case shared.mob of
                Just mob ->
                    Shared.pushUrl shared <| Routing.Mob mob

                Nothing ->
                    Shared.pushUrl shared <| Routing.Login


view : Shared -> View Msg
view shared =
    { title = "Profile"
    , modal = Nothing
    , body =
        [ UI.Layout.wrap shared <|
            Html.div [ Attr.css [ Css.paddingTop <| Css.rem 1 ] ]
                [ Pages.Profile.Component.display
                    { mob = shared.mob
                    , secondsToggle =
                        { value = shared.preferences.displaySeconds
                        , onToggle = ToggleSeconds
                        }
                    , volume =
                        { onChange = VolumeMsg << Volume.Field.Change
                        , onTest = VolumeMsg Volume.Field.Test
                        , volume = shared.preferences.volume
                        }
                    , onJoin = Join
                    }
                ]
        ]
    }
