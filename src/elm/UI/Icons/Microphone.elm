module UI.Icons.Microphone exposing (display)

import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes as SvgAttr
import UI.Color as Color exposing (RGBA255)
import UI.Size as Size exposing (Size)


display : { size : Size, color : RGBA255 } -> Svg msg
display { size, color } =
    Svg.svg
        [ SvgAttr.height <| Size.toCssString size
        , SvgAttr.viewBox "10 0 44 64"
        , SvgAttr.xmlSpace "preserve"
        ]
        [ Svg.g []
            [ Svg.path
                [ SvgAttr.fill <| Color.toCss color
                , SvgAttr.d "M32,48c7.732,0,14-6.268,14-14V14c0-7.732-6.268-14-14-14S18,6.268,18,14v20C18,41.732,24.268,48,32,48z\n\t\t M20,31h5c0.553,0,1-0.447,1-1s-0.447-1-1-1h-5v-4h5c0.553,0,1-0.447,1-1s-0.447-1-1-1h-5v-4h5c0.553,0,1-0.447,1-1s-0.447-1-1-1\n\t\th-5v-3c0-6.627,5.373-12,12-12s12,5.373,12,12v3h-5c-0.553,0-1,0.447-1,1s0.447,1,1,1h5v4h-5c-0.553,0-1,0.447-1,1s0.447,1,1,1h5v4\n\t\th-5c-0.553,0-1,0.447-1,1s0.447,1,1,1h5v3c0,6.627-5.373,12-12,12s-12-5.373-12-12V31z"
                ]
                []
            , Svg.path
                [ SvgAttr.fill <| Color.toCss color
                , SvgAttr.d "M51,31.002c-1.657,0-2.999,1.342-3,2.998c-0.001,8.838-7.163,15.999-16,15.999S16.001,42.838,16,34\n\t\tc0-1.656-1.343-3-3-3s-3,1.344-3,3c0,10.43,7.26,19.157,17,21.423v4.576c0,2.209,1.791,4,4,4h2c2.209,0,4-1.791,4-4v-4.576\n\t\tC46.74,53.157,54,44.43,54,34C53.999,32.344,52.657,31.002,51,31.002z M37,53.345c-0.654,0.168-1.321,0.304-2,0.407v6.247\n\t\tc0,1.104-0.896,2-2,2h-2c-1.104,0-2-0.896-2-2v-6.247c-0.679-0.104-1.346-0.239-2-0.407C18.379,51.121,12,43.315,12,34\n\t\tc0-0.553,0.447-1,1-1s1,0.447,1,1c0.001,9.94,8.059,17.999,18,17.999S49.999,43.94,50,34c0.001-0.551,0.447-0.998,1-0.998\n\t\ts0.999,0.447,1,0.998C52,43.315,45.621,51.121,37,53.345z"
                ]
                []
            ]
        ]
