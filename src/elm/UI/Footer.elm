module UI.Footer exposing (..)

import Html.Styled exposing (Html, a, footer, text)
import Html.Styled.Attributes exposing (href, id, target)
import UI.Icons.Custom
import UI.Icons.Ion


view : Html msg
view =
    footer
        []
        [ a
            [ href "https://github.com/HadrienMP/mob-time-elm"
            , id "git"
            , target "blank"
            ]
            [ UI.Icons.Ion.github
            , text "Checkout the code!"
            ]
        , a [ href "https://liberapay.com/HadrienMP/donate", target "blank", id "liberapay" ]
            [ UI.Icons.Custom.rocket
            , text "Support hosting"
            ]
        ]
