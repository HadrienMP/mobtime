module Playlist.Playlists__Spec exposing (..)

import Expect
import Lib.NonEmptyList exposing (toggle)
import Playlist.ClassicWeird exposing (classicWeird)
import Playlist.OfficeSafe exposing (officeSafe)
import Playlist.Types exposing (PlaylistCode(..))
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "NonEmptyList"
        [ describe "toggle"
            [ test "the only one selected doesn't do anything, at least one playlist must be selected" <|
                \_ ->
                    ( classicWeird.code, [] )
                        |> toggle classicWeird.code
                        |> Expect.equal ( classicWeird.code, [] )
            , test "delete in rest of list, single element" <|
                \_ ->
                    ( classicWeird.code, [ officeSafe.code ] )
                        |> toggle officeSafe.code
                        |> Expect.equal ( classicWeird.code, [] )
            , test "delete in rest of list, multiple elements" <|
                \_ ->
                    ( classicWeird.code, [ PlaylistCode "a", officeSafe.code, PlaylistCode "b" ] )
                        |> toggle officeSafe.code
                        |> Expect.equal ( classicWeird.code, [ PlaylistCode "a", PlaylistCode "b" ] )
            , test "delete first element, multiple elements" <|
                \_ ->
                    ( classicWeird.code, [ PlaylistCode "a", PlaylistCode "b" ] )
                        |> toggle classicWeird.code
                        |> Expect.equal ( PlaylistCode "a", [ PlaylistCode "b" ] )
            , test "add" <|
                \_ ->
                    ( PlaylistCode "a", [ PlaylistCode "b" ] )
                        |> toggle (PlaylistCode "c")
                        |> Expect.equal ( PlaylistCode "a", [ PlaylistCode "c", PlaylistCode "b" ] )
            ]
        ]
