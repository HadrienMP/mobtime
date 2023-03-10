module UI.Icons.Tape exposing (display)

import Svg.Styled as Svg exposing (path, svg)
import Svg.Styled.Attributes as SvgAttr
import UI.Color as Color
import UI.Icons.Common exposing (Icon)
import UI.Size as Size


display : Icon msg
display { size, color } =
    svg
        [ SvgAttr.height <| String.fromFloat <| Size.toPixels size
        , SvgAttr.version "1.1"
        , SvgAttr.viewBox "0 0 109 78"
        ]
        [ Svg.g
            [ SvgAttr.stroke <| Color.toCss color
            ]
            [ path
                [ SvgAttr.d "m30.639 60.301 47.045-0.0881 8.1914 15.502h-63.427zm-25.328-58.166h97.696c1.7601 0 3.177 1.6378 3.177 3.6722v66.196c0 2.0344-1.4169 3.6721-3.177 3.6721h-97.696c-1.7601 0-3.177-1.6378-3.177-3.6721v-66.196c0-2.0344 1.4169-3.6722 3.177-3.6722z"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth "4.269"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "8.0724"
                , SvgAttr.cy "7.4835"
                , SvgAttr.r ".71182"
                , SvgAttr.strokeWidth "1.5415"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "100.25"
                , SvgAttr.cy "7.4835"
                , SvgAttr.r ".71182"
                , SvgAttr.strokeWidth "1.5415"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "7.9279"
                , SvgAttr.cy "70.532"
                , SvgAttr.r ".71182"
                , SvgAttr.strokeWidth "1.5415"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "100.1"
                , SvgAttr.cy "70.532"
                , SvgAttr.r ".71182"
                , SvgAttr.strokeWidth "1.5415"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "31.522"
                , SvgAttr.cy "35.22"
                , SvgAttr.r "7.9478"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth "2.6972"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "76.797"
                , SvgAttr.cy "35.22"
                , SvgAttr.r "7.9478"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth "2.6972"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , Svg.rect
                [ SvgAttr.x "22.916"
                , SvgAttr.y "26.641"
                , SvgAttr.width "62.37"
                , SvgAttr.height "16.978"
                , SvgAttr.rx "8.8475"
                , SvgAttr.ry "8.489"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth "2.569"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , path
                [ SvgAttr.d "m39.607 26.641a11.789 11.789 0 0 1 3.7039 8.5796 11.789 11.789 0 0 1-3.5282 8.4105"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth ".97485"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , path
                [ SvgAttr.d "m68.537 43.631a11.789 11.789 0 0 1-3.5282-8.4105 11.789 11.789 0 0 1 3.7112-8.5865"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth ".97485"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , path
                [ SvgAttr.d "m43.627 26.64a14.838 14.838 0 0 1 2.7323 8.58 14.838 14.838 0 0 1-2.6122 8.408"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth ".927"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , path
                [ SvgAttr.d "m64.572 43.628a14.838 14.838 0 0 1-2.6123-8.4081 14.838 14.838 0 0 1 2.7371-8.5868"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth ".927"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , path
                [ SvgAttr.d "m47.01 26.64a17.559 17.559 0 0 1 2.2601 8.6175 17.559 17.559 0 0 1-2.1223 8.3682"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth ".897"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , path
                [ SvgAttr.d "m50.317 26.641a20.478 20.478 0 0 1 1.8727 8.5552 20.478 20.478 0 0 1-1.8154 8.4293"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth ".946"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , path
                [ SvgAttr.d "m53.63 26.641a23.495 23.495 0 0 1 1.5768 8.4623 23.495 23.495 0 0 1-1.5982 8.5175"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth "1.0854"
                , SvgAttr.style "paint-order:normal"
                ]
                []
            , Svg.g
                [ SvgAttr.transform "rotate(30 23.622 33.104)"
                , SvgAttr.strokeWidth ".96343"
                ]
                [ Svg.rect
                    [ SvgAttr.x "30.803"
                    , SvgAttr.y "34.909"
                    , SvgAttr.width "1.4378"
                    , SvgAttr.height "4.8923"
                    , SvgAttr.style "paint-order:normal"
                    ]
                    []
                , Svg.rect
                    [ SvgAttr.x "30.803"
                    , SvgAttr.y "22.172"
                    , SvgAttr.width "1.4378"
                    , SvgAttr.height "4.8923"
                    , SvgAttr.style "paint-order:normal"
                    ]
                    []
                , Svg.rect
                    [ SvgAttr.transform "rotate(90)"
                    , SvgAttr.x "30.268"
                    , SvgAttr.y "-27.599"
                    , SvgAttr.width "1.4378"
                    , SvgAttr.height "4.8923"
                    , SvgAttr.style "paint-order:normal"
                    ]
                    []
                , Svg.rect
                    [ SvgAttr.transform "rotate(90)"
                    , SvgAttr.x "30.268"
                    , SvgAttr.y "-40.337"
                    , SvgAttr.width "1.4378"
                    , SvgAttr.height "4.8923"
                    , SvgAttr.style "paint-order:normal"
                    ]
                    []
                ]
            , Svg.g
                [ SvgAttr.transform "rotate(30 69.766 32.1)"
                , SvgAttr.strokeWidth ".96343"
                ]
                [ Svg.rect
                    [ SvgAttr.x "76.696"
                    , SvgAttr.y "35.209"
                    , SvgAttr.width "1.4378"
                    , SvgAttr.height "4.8923"
                    , SvgAttr.style "paint-order:normal"
                    ]
                    []
                , Svg.rect
                    [ SvgAttr.x "76.696"
                    , SvgAttr.y "22.472"
                    , SvgAttr.width "1.4378"
                    , SvgAttr.height "4.8923"
                    , SvgAttr.style "paint-order:normal"
                    ]
                    []
                , Svg.rect
                    [ SvgAttr.transform "rotate(90)"
                    , SvgAttr.x "30.568"
                    , SvgAttr.y "-73.493"
                    , SvgAttr.width "1.4378"
                    , SvgAttr.height "4.8923"
                    , SvgAttr.style "paint-order:normal"
                    ]
                    []
                , Svg.rect
                    [ SvgAttr.transform "rotate(90)"
                    , SvgAttr.x "30.568"
                    , SvgAttr.y "-86.23"
                    , SvgAttr.width "1.4378"
                    , SvgAttr.height "4.8923"
                    , SvgAttr.style "paint-order:normal"
                    ]
                    []
                ]
            , path
                [ SvgAttr.d "m16.179 9.1955h75.555l6.6785 7.1717v39.13h-88.282v-39.512z"
                , SvgAttr.fill "none"
                , SvgAttr.strokeWidth "2"
                ]
                []
            ]
        ]
