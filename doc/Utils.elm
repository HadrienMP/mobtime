module Utils exposing (placeholder)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Color
import UI.Rem


placeholder : UI.Rem.Rem -> Html.Html msg
placeholder height =
    Html.div
        [ Attr.css
            [ Css.backgroundColor <| UI.Color.toElmCss <| UI.Color.fromHex "#2aaae7"
            , Css.height <| UI.Rem.toElmCss height
            , Css.width <| Css.pct 100
            ]
        ]
        []
