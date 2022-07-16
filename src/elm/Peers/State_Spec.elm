module Peers.State_Spec exposing (..)

import Expect
import Js.Commands
import Lib.Duration as Duration
import Model.Clock as Clock
import Sounds
import Peers.Events exposing (ClockEvent(..), Event(..))
import Peers.State
import Test exposing (Test, describe, test)
import Time


suite : Test
suite =
    describe "Peers shared state"
        [ describe "Pomodoro"
            [ test "Starts with a turn when off" <|
                \_ ->
                    let
                        ( state, _ ) =
                            Peers.State.init
                                |> Peers.State.evolve (Clock <| turnOnAt midnight)
                    in
                    state.pomodoro
                        |> Expect.equal
                            (Clock.On
                                { end = minutesPast 25 midnight
                                , length = Duration.ofMinutes 25
                                , ended = False
                                }
                            )
            , test "Does not restart with a turn when on" <|
                \_ ->
                    let
                        ( state, _ ) =
                            Peers.State.init
                                |> Peers.State.evolve (Clock <| turnOnAt midnight)
                                |> Peers.State.evolve_ (Clock <| Stopped)
                                |> Peers.State.evolve_ (Clock <| turnOnAt <| minutesPast 10 midnight)
                    in
                    state.pomodoro
                        |> Expect.equal
                            (Clock.On
                                { end = minutesPast 25 midnight
                                , length = Duration.ofMinutes 25
                                , ended = False
                                }
                            )
            , test "Can be stopped manually" <|
                \_ ->
                    let
                        ( state, _ ) =
                            Peers.State.init
                                |> Peers.State.evolve (Clock <| turnOnAt midnight)
                                |> Peers.State.evolve_ PomodoroStopped
                    in
                    state.pomodoro
                        |> Expect.equal Clock.Off
            ]
        , describe "command from event history"
            [ test "none for no events" <|
                \_ ->
                    let
                        ( _, command ) =
                            Peers.State.init
                                |> Peers.State.evolveMany []
                    in
                    command
                        |> Expect.equal Cmd.none
            , test "set alarm for one start event" <|
                \_ ->
                    let
                        alarm =
                            Sounds.default

                        started =
                            Clock <| turnOnWithAlarm alarm

                        ( _, command ) =
                            Peers.State.init
                                |> Peers.State.evolveMany [ started ]
                    in
                    command
                        |> Expect.equal (Js.Commands.send <| Js.Commands.SetAlarm alarm)
            ]
        ]


turnOnWithAlarm :  Sounds.Sound -> ClockEvent
turnOnWithAlarm sound =
    Started { time = midnight, alarm = sound, length = Duration.ofMinutes 10 }


turnOnAt : Time.Posix -> ClockEvent
turnOnAt posix =
    Started { time = posix, alarm = Sounds.default, length = Duration.ofMinutes 10 }


midnight =
    Time.millisToPosix 0


minutesPast : Int -> Time.Posix -> Time.Posix
minutesPast minutes time =
    Duration.addToTime (Duration.ofMinutes minutes) time
