module Lib.Circle exposing (Circle, Coordinates, Stroke, draw, drawWithoutInsideBorder, inside)

import Html.Attributes as Html
import Lib.Ratio as Ratio exposing (Ratio)
import Svg exposing (Svg)
import Svg.Attributes as Svg


borderStroke : Stroke
borderStroke =
    Stroke 1 "#ddd"


type alias Coordinates =
    { x : Int
    , y : Int
    }


type alias Circle =
    { radiant : Int
    , center : Coordinates
    , stroke : Stroke
    }


type alias Stroke =
    { width : Int
    , color : String
    }


inside : Circle -> Stroke -> Circle
inside outer stroke =
    { radiant = outer.radiant - ceiling (toFloat outer.stroke.width / 2 + toFloat stroke.width / 2)
    , center = outer.center
    , stroke = stroke
    }


draw : Circle -> Ratio -> List (Svg msg)
draw circle ratio =
    circles circle ratio 2
        |> List.map (\( c, r ) -> draw_ c r)


drawWithoutInsideBorder : Circle -> Ratio -> List (Svg msg)
drawWithoutInsideBorder circle ratio =
    circles circle ratio 1
        |> List.take 3
        |> List.map (\( c, r ) -> draw_ c r)


circles : Circle -> Ratio -> Int -> List ( Circle, Ratio )
circles circle ratio nBorders =
    let
        outerBorder =
            { radiant = circle.radiant + circle.stroke.width // 2
            , center = circle.center
            , stroke = borderStroke
            }

        principalWidth =
            circle.stroke.width - nBorders * borderStroke.width

        principal =
            inside outerBorder <| Stroke principalWidth circle.stroke.color

        background =
            inside outerBorder (Stroke circle.stroke.width "#ccc")

        innerBorder =
            inside principal borderStroke
    in
    [ ( background, Ratio.full )
    , ( principal, ratio )
    , ( outerBorder, Ratio.full )
    , ( innerBorder, Ratio.full )
    ]



--
-- DRAW
--


draw_ : Circle -> Ratio -> Svg msg
draw_ circle ratio =
    let
        perimeter =
            2 * pi * toFloat circle.radiant
    in
    Svg.circle
        [ Svg.cx <| String.fromInt circle.center.x
        , Svg.cy <| String.fromInt circle.center.y
        , Svg.r <| String.fromInt circle.radiant
        , Svg.stroke circle.stroke.color
        , Svg.strokeWidth <| String.fromInt circle.stroke.width
        , Svg.fillOpacity "0"
        , Svg.strokeDasharray <| String.fromFloat perimeter
        , Html.style "stroke-dashoffset" <| String.fromFloat <| Ratio.apply ratio perimeter
        ]
        []
