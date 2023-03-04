module Utils exposing (placeholder)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Color as Color
import UI.Rem as Rem


placeholder : Rem.Rem -> Html.Html msg
placeholder height =
    Html.div
        [ Attr.css
            [ Css.backgroundColor <| Color.toElmCss <| Color.fromHex "#2aaae7"
            , Css.height <| Rem.toElmCss height
            , Css.width <| Css.pct 100
            ]
        ]
        []
