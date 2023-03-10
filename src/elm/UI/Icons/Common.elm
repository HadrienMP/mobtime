module UI.Icons.Common exposing (Icon)

import Svg.Styled exposing (Svg)
import UI.Color exposing (RGBA255)
import UI.Size exposing (Size)


type alias Icon msg =
    { size : Size, color : RGBA255 } -> Svg msg
