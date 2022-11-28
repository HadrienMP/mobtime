module Pages.Mob.Tabs.Clocks exposing (..)

import Html.Styled exposing (Html, button, div, h3, input, label, p, text)
import Html.Styled.Attributes as Attr exposing (class, classList, for, id, step, type_, value)
import Html.Styled.Events exposing (onClick, onInput)
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
import UI.Rem


type alias Model =
    { displaySeconds : Bool }


init : Model
init =
    { displaySeconds = False }


type Msg
    = DisplaySecondsChanged Bool
    | ShareEvent Model.Events.Event


update : Msg -> Model -> MobName -> ( Model, Cmd Msg )
update msg model mob =
    case msg of
        DisplaySecondsChanged bool ->
            ( { model | displaySeconds = bool }, Cmd.none )

        ShareEvent event ->
            ( model
            , event
                |> Model.Events.MobEvent mob
                |> Model.Events.mobEventToJson
                |> Model.Events.sendEvent
            )


view : Shared -> Model -> Time.Posix -> Model.State.State -> Html Msg
view shared model now state =
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
                    [ classList [ ( "active", not model.displaySeconds ) ]
                    , onClick <| DisplaySecondsChanged False
                    ]
                    [ text "Hide" ]
                , button
                    [ classList [ ( "active", model.displaySeconds ) ]
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
                , input
                    [ id "turn-length"
                    , type_ "range"
                    , step "1"
                    , onInput <|
                        String.toInt
                            >> Maybe.withDefault (toValue shared Model.State.defaultTurnLength)
                            >> toDuration shared
                            >> Model.Events.TurnLengthChanged
                            >> ShareEvent
                    , Attr.min "2"
                    , Attr.max "20"
                    , value <| String.fromInt <| toValue shared state.turnLength
                    ]
                    []
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
                , input
                    [ id "pomodoro-length"
                    , type_ "range"
                    , step "1"
                    , onInput <|
                        String.toInt
                            >> Maybe.withDefault (toValue shared Model.State.defaultPomodoroLength)
                            >> toDuration shared
                            >> Model.Events.PomodoroLengthChanged
                            >> ShareEvent
                    , Attr.min "10"
                    , Attr.max "45"
                    , value <| String.fromInt <| toValue shared state.pomodoroLength
                    ]
                    []
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
