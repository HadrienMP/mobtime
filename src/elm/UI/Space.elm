module UI.Space exposing (..)

import Css


scale : Int -> Float
scale value =
    6 * (1.5 ^ toFloat value)


xs : Css.Px
xs =
    scale 1 |> Css.px


s : Css.Px
s =
    scale 2 |> Css.px


m : Css.Px
m =
    scale 3 |> Css.px


l : Css.Px
l =
    scale 4 |> Css.px


xl : Css.Px
xl =
    scale 5 |> Css.px


xxl : Css.Px
xxl =
    scale 6 |> Css.px
