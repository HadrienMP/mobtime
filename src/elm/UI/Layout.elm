module UI.Layout exposing (..)

import Css
import Html.Styled as Html exposing (Html, a, div, h1, nav, text)
import Html.Styled.Attributes as Attr exposing (css)
import Model.MobName exposing (MobName)
import Shared exposing (Shared)
import Socket
import UI.Color
import UI.Css
import UI.Icons.Common exposing (Icon)
import UI.Icons.Custom
import UI.Icons.Ion
import UI.Icons.Tape
import UI.Palettes
import UI.Rem
import UI.Space


limitWidth : List Css.Style
limitWidth =
    [ Css.maxWidth <| Css.rem 22
    , Css.margin Css.auto
    , Css.width <| Css.pct 100
    ]


wrap : Shared -> MobName -> Html msg -> Html msg
wrap shared mob child =
    div
        [ css
            [ Css.displayFlex
            , Css.flexDirection Css.column
            , Css.height <| Css.pct 100
            ]
        ]
        [ navBar mob
        , div
            [ css
                [ Css.flexGrow <| Css.num 1
                , Css.displayFlex
                , Css.overflow Css.auto
                , Css.flexDirection Css.column
                ]
            ]
            [ div
                [ css
                    ([ Css.flexGrow <| Css.num 1
                     , Css.position Css.relative
                     ]
                        ++ limitWidth
                    )
                ]
                [ div
                    [ css [ Css.padding sidePadding ] ]
                    [ child ]
                ]
            , Socket.view [ Attr.css [ Css.important <| Css.top <| UI.Space.xxl ] ] shared.socket
            , footer
            ]
        ]


navBar : MobName -> Html msg
navBar mob =
    nav
        [ css
            [ Css.position Css.sticky
            , Css.top Css.zero
            , Css.left Css.zero
            , Css.right Css.zero
            , Css.zIndex <| Css.int 100
            , Css.boxShadow3 Css.zero Css.zero (Css.rem 0.2)
            , Css.backgroundColor <|
                UI.Color.toElmCss <|
                    UI.Palettes.monochrome.surface
            , Css.color <|
                UI.Color.toElmCss <|
                    UI.Palettes.monochrome.on.surface
            ]
        ]
        [ div
            [ css
                (limitWidth
                    ++ [ Css.displayFlex
                       , Css.alignItems Css.center
                       , Css.justifyContent Css.spaceBetween
                       , Css.padding sidePadding
                       ]
                )
            ]
            [ a
                [ css
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
                , h1
                    [ css
                        [ Css.alignSelf <| Css.center
                        , Css.paddingLeft <| Css.rem 0.5
                        ]
                    ]
                    [ div [ css [ Css.fontWeight Css.bolder ] ] [ text "Mob" ]
                    , div [ css [ Css.fontWeight Css.lighter ] ] [ text "Time" ]
                    ]
                ]
            , Html.h2 [] [ Html.text <| (++) "Mob: " <| Model.MobName.print mob ]
            ]
        ]


sidePadding : Css.Rem
sidePadding =
    Css.rem 0.5


forHome : Shared -> Html msg -> Html msg
forHome shared child =
    div
        [ css
            [ Css.displayFlex
            , Css.flexDirection Css.column
            , Css.height <| Css.pct 100
            ]
        ]
        [ div
            [ css [ Css.flexGrow <| Css.num 1 ] ]
            [ div
                [ css
                    (Css.padding sidePadding
                        :: UI.Css.center
                        ++ limitWidth
                    )
                ]
                [ child ]
            ]
        , footer
        , Socket.view [] shared.socket
        ]


footer : Html msg
footer =
    Html.footer
        [ css
            [ Css.backgroundColor <| UI.Color.toElmCss <| UI.Palettes.monochrome.background
            , Css.marginTop <| Css.rem 1
            , Css.borderTop3 (Css.px 1) Css.solid <| UI.Color.toElmCss <| UI.Palettes.monochrome.on.background
            ]
        ]
        [ div
            [ css
                (limitWidth
                    ++ [ Css.displayFlex
                       , Css.justifyContent Css.spaceAround
                       ]
                )
            ]
            [ footerLink []
                { url = "https://github.com/HadrienMP/mob-time-elm"
                , icon = UI.Icons.Ion.github
                , label = "Checkout the code!"
                , class = "github"
                }
            , footerLink []
                { url = "https://liberapay.com/HadrienMP/donate"
                , icon = UI.Icons.Custom.rocket
                , label = "Support hosting"
                , class = "support-hosting"
                }
            ]
        ]


footerLink :
    List (Html.Attribute msg)
    ->
        { url : String
        , icon : Icon msg
        , class : String
        , label : String
        }
    -> Html msg
footerLink attributes { url, icon, label } =
    a
        ([ Attr.href url
         , Attr.target "blank"
         , Attr.css
            [ Css.padding2 (Css.rem 0.4) Css.zero
            , Css.fontSize (Css.rem 0.9)
            , Css.color <|
                UI.Color.toElmCss <|
                    UI.Palettes.monochrome.on.background
            , Css.visited
                [ Css.color <|
                    UI.Color.toElmCss <|
                        UI.Palettes.monochrome.on.background
                ]
            ]
         ]
            ++ attributes
        )
        [ div
            [ Attr.css
                [ Css.alignItems Css.center
                , Css.displayFlex
                , Css.margin Css.auto
                ]
            ]
            [ icon { size = UI.Rem.Rem 1, color = UI.Palettes.monochrome.on.background }
            , Html.span [ Attr.css [ Css.padding <| Css.rem 0.2 ] ] []
            , div [ Attr.css [ Css.position Css.relative, Css.top <| Css.px -1 ] ] [ text label ]
            ]
        ]
