module UI.Text.View exposing (..)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr


light : String -> Html msg
light value =
    Html.p
        [ Attr.css
            [ Css.fontWeight Css.lighter
            , Css.margin Css.zero
            , Css.textAlign Css.justify
            ]
        ]
        [ Html.text value ]
