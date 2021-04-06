module Pages.Mob.Sound.Library exposing (Profile(..), Sound, default, pick, profileFromString, profileToString)

import Random


type alias Sound =
    String


type Profile
    = ClassicWeird
    | Riot


profileToString : Profile -> String
profileToString profile =
    case profile of
        ClassicWeird ->
            "ClassicWeird"

        Riot ->
            "Riot"


profileFromString : String -> Profile
profileFromString string =
    case string of
        "Riot" ->
            Riot
        _ ->
            ClassicWeird




default : Sound
default =
    "classic-weird/celebration.mp3"


pick : Profile -> Random.Generator Sound
pick profile =
    soundsOf profile
        |> (\( d, list ) -> Random.uniform d list)


soundsOf : Profile -> ( Sound, List Sound )
soundsOf profile =
    case profile of
        ClassicWeird ->
            ( "classic-weird/celebration.mp3"
            , classicWeird
            )

        Riot ->
            ( "riot/faut plus de gouvernement.mp3"
            , riot
            )


riot : List Sound
riot =
    [ "riot/ca cest paris.mp3"
    , "riot/el pueblo unido.mp3"
    , "riot/france qui ferme sa gueule.mp3"
    , "riot/internationale.mp3"
    , "riot/internationale2.mp3"
    , "riot/milliards contre une elite.mp3"
    , "riot/mort aux patrons.mp3"
    , "riot/ravachole.mp3"
    ]


classicWeird : List Sound
classicWeird =
    [ "classic-weird/007-james-bond-theme.mp3"
    , "classic-weird/007-sound-final.mp3"
    , "classic-weird/a-ha-take-on-me-cut-mp3.mp3"
    , "classic-weird/anthologie-de-julien-lepers.mp3"
    , "classic-weird/breaking-bad-intro.mp3"
    , "classic-weird/cantina-band.mp3"
    , "classic-weird/complotiste.mp3"
    , "classic-weird/denis-brogniart-ah-original.mp3"
    , "classic-weird/donald-trump-fake-news-sound-effect.mp3"
    , "classic-weird/drwho.mp3"
    , "classic-weird/fake-news-great.mp3"
    , "classic-weird/flashgordontheme.mp3"
    , "classic-weird/george-micael-wham-careless-whisper-1.mp3"
    , "classic-weird/got.mp3"
    , "classic-weird/hallelujahshort.swf.mp3"
    , "classic-weird/harry-potter-hedwigs-theme-short.mp3"
    , "classic-weird/i-am-your-father_rCXrfcX.mp3"
    , "classic-weird/imperial_march.mp3"
    , "classic-weird/inceptionbutton.mp3"
    , "classic-weird/indiana-jones-theme-song.mp3"
    , "classic-weird/its-me-mario.mp3"
    , "classic-weird/jurrasic-theme-2-hq.mp3"
    , "classic-weird/kaamelott-theme.mp3"
    , "classic-weird/knight-rider.mp3"
    , "classic-weird/lemon-grab-unacceptable.mp3"
    , "classic-weird/macron_projet_final.mp3"
    , "classic-weird/mc-hammer-u-cant-touch-this.mp3"
    , "classic-weird/mission-impossible.mp3"
    , "classic-weird/music-missionimpossibletheme.mp3"
    , "classic-weird/nyan-cat_1.mp3"
    , "classic-weird/o-bom-o-mal-e-o-feio-velho-oeste-desafio-dont-talk-duelo-desafio-armas.mp3"
    , "classic-weird/over9000.swf.mp3"
    , "classic-weird/perlin.mp3"
    , "classic-weird/poudreperlinpinpin_fqw6cN8.mp3"
    , "classic-weird/psy-gangnam-style-1.mp3"
    , "classic-weird/robin-hood-1973-whistle-stop.mp3"
    , "classic-weird/star-wars-john-williams-duel-of-the-fates.mp3"
    , "classic-weird/super-mario-bros-ost-8-youre-dead.mp3"
    , "classic-weird/tetris-theme.mp3"
    , "classic-weird/the-addams-family-intro-theme-song.mp3"
    , "classic-weird/the-benny-hill-show-theme-short-sound-clip-and-quote-hark.mp3"
    , "classic-weird/the-it-crowd-theme.mp3"
    , "classic-weird/the-pink-panther-theme-song-original-version.mp3"
    , "classic-weird/the-simpsons-nelsons-haha.mp3"
    , "classic-weird/the-weather-girls-its-raining-men-1-cut-mp3.mp3"
    , "classic-weird/untitled_3.mp3"
    , "classic-weird/utini.mp3"
    , "classic-weird/we-are-the-champions-copia.mp3"
    , "classic-weird/zelda.mp3"
    ]
