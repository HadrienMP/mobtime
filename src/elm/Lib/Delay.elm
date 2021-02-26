module Lib.Delay exposing (Unit(..), after)

import Process
import Task

type Unit
    = Seconds Int

after : Unit -> msg -> Cmd msg
after delay msg =
    toMs delay
    |> Process.sleep
    |> Task.perform (always msg)

toMs : Unit -> Float
toMs unit =
    case unit of
        Seconds s -> s * 1000 |> toFloat
