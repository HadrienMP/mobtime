module Components.NavBar.View exposing (Props, view)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Model.MobName as MobName exposing (MobName)
import UI.Color as Color
import UI.Css
import UI.Icons.Tape
import UI.Palettes as Palettes
import UI.Row as Row
import UI.Size as Size
import UI.Space as Space


type alias Props msg =
    { mob : MobName
    , socket : Html msg
    , addedStyle : List Css.Style
    }


view : Props msg -> Html msg
view props =
    Html.nav
        [ Attr.css
            [ Css.position Css.sticky
            , Css.top Css.zero
            , Css.left Css.zero
            , Css.right Css.zero
            , Css.zIndex <| Css.int 100
            , Css.backgroundColor <|
                Color.toElmCss <|
                    Palettes.monochrome.surface
            , Css.color <|
                Color.toElmCss <|
                    Palettes.monochrome.on.surface
            ]
        ]
        [ Html.div
            [ Attr.css
                ([ Css.displayFlex
                 , Css.alignItems Css.center
                 , Css.justifyContent Css.spaceBetween
                 , Css.padding <| Size.toElmCss Space.xs
                 ]
                    ++ props.addedStyle
                )
            ]
            [ title
            , Html.span
                [ Attr.css
                    [ Css.textOverflow Css.ellipsis
                    , Css.whiteSpace Css.noWrap
                    , Css.overflow Css.hidden
                    , Css.padding2 Css.zero <| Css.rem 1
                    , Css.lineHeight <| Css.em 1.4
                    ]
                ]
                [ Html.text <|
                    MobName.print <|
                        props.mob
                ]
            , rightNavBar props
            ]
        ]


title : Html msg
title =
    Html.a
        [ Attr.css
            [ Css.displayFlex
            , Css.textDecoration Css.none
            , Css.color <|
                Color.toElmCss <|
                    Palettes.monochrome.on.surface
            ]
        , Attr.href "/"
        ]
        [ UI.Icons.Tape.display
            { size = Size.rem 2
            , color = Palettes.monochrome.on.surface
            }
        , Html.h1
            [ Attr.css
                [ Css.alignSelf <| Css.center
                , Css.paddingLeft <| Css.rem 0.5
                , Css.lineHeight <| Css.num 1
                ]
            ]
            [ Html.div [ Attr.css [ Css.fontWeight Css.bolder ] ] [ Html.text "Mob" ]
            , Html.div [ Attr.css [ Css.fontWeight Css.lighter ] ] [ Html.text "Time" ]
            ]
        ]


rightNavBar : Props msg -> Html msg
rightNavBar props =
    Row.row
        [ Attr.css
            [ Css.alignItems Css.center
            , UI.Css.gap Space.xs
            ]
        ]
        [ props.socket
        ]
