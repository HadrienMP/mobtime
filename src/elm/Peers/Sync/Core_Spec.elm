module Peers.Sync.Core_Spec exposing (..)

import Expect
import Iso8601
import Peers.Sync.Core exposing (CommandType(..), Recipient(..), adjustTimeFrom, handle, start)
import Test exposing (Test, describe, skip, test)
import Time


suite : Test
suite =
    describe "Clock Sync" <|
        [ describe "adjustment" <|
            [ test "calculates the duration to be added to a time received" <|
                \_ ->
                    let
                        syncId =
                            "syncId"

                        t1 =
                            toPosix "T00:00:01"

                        t2 =
                            toPosix "T00:00:04"

                        t3 =
                            toPosix "T00:00:05"

                        ( state1, _ ) =
                            start { peerId = "peer 1", time = t1, syncId = syncId }

                        ( state2, _ ) =
                            handle
                                { context = { peerId = "peer 2", time = t2, syncId = syncId }
                                , type_ = ExchangeTime
                                , recipient = Peer "Peer 1"
                                }
                                t3
                                state1
                    in
                    adjustTimeFrom "peer 2" state2 (toPosix "T00:00:04")
                        |> Expect.equal (toPosix "T00:00:03")
            , test "calculates the time adjustment with a new peer" <|
                \_ ->
                    let
                        syncId =
                            "syncId"

                        ( state1, _ ) =
                            start { peerId = "peer 2", time = toPosix "T00:00:00", syncId = syncId }

                        ( state2, _ ) =
                            handle
                                { context =
                                    { peerId = "peer 1"
                                    , time = toPosix "T00:00:01"
                                    , syncId = syncId
                                    }
                                , type_ = TellMeYourTime
                                , recipient = Peer "peer 2"
                                }
                                (toPosix "T00:00:04")
                                state1

                        ( state3, _ ) =
                            handle
                                { context =
                                    { peerId = "peer 1"
                                    , time = toPosix "T00:00:04"
                                    , syncId = syncId
                                    }
                                , type_ = MyTimeIs
                                , recipient = Peer "peer 2"
                                }
                                (toPosix "T00:00:08")
                                state2
                    in
                    adjustTimeFrom "peer 1" state3 (toPosix "T00:00:04")
                        |> Expect.equal (toPosix "T00:00:06")
            ]
        , describe "commands" <|
            [ test "On the starting end" <|
                \_ ->
                    let
                        startTime =
                            toPosix "T00:00:01"

                        syncId =
                            "syncId"

                        ( state1, command1 ) =
                            start { peerId = "peer 1", time = startTime, syncId = syncId }

                        -- TODO HMP dont use the recipient in incoming messages
                        ( _, command2 ) =
                            handle
                                { context =
                                    { peerId = "peer 2"
                                    , time = toPosix "T00:00:04"
                                    , syncId = syncId
                                    }
                                , type_ = ExchangeTime
                                , recipient = Peer "peer 1"
                                }
                                (toPosix "T00:00:05")
                                state1
                    in
                    [ Just command1, command2 ]
                        |> Expect.equal
                            ([ { context = { peerId = "peer 1", time = startTime, syncId = syncId }
                               , type_ = TellMeYourTime
                               , recipient = All
                               }
                             , { context = { peerId = "peer 1", time = startTime, syncId = syncId }
                               , type_ = MyTimeIs
                               , recipient = Peer "peer 2"
                               }
                             ]
                                |> List.map Just
                            )
            , test "on the receiving end" <|
                \_ ->
                    let
                        syncId =
                            "syncId"

                        ( state1, _ ) =
                            start { peerId = "peer 2", time = toPosix "T00:00:00", syncId = syncId }

                        ( state2, command2 ) =
                            handle
                                { context =
                                    { peerId = "peer 1"
                                    , time = toPosix "T00:00:01"
                                    , syncId = syncId
                                    }
                                , type_ = TellMeYourTime
                                , recipient = Peer "peer 2"
                                }
                                (toPosix "T00:00:04")
                                state1

                        ( _, command3 ) =
                            handle
                                { context =
                                    { peerId = "peer 1"
                                    , time = toPosix "T00:00:04"
                                    , syncId = syncId
                                    }
                                , type_ = MyTimeIs
                                , recipient = Peer "peer 2"
                                }
                                (toPosix "T00:00:08")
                                state2
                    in
                    [ command2, command3 ]
                        |> Expect.equal
                            [ Just
                                { context = { peerId = "peer 2", time = toPosix "T00:00:04", syncId = syncId }
                                , type_ = ExchangeTime
                                , recipient = Peer "peer 1"
                                }
                            , Nothing
                            ]
            ]
        , skip <|
            test "ignores messages for an unknown sync id" <|
                \_ ->
                    let
                        ( state1, _ ) =
                            start { peerId = "peer 1", time = toPosix "T00:00:01", syncId = "syncId" }

                        ( state2, _ ) =
                            handle
                                { context = { peerId = "peer 2", time = toPosix "T00:00:04", syncId = "unknown" }
                                , type_ = ExchangeTime
                                , recipient = Peer "peer 2"
                                }
                                (toPosix "T00:00:05")
                                state1
                    in
                    Expect.equal state1 state2
        ]


toPosix : String -> Time.Posix
toPosix string =
    Iso8601.toTime ("2021-01-01" ++ string) |> Result.withDefault (Time.millisToPosix 0)
