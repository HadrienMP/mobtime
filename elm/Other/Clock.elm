module Clock exposing (..)

import Graphics.Circle
import Ratio exposing (Ratio)
import Svg exposing (Svg)


type State
    = Off
    | On { timeLeft : Int, length : Int }


view : Graphics.Circle.Circle -> State -> List (Svg msg)
view mobCircle turn =
    Graphics.Circle.draw mobCircle (ratio turn)


ratio : State -> Ratio
ratio state =
    case state of
        On on ->
            (1 - (toFloat (on.timeLeft - 1) / (toFloat on.length * 60)))
                |> Debug.log ""
                |> Ratio.from

        Off ->
            Ratio.full
