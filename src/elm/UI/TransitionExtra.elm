module UI.TransitionExtra exposing (..)

import Css
import Lib.Duration


dashoffset : Lib.Duration.Duration -> Css.Style
dashoffset speed =
    Css.property "transition"
        ("stroke-dashoffset "
            ++ (speed
                    |> Lib.Duration.toMillis
                    |> String.fromInt
               )
            ++ "ms linear"
        )
