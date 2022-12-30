module UI.Layout exposing (..)

import Components.NavBar.Component
import Components.Socket.Socket
import Css
import Html.Styled as Html exposing (Html, a, div, text)
import Html.Styled.Attributes as Attr exposing (css)
import Shared exposing (Shared)
import UI.Color
import UI.Css
import UI.Icons.Common exposing (Icon)
import UI.Icons.Custom
import UI.Icons.Ion
import UI.Palettes
import UI.Rem


limitWidth : List Css.Style
limitWidth =
    [ Css.maxWidth <| Css.rem 22
    , Css.margin2 Css.zero Css.auto
    , Css.width <| Css.pct 100
    ]


wrap : Shared -> Html msg -> List (Html msg)
wrap shared child =
    [ Components.NavBar.Component.view (Css.padding sidePadding :: limitWidth) shared
    , Html.main_
        [ css
            [ Css.flexGrow <| Css.num 1
            , Css.displayFlex
            , Css.flexDirection Css.column
            , Css.padding sidePadding
            ]
        ]
        [ div
            [ Attr.css (Css.padding sidePadding :: limitWidth)
            ]
            [ child
            ]
        ]
    , footer
    ]


sidePadding : Css.Rem
sidePadding =
    Css.rem 0.5


forHome : Shared -> Html msg -> List (Html msg)
forHome shared child =
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
    , Components.Socket.Socket.view
        [ Attr.css
            [ Css.position Css.absolute
            , Css.top <| Css.rem 1
            , Css.right <| Css.rem 1
            ]
        ]
        UI.Palettes.monochrome.on.background
        shared.socket
    ]


footer : Html msg
footer =
    Html.footer
        [ css
            [ Css.backgroundColor <| UI.Color.toElmCss <| UI.Palettes.monochrome.background
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
