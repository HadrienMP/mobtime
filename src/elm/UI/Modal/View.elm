module UI.Modal.View exposing (..)

import Css
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr
import Lib.Duration
import UI.Animations
import UI.Button.View
import UI.Color
import UI.Css
import UI.Icons.Ion
import UI.Palettes
import UI.Row
import UI.Space


type alias Modal msg =
    { onClose : msg, content : Html msg }


map : (a -> b) -> Modal a -> Modal b
map f modal =
    { onClose = f modal.onClose
    , content = Html.map f modal.content
    }


view : Modal msg -> Html msg
view { onClose, content } =
    div
        [ Attr.class "modal"
        , Attr.css
            ([ Css.backgroundColor <|
                UI.Color.toElmCss <|
                    UI.Palettes.monochrome.background
             , Css.zIndex <| Css.int 1000
             , Css.displayFlex
             , Css.flexDirection Css.column
             , UI.Css.roundBorder
             ]
                ++ UI.Css.fullpage
                ++ UI.Animations.bottomSlide (Lib.Duration.ofMillis 400)
            )
        ]
        [ UI.Row.row [ Attr.css [ Css.width <| Css.pct 100 ] ]
            []
            [ Html.span [ Attr.css [ Css.flexGrow <| Css.int 1 ] ] []
            , UI.Button.View.button []
                { content = UI.Button.View.Both { icon = UI.Icons.Ion.close, text = "Close" }
                , variant = UI.Button.View.Primary
                , size = UI.Button.View.S
                , action = UI.Button.View.OnPress <| Just onClose
                }
            ]
        , div
            [ Attr.css
                [ Css.flexGrow <| Css.int 1
                , Css.padding UI.Space.s
                , Css.displayFlex
                , Css.alignItems Css.center
                , Css.justifyContent Css.center
                ]
            ]
            [ content ]
        ]
