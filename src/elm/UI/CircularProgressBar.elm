module UI.CircularProgressBar exposing (..)

import Css
import Html.Styled as Html
import Html.Styled.Attributes exposing (css)
import Lib.Duration
import Lib.Ratio
import Svg.Styled exposing (Svg)
import UI.CircleFragment
import UI.Color
import UI.Rem exposing (..)


draw :
    List (Html.Attribute msg)
    ->
        { color : UI.Color.RGBA255
        , strokeWidth : Rem
        , diameter : Rem
        , progress : Lib.Ratio.Ratio
        , refreshRate : Lib.Duration.Duration
        }
    -> Svg msg
draw attributes { color, strokeWidth, diameter, progress, refreshRate } =
    UI.CircleFragment.draw
        { color = color
        , strokeWidth = strokeWidth
        , diameter = diameter
        , fragment = progress
        , svgAttr = attributes
        , background = UI.Color.fromHex "#cccccc"
        , circleAttr =
            [ css
                [ Css.property "transition"
                    ("stroke-dashoffset "
                        ++ (refreshRate
                                |> Lib.Duration.toMillis
                                |> String.fromInt
                           )
                        ++ "ms linear"
                    )
                ]
            ]
        }
