module Pages.Mob.Tabs.Clocks exposing (..)

import Html.Styled exposing (Html, button, div, h3, input, label, p, text)
import Html.Styled.Attributes as Attr exposing (class, classList, for, id, step, type_, value)
import Html.Styled.Events exposing (onClick, onInput)
import Lib.Duration as Duration
import UI.Icons.Custom
import UI.Icons.Ion
import Model.Clock as Clock
import Model.Events
import Model.MobName exposing (MobName)
import Model.State
import Time


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


view : Model -> Time.Posix -> Model.State.State -> Html Msg
view model now shared =
    div [ id "timer", class "tab" ]
        [ h3 []
            [ UI.Icons.Ion.people
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
                [ UI.Icons.Custom.rabbit
                , input
                    [ id "turn-length"
                    , type_ "range"
                    , step "1"
                    , onInput <|
                        String.toInt
                            >> Maybe.withDefault (Duration.toMinutes Model.State.defaultTurnLength)
                            >> Duration.ofMinutes
                            >> Model.Events.TurnLengthChanged
                            >> ShareEvent
                    , Attr.min "2"
                    , Attr.max "20"
                    , value <| String.fromInt <| Duration.toMinutes shared.turnLength
                    ]
                    []
                , UI.Icons.Custom.elephant
                ]
            ]
        , h3 []
            [ UI.Icons.Custom.tomato
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
                [ UI.Icons.Ion.batteryFull
                , input
                    [ id "pomodoro-length"
                    , type_ "range"
                    , step "1"
                    , onInput <|
                        String.toInt
                            >> Maybe.withDefault (Duration.toMinutes Model.State.defaultPomodoroLength)
                            >> Duration.ofMinutes
                            >> Model.Events.PomodoroLengthChanged
                            >> ShareEvent
                    , Attr.min "10"
                    , Attr.max "45"
                    , value <| String.fromInt <| Duration.toMinutes shared.pomodoroLength
                    ]
                    []
                , UI.Icons.Ion.batteryLow
                ]
            ]
        ]
