module UI.Rem exposing (..)

import Css
import Lib.Ratio


type Rem
    = Rem Float


open : Rem -> Float
open (Rem raw) =
    raw


divideBy : Float -> Rem -> Rem
divideBy divider rem =
    rem
        |> open
        |> (\numerator -> numerator / divider)
        |> Rem


multiplyBy : Float -> Rem -> Rem
multiplyBy multiplier rem =
    rem
        |> open
        |> (\numerator -> numerator * multiplier)
        |> Rem


multiplyRatio : Lib.Ratio.Ratio -> Rem -> Rem
multiplyRatio ratio rem =
    rem
        |> open
        |> Lib.Ratio.apply ratio
        |> Rem


add : Rem -> Rem -> Rem
add a b =
    open a + open b |> Rem


subtract : Rem -> Rem -> Rem
subtract b a =
    open a - open b |> Rem


toCssString : Rem -> String
toCssString rem =
    (open rem |> String.fromFloat) ++ "rem"


toElmCss : Rem -> Css.Rem
toElmCss rem =
    open rem |> Css.rem


toPixelsFake : Rem -> Int
toPixelsFake rem =
    open rem |> (*) 12 |> round