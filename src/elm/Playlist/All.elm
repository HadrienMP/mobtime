module Playlist.All exposing (fromCode, playlists)

import Playlist.ClassicWeird exposing (classicWeird)
import Playlist.Funky exposing (funky)
import Playlist.Kaamelott exposing (kaamelott)
import Playlist.OfficeSafe exposing (officeSafe)
import Playlist.Riot exposing (riot)
import Playlist.Types exposing (Playlist, PlaylistCode)


playlists : List Playlist
playlists =
    [ classicWeird
    , funky
    , kaamelott
    , officeSafe
    , riot
    ]


fromCode : PlaylistCode -> Playlist
fromCode target =
    playlists
        |> List.filter (\{ code } -> code == target)
        |> List.head
        |> Maybe.withDefault classicWeird
