module UI.Typography.Typography exposing (fontSize, l, m, s, xl, xs)

import Css
import UI.Size as Size


scaled : Int -> Float
scaled scale =
    0.6 * (1.3 ^ toFloat scale) |> (*) 10 |> round |> (\x -> toFloat x / 10)


xs : Size.Size
xs =
    Size.rem <| scaled 0


s : Size.Size
s =
    Size.rem <| scaled 1


m : Size.Size
m =
    Size.rem <| scaled 2


l : Size.Size
l =
    Size.rem <| scaled 3


xl : Size.Size
xl =
    Size.rem <| scaled 4


fontSize : Size.Size -> Css.Style
fontSize =
    Css.fontSize << Size.toElmCss
