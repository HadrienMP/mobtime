module Footer exposing (..)

import Html exposing (Html, a, footer, text)
import Html.Attributes exposing (href, id, target)
import Lib.Icons.Ion


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
            , text "Fork me on github!"
            ]
        ]
