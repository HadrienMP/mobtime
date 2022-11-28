module UI.Modal exposing (..)

import Css
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr
import Lib.Duration
import UI.Animations
import UI.Color
import UI.Css
import UI.Palettes


withContent : Html msg -> Html msg
withContent content =
    div
        [ Attr.css
            (UI.Css.fullpage
                ++ [ Css.backgroundColor <|
                        UI.Color.toElmCss <|
                            UI.Palettes.monochrome.background
                   ]
                ++ UI.Animations.fadeIn (Lib.Duration.ofMillis 400)
            )
        ]
        [ content
        ]
