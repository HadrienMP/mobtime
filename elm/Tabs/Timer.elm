module Tabs.Timer exposing (..)

import Html exposing (Html, a, div, hr, i, input, label, strong, text)
import Html.Attributes exposing (checked, class, for, id, step, type_, value)
import Html.Events exposing (onCheck, onInput)


type Msg
    = TurnLengthChanged String
    | DisplaySecondsChanged Bool


view : Bool -> Int -> Html Msg
view displaySeconds turnLength =
    div [ id "timer", class "tab" ]
        [ a [ id "share-link" ]
            [ text "You are in the "
            , strong [] [ text "Agicap" ]
            , text " mob"
            , i [ id "share-button", class "fas fa-share-alt" ] []
            ]
        , hr [] []
        , div
            [ id "seconds-field", class "form-field" ]
            [ label [ for "seconds" ] [ text "Display seconds" ]
            , input
                [ id "seconds"
                , type_ "checkbox"
                , onCheck DisplaySecondsChanged
                , checked displaySeconds
                ]
                []
            ]
        , div
            [ id "turn-length-field", class "form-field" ]
            [ label
                [ for "turn-length" ]
                [ text <|
                    "Turn : "
                        ++ String.fromInt turnLength
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
                , value <| String.fromInt turnLength
                ]
                []
            , i [ class "fas fa-hippo" ] []
            ]
        ]
