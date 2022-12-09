module UserPreferences__Spec exposing (..)

import Expect
import Test exposing (Test, describe, test)
import UserPreferences
import Volume.Type exposing (Volume(..))


suite : Test
suite =
    describe "UserPreferences"
        [ test "should serialize and deserialize to the same object" <|
            \_ ->
                let
                    preferences =
                        { volume = Volume 12, displaySeconds = True }
                in
                preferences
                    |> UserPreferences.encode
                    |> UserPreferences.decode
                    |> Expect.equal
                        preferences
        ]
