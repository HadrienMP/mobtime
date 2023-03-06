module UI.Typography.Typography exposing (l, m, s, xl, xs)

import Css


scaled : Int -> Float
scaled scale =
    0.6 * (1.3 ^ toFloat scale) |> (*) 10 |> round |> (\x -> toFloat x / 10)


xs : Css.Style
xs =
    Css.fontSize <| Css.rem <| scaled 0


s : Css.Style
s =
    Css.fontSize <| Css.rem <| scaled 1


m : Css.Style
m =
    Css.fontSize <| Css.rem <| scaled 2


l : Css.Style
l =
    Css.fontSize <| Css.rem <| scaled 3


xl : Css.Style
xl =
    Css.fontSize <| Css.rem <| scaled 4
