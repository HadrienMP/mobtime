module Other.Clock exposing (..)

import Graphics.Circle
import Lib.Duration exposing (Duration)
import Lib.Ratio as Ratio exposing (Ratio)
import Svg exposing (Svg)


type State
    = Off
    | On { timeLeft : Duration, length : Duration }


view : Graphics.Circle.Circle -> State -> List (Svg msg)
view mobCircle turn =
    Graphics.Circle.draw mobCircle (ratio turn)


finished : State -> Bool
finished state =
    case state of
        Off -> True
        On on -> Lib.Duration.toSeconds on.timeLeft <= 1

ratio : State -> Ratio
ratio state =
    case state of
        On on ->
            Lib.Duration.div on.timeLeft on.length
            |> (-) 1
            |> Ratio.from

        Off ->
            Ratio.full
