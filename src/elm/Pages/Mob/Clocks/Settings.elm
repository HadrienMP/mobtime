module Pages.Mob.Clocks.Settings exposing (..)

import Html exposing (Html, button, div, h3, input, label, p, text)
import Html.Attributes exposing (class, classList, for, id, step, type_, value)
import Html.Events exposing (onClick, onInput)
import Lib.Duration as Duration
import Lib.Icons.Custom
import Lib.Icons.Ion
import Model.Clock as Clock
import Model.MobName exposing (MobName)
import Peers.Events
import Peers.State
import Time


type alias Model =
    { displaySeconds : Bool }


init : Model
init =
    { displaySeconds = False }


type Msg
    = DisplaySecondsChanged Bool
    | ShareEvent Peers.Events.Event


update : Msg -> Model -> MobName -> ( Model, Cmd Msg )
update msg model mob =
    case msg of
        DisplaySecondsChanged bool ->
            ( { model | displaySeconds = bool }, Cmd.none )

        ShareEvent event ->
            ( model
            , event
                |> Peers.Events.MobEvent mob
                |> Peers.Events.mobEventToJson
                |> Peers.Events.sendEvent
            )


view : Model -> Time.Posix -> Peers.State.State -> Html Msg
view model now shared =
    div [ id "timer", class "tab" ]
        [ h3 []
            [ Lib.Icons.Ion.people
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
                        ++ (String.fromInt <| Duration.toMinutes shared.turnLength)
                        ++ " min"
                ]
            , div [ class "field-input" ]
                [ Lib.Icons.Custom.rabbit
                , input
                    [ id "turn-length"
                    , type_ "range"
                    , step "1"
                    , onInput <|
                        String.toInt
                            >> Maybe.withDefault (Duration.toMinutes Peers.State.defaultTurnLength)
                            >> Duration.ofMinutes
                            >> Peers.Events.TurnLengthChanged
                            >> ShareEvent
                    , Html.Attributes.min "2"
                    , Html.Attributes.max "20"
                    , value <| String.fromInt <| Duration.toMinutes shared.turnLength
                    ]
                    []
                , Lib.Icons.Custom.elephant
                ]
            ]
        , h3 []
            [ Lib.Icons.Custom.tomato
            , text "Pomodoro"
            ]
        , div
            [ class "form-field" ]
            [ label [ for "stop-pomodoro" ] [ text "Action" ]
            , button
                [ onClick <| ShareEvent <| Peers.Events.PomodoroStopped ]
                [ text "Stop" ]
            ]
        , div
            [ class "form-field" ]
            [ p [] [ text "Time left" ]
            , p [] [ text <| Clock.timeLeft now shared.pomodoro ]
            ]
        , div
            [ id "pomodoro-length-field", class "form-field" ]
            [ label
                [ for "pomodoro-length" ]
                [ text <|
                    "Length : "
                        ++ (String.fromInt <| Duration.toMinutes shared.pomodoroLength)
                        ++ " min"
                ]
            , div [ class "field-input" ]
                [ Lib.Icons.Ion.batteryFull
                , input
                    [ id "pomodoro-length"
                    , type_ "range"
                    , step "1"
                    , onInput <|
                        String.toInt
                            >> Maybe.withDefault (Duration.toMinutes Peers.State.defaultPomodoroLength)
                            >> Duration.ofMinutes
                            >> Peers.Events.PomodoroLengthChanged
                            >> ShareEvent
                    , Html.Attributes.min "10"
                    , Html.Attributes.max "45"
                    , value <| String.fromInt <| Duration.toMinutes shared.pomodoroLength
                    ]
                    []
                , Lib.Icons.Ion.batteryLow
                ]
            ]
        ]
