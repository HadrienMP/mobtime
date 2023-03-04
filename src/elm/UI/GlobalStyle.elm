module UI.GlobalStyle exposing (globalStyle)

import Css
import Css.Global
import Html.Styled exposing (Html)
import UI.Color as Color
import UI.Palettes as Palettes


globalStyle : Html msg
globalStyle =
    Css.Global.global
        [ Css.Global.html
            [ Css.color <| Color.toElmCss <| Palettes.monochrome.on.background
            , Css.backgroundColor <| Color.toElmCss <| Palettes.monochrome.background
            , Css.fontSize <| Css.pt 15
            , Css.height <| Css.pct 100
            ]
        , Css.Global.body
            [ Css.height <| Css.pct 100
            , Css.Global.descendants
                [ Css.Global.everything
                    [ Css.boxSizing Css.borderBox
                    , Css.fontFamilies [ "Oswald", "sans-serif" ]
                    , Css.lineHeight <| Css.em 1
                    ]
                ]
            ]
        ]
