module Lib.Delay exposing (after)

import Lib.Duration
import Process
import Task


after : Lib.Duration.Duration -> msg -> Cmd msg
after delay msg =
    Lib.Duration.toMillis delay
        |> toFloat
        |> Process.sleep
        |> Task.perform (always msg)
