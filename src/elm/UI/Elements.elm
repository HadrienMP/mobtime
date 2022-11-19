module UI.Elements exposing (..)

import Css
import Html.Styled as Html
import Html.Styled.Attributes exposing (css)
import Color


dot : Color.Color -> Html.Html msg
dot color =
    let
        {hue,saturation,lightness,alpha}=Color.toHsla color
    in
    Html.div
        [ css
            [ Css.backgroundColor <| Css.hsla hue saturation lightness alpha
            , Css.height <| Css.px 10
            , Css.width <| Css.px 10
            , Css.borderRadius (Css.pct 100)
            ]
        ]
        []
