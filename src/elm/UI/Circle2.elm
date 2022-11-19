module UI.Circle2 exposing (..)

import Color
import Html.Styled as Html
import Lib.Ratio
import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes as SvgAttr
import UI.Circle
import UI.Rem exposing (..)
import Lib.Duration


draw :
    List (Html.Attribute msg)
    ->
        { color : Color.Color
        , strokeWidth : Rem
        , diameter : Rem
        , progress : Lib.Ratio.Ratio
        ,refreshRate:Lib.Duration.Duration
        }
    -> Svg msg
draw attributes circle =
    let
        radiant =
            divide circle.diameter 2

        totalWidth =
            add circle.diameter circle.strokeWidth

        center =
            add radiant <| divide circle.strokeWidth 2
    in
    Svg.svg
        ([ SvgAttr.width <| toCssString totalWidth
         , SvgAttr.height <| toCssString totalWidth
         ]
            ++ attributes
        )
        (UI.Circle.draw
            (UI.Circle.Circle
                radiant
                (UI.Circle.Coordinates center center)
                (UI.Circle.Stroke circle.strokeWidth circle.color)
                circle.refreshRate
            )
            circle.progress
        )
