module UI.Icons.Tea exposing (display)

import Svg.Styled as Svg exposing (Svg, path, svg)
import Svg.Styled.Attributes as SvgAttr
import UI.Color as Color exposing (RGBA255)
import UI.Size as Size exposing (Size)


display : { size : Size, color : RGBA255 } -> Svg msg
display { size, color } =
    svg
        [ SvgAttr.height <| Size.toCssString size
        , SvgAttr.version "1.1"
        , SvgAttr.viewBox "0 0 1269.754 1708.2892"
        ]
        [ Svg.g
            [ SvgAttr.stroke <| Color.toCss color
            ]
            [ path
                [ SvgAttr.d "m43.104 1092.8l985.16-14.377c5.26 208.34-128.61 446.76-226.91 491.33-46.882 21.253-360.06 23.754-433.19 6.8761-211.86-48.891-312.74-226.25-325.05-483.83z"
                , SvgAttr.fill "none"
                , SvgAttr.strokeMiterlimit "10"
                , SvgAttr.strokeWidth "18.753"
                ]
                []
            , path
                [ SvgAttr.d "m368.16 1576.6c-9.0892 8.8455-15.663 18.287-19.945 28.298-4.6635 10.903 1.7946 23.372 13.417 25.725 147.56 29.877 294.84 33.16 441.73-1.0442 8.5941-2.0013 14.686-9.7212 14.488-18.543-0.3083-13.742-6.2108-27.514-16.492-41.312"
                , SvgAttr.fill "none"
                , SvgAttr.strokeMiterlimit "10"
                , SvgAttr.strokeWidth "18.753"
                ]
                []
            , path
                [ SvgAttr.d "m325.14 1500.3c-4.207-5.2076 0.0296-12.886 6.6766-12.088 189.47 22.752 305.46 1.4133 387.02-42.253 121.15-64.862 197.62-167.33 232.67-302.37 0.4037-1.5557 2.7057-1.2213 2.6433 0.3846-7.0149 180.56-95.042 350.18-193.43 380.12-148.68 45.252-392.49 29.546-435.58-23.797z"
                ]
                []
            , path
                [ SvgAttr.d "m1024.8 1151.6c46.873-51.494 106.86-76.407 162.91-41.91 57.586 35.44 44.023 154.58 10.627 181.9-27.504 22.504-103.65 21.702-138.77 60.635-22.197 24.608 0 63.135-3.7506 78.138-7.048 28.191-73.84 22.731-85.013-12.502-5.2479-16.548-1e-4 -69.442-1e-4 -69.442"
                , SvgAttr.fill "none"
                , SvgAttr.strokeMiterlimit "10"
                , SvgAttr.strokeWidth "18.753"
                ]
                []
            , path
                [ SvgAttr.d "m1006.3 1246.4c17.542-5.775 31.501-28.737 57.557-53.58 25.938-24.731 74.139-35.377 96.89-5.6259 16.253 21.253-10.702 66.477-47.507 82.513-61.61 26.844-111.56 57.393-144.32 103.61"
                , SvgAttr.fill "none"
                , SvgAttr.strokeMiterlimit "10"
                , SvgAttr.strokeWidth "18.753"
                ]
                []
            , path
                [ SvgAttr.d "m153.13 1091.2c1.4202 22.78 10.737 45.633 16.249 71.617 8.7514 41.257-50.289 82.034-8.1243 126.9 20.232 21.526 59.178 25.478 69.384 0 18.095-45.172-28.129-93.14 0-120.58 21.661-21.13 56.884 12.437 55.009 39.316-4.6844 37.372 24.379 61.885 52.508 36.256 16.093-14.663 24.721-45.49 18.753-68.761-6.8083-18.078-6.6949-31.402 10.002-33.337 32.099-3.1681 40.854 11.485 49.383 36.462 8.7515 25.629 55.634 10.627 57.509-9.9368 3.2484-35.618-13.752-56.949 33.15-83.096"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "221.88"
                , SvgAttr.cy "1376.6"
                , SvgAttr.r "26.879"
                , SvgAttr.fill "none"
                , SvgAttr.strokeMiterlimit "10"
                , SvgAttr.strokeWidth "9.3765"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "352.53"
                , SvgAttr.cy "1329.7"
                , SvgAttr.r "37.506"
                , SvgAttr.fill "none"
                , SvgAttr.strokeMiterlimit "10"
                , SvgAttr.strokeWidth "13.084"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "278.14"
                , SvgAttr.cy "1313.4"
                , SvgAttr.r "11.877"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "430.67"
                , SvgAttr.cy "1037.1"
                , SvgAttr.r "11.877"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "494.43"
                , SvgAttr.cy "1037.8"
                , SvgAttr.r "10.002"
                ]
                []
            , Svg.circle
                [ SvgAttr.cx "533.18"
                , SvgAttr.cy "1028.4"
                , SvgAttr.r "8.7514"
                ]
                []
            , path
                [ SvgAttr.d "m470.36 1002.3c90.014-97.516 47.82-203-34.693-222.22-144.98-33.774-262.07-104.08-285.98-238.16-28.554-160.13 74.54-268.19 182.37-282.23 100.8-13.127 187.76 29.862 216.6 123.77 32.09 104.5 2.952 172.81-87.67 202.06-113.88 36.76-206.75-9.3765-218-84.388-12.334-82.228 68.068-140.91 118.14-143.93 77.825-4.6883 107.36 68.448 84.388 98.922-31.863 42.268-105.02 42.663-111.58 21.566-4.9552-15.927 16.679-25.772 33.286-27.192"
                , SvgAttr.fill "none"
                , SvgAttr.stroke "#010101"
                , SvgAttr.strokeLinecap "round"
                , SvgAttr.strokeMiterlimit "10"
                , SvgAttr.strokeWidth "18.753"
                ]
                []
            , path
                [ SvgAttr.d "m610.07 998.39s207.53-110.64-43.132-379.44"
                , SvgAttr.fill "none"
                , SvgAttr.stroke "#010101"
                , SvgAttr.strokeLinecap "round"
                , SvgAttr.strokeMiterlimit "10"
                , SvgAttr.strokeWidth "18.753"
                ]
                []
            , path
                [ SvgAttr.d "m476.3 257.37c4.0106-109.57 53.019-182.63 141.9-199.13 104.39-19.378 225.75 32.082 243.79 110.64 21.347 92.99-5.9852 153.47-96.728 181.28-21.205 6.4995-45.404 1.8124-62.048 13.752-28.754 20.628-70.618 124.25-60.01 199.41 8.0314 56.904 60.42 105.48 99.391 171.28 48.133 81.263 18.562 232.97-78.763 274.42"
                , SvgAttr.fill "none"
                , SvgAttr.stroke "#010101"
                , SvgAttr.strokeLinecap "round"
                , SvgAttr.strokeMiterlimit "10"
                , SvgAttr.strokeWidth "18.753"
                ]
                []
            , path
                [ SvgAttr.d "m703.21 363.91c-91.89-4.3756-142.27-52.591-127.52-114.39 19.057-79.86 91.264-120.64 143.77-106.27 71.198 19.495 86.889 97.516 36.256 125.64-64.741 35.967-105.02-5.0007-86.576-33.755 11.046-17.224 37.084-14.352 60.947-6.876"
                , SvgAttr.fill "none"
                , SvgAttr.stroke "#010101"
                , SvgAttr.strokeLinecap "round"
                , SvgAttr.strokeMiterlimit "10"
                , SvgAttr.strokeWidth "18.753"
                ]
                []
            ]
        ]
