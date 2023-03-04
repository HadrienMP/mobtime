module Lib.LibExtras_Spec exposing (suite)

import Expect
import Lib.ListExtras exposing (rotate, zip)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "List extras"
        [ describe "rotate"
            [ test "The first element ends up at the end" <|
                \_ ->
                    [ "First", "Second", "Third" ]
                        |> rotate
                        |> Expect.equalLists [ "Second", "Third", "First" ]
            , test "An empty list stays empty" <|
                \_ ->
                    [] |> rotate |> Expect.equalLists []
            ]
        , describe "zip"
            [ test "pairs values at the same indexes of two lists" <|
                \_ ->
                    zip [ 1, 2 ] [ "a", "b" ]
                        |> Expect.equalLists [ ( 1, "a" ), ( 2, "b" ) ]
            , test "ignores values that can't be paired" <|
                \_ ->
                    zip [ 1, 2 ] [ "a" ]
                        |> Expect.equalLists [ ( 1, "a" ) ]
            , test "returns an empty list for two empty lists" <|
                \_ -> zip [] [] |> Expect.equalLists []
            ]
        ]
