module UI.Range.View exposing (..)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import UI.Color
import UI.Palettes


view :
    { onChange : Int -> msg
    , value : Int
    , min : Int
    , max : Int
    }
    -> Html msg
view { onChange, value, min, max } =
    Html.input
        [ Attr.id "volume"
        , Attr.type_ "range"
        , Evts.onInput
            (String.toInt
                >> Maybe.withDefault value
                >> onChange
            )
        , Attr.min <| String.fromInt min
        , Attr.max <| String.fromInt max
        , Attr.value <| String.fromInt value
        , Attr.css
            [ Css.width <| Css.pct 100
            , Css.property "appearance" "none"
            , Css.backgroundColor Css.transparent
            , Css.cursor Css.pointer
            , Css.pseudoElement "-webkit-slider-runnable-track" trackStyle
            , Css.pseudoElement "-moz-range-track" trackStyle
            , Css.pseudoElement "-webkit-slider-thumb"
                ([ Css.property "-webkit-appearance" "none"
                 , Css.transform <| Css.translateY <| Css.pct -40
                 ]
                    ++ thumbStyle
                )
            , Css.pseudoElement "-moz-range-thumb" thumbStyle
            , Css.pseudoElement "-moz-range-progress" progressStyle
            ]
        ]
        []


thumbStyle : List Css.Style
thumbStyle =
    [ Css.property "appearance" "none"
    , Css.backgroundColor <| UI.Color.toElmCss <| UI.Palettes.monochrome.on.surface
    , Css.border3 (Css.px 2) Css.solid <| UI.Color.toElmCss <| UI.Palettes.monochrome.surface
    , Css.height <| Css.rem 1
    , Css.width <| Css.rem 1
    , Css.borderRadius <| Css.pct 100
    ]


progressStyle : List Css.Style
progressStyle =
    [ Css.backgroundColor <| UI.Color.toElmCss <| UI.Palettes.monochrome.surface
    , Css.height <| Css.rem 0.3
    ]


trackStyle : List Css.Style
trackStyle =
    [ Css.backgroundColor <| UI.Color.toElmCss <| UI.Palettes.monochrome.surfaceActive
    , Css.height <| Css.rem 0.2
    ]
