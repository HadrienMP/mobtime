module UI.Icons.Common exposing (Icon)

import Svg.Styled exposing (Svg)
import UI.Color exposing (RGBA255)
import UI.Rem exposing (Rem)


type alias Icon msg =
    { size : Rem, color : RGBA255 } -> Svg msg
