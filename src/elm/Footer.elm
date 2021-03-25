module Footer exposing (..)

import Html exposing (Html, a, footer, i, text)
import Html.Attributes exposing (class, href, id, target)
import Lib.Icons


view : Html msg
view =
    footer
        []
        [ a
            [ href "https://github.com/HadrienMP/mob-time-elm"
            , id "git"
            , target "blank"
            ]
            [ Lib.Icons.github
            , text "Fork me on github!"
            ]
        ]
