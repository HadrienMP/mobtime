module Playlist.Funky exposing (funky)

import Playlist.Types exposing (Playlist, PlaylistCode(..))


funky : Playlist
funky =
    { code = PlaylistCode "funky"
    , title = "Funky"
    , sounds =
        ( "caravan.mp3"
        , [ "cry.mp3"
          , "do-it.mp3"
          , "essence.mp3"
          , "feuille.mp3"
          , "fly.mp3"
          , "little.mp3"
          , "merci.mp3"
          , "rock.mp3"
          , "snip-snap.mp3"
          , "sol.mp3"
          , "stolen.mp3"
          , "there.mp3"
          ]
        )
    }
