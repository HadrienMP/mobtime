module Clock.TurnClock exposing (..)

import Clock.Clock exposing (ClockState(..))
import Js.Commands
import Time


timePassed : Time.Posix -> ClockState -> ( ClockState, Cmd msg )
timePassed now clockState =
    Clock.Clock.timePassed now clockState
        |> Tuple.mapSecond
            (\event ->
                case event of
                    Clock.Clock.Ended ->
                        Js.Commands.send Js.Commands.SoundAlarm

                    Clock.Clock.Continued ->
                        Cmd.none
            )
