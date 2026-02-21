module Playlist.Riot exposing (riot)

import Playlist.Types exposing (Playlist, PlaylistCode(..))


riot : Playlist
riot =
    { code = PlaylistCode "riot"
    , title = "Riot"
    , sounds =
        ( "ca-cest-paris.mp3"
        , [ "el-pueblo-unido.mp3"
          , "france-qui-ferme-sa-gueule.mp3"
          , "internationale.mp3"
          , "internationale2.mp3"
          , "milliards-contre-une-elite.mp3"
          , "mort-aux-patrons.mp3"
          , "ravachole.mp3"
          , "eiffel_larue.wav.mp3"
          ]
        )
    }
