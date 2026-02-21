module Playlist.Pick exposing (pick)

import Playlist.OfficeSafe exposing (officeSafe, officeSafeSoundFolder)
import Playlist.Types exposing (Playlist, Sound, codeToString)
import Random
import Url.Builder


pick : Playlist -> Random.Generator Sound
pick profile =
    profile.sounds
        |> (\( d, list ) -> Random.uniform d list)
        |> Random.map (fileNameToPath profile)


fileNameToPath : Playlist -> String -> String
fileNameToPath playlist sound =
    let
        folder =
            if playlist.code == officeSafe.code then
                officeSafeSoundFolder

            else
                codeToString playlist.code
    in
    Url.Builder.absolute [ "playlists", folder, "sounds", sound ] []
