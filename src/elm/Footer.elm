module Footer exposing (..)

import Html exposing (Html, a, footer, text)
import Html.Attributes exposing (href, id, target)
import Lib.Icons.Ion
import Lib.Icons.Custom


view : Html msg
view =
    footer
        []
        [ a
            [ href "https://github.com/HadrienMP/mob-time-elm"
            , id "git"
            , target "blank"
            ]
            [ Lib.Icons.Ion.github
            , text "Checkout the code!"
            ]
        , a [ href "https://liberapay.com/HadrienMP/donate", target "blank", id "liberapay" ]
            [ Lib.Icons.Custom.rocket
            , text "Support hosting"
            ]
        ]
