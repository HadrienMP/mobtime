module Footer exposing (..)

import Html exposing (Html, a, footer, i, text)
import Html.Attributes exposing (class, href, id, target)


view : Html msg
view =
    footer
        []
        [ a
            [ href "https://github.com/HadrienMP/mob-time-elm"
            , id "git"
            , target "blank"
            ]
            [ i [ class "fab fa-github" ] []
            , text "Fork me on github!"
            ]
        ]
