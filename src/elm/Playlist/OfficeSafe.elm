module Playlist.OfficeSafe exposing (officeSafe, officeSafeSoundFolder)

import Playlist.Types exposing (Playlist, PlaylistCode(..))


officeSafeSoundFolder : String
officeSafeSoundFolder =
    "classic-weird"


officeSafe : Playlist
officeSafe =
    { code = PlaylistCode "office-safe"
    , title = "OfficeSafe"
    , sounds =
        ( "007-james-bond-theme.mp3"
        , [ "007-sound-final.mp3"
          , "a-ha-take-on-me-cut-mp3.mp3"
          , "anthologie-de-julien-lepers.mp3"
          , "aroundtheworld.wav.mp3"
          , "boneym_rasputin.wav.mp3"
          , "breaking-bad-intro.mp3"
          , "cantina-band.mp3"
          , "carldouglas_kungfufighting.wav.mp3"
          , "chic_freak.wav.mp3"
          , "coolio_ganstaparadise.wav.mp3"
          , "denis-brogniart-ah-original.mp3"
          , "digitallove.wav.mp3"
          , "donald-trump-fake-news-sound-effect.mp3"
          , "doors_strange.wav.mp3"
          , "drdre_stilldre.wav.mp3"
          , "drwho.mp3"
          , "eminem_slimshady.wav.mp3"
          , "fake-news-great.mp3"
          , "flashgordontheme.mp3"
          , "george-micael-wham-careless-whisper-1.mp3"
          , "got.mp3"
          , "hallelujahshort.swf.mp3"
          , "harry-potter-hedwigs-theme-short.mp3"
          , "i-am-your-father_rCXrfcX.mp3"
          , "imperial_march.mp3"
          , "inceptionbutton.mp3"
          , "indiana-jones-theme-song.mp3"
          , "indochine_aventurier.wav.mp3"
          , "its-me-mario.mp3"
          , "jurrasic-theme-2-hq.mp3"
          , "kaamelott-theme.mp3"
          , "kiss_madeforlovingyou.wav.mp3"
          , "knight-rider.mp3"
          , "lemon-grab-unacceptable.mp3"
          , "lmfao_partyrockanthem.wav.mp3"
          , "matmatah_apologie.wav.mp3"
          , "mc-hammer-u-cant-touch-this.mp3"
          , "mission-impossible.mp3"
          , "mjackson_beatit.wav.mp3"
          , "nyan-cat_1.mp3"
          , "psy-gangnam-style-1.mp3"
          , "queen_breakfree.wav.mp3"
          , "rickroll.wav.mp3"
          , "robin-hood-1973-whistle-stop.mp3"
          , "smokeonthewater.wav.mp3"
          , "spindoctors_twoprinces.wav.mp3"
          , "star-wars-john-williams-duel-of-the-fates.mp3"
          , "super-mario-bros-ost-8-youre-dead.mp3"
          , "sweethomealabam.wav.mp3"
          , "tetris-theme.mp3"
          , "the-addams-family-intro-theme-song.mp3"
          , "the-benny-hill-show-theme-short-sound-clip-and-quote-hark.mp3"
          , "the-it-crowd-theme.mp3"
          , "the-pink-panther-theme-song-original-version.mp3"
          , "the-simpsons-nelsons-haha.mp3"
          , "the-weather-girls-its-raining-men-1-cut-mp3.mp3"
          , "thislove.wav.mp3"
          , "toto_africa.wav.mp3"
          , "toxic.wav.mp3"
          , "we-are-the-champions-copia.mp3"
          , "zelda.mp3"

          -- TODO: what is love
          ]
        )
    }
