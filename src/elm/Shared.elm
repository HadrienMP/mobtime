module Shared exposing (..)

import Clock.Model exposing (ClockState(..))
import Js.Commands
import Json.Decode
import Lib.Duration exposing (Duration)
import Lib.ListExtras exposing (rotate, uncons)
import Mobbers.Model exposing (Mobbers)
import SharedEvents
import Time


type alias State =
    { clock : ClockState
    , turnLength: Duration
    , mobbers : Mobbers
    }


init : State
init =
    { clock = Off
    , turnLength = Lib.Duration.ofMinutes 8
    , mobbers = []
    }


timePassed : Time.Posix -> State -> ( State, Cmd msg )
timePassed now state =
    let
        ( clock, command ) =
            Clock.Model.timePassed now state.clock
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
            evolveMany (applyTo model head |> Tuple.first) tail


applyTo : State -> SharedEvents.Event -> ( State, Cmd msg )
applyTo state event =
    case ( event, state.clock ) of
        ( SharedEvents.Started started, Off ) ->
            ( { state
                | clock =
                    On
                        { end = Time.posixToMillis started.time + (Lib.Duration.toMillis started.length) |> Time.millisToPosix
                        , length = started.length
                        , ended = False
                        }
              }
            , Js.Commands.send <| Js.Commands.SetAlarm started.alarm
            )

        ( SharedEvents.Stopped, On _ ) ->
            ( { state
                | clock = Off
                , mobbers = rotate state.mobbers
              }
            , Cmd.none
            )

        ( SharedEvents.AddedMobber mobber, _ ) ->
            ( { state | mobbers = state.mobbers ++ [ mobber ] }, Cmd.none )

        ( SharedEvents.DeletedMobber mobber, _ ) ->
            ( { state | mobbers = List.filter (\m -> m /= mobber) state.mobbers }, Cmd.none )

        ( SharedEvents.RotatedMobbers, _ ) ->
            ( { state | mobbers = rotate state.mobbers }, Cmd.none )

        ( SharedEvents.ShuffledMobbers mobbers, _ ) ->
            ( { state | mobbers = mobbers ++ List.filter (\el -> not <| List.member el mobbers) state.mobbers }, Cmd.none )

        (SharedEvents.TurnLengthChanged turnLength, _) ->
            ( { state | turnLength = turnLength }, Cmd.none )

        _ ->
            ( state, Cmd.none )