module Lib.LibExtras_Spec exposing (..)

import Expect
import Lib.ListExtras exposing (assign, rotate)
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
        , describe "assign"
            [ test "pairs values at the same indexes of two lists" <|
                \_ ->
                    assign [ 1, 2 ] [ "a" ]
                        |> Expect.equalLists [ ( Just 1, Just "a" ), ( Just 2, Nothing ) ]
            , test "returns an empty list for two empty lists" <|
                \_ -> assign [] [] |> Expect.equalLists []
            ]
        ]
