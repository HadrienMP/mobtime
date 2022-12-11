module Components.NavBar.View exposing (..)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Model.MobName as MobName exposing (MobName)
import UI.Color
import UI.Icons.Tape
import UI.Palettes
import UI.Rem
import UI.Row


type alias Props msg =
    { mob : Maybe MobName
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
                UI.Color.toElmCss <|
                    UI.Palettes.monochrome.surface
            , Css.color <|
                UI.Color.toElmCss <|
                    UI.Palettes.monochrome.on.surface
            ]
        ]
        [ Html.div
            [ Attr.css
                ([ Css.displayFlex
                 , Css.alignItems Css.center
                 , Css.justifyContent Css.spaceBetween
                 , Css.padding <| Css.rem 0.4
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
                    ]
                ]
                [ Html.text <|
                    Maybe.withDefault "" <|
                        Maybe.map MobName.print <|
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
                UI.Color.toElmCss <|
                    UI.Palettes.monochrome.on.surface
            ]
        , Attr.href "/"
        ]
        [ UI.Icons.Tape.display
            { height = UI.Rem.Rem 2
            , color = UI.Palettes.monochrome.on.surface
            }
        , Html.h1
            [ Attr.css
                [ Css.alignSelf <| Css.center
                , Css.paddingLeft <| Css.rem 0.5
                ]
            ]
            [ Html.div [ Attr.css [ Css.fontWeight Css.bolder ] ] [ Html.text "Mob" ]
            , Html.div [ Attr.css [ Css.fontWeight Css.lighter ] ] [ Html.text "Time" ]
            ]
        ]


rightNavBar : Props msg -> Html msg
rightNavBar props =
    UI.Row.row [ Attr.css [ Css.alignItems Css.center ] ]
        [ UI.Row.Gap <| UI.Rem.Rem 1 ]
        [ props.socket
        ]
