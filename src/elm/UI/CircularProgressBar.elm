module UI.CircularProgressBar exposing (..)

import Color
import Css
import Html.Styled as Html
import Html.Styled.Attributes exposing (css)
import Lib.Duration
import Lib.Ratio
import Svg.Styled exposing (Svg)
import UI.CircleFragment
import UI.Rem exposing (..)


draw :
    List (Html.Attribute msg)
    ->
        { color : Color.Color
        , strokeWidth : Rem
        , diameter : Rem
        , progress : Lib.Ratio.Ratio
        , refreshRate : Lib.Duration.Duration
        }
    -> Svg msg
draw attributes { color, strokeWidth, diameter, progress, refreshRate } =
    UI.CircleFragment.draw
        (css
            [ Css.property "transition"
                ("stroke-dashoffset "
                    ++ (refreshRate
                            |> Lib.Duration.toMillis
                            |> String.fromInt
                       )
                    ++ "ms linear"
                )
            ]
            :: attributes
        )
        { color = color
        , strokeWidth = strokeWidth
        , diameter = diameter
        , fragment = progress
        }
