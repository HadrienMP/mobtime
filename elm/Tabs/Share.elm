module Tabs.Share exposing (..)

import Html exposing (Html, a, div, hr, i, strong, text)
import Html.Attributes exposing (class, id)
import QRCode
import Svg.Attributes as Svg


view : Html msg
view =
    div [ id "share", class "tab" ]
        [ a [ id "share-link" ]
            [ text "You are in the "
            , strong [] [ text "Agicap" ]
            , text " mob"
            , i [ id "share-button", class "fas fa-share-alt" ] []
            ]
        , QRCode.fromString "http://localhost:3000"
                  |> Result.map
                      (QRCode.toSvg
                          [ Svg.width "300px"
                          , Svg.height "300px"
                          ]
                      )
                  |> Result.withDefault (Html.text "Error while encoding to QRCode.")
        ]
