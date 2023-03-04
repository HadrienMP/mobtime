module UI.Circle exposing
    ( Circle
    , CircleBorder
    , ConcentricCircles
    , addBackground
    , addBorders
    , buildFragment
    , draw
    , withAttributes
    )

import Html.Styled as Html
import Lib.Ratio
import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes as SvgAttr
import UI.Color
import UI.Rem as Rem exposing (Rem)



--
-- Build
--


type alias Circle msg =
    { color : UI.Color.RGBA255
    , strokeWidth : Rem
    , radiant : Rem
    , attributes : List (Html.Attribute msg)
    }


type alias CircleBorder =
    { color : UI.Color.RGBA255
    , width : Rem
    }


type alias ConcentricCircles msg =
    { main : Circle msg
    , fragment : Maybe Lib.Ratio.Ratio
    , outerBorder : Maybe (Circle msg)
    , innerBorder : Maybe (Circle msg)
    , background : Maybe (Circle msg)
    , size : Rem
    , center : Rem
    }


buildFragment :
    { color : UI.Color.RGBA255
    , strokeWidth : Rem
    , diameter : Rem
    , fragment : Lib.Ratio.Ratio
    }
    -> ConcentricCircles msg
buildFragment circle =
    let
        { radiant, center } =
            drawingDimensions circle
    in
    { main =
        { color = circle.color
        , strokeWidth = circle.strokeWidth
        , radiant = radiant
        , attributes = []
        }
    , fragment = Just circle.fragment
    , center = center
    , size = circle.diameter
    , outerBorder = Nothing
    , innerBorder = Nothing
    , background = Nothing
    }


withAttributes : List (Html.Attribute msg) -> ConcentricCircles msg -> ConcentricCircles msg
withAttributes attributes builder =
    let
        main =
            builder.main
    in
    { builder | main = { main | attributes = attributes } }


addBackground : UI.Color.RGBA255 -> ConcentricCircles msg -> ConcentricCircles msg
addBackground color builder =
    let
        main =
            builder.main
    in
    { builder | background = Just { main | color = color } }


addBorders : CircleBorder -> ConcentricCircles msg -> ConcentricCircles msg
addBorders border =
    addInnerBorder border >> addOuterBorder border


addInnerBorder : CircleBorder -> ConcentricCircles msg -> ConcentricCircles msg
addInnerBorder border builder =
    { builder
        | innerBorder =
            Just
                { color = border.color
                , strokeWidth = border.width
                , radiant =
                    builder.main.radiant
                        |> Rem.subtract (builder.main.strokeWidth |> Rem.divideBy 2)
                        |> Rem.subtract (border.width |> Rem.divideBy 2)
                , attributes = []
                }
    }


addOuterBorder : CircleBorder -> ConcentricCircles msg -> ConcentricCircles msg
addOuterBorder border builder =
    { builder
        | outerBorder =
            Just
                { color = border.color
                , strokeWidth = border.width
                , radiant =
                    builder.main.radiant
                        |> Rem.add (builder.main.strokeWidth |> Rem.divideBy 2)
                        |> Rem.add (border.width |> Rem.divideBy 2)
                , attributes = []
                }
        , size = builder.size |> Rem.add (border.width |> Rem.multiplyBy 2)
        , center = builder.center |> Rem.add border.width
    }



--
-- Draw
--


draw :
    List (Html.Attribute msg)
    -> ConcentricCircles msg
    -> Svg msg
draw attributes builder =
    Svg.svg
        ([ SvgAttr.width <| Rem.toCssString builder.size
         , SvgAttr.height <| Rem.toCssString builder.size
         ]
            ++ attributes
        )
        ((builder.background
            |> Maybe.map (drawCircle { fragment = Lib.Ratio.full, center = builder.center })
            |> Maybe.map List.singleton
            |> Maybe.withDefault []
         )
            ++ [ drawCircle
                    { fragment = builder.fragment |> Maybe.withDefault Lib.Ratio.full
                    , center = builder.center
                    }
                    builder.main
               ]
            ++ (builder.outerBorder
                    |> Maybe.map (drawCircle { fragment = Lib.Ratio.full, center = builder.center })
                    |> Maybe.map List.singleton
                    |> Maybe.withDefault []
               )
            ++ (builder.innerBorder
                    |> Maybe.map (drawCircle { fragment = Lib.Ratio.full, center = builder.center })
                    |> Maybe.map List.singleton
                    |> Maybe.withDefault []
               )
        )


drawCircle : { fragment : Lib.Ratio.Ratio, center : Rem } -> Circle msg -> Svg msg
drawCircle { fragment, center } circle =
    let
        perimeter =
            circle.radiant
                |> Rem.multiplyBy 2
                |> Rem.multiplyBy pi
    in
    Svg.circle
        ([ SvgAttr.cx <| Rem.toCssString center
         , SvgAttr.cy <| Rem.toCssString center
         , SvgAttr.r <| Rem.toCssString circle.radiant
         , SvgAttr.stroke <| UI.Color.toCss circle.color
         , SvgAttr.strokeWidth <| Rem.toCssString circle.strokeWidth
         , SvgAttr.fillOpacity "0"
         , SvgAttr.strokeDasharray <| Rem.toCssString perimeter
         , SvgAttr.strokeDashoffset <|
            Rem.toCssString <|
                Rem.multiplyRatio
                    fragment
                    perimeter
         ]
            ++ circle.attributes
        )
        []


drawingDimensions : { a | diameter : Rem, strokeWidth : Rem } -> { center : Rem, radiant : Rem }
drawingDimensions circle =
    let
        radiant =
            circle.diameter
                |> Rem.divideBy 2
                -- force the diameter to be the outside width
                |> Rem.subtract (circle.strokeWidth |> Rem.divideBy 2)

        -- The stroke spans both sides of the circle, hence the center
        center =
            circle.diameter |> Rem.divideBy 2
    in
    { radiant = radiant, center = center }
