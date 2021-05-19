module Peers.Clock_Sync_Spec exposing (..)

import Expect exposing (Expectation)
import Iso8601
import Peers.Clock_Sync exposing (CommandType(..), adjustTimeFrom, handle, start)
import Test exposing (Test, describe, test)
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
                                { peer = "peer 2", time = t2, syncId = syncId, type_ = ExchangeTime }
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
                                { peer = "peer 1", time = toPosix "T00:00:01", syncId = syncId, type_ = TellMeYourTime }
                                (toPosix "T00:00:04")
                                state1

                        ( state3, _ ) =
                            handle
                                { peer = "peer 1", time = toPosix "T00:00:04", syncId = syncId, type_ = MyTimeIs }
                                (toPosix "T00:00:08")
                                state2
                    in
                    adjustTimeFrom "peer 1" state3 (toPosix "T00:00:04")
                        |> Expect.equal (toPosix "T00:00:06")
            ]
        , describe "commands" <|
            []
        , test "ignores messages for an unknown sync id" <|
            \_ ->
                let
                    ( state1, _ ) =
                        start { peerId = "peer 1", time = toPosix "T00:00:01", syncId = "syncId" }

                    ( state2, _ ) =
                        handle
                            { peer = "peer 2", time = toPosix "T00:00:04", syncId = "unknown", type_ = ExchangeTime }
                            (toPosix "T00:00:05")
                            state1
                in
                Expect.equal state1 state2
        ]


toPosix : String -> Time.Posix
toPosix string =
    Iso8601.toTime ("2021-01-01" ++ string) |> Result.withDefault (Time.millisToPosix 0)
