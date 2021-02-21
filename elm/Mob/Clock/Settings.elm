module Mob.Clock.Settings exposing (..)

import Html exposing (Html, button, div, i, input, label, text)
import Html.Attributes exposing (checked, class, classList, for, id, step, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Lib.Duration as Duration exposing (Duration)


type Speed
    = Normal
    | Fast


type alias Model =
    { turnLength : Duration
    , displaySeconds : Bool
    , speed : Speed
    }


init : Model
init =
    { turnLength = Duration.ofMinutes 8
    , displaySeconds = False
    , speed = Normal
    }


type Msg
    = TurnLengthChanged String
    | DisplaySecondsChanged Bool
    | SpeedChanged Speed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TurnLengthChanged turnLength ->
            ( { model | turnLength = String.toInt turnLength |> Maybe.withDefault 8 |> Duration.ofMinutes }
            , Cmd.none
            )

        DisplaySecondsChanged displaySeconds ->
            ( { model | displaySeconds = displaySeconds }
            , Cmd.none
            )

        SpeedChanged speed ->
            ( { model | speed = speed }, Cmd.none )


seconds : Model -> Duration
seconds model =
    case model.speed of
        Normal ->
            Duration.ofSeconds 1

        Fast ->
            Duration.ofSeconds 20


format : Model -> Duration -> List String
format model duration =
    if model.displaySeconds then
        Duration.toLongString duration

    else
        Duration.toShortString duration


view : Model -> Html Msg
view model =
    div [ id "timer", class "tab" ]
        [ div
            [ id "seconds-field", class "form-field" ]
            [ label [ for "seconds" ] [ text "Display seconds" ]
            , input
                [ id "seconds"
                , type_ "checkbox"
                , onCheck DisplaySecondsChanged
                , checked model.displaySeconds
                ]
                []
            ]
        , div
            [ id "turn-length-field", class "form-field" ]
            [ label
                [ for "turn-length" ]
                [ text <|
                    "Turn : "
                        ++ (String.fromInt <| Duration.toMinutes model.turnLength)
                        ++ " min"
                ]
            , i [ class "fas fa-dove" ] []
            , input
                [ id "turn-length"
                , type_ "range"
                , step "1"
                , onInput TurnLengthChanged
                , Html.Attributes.min "2"
                , Html.Attributes.max "20"
                , value <| String.fromInt <| Duration.toMinutes model.turnLength
                ]
                []
            , i [ class "fas fa-hippo" ] []
            ]
        , div
            [ id "speed-field", class "form-field" ]
            [ label [ for "speed" ] [ text "Speed" ]
            , div
                [ class "toggles" ]
                [ button
                    [ classList [ ( "active", model.speed == Normal ) ]
                    , onClick <| SpeedChanged Normal
                    ]
                    [ i [ class "fas fa-angle-right" ] []
                    , text " | Normal"
                    ]
                , button
                    [ classList [ ( "active", model.speed == Fast ) ]
                    , onClick <| SpeedChanged Fast
                    ]
                    [ i [ class "fas fa-angle-double-right" ] []
                    , text " | Fast"
                    ]
                ]
            ]
        ]
