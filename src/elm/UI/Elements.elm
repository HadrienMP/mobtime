module UI.Elements exposing (..)

import Css
import Html.Styled as Html
import Html.Styled.Attributes exposing (css)


dot : Css.Color -> Html.Html msg
dot color =
    Html.div
        [ css
            [ Css.backgroundColor color
            , Css.height <| Css.px 10
            , Css.width <| Css.px 10
            , Css.borderRadius (Css.pct 100)
            ]
        ]
        []
