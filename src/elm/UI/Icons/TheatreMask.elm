module UI.Icons.TheatreMask exposing (display)

import Svg.Styled as Svg exposing (Svg, svg)
import Svg.Styled.Attributes as SvgAttr
import UI.Color as Color exposing (RGBA255)
import UI.Size as Size exposing (Size)


display : { size : Size, color : RGBA255 } -> Svg msg
display { size, color } =
    svg
        [ SvgAttr.fill <| Color.toCss color
        , SvgAttr.height <| Size.toCssString size
        , SvgAttr.version "1.1"
        , SvgAttr.viewBox "0 0 512 512"
        , SvgAttr.xmlSpace "preserve"
        ]
        [ Svg.g []
            [ Svg.g []
                [ Svg.path
                    [ SvgAttr.d "M304.762,109.714H36.571C16.374,109.714,0,126.089,0,146.286v182.857C0,423.4,76.41,499.81,170.667,499.81\n\t\t\ts170.667-76.41,170.667-170.667V146.286C341.333,126.089,324.959,109.714,304.762,109.714z M170.667,444.952\n\t\t\tc-47.414,0-89.552-28.409-107.355-72.375l33.898-13.726c12.182,30.089,41.017,49.53,73.457,49.53s61.275-19.441,73.459-49.53\n\t\t\tl33.898,13.726C260.219,416.544,218.08,444.952,170.667,444.952z"
                    ]
                    []
                ]
            ]
        , Svg.g []
            [ Svg.g []
                [ Svg.path
                    [ SvgAttr.d "M475.429,12.19h-268.19c-20.197,0-36.571,16.374-36.571,36.571v24.381h134.095c40.331,0,73.143,32.812,73.143,73.143\n\t\t\tv97.302c31.671,10.462,57.779,34.302,70.813,66.504l-33.9,13.722c-7.279-17.982-20.513-32.156-36.913-40.655v45.985\n\t\t\tc0,25.107-4.491,49.184-12.707,71.474C448.155,389.007,512,317.776,512,231.619V48.762C512,28.565,495.626,12.19,475.429,12.19z"
                    ]
                    []
                ]
            ]
        ]
