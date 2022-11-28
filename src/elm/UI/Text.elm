module UI.Text exposing (..)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr


h2 : String -> Html.Html msg
h2 text =
    Html.h2 [ Attr.css [ Css.fontSize <| Css.rem 2 ] ] [ Html.text text ]
