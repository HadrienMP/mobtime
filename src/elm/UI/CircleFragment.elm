module UI.CircleFragment exposing (..)

import Color
import Html.Styled as Html
import Lib.Ratio
import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes as SvgAttr
import UI.Rem exposing (..)


draw :
    List (Html.Attribute msg)
    ->
        { color : Color.Color
        , strokeWidth : Rem
        , diameter : Rem
        , fragment : Lib.Ratio.Ratio
        }
    -> Svg msg
draw attributes circle =
    let
        radiant =
            circle.diameter |> divideBy 2

        totalWidth =
            circle.diameter
                |> add circle.strokeWidth

        -- The stroke spans both sides of the circle, hence the center
        center =
            circle.strokeWidth
                |> divideBy 2
                |> add radiant

        perimeter =
            radiant
                |> multiplyBy 2
                |> multiplyBy pi
    in
    Svg.svg
        ([ SvgAttr.width <| toCssString totalWidth
         , SvgAttr.height <| toCssString totalWidth
         ]
            ++ attributes
        )
        [ Svg.circle
            [ SvgAttr.cx <| UI.Rem.toCssString center
            , SvgAttr.cy <| UI.Rem.toCssString center
            , SvgAttr.r <| UI.Rem.toCssString radiant
            , SvgAttr.stroke <| Color.toCssString circle.color
            , SvgAttr.strokeWidth <| UI.Rem.toCssString circle.strokeWidth
            , SvgAttr.fillOpacity "0"
            , SvgAttr.strokeDasharray <| UI.Rem.toCssString perimeter
            , SvgAttr.strokeDashoffset <|
                UI.Rem.toCssString <|
                    UI.Rem.multiplyRatio
                        circle.fragment
                        perimeter
            ]
            []
        ]
