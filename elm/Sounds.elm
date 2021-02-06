module Sounds exposing (..)

import Random
type alias Sound = String

default : Sound
default = "celebration.mp3"

pick : Random.Generator Sound
pick = Random.uniform default all

all : List Sound
all =
    [ "007-james-bond-theme.mp3"
    , "007-sound-final.mp3"
    , "a-ha-take-on-me-cut-mp3.mp3"
    , "anthologie-de-julien-lepers.mp3"
    , "breaking-bad-intro.mp3"
    , "cantina-band.mp3"
    , "celebration.mp3"
    , "complotiste.mp3"
    , "denis-brogniart-ah-original.mp3"
    , "donald-trump-fake-news-sound-effect.mp3"
    , "drwho.mp3"
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
    , "its-me-mario.mp3"
    , "jurrasic-theme-2-hq.mp3"
    , "kaamelott-theme.mp3"
    , "knight-rider.mp3"
    , "lemon-grab-unacceptable.mp3"
    , "macron_projet_final.mp3"
    , "mc-hammer-u-cant-touch-this.mp3"
    , "mission-impossible.mp3"
    , "music-missionimpossibletheme.mp3"
    , "nyan-cat_1.mp3"
    , "o-bom-o-mal-e-o-feio-velho-oeste-desafio-dont-talk-duelo-desafio-armas.mp3"
    , "over9000.swf.mp3"
    , "perlin.mp3"
    , "poudreperlinpinpin_fqw6cN8.mp3"
    , "psy-gangnam-style-1.mp3"
    , "robin-hood-1973-whistle-stop.mp3"
    , "star-wars-john-williams-duel-of-the-fates.mp3"
    , "super-mario-bros-ost-8-youre-dead.mp3"
    , "tetris-theme.mp3"
    , "the-addams-family-intro-theme-song.mp3"
    , "the-benny-hill-show-theme-short-sound-clip-and-quote-hark.mp3"
    , "the-it-crowd-theme.mp3"
    , "the-pink-panther-theme-song-original-version.mp3"
    , "the-simpsons-nelsons-haha.mp3"
    , "the-weather-girls-its-raining-men-1-cut-mp3.mp3"
    , "untitled_3.mp3"
    , "utini.mp3"
    , "we-are-the-champions-copia.mp3"
    , "zelda.mp3"
    ]
