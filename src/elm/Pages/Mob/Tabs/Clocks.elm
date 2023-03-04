module Pages.Mob.Tabs.Clocks exposing (Msg(..), update, view)

import Css
import Effect exposing (Effect)
import Html.Styled exposing (Html, button, div, h3, label, p, text)
import Html.Styled.Attributes as Attr exposing (class, for, id)
import Html.Styled.Events exposing (onClick)
import Lib.Duration as Duration
import Model.Clock as Clock
import Model.Events
import Model.MobName exposing (MobName)
import Model.State
import Shared exposing (Shared)
import Time
import UI.Css
import UI.Icons.Custom
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Range.View
import UI.Rem as Rem


type Msg
    = ShareEvent Model.Events.Event


update : Msg -> MobName -> Effect Shared.Msg Msg
update msg mob =
    case msg of
        ShareEvent event ->
            event
                |> Model.Events.MobEvent mob
                |> Effect.share


view : Shared -> Time.Posix -> Model.State.State -> Html Msg
view shared now state =
    div [ id "timer", class "tab" ]
        [ h3
            [ Attr.css
                [ Css.displayFlex
                , Css.alignItems Css.center
                , UI.Css.gap <| Rem.Rem 0.4
                ]
            ]
            [ UI.Icons.Ion.people
                { size = Rem.Rem 3
                , color = Palettes.monochrome.on.background
                }
            , text "Turn"
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
                    { size = Rem.Rem 1
                    , color = Palettes.monochrome.on.background
                    }
                , UI.Range.View.view
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
                    { size = Rem.Rem 1
                    , color = Palettes.monochrome.on.background
                    }
                ]
            ]
        , h3 []
            [ UI.Icons.Custom.tomato
                { size = Rem.Rem 1
                , color = Palettes.monochrome.on.background
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
                    { size = Rem.Rem 3
                    , color = Palettes.monochrome.on.background
                    }
                , UI.Range.View.view
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
                    { size = Rem.Rem 3
                    , color = Palettes.monochrome.on.background
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
