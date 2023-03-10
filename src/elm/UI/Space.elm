module UI.Space exposing (l, m, s, scale, spacer, xl, xs, xxl)

import Html.Styled as Html
import UI.Size


spacer : Html.Html msg
spacer =
    Html.div [] []


scale : Int -> Float
scale value =
    6 * (1.5 ^ toFloat value)


xs : UI.Size.Size
xs =
    scale 1 |> UI.Size.px


s : UI.Size.Size
s =
    scale 2 |> UI.Size.px


m : UI.Size.Size
m =
    scale 3 |> UI.Size.px


l : UI.Size.Size
l =
    scale 4 |> UI.Size.px


xl : UI.Size.Size
xl =
    scale 5 |> UI.Size.px


xxl : UI.Size.Size
xxl =
    scale 6 |> UI.Size.px
