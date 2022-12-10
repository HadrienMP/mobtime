module UserPreferences__Spec exposing (..)

import Components.Volume.Type exposing (Volume(..))
import Expect
import Test exposing (Test, describe, test)
import UserPreferences


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
