module Lib.LibExtras_Spec exposing (..)

import Expect
import Lib.ListExtras exposing (rotate)
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
        ]
