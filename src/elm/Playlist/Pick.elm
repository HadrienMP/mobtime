module Playlist.Pick exposing (pick)

import Lib.ListExtras
import Playlist.ClassicWeird exposing (classicWeird)
import Playlist.OfficeSafe exposing (officeSafe, officeSafeSoundFolder)
import Playlist.Types exposing (Playlist, PlaylistCode, Playlists, Sound, codeToString)
import Random
import Url.Builder


pick : Playlists -> Random.Generator Sound
pick playlists =
    let
        ( firstSound, restSound ) =
            playlistsToSounds playlists
    in
    Random.uniform firstSound restSound
        |> Random.map pathOfSound


type alias SoundInPlaylist =
    { playlist : PlaylistCode, sound : Sound }


playlistsToSounds : Playlists -> ( SoundInPlaylist, List SoundInPlaylist )
playlistsToSounds ( firstPlaylist, restOfPlaylists ) =
    firstPlaylist
        :: restOfPlaylists
        |> List.concatMap playlistToSounds
        |> Lib.ListExtras.uncons
        |> Tuple.mapFirst (Maybe.withDefault classicWeirdFirstSound)


classicWeirdFirstSound : SoundInPlaylist
classicWeirdFirstSound =
    SoundInPlaylist classicWeird.code (Tuple.first classicWeird.sounds)


playlistToSounds : Playlist -> List SoundInPlaylist
playlistToSounds playlist =
    let
        ( first, rest ) =
            playlist.sounds
    in
    first :: rest |> List.map (SoundInPlaylist playlist.code)


pathOfSound : SoundInPlaylist -> String
pathOfSound t =
    Url.Builder.absolute [ "playlists", folderOf t.playlist, "sounds", t.sound ] []


folderOf : PlaylistCode -> String
folderOf playlist =
    if playlist == officeSafe.code then
        officeSafeSoundFolder

    else
        codeToString playlist
