module UI.Icons.Plugs exposing (off)

import Svg.Styled as Svg exposing (Svg, path, svg)
import Svg.Styled.Attributes as SvgAttr
import UI.Color as Color exposing (RGBA255)
import UI.Size as Size exposing (Size)


off : { height : Size, color : RGBA255 } -> Svg msg
off { height, color } =
    svg
        [ SvgAttr.height <| Size.toCssString height
        , SvgAttr.version "1.1"
        , SvgAttr.viewBox "0 0 60 60"
        ]
        [ Svg.g
            [ SvgAttr.transform "translate(-62.424 -116.07)"
            , SvgAttr.stroke <| Color.toCss color
            ]
            [ Svg.g
                [ SvgAttr.transform "rotate(45 92.429 146.24)"
                ]
                [ path
                    [ SvgAttr.d "m75.39 135.54h34.11c0.38449 0 0.69402 0.21886 0.69402 0.49072v0.0682c0 0.27185-0.30953 0.49072-0.69402 0.49072h-34.11c-0.38449 0-0.69403-0.21887-0.69403-0.49072v-0.0682c0-0.27186 0.30954-0.49072 0.69403-0.49072z"
                    , SvgAttr.strokeWidth "4.152"
                    ]
                    []
                , path
                    [ SvgAttr.d "m91.809 116.2v-8.9898c0-0.10134 0.20965-0.18291 0.47008-0.18291h0.06536c0.26042 0 0.47008 0.0816 0.47008 0.18291v8.9898c0 0.10134-0.20966 0.18291-0.47008 0.18291h-0.06536c-0.26043 0-0.47008-0.0816-0.47008-0.18291z"
                    , SvgAttr.strokeWidth "4.2134"
                    ]
                    []
                , Svg.g
                    [ SvgAttr.transform "translate(.29125)"
                    , SvgAttr.strokeWidth "4.2134"
                    ]
                    [ path
                        [ SvgAttr.d "m86.201 145.18v-8.9898c0-0.10134 0.20966-0.18291 0.47008-0.18291h0.0654c0.26042 0 0.47008 0.0816 0.47008 0.18291v8.9898c0 0.10134-0.20966 0.18291-0.47008 0.18291h-0.0654c-0.26042 0-0.47008-0.0816-0.47008-0.18291z"
                        ]
                        []
                    , path
                        [ SvgAttr.d "m96.834 145.18v-8.9898c0-0.10134 0.20966-0.18291 0.47008-0.18291h0.0654c0.26042 0 0.47008 0.0816 0.47008 0.18291v8.9898c0 0.10134-0.20966 0.18291-0.47008 0.18291h-0.0654c-0.26042 0-0.47008-0.0816-0.47008-0.18291z"
                        ]
                        []
                    ]
                , path
                    [ SvgAttr.d "m78.917 136.59v-4.4989c0-7.4203 5.9738-13.394 13.394-13.394s13.394 5.9738 13.394 13.394v4.4989"
                    , SvgAttr.fill "none"
                    , SvgAttr.strokeWidth "5.1"
                    ]
                    []
                ]
            , Svg.g
                [ SvgAttr.transform "rotate(45 38.11 142.81)"
                ]
                [ path
                    [ SvgAttr.d "m95.988 117.54h-34.11c-0.38449 0-0.69403-0.21886-0.69403-0.49072v-0.0682c0-0.27186 0.30954-0.49073 0.69403-0.49073h34.11c0.38449 0 0.69403 0.21887 0.69403 0.49073v0.0682c0 0.27186-0.30954 0.49072-0.69403 0.49072z"
                    , SvgAttr.strokeWidth "4.152"
                    ]
                    []
                , path
                    [ SvgAttr.d "m79.569 136.87v8.9898c0 0.10134-0.20966 0.18291-0.47008 0.18291h-0.0654c-0.26042 0-0.47008-0.0816-0.47008-0.18291v-8.9898c0-0.10134 0.20966-0.18291 0.47008-0.18291h0.0654c0.26042 0 0.47008 0.0816 0.47008 0.18291z"
                    , SvgAttr.strokeWidth "4.2134"
                    ]
                    []
                , path
                    [ SvgAttr.d "m92.46 116.49v4.4989c0 7.4203-5.9738 13.394-13.394 13.394-7.4203 0-13.394-5.9738-13.394-13.394l1e-5 -4.4989"
                    , SvgAttr.fill "none"
                    , SvgAttr.strokeWidth "5.1"
                    ]
                    []
                ]
            ]
        ]
