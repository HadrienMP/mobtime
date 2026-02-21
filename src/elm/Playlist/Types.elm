module Playlist.Types exposing (Playlist, PlaylistCode(..), Sound, codeToJson, codeToString)

import Json.Encode as Json


type alias Sound =
    String


type PlaylistCode
    = PlaylistCode String


type alias Playlist =
    { code : PlaylistCode -- The code is used a json key and is the name of the playlist's folder in public/playlists
    , sounds : ( String, List String )
    , title : String
    }


codeToString : PlaylistCode -> String
codeToString (PlaylistCode value) =
    value


codeToJson : PlaylistCode -> Json.Value
codeToJson =
    codeToString >> Json.string
