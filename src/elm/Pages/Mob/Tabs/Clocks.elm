module Pages.Mob.Tabs.Clocks exposing (..)

import Effect exposing (Effect)
import Html.Styled exposing (Html, button, div, h3, label, p, text)
import Html.Styled.Attributes exposing (class, classList, for, id)
import Html.Styled.Events exposing (onClick)
import Lib.Duration as Duration
import Model.Clock as Clock
import Model.Events
import Model.MobName exposing (MobName)
import Model.State
import Shared exposing (Shared)
import Time
import UI.Icons.Custom
import UI.Icons.Ion
import UI.Palettes
import UI.Range.Component
import UI.Rem
import UserPreferences


type Msg
    = DisplaySecondsChanged Bool
    | ShareEvent Model.Events.Event


update : Msg -> MobName -> Effect Shared.Msg Msg
update msg mob =
    case msg of
        DisplaySecondsChanged bool ->
            Effect.fromShared <| Shared.PreferencesMsg <| UserPreferences.DisplaySeconds bool

        ShareEvent event ->
            event
                |> Model.Events.MobEvent mob
                |> Effect.share


view : Shared -> Time.Posix -> Model.State.State -> Html Msg
view shared now state =
    div [ id "timer", class "tab" ]
        [ h3 []
            [ UI.Icons.Ion.people
                { size = UI.Rem.Rem 1
                , color = UI.Palettes.monochrome.on.background
                }
            , text "Turn"
            ]
        , div
            [ id "seconds-field", class "form-field" ]
            [ label [ for "seconds" ] [ text "Seconds" ]
            , div
                [ class "toggles" ]
                [ button
                    [ classList [ ( "active", not shared.preferences.displaySeconds ) ]
                    , onClick <| DisplaySecondsChanged False
                    ]
                    [ text "Hide" ]
                , button
                    [ classList [ ( "active", shared.preferences.displaySeconds ) ]
                    , onClick <| DisplaySecondsChanged True
                    ]
                    [ text "Show" ]
                ]
            ]
        , div
            [ id "turn-length-field", class "form-field" ]
            [ label
                [ for "turn-length" ]
                [ text <|
                    "Turn : "
                        ++ Duration.print state.turnLength
                ]
            , div [ class "field-input" ]
                [ UI.Icons.Custom.rabbit
                    { size = UI.Rem.Rem 1
                    , color = UI.Palettes.monochrome.on.background
                    }
                , UI.Range.Component.display
                    { onChange =
                        toDuration shared
                            >> Model.Events.TurnLengthChanged
                            >> ShareEvent
                    , min = 2
                    , max = 20
                    , value =
                        state.turnLength
                            |> toValue shared
                    }
                , UI.Icons.Custom.elephant
                    { size = UI.Rem.Rem 1
                    , color = UI.Palettes.monochrome.on.background
                    }
                ]
            ]
        , h3 []
            [ UI.Icons.Custom.tomato
                { size = UI.Rem.Rem 1
                , color = UI.Palettes.monochrome.on.background
                }
            , text "Pomodoro"
            ]
        , div
            [ class "form-field" ]
            [ label [ for "stop-pomodoro" ] [ text "Action" ]
            , button
                [ onClick <| ShareEvent <| Model.Events.PomodoroStopped ]
                [ text "Stop" ]
            ]
        , div
            [ class "form-field" ]
            [ p [] [ text "Time left" ]
            , p [] [ text <| Clock.timeLeft now state.pomodoro ]
            ]
        , div
            [ id "pomodoro-length-field", class "form-field" ]
            [ label
                [ for "pomodoro-length" ]
                [ text <|
                    "Length : "
                        ++ Duration.print state.pomodoroLength
                ]
            , div [ class "field-input" ]
                [ UI.Icons.Ion.batteryFull
                    { size = UI.Rem.Rem 1
                    , color = UI.Palettes.monochrome.on.background
                    }
                , UI.Range.Component.display
                    { onChange =
                        toDuration shared
                            >> Model.Events.PomodoroLengthChanged
                            >> ShareEvent
                    , min = 10
                    , max = 45
                    , value =
                        state.pomodoroLength
                            |> toValue shared
                    }
                , UI.Icons.Ion.batteryLow
                    { size = UI.Rem.Rem 1
                    , color = UI.Palettes.monochrome.on.background
                    }
                ]
            ]
        ]


toDuration : Shared -> Int -> Duration.Duration
toDuration shared =
    if shared.devMode then
        Duration.ofSeconds

    else
        Duration.ofMinutes


toValue : Shared -> Duration.Duration -> Int
toValue shared =
    if shared.devMode then
        Duration.toSeconds

    else
        Duration.toMinutes
