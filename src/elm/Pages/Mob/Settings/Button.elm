module Pages.Mob.Settings.Button exposing (Props, view)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import UI.Color as Color exposing (RGBA255)
import UI.Css
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Rem as Rem


type alias Props =
    { target : String
    , color : RGBA255
    }


view : List (Html.Attribute msg) -> Props -> Html msg
view attributes props =
    Html.a
        ([ Attr.css
            [ Css.cursor Css.pointer
            , Css.displayFlex
            , Css.flexDirection Css.column
            , Css.alignItems Css.center
            , Css.maxWidth Css.fitContent
            , UI.Css.gap <| Rem.Rem 0.2
            , Css.textDecoration Css.none
            , Css.hover [ Css.textDecoration Css.underline ]
            ]
         , Attr.href props.target
         ]
            ++ attributes
        )
        [ Html.div
            [ Attr.css
                [ Css.border3 (Css.px 2) Css.solid (Color.toElmCss Palettes.monochrome.on.background)
                , Css.borderRadius <| Css.pct 50
                , Css.padding <| Css.rem 0.5
                , Css.maxWidth Css.fitContent
                , Css.backgroundColor <| Color.toElmCss <| Palettes.monochrome.background
                , Css.lineHeight <| Css.rem 1
                ]
            ]
            [ UI.Icons.Ion.settings
                { size = Rem.Rem 1.4
                , color = props.color
                }
            ]
        , Html.span
            [ Attr.css
                [ Css.fontSize <| Css.rem 0.9
                , Css.fontWeight Css.lighter
                , Css.color <| Color.toElmCss <| Palettes.monochrome.on.background
                , Css.textDecoration Css.underline
                ]
            ]
            [ Html.text "Settings" ]
        ]
