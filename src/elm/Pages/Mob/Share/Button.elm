module Pages.Mob.Share.Button exposing (..)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import UI.Color exposing (RGBA255)
import UI.Css
import UI.Icons.Ion
import UI.Palettes
import UI.Rem


type alias Props =
    { sharePage : String
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
            , UI.Css.gap <| UI.Rem.Rem 0.2
            , Css.textDecoration Css.none
            , Css.hover [ Css.textDecoration Css.underline ]
            ]
         , Attr.href props.sharePage
         ]
            ++ attributes
        )
        [ Html.div
            [ Attr.css
                [ Css.border3 (Css.px 2) Css.solid (UI.Color.toElmCss UI.Palettes.monochrome.on.background)
                , Css.borderRadius <| Css.pct 50
                , Css.padding <| Css.rem 0.5
                , Css.paddingRight <| Css.rem 0.6
                , Css.maxWidth Css.fitContent
                , Css.backgroundColor <| UI.Color.toElmCss <| UI.Palettes.monochrome.background
                ]
            ]
            [ UI.Icons.Ion.share
                { size = UI.Rem.Rem 2.4
                , color = props.color
                }
            ]
        , Html.span
            [ Attr.css
                [ Css.fontSize <| Css.rem 0.9
                , Css.fontWeight Css.lighter
                , Css.color <| UI.Color.toElmCss <| UI.Palettes.monochrome.on.background
                ]
            ]
            [ Html.text "Invite" ]
        ]
