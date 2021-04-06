module Pages.Mob.Clocks.TurnClock exposing (..)

import Pages.Mob.Clocks.Clock exposing (ClockState(..))
import Js.Commands
import Time


timePassed : Time.Posix -> ClockState -> ( ClockState, Cmd msg )
timePassed now clockState =
    Pages.Mob.Clocks.Clock.timePassed now clockState
        |> Tuple.mapSecond
            (\event ->
                case event of
                    Pages.Mob.Clocks.Clock.Ended ->
                        Js.Commands.send Js.Commands.SoundAlarm

                    Pages.Mob.Clocks.Clock.Continued ->
                        Cmd.none
            )
