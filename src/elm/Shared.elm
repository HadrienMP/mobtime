module Shared exposing (..)

import Clock.Clock exposing (ClockState(..))
import Clock.TurnClock
import Js.Commands
import Json.Decode
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


timePassed : Time.Posix -> State -> ( State, Cmd msg )
timePassed now state =
    let
        ( clock, command ) =
            Clock.TurnClock.timePassed now state.clock
    in
    ( { state | clock = clock }
    , command
    )


evolveMany : State -> List (Result Json.Decode.Error SharedEvents.Event) -> State
evolveMany model events =
    case uncons events of
        ( Nothing, _ ) ->
            model

        ( Just (Err _), tail ) ->
            evolveMany model tail

        ( Just (Ok head), tail ) ->
            evolveMany (evolve model head |> Tuple.first) tail


evolve : State -> SharedEvents.Event -> ( State, Cmd msg )
evolve state event =
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

        ( SharedEvents.AddedMobber mobber, _ ) ->
            ( { state | mobbers = Mobbers.add mobber state.mobbers  }, Cmd.none )

        ( SharedEvents.DeletedMobber mobber, _ ) ->
            ( { state | mobbers = Mobbers.delete mobber state.mobbers }, Cmd.none )

        ( SharedEvents.RotatedMobbers, _ ) ->
            ( { state | mobbers = Mobbers.rotate state.mobbers }, Cmd.none )

        ( SharedEvents.ShuffledMobbers mobbers, _ ) ->
            ( { state | mobbers = Mobbers.merge mobbers state.mobbers }, Cmd.none )

        ( SharedEvents.TurnLengthChanged turnLength, _ ) ->
            ( { state | turnLength = turnLength }, Cmd.none )

        ( SharedEvents.SelectedMusicProfile profile, _ ) ->
            ( { state | soundProfile = profile }, Cmd.none )

        _ ->
            ( state, Cmd.none )
