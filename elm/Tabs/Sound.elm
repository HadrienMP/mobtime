module Tabs.Sound exposing (..)

import Html exposing (Html, button, div, i, input, label, p, text)
import Html.Attributes exposing (class, classList, for, id, step, type_, value)
import Html.Events exposing (onClick, onInput)
import Sounds


type Msg
    = VolumeChanged String
    | SelectedSoundProfile Sounds.Profile


view : Int -> Sounds.Profile -> Html Msg
view volume profile =
    div [ id "sound", class "tab" ]
        [ div
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
            [ label [] [ text "Profiles" ]
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
                    [ i [ class "fas fa-flag" ] []
                    , p [] [ text "Revolution" ]
                    ]
                ]
            ]
        ]
