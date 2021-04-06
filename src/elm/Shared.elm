module Shared exposing (..)

import Pages.Mob.Clocks.Clock exposing (ClockState(..))
import Js.Commands
import Lib.Duration exposing (Duration)
import Lib.ListExtras exposing (uncons)
import Mobbers.Mobbers as Mobbers exposing (Mobbers)
import SharedEvents
import Sound.Library
import Time


type alias State =
    { clock : ClockState
    , turnLength : Duration
    , mobbers : Mobbers
    , soundProfile : Sound.Library.Profile
    }


init : State
init =
    { clock = Off
    , turnLength = Lib.Duration.ofMinutes 8
    , mobbers = Mobbers.empty
    , soundProfile = Sound.Library.ClassicWeird
    }


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


evolveMany : State -> List SharedEvents.Event -> State
evolveMany model events =
    case uncons events of
        ( Nothing, _ ) ->
            model

        ( Just head, tail ) ->
            evolveMany (evolve model head |> Tuple.first) tail


evolve : State -> SharedEvents.Event -> ( State, Cmd msg )
evolve state event =
    case event of
        SharedEvents.Clock clockEvent ->
            evolveClock clockEvent state

        SharedEvents.AddedMobber mobber ->
            ( { state | mobbers = Mobbers.add mobber state.mobbers }, Cmd.none )

        SharedEvents.DeletedMobber mobber ->
            ( { state | mobbers = Mobbers.delete mobber state.mobbers }, Cmd.none )

        SharedEvents.RotatedMobbers ->
            ( { state | mobbers = Mobbers.rotate state.mobbers }, Cmd.none )

        SharedEvents.ShuffledMobbers mobbers ->
            ( { state | mobbers = Mobbers.merge mobbers state.mobbers }, Cmd.none )

        SharedEvents.TurnLengthChanged turnLength ->
            ( { state | turnLength = turnLength }, Cmd.none )

        SharedEvents.SelectedMusicProfile profile ->
            ( { state | soundProfile = profile }, Cmd.none )

        SharedEvents.Unknown _ ->
            ( state, Cmd.none )


evolveClock : SharedEvents.ClockEvent -> State -> ( State, Cmd msg )
evolveClock event state =
    case ( event, state.clock ) of
        ( SharedEvents.Started started, Off ) ->
            ( { state
                | clock =
                    On
                        { end = Time.posixToMillis started.time + Lib.Duration.toMillis started.length |> Time.millisToPosix
                        , length = started.length
                        , ended = False
                        }
              }
            , Js.Commands.send <| Js.Commands.SetAlarm started.alarm
            )

        ( SharedEvents.Stopped, On _ ) ->
            ( { state
                | clock = Off
                , mobbers = Mobbers.rotate state.mobbers
              }
            , Cmd.none
            )

        _ ->
            ( state, Cmd.none )
