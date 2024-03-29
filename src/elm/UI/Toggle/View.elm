module UI.Toggle.View exposing (Props, view)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import UI.Color as Color
import UI.Palettes as Palettes


type alias Props msg =
    { onToggle : msg, value : Bool }


view : Props msg -> Html msg
view props =
    Html.button
        [ Attr.css
            [ Css.height <| Css.rem 1.3
            , Css.width <| Css.rem 2.8
            , Css.backgroundColor <|
                Color.toElmCss <|
                    if props.value then
                        Palettes.monochrome.surface

                    else
                        Palettes.monochrome.surfaceActive
            , Css.border Css.zero
            , Css.borderRadius <| Css.rem 2
            , Css.cursor Css.pointer
            , Css.padding2 Css.zero <| Css.rem 0.1
            , Css.displayFlex
            , Css.alignItems Css.center
            , Css.hover
                [ Css.backgroundColor <|
                    Color.toElmCss <|
                        if props.value then
                            Palettes.monochrome.surface

                        else
                            Palettes.monochrome.surfaceActive
                ]
            ]
        , Attr.class "toggle"
        , Evts.onClick props.onToggle
        ]
        [ Html.div
            [ Attr.css
                [ Css.height <| Css.rem 1.1
                , Css.width <| Css.rem 1.1
                , Css.borderRadius <| Css.pct 50
                , Css.backgroundColor <|
                    Color.toElmCss <|
                        Palettes.monochrome.background
                , if props.value then
                    Css.marginLeft Css.auto

                  else
                    Css.marginLeft <| Css.pct 0
                ]
            ]
            []
        ]
