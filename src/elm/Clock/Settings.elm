module Clock.Settings exposing (..)

import Html exposing (Html, div, input, label, text)
import Html.Attributes exposing (class, for, id, step, type_, value)
import Html.Events exposing (onInput)
import Lib.Duration as Duration
import Lib.Icons.Animals
import SharedEvents

view : Duration.Duration -> (SharedEvents.Event -> msg) -> Html msg
view turnLength shareEvent =
    div [ id "timer", class "tab" ]
        [ div
            [ id "turn-length-field", class "form-field" ]
            [ label
                [ for "turn-length" ]
                [ text <|
                    "Turn : "
                        ++ (String.fromInt <| Duration.toMinutes turnLength)
                        ++ " min"
                ]
            , div [ class "field-input" ]
                [ Lib.Icons.Animals.rabbit
                , input
                    [ id "turn-length"
                    , type_ "range"
                    , step "1"
                    , onInput <|
                        String.toInt
                            >> Maybe.withDefault 8
                            >> Duration.ofMinutes
                            >> SharedEvents.TurnLengthChanged
                            >> shareEvent
                    , Html.Attributes.min "2"
                    , Html.Attributes.max "20"
                    , value <| String.fromInt <| Duration.toMinutes turnLength
                    ]
                    []
                , Lib.Icons.Animals.elephant
                ]
            ]
        ]
