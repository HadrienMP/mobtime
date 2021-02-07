module Tabs.Timer exposing (..)

import Html exposing (Html, a, div, i, input, label, strong, text)
import Html.Attributes exposing (class, for, id, step, type_, value)
import Html.Events exposing (onInput)


type Msg
    = VolumeChanged String


view : Int -> Html Msg
view volume =
    div [ id "timer", class "tab" ]
        [ a [ id "share-link" ]
            [ text "You are in the "
            , strong [] [ text "Agicap" ]
            , text " mob"
            , i [ id "share-button", class "fas fa-share-alt" ] []
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
        ]
