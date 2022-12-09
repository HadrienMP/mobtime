module UI.GlobalStyle exposing (..)

import Css
import Css.Global
import Html.Styled exposing (Html)
import UI.Color
import UI.Palettes


globalStyle : Html msg
globalStyle =
    Css.Global.global
        [ Css.Global.html
            [ Css.color <| UI.Color.toElmCss <| UI.Palettes.monochrome.on.background
            , Css.backgroundColor <| UI.Color.toElmCss <| UI.Palettes.monochrome.background
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
