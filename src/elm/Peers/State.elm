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


defaultTurnLength =
    Duration.ofMinutes 8


defaultPomodoroLength =
    Duration.ofMinutes 25


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


evolve : Events.InEvent -> State -> ( State, Cmd msg )
evolve event state =
    evolve_ event (state, Cmd.none)

evolve_ : Events.InEvent -> ( State, Cmd msg ) -> ( State, Cmd msg )
evolve_ event (state, previousCommand) =
    case event.content of
        Events.Clock clockEvent ->
            evolveClock clockEvent event.time state

        Events.AddedMobber mobber ->
            ( { state | mobbers = Mobbers.add mobber state.mobbers }
            , previousCommand
            )

        Events.DeletedMobber mobber ->
            ( { state | mobbers = Mobbers.delete mobber state.mobbers }
            , previousCommand
            )

        Events.RotatedMobbers ->
            ( { state | mobbers = Mobbers.rotate state.mobbers }
            , previousCommand
            )

        Events.ShuffledMobbers mobbers ->
            ( { state | mobbers = Mobbers.merge mobbers state.mobbers }
            , previousCommand
            )

        Events.TurnLengthChanged turnLength ->
            ( { state | turnLength = turnLength }
            , previousCommand
            )

        Events.SelectedMusicProfile profile ->
            ( { state | soundProfile = profile }
            , previousCommand
            )

        Events.Unknown _ ->
            ( state
            , previousCommand
            )

        Events.PomodoroStopped ->
            ( { state | pomodoro = Off }
            , previousCommand
            )

        Events.PomodoroLengthChanged duration ->
            ( { state | pomodoroLength = duration }
            , previousCommand
            )


evolveMany : List Events.InEvent -> State -> (State, Cmd msg)
evolveMany events model =
    evolveMany_ events (model, Cmd.none)


evolveMany_ : List Events.InEvent -> (State, Cmd msg) -> (State, Cmd msg)
evolveMany_ events previous =
    case uncons events of
        ( Nothing, _ ) ->
            previous

        ( Just first, others ) ->
            evolve_ first previous
            |> evolveMany_ others


evolveClock : Events.ClockEvent -> Time.Posix -> State -> ( State, Cmd msg )
evolveClock event eventTime state =
    case ( event, state.clock ) of
        ( Events.Started started, Off ) ->
            ( { state
                | clock =
                    On
                        { end = Duration.addToTime started.length eventTime
                        , length = started.length
                        , ended = False
                        }
                , pomodoro =
                    case state.pomodoro of
                        On _ ->
                            state.pomodoro

                        Off ->
                            On
                                { end = Duration.addToTime state.pomodoroLength eventTime
                                , length = state.pomodoroLength
                                , ended = False
                                }
              }
            , Js.Commands.send <| Js.Commands.SetAlarm started.alarm
            )

        ( Events.Stopped, On _ ) ->
            ( { state
                | clock = Off
                , mobbers = Mobbers.rotate state.mobbers
              }
            , Cmd.none
            )

        _ ->
            ( state, Cmd.none )
