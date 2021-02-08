module Tabs.Timer exposing (..)

import Html exposing (Html, a, button, div, hr, i, input, label, p, strong, text)
import Html.Attributes exposing (checked, class, classList, for, href, id, step, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Sounds


type Msg
    = VolumeChanged String
    | TurnLengthChanged String
    | DisplaySecondsChanged Bool
    | SelectedSoundProfile Sounds.Profile


view : Bool -> Int -> Int -> Sounds.Profile -> Html Msg
view displaySeconds turnLength volume profile =
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
        , hr [] []
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
        , div
            [ id "volume-field", class "form-field" ]
            [ label [ for "volume" ] [ text "Volume" ]
            , i [ class "fas fa-volume-down" ] []
            , input
                [ id "volume"
                , type_ "range"
                , onInput VolumeChanged
                , step "10"
                , value <| String.fromInt volume
                ]
                []
            , i [ class "fas fa-volume-up" ] []
            ]
        , div
            [ id "sounds-field", class "form-field" ]
            [ label [] [ text "Sounds" ]
            , div
                [ id "sound-cards" ]
                [ button
                    [ classList [ ( "active", profile == Sounds.ClassicWeird ) ]
                    , onClick <| SelectedSoundProfile Sounds.ClassicWeird
                    ]
                    [ i [ class "fas fa-grin-stars" ] []
                    , p [] [ text "Classic Weird" ]
                    ]
                , button
                    [ classList [ ( "active", profile == Sounds.Riot ) ]
                    , onClick <| SelectedSoundProfile Sounds.Riot
                    ]
                    [ i [ class "fas fa-hand-rock" ] []
                    , p [] [ text "Riot" ]
                    ]
                ]
            ]
        ]
