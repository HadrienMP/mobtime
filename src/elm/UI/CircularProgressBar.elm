module UI.CircularProgressBar exposing (..)

import Css
import Html.Styled exposing (Html)
import Html.Styled.Attributes exposing (css)
import Lib.Duration
import Lib.Ratio
import UI.Color
import UI.ConcentricCircles
import UI.Rem exposing (..)
import UI.TransitionExtra


draw :
    { colors :
        { main : UI.Color.RGBA255
        , background : UI.Color.RGBA255
        , border : UI.Color.RGBA255
        }
    , strokeWidth : Rem
    , diameter : Rem
    , progress : Lib.Ratio.Ratio
    , refreshRate : Lib.Duration.Duration
    }
    -> Html msg
draw { colors, strokeWidth, diameter, progress, refreshRate } =
    UI.ConcentricCircles.buildFragment
        { color = colors.main
        , strokeWidth = strokeWidth
        , diameter = diameter
        , fragment = progress
        }
        |> UI.ConcentricCircles.withAttributes [ css [ UI.TransitionExtra.dashoffset refreshRate ] ]
        |> UI.ConcentricCircles.addBackground colors.background
        |> UI.ConcentricCircles.addBorders
            { color = colors.border
            , width = strokeWidth |> divideBy 6
            }
        |> UI.ConcentricCircles.draw [ css [ Css.transform <| Css.rotate <| Css.deg -90 ] ]
