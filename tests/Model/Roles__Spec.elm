module Model.Roles__Spec exposing (..)

import Expect
import Model.Role as Role
import Model.Roles as Roles
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Roles"
        [ describe "Parse"
            [ test "Single role" <|
                \_ ->
                    "Word"
                        |> Roles.parse
                        |> Expect.equal [ Role.fromString "Word" ]
            , test "Roles are split by commas" <|
                \_ ->
                    "One,Two"
                        |> Roles.parse
                        |> List.map .name
                        |> Expect.equal [ "One", "Two" ]
            , test "Roles are trimmed" <|
                \_ ->
                    "One, Two"
                        |> Roles.parse
                        |> List.map .name
                        |> Expect.equal [ "One", "Two" ]
            ]
        ]
