module Tabs.Share exposing (..)

import Html exposing (Html, a, div, hr, i, strong, text)
import Html.Attributes exposing (class, id)


view : Html msg
view =
    div [ id "share", class "tab" ]
        [ a [ id "share-link" ]
            [ text "You are in the "
            , strong [] [ text "Agicap" ]
            , text " mob"
            , i [ id "share-button", class "fas fa-share-alt" ] []
            ]
        , hr [] []
        ]
