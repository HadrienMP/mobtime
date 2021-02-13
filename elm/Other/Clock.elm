module Other.Clock exposing (..)

import Graphics.Circle
import Lib.Duration as Duration exposing (Duration)
import Lib.Ratio as Ratio exposing (Ratio)
import Svg exposing (Svg)

type Event
    = Finished
    | TimePassed

type State
    = Off
    | On { timeLeft : Duration, length : Duration }


start : Duration -> State
start duration =
    On { timeLeft = duration, length = duration }


timePassed : State -> Duration -> (State, Event)
timePassed state duration =
    case state of
        Off ->
            (state, TimePassed)

        On on ->
            let
                timeLeft =
                    Duration.subtract on.timeLeft duration
            in
            if Duration.toSeconds timeLeft <= 0 then
                (Off, Finished)

            else
                (On { on | timeLeft = timeLeft }, TimePassed)


view : Graphics.Circle.Circle -> State -> List (Svg msg)
view mobCircle turn =
    Graphics.Circle.draw mobCircle (ratio turn)


ratio : State -> Ratio
ratio state =
    case state of
        On on ->
            Duration.div on.timeLeft on.length
                |> (-) 1
                |> Ratio.from

        Off ->
            Ratio.full
