module UI.GlobalStyle exposing (globalStyle)

import Css
import Css.Global
import Html.Styled exposing (Html)
import UI.Color as Color
import UI.Palettes as Palettes
import UI.Size as Size


globalStyle : Html msg
globalStyle =
    Css.Global.global
        [ Css.Global.html
            [ Css.color <| Color.toElmCss <| Palettes.monochrome.on.background
            , Css.backgroundColor <| Color.toElmCss <| Palettes.monochrome.background
            , Css.fontSize <| Css.px Size.rootSizeAsPx
            , Css.height <| Css.pct 100
            ]
        , Css.Global.body
            [ Css.height <| Css.pct 100
            , Css.Global.descendants
                [ Css.Global.everything
                    [ Css.boxSizing Css.borderBox
                    , Css.fontFamilies [ "Oswald", "sans-serif" ]
                    ]
                ]
            ]
        , Css.Global.h2 [ Css.margin Css.zero ]
        , Css.Global.p
            [ Css.margin Css.zero
            ]
        , Css.Global.selector "#action.on"
            [ Css.Global.descendants
                [ Css.Global.id "action-icon"
                    [ Css.display Css.none
                    ]
                ]
            , Css.hover
                [ Css.Global.descendants
                    [ Css.Global.id "action-icon"
                        [ Css.display Css.block
                        ]
                    ]
                ]
            ]
        ]
