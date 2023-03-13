module UI.Space exposing (m, s, spacer, xl, xs, xxl)

import Html.Styled as Html
import UI.Size as Size


spacer : Html.Html msg
spacer =
    Html.div [] []


scale : Int -> Float
scale value =
    6 * (1.5 ^ toFloat value)


xs : Size.Size
xs =
    scale 1 |> Size.px


s : Size.Size
s =
    scale 2 |> Size.px


m : Size.Size
m =
    scale 3 |> Size.px


xl : Size.Size
xl =
    scale 5 |> Size.px


xxl : Size.Size
xxl =
    scale 6 |> Size.px
