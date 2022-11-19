module UI.Circle exposing (Circle, Coordinates, Stroke, draw)

import Color
import Css
import Lib.Duration
import Lib.Ratio as Ratio exposing (Ratio)
import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes
    exposing
        ( css
        , cx
        , cy
        , fillOpacity
        , r
        , stroke
        , strokeDasharray
        , strokeDashoffset
        , strokeWidth
        )
import UI.Rem exposing (..)


type alias Coordinates =
    { x : Rem
    , y : Rem
    }


type alias Circle =
    { radiant : Rem
    , center : Coordinates
    , stroke : Stroke
    , refreshRate : Lib.Duration.Duration
    }


type alias Stroke =
    { width : Rem
    , color : Color.Color
    }


draw : Circle -> Ratio -> List (Svg msg)
draw circle ratio =
    draw_ circle ratio |> List.singleton



--
-- DRAW
--


draw_ : Circle -> Ratio -> Svg msg
draw_ circle ratio =
    let
        perimeter =
            circle.radiant
                |> multiply (toFloat 2)
                |> multiply pi
    in
    Svg.circle
        [ cx <| UI.Rem.toCssString circle.center.x
        , cy <| UI.Rem.toCssString circle.center.y
        , r <| UI.Rem.toCssString circle.radiant
        , stroke <| Color.toCssString circle.stroke.color
        , strokeWidth <| UI.Rem.toCssString circle.stroke.width
        , fillOpacity "0"
        , strokeDasharray <| UI.Rem.toCssString perimeter
        , strokeDashoffset <| (String.fromFloat <| Ratio.apply ratio (UI.Rem.open perimeter)) ++ "rem"
        , css
            [ Css.property "transition"
                ("stroke-dashoffset "
                    ++ (circle.refreshRate
                            |> Lib.Duration.toMillis
                            |> String.fromInt
                       )
                    ++ "ms linear"
                )
            ]
        ]
        []
