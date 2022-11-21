module UI.CircularProgressBar exposing (..)

import Html.Styled as Html
import Html.Styled.Attributes exposing (css)
import Lib.Duration
import Lib.Ratio
import Svg.Styled exposing (Svg)
import UI.ConcentricCircles
import UI.Color
import UI.Rem exposing (..)
import UI.TransitionExtra


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
    UI.ConcentricCircles.buildFragment
        { color = color
        , strokeWidth = strokeWidth
        , diameter = diameter
        , fragment = progress
        }
        |> UI.ConcentricCircles.withAttributes [ css [ UI.TransitionExtra.dashoffset refreshRate ] ]
        |> UI.ConcentricCircles.addBackground (UI.Color.lighten 9 color)
        |> UI.ConcentricCircles.addBorders
            { color = UI.Color.lighten 7 color
            , width = strokeWidth |> divideBy 6
            }
        |> UI.ConcentricCircles.draw attributes
