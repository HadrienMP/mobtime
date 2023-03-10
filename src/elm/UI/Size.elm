module UI.Size exposing
    ( Size
    , add
    , divideBy
    , multiplyBy
    , multiplyRatio
    , px
    , rem
    , rootSizeAsPx
    , subtract
    , toCssString
    , toElmCss
    , toPixels
    )

import Css
import Lib.Ratio


rootSizeAsPx : Float
rootSizeAsPx =
    20


type Size
    = Rem Float
    | Px Float


rem : Float -> Size
rem =
    Rem


px : Float -> Size
px =
    Px


map : (Float -> Float) -> Size -> Size
map f size =
    case size of
        Rem value ->
            f value |> Rem

        Px value ->
            f value |> Px


divideBy : Float -> Size -> Size
divideBy divider size =
    size |> map (\numerator -> numerator / divider)


multiplyBy : Float -> Size -> Size
multiplyBy multiplier size =
    size |> map (\numerator -> numerator * multiplier)


multiplyRatio : Lib.Ratio.Ratio -> Size -> Size
multiplyRatio ratio size =
    size |> map (Lib.Ratio.apply ratio)


add : Size -> Size -> Size
add a b =
    toPixels a + toPixels b |> px


subtract : Size -> Size -> Size
subtract b a =
    toPixels a - toPixels b |> px


toCssString : Size -> String
toCssString size =
    case size of
        Rem value ->
            (value |> String.fromFloat) ++ "rem"

        Px value ->
            (value |> String.fromFloat) ++ "px"


toElmCss : Size -> Css.Px
toElmCss size =
    Css.px <| toPixels size


toPixels : Size -> Float
toPixels size =
    case size of
        Rem value ->
            value |> (*) rootSizeAsPx

        Px value ->
            value
