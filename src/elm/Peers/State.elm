module Peers.State exposing (..)

import Js.Commands
import Lib.Duration as Duration exposing (Duration)
import Lib.ListExtras exposing (uncons)
import Pages.Mob.Clocks.Clock exposing (ClockState(..))
import Pages.Mob.Mobbers.Mobbers as Mobbers exposing (Mobbers)
import Pages.Mob.Sound.Library
import Peers.Events as Events
import Time


type alias State =
    { clock : ClockState
    , turnLength : Duration
    , pomodoro : ClockState
    , pomodoroLength : Duration
    , mobbers : Mobbers
    , soundProfile : Pages.Mob.Sound.Library.Profile
    }


init : State
init =
    { clock = Off
    , turnLength = defaultTurnLength
    , pomodoro = Off
    , pomodoroLength = defaultPomodoroLength
    , mobbers = Mobbers.empty
    , soundProfile = Pages.Mob.Sound.Library.ClassicWeird
    }

defaultTurnLength = Duration.ofMinutes 8
defaultPomodoroLength = Duration.ofMinutes 25


type alias TimePassedResult =
    { updated : State
    , turnEvent : Pages.Mob.Clocks.Clock.Event
    }


timePassed : Time.Posix -> State -> TimePassedResult
timePassed now state =
    let
        ( clock, event ) =
            Pages.Mob.Clocks.Clock.timePassed now state.clock
    in
    { updated = { state | clock = clock }
    , turnEvent = event
    }


evolveMany : State -> List Events.Event -> State
evolveMany model events =
    case uncons events of
        ( Nothing, _ ) ->
            model

        ( Just first, others ) ->
            evolveMany (evolve first model) others


evolve : Events.Event -> State -> State
evolve event state =
    case event of
        Events.Clock clockEvent ->
            evolveClock clockEvent state

        Events.AddedMobber mobber ->
            { state | mobbers = Mobbers.add mobber state.mobbers }

        Events.DeletedMobber mobber ->
            { state | mobbers = Mobbers.delete mobber state.mobbers }

        Events.RotatedMobbers ->
            { state | mobbers = Mobbers.rotate state.mobbers }

        Events.ShuffledMobbers mobbers ->
            { state | mobbers = Mobbers.merge mobbers state.mobbers }

        Events.TurnLengthChanged turnLength ->
            { state | turnLength = turnLength }

        Events.SelectedMusicProfile profile ->
            { state | soundProfile = profile }

        Events.Unknown _ ->
            state

        Events.PomodoroStopped ->
            { state | pomodoro = Off }

        Events.PomodoroLengthChanged duration ->
            { state | pomodoroLength = duration }


command : Events.Event -> State -> Cmd msg
command event state =
    case ( event, state.clock ) of
        ( Events.Clock (Events.Started started), Off ) ->
            Js.Commands.send <| Js.Commands.SetAlarm started.alarm

        _ ->
            Cmd.none


evolveClock : Events.ClockEvent -> State -> State
evolveClock event state =
    case ( event, state.clock ) of
        ( Events.Started started, Off ) ->
            { state
                | clock =
                    On
                        { end = Duration.addToTime started.length started.time
                        , length = started.length
                        , ended = False
                        }
                , pomodoro =
                    case state.pomodoro of
                        On _ ->
                            state.pomodoro

                        Off ->
                            On
                                { end = Duration.addToTime state.pomodoroLength started.time
                                , length = state.pomodoroLength
                                , ended = False
                                }
            }

        ( Events.Stopped, On _ ) ->
            { state
                | clock = Off
                , mobbers = Mobbers.rotate state.mobbers
            }

        _ ->
            state
