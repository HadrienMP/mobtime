module State__Spec exposing (..)

import Expect
import Js.Commands
import Lib.Duration as Duration
import Model.Clock as Clock
import Model.Events exposing (ClockEvent(..), Event(..))
import Model.Mob
import Model.MobName
import Model.Mobber as Mobber
import Model.Role
import Sounds
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
                            Model.MobName.MobName "awesome"
                                |> Model.Mob.init
                                |> Model.Mob.evolve (Clock <| turnOnAt midnight)
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
                            Model.MobName.MobName "awesome"
                                |> Model.Mob.init
                                |> Model.Mob.evolve (Clock <| turnOnAt midnight)
                                |> Model.Mob.evolve_ (Clock <| Stopped)
                                |> Model.Mob.evolve_ (Clock <| turnOnAt <| minutesPast 10 midnight)
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
                            Model.MobName.MobName "awesome"
                                |> Model.Mob.init
                                |> Model.Mob.evolve (Clock <| turnOnAt midnight)
                                |> Model.Mob.evolve_ PomodoroStopped
                    in
                    state.pomodoro
                        |> Expect.equal Clock.Off
            ]
        , describe "command from event history"
            [ test "none for no events" <|
                \_ ->
                    let
                        ( _, command ) =
                            Model.MobName.MobName "awesome"
                                |> Model.Mob.init
                                |> Model.Mob.evolveMany []
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
                            Model.MobName.MobName "awesome"
                                |> Model.Mob.init
                                |> Model.Mob.evolveMany [ started ]
                    in
                    command
                        |> Expect.equal (Js.Commands.send <| Js.Commands.SetAlarm alarm)
            ]
        , describe "full turn: when every mobber has been driver and navigator"
            [ test "notify everyone" <|
                \_ ->
                    let
                        driver =
                            Model.Role.fromString "Driver"

                        navigator =
                            Model.Role.fromString "Navigator"

                        mobber =
                            Model.Role.fromString "Mobber"

                        jane =
                            { id = Mobber.idFromString "jane", name = "Jane" }

                        camille =
                            { id = Mobber.idFromString "camille", name = "Camille" }

                        roles =
                            { default = mobber, special = [ driver, navigator ] }

                        ( state, _ ) =
                            Model.MobName.MobName "awesome"
                                |> Model.Mob.init
                                |> Model.Mob.evolveMany
                                    [ AddedMobber jane
                                    , AddedMobber camille
                                    , ChangedRoles roles
                                    , Clock <| turnOnAt midnight
                                    , Clock Stopped
                                    ]
                    in
                    state
                        |> Model.Mob.assignRoles
                        |> Expect.equal [ ( driver, camille ), ( navigator, jane ) ]
            ]
        ]


turnOnWithAlarm : Sounds.Sound -> ClockEvent
turnOnWithAlarm sound =
    Started { time = midnight, alarm = sound, length = Duration.ofMinutes 10 }


turnOnAt : Time.Posix -> ClockEvent
turnOnAt posix =
    Started { time = posix, alarm = Sounds.default, length = Duration.ofMinutes 10 }


midnight : Time.Posix
midnight =
    Time.millisToPosix 0


minutesPast : Int -> Time.Posix -> Time.Posix
minutesPast minutes time =
    Duration.addToTime (Duration.ofMinutes minutes) time
