module UI.Elements exposing (..)

import Color
import Css
import Html.Styled as Html
import Html.Styled.Attributes exposing (css)
import UI.Color


dot : Color.Color -> Html.Html msg
dot color =
    Html.div
        [ css
            [ Css.backgroundColor <| UI.Color.toElmCss color
            , Css.height <| Css.px 10
            , Css.width <| Css.px 10
            , Css.borderRadius (Css.pct 100)
            ]
        ]
        []
