module UI.Typography.Typography exposing (fontSize, l, m, s, xl, xs)

import Css
import UI.Rem as Rem


scaled : Int -> Float
scaled scale =
    0.6 * (1.3 ^ toFloat scale) |> (*) 10 |> round |> (\x -> toFloat x / 10)


xs : Rem.Rem
xs =
    Rem.Rem <| scaled 0


s : Rem.Rem
s =
    Rem.Rem <| scaled 1


m : Rem.Rem
m =
    Rem.Rem <| scaled 2


l : Rem.Rem
l =
    Rem.Rem <| scaled 3


xl : Rem.Rem
xl =
    Rem.Rem <| scaled 4


fontSize : Rem.Rem -> Css.Style
fontSize =
    Css.fontSize << Rem.toElmCss
