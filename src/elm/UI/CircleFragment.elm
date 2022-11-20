module UI.CircleFragment exposing (..)

import Html.Styled as Html
import Lib.Ratio
import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes as SvgAttr
import UI.Color
import UI.Rem exposing (..)


draw :
    { color : UI.Color.RGBA255
    , strokeWidth : Rem
    , diameter : Rem
    , fragment : Lib.Ratio.Ratio
    , background : UI.Color.RGBA255
    , svgAttr : List (Html.Attribute msg)
    , circleAttr : List (Html.Attribute msg)
    }
    -> Svg msg
draw circle =
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
            ++ circle.svgAttr
        )
        [ Svg.circle
            [ SvgAttr.cx <| UI.Rem.toCssString center
            , SvgAttr.cy <| UI.Rem.toCssString center
            , SvgAttr.r <| UI.Rem.toCssString radiant
            , SvgAttr.stroke <| UI.Color.toCss circle.background
            , SvgAttr.strokeWidth <| UI.Rem.toCssString circle.strokeWidth
            , SvgAttr.fillOpacity "0"
            ]
            []
        , Svg.circle
            ([ SvgAttr.cx <| UI.Rem.toCssString center
             , SvgAttr.cy <| UI.Rem.toCssString center
             , SvgAttr.r <| UI.Rem.toCssString radiant
             , SvgAttr.stroke <| UI.Color.toCss circle.color
             , SvgAttr.strokeWidth <| UI.Rem.toCssString circle.strokeWidth
             , SvgAttr.fillOpacity "0"
             , SvgAttr.strokeDasharray <| UI.Rem.toCssString perimeter
             , SvgAttr.strokeDashoffset <|
                UI.Rem.toCssString <|
                    UI.Rem.multiplyRatio
                        circle.fragment
                        perimeter
             ]
                ++ circle.circleAttr
            )
            []
        ]
