module UI.CircularProgressBar exposing (draw)

import Css
import Html.Styled exposing (Html)
import Html.Styled.Attributes exposing (css)
import Lib.Duration
import Lib.Ratio
import UI.Circle
import UI.Color as Color
import UI.Rem as Rem exposing (Rem)
import UI.TransitionExtra


draw :
    { colors :
        { main : Color.RGBA255
        , background : Color.RGBA255
        , border : Color.RGBA255
        }
    , strokeWidth : Rem
    , diameter : Rem
    , progress : Lib.Ratio.Ratio
    , refreshRate : Lib.Duration.Duration
    }
    -> Html msg
draw { colors, strokeWidth, diameter, progress, refreshRate } =
    UI.Circle.buildFragment
        { color = colors.main
        , strokeWidth = strokeWidth
        , diameter = diameter
        , fragment = progress
        }
        |> UI.Circle.withAttributes [ css [ UI.TransitionExtra.dashoffset refreshRate ] ]
        |> UI.Circle.addBackground colors.background
        |> UI.Circle.addBorders
            { color = colors.border
            , width = strokeWidth |> Rem.divideBy 6
            }
        |> UI.Circle.draw [ css [ Css.transform <| Css.rotate <| Css.deg -90 ] ]
