module UI.Link.IconLink exposing (Props, view)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Color as Color
import UI.Css
import UI.Icons.Common exposing (Icon)
import UI.Palettes as Palettes
import UI.Size as Size


type alias Props msg =
    { target : String
    , icon : Icon msg
    , text : String
    , color : Color.RGBA255
    }


view : List (Html.Attribute msg) -> Props msg -> Html.Html msg
view attributes props =
    Html.a
        ([ Attr.css
            [ Css.cursor Css.pointer
            , Css.displayFlex
            , Css.flexDirection Css.column
            , Css.alignItems Css.center
            , Css.maxWidth Css.fitContent
            , UI.Css.gap <| Size.rem 0.2
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
                , Css.lineHeight <| Css.num 1
                ]
            ]
            [ props.icon
                { size = Size.rem 1.4
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
            [ Html.text props.text ]
        ]
