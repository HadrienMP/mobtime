module Sounds exposing
    ( Image
    , Profile(..)
    , Sound
    , allProfiles
    , code
    , default
    , fromCode
    , pick
    , poster
    , title
    )

import Dict
import Random


type alias Sound =
    String


type alias Image =
    { url : String
    , alt : String
    }


type Profile
    = ClassicWeird
    | OfficeSafe
    | Riot
    | Funky


poster : Profile -> Image
poster profile =
    { url =
        (++) "/images/sound-library/" <|
            case profile of
                ClassicWeird ->
                    "weird.webp"

                Riot ->
                    "commune.webp"

                OfficeSafe ->
                    "officesafe.jpg"

                Funky ->
                    "funky.webp"

    , alt =
        case profile of
            ClassicWeird ->
                "Photography of a man wearing a watermelon hat"

            Riot ->
                "Comic book drawing of the paris commune revolution"

            OfficeSafe ->
                "An office meeting room full of multicolored plastic balls"

            Funky ->
                "Photography of George Clinton"
    }


allProfiles : List Profile
allProfiles =
    nextProfile [] |> List.reverse


nextProfile : List Profile -> List Profile
nextProfile list =
    case List.head list of
        Nothing ->
            nextProfile (ClassicWeird :: list)

        Just ClassicWeird ->
            nextProfile (Riot :: list)

        Just Riot ->
            nextProfile (OfficeSafe :: list)

        Just OfficeSafe ->
            nextProfile (Funky :: list)

        Just Funky ->
            list


title : Profile -> String
title profile =
    case profile of
        ClassicWeird ->
            "Classic Weird"

        Riot ->
            "Riot"

        OfficeSafe ->
            "Office Safe"

        Funky ->
            "Funky"


code : Profile -> String
code profile =
    case profile of
        ClassicWeird ->
            "ClassicWeird"

        Riot ->
            "Riot"

        OfficeSafe ->
            "OfficeSafe"

        Funky ->
            "Funky"


fromCode : String -> Profile
fromCode string =
    allProfiles
        |> List.map (\profile -> ( code profile, profile ))
        |> Dict.fromList
        |> Dict.get string
        |> Maybe.withDefault ClassicWeird


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

        OfficeSafe ->
            ( "classic-weird/celebration.mp3"
            , officeSafe
            )

        Funky ->
            ( "funky/essence.mp3"
            , funky
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
    , "riot/eiffel_larue.wav.mp3"
    ]

funky : List Sound
funky =
    ["funky/essence.mp3"
    , "funky/caravan.mp3"
    , "funky/cry.mp3"
    , "funky/do-it.mp3"
    , "funky/feuille.mp3"
    , "funky/fly.mp3"
    , "funky/little.mp3"
    , "funky/merci.mp3"
    , "funky/rock.mp3"
    , "funky/snip-snap.mp3"
    , "funky/sol.mp3"
    , "funky/stolen.mp3"
    , "funky/there.mp3"
    ]


classicWeird : List Sound
classicWeird =
    [ "classic-weird/007-james-bond-theme.mp3"
    , "classic-weird/007-sound-final.mp3"
    , "classic-weird/a-ha-take-on-me-cut-mp3.mp3"
    , "classic-weird/anthologie-de-julien-lepers.mp3"
    , "classic-weird/aroundtheworld.wav.mp3"
    , "classic-weird/banane.wav.mp3"
    , "classic-weird/blablabla.wav.mp3"
    , "classic-weird/boneym_rasputin.wav.mp3"
    , "classic-weird/breaking-bad-intro.mp3"
    , "classic-weird/cantina-band.mp3"
    , "classic-weird/carldouglas_kungfufighting.wav.mp3"
    , "classic-weird/celebration.mp3"
    , "classic-weird/chic_freak.wav.mp3"
    , "classic-weird/complotiste.mp3"
    , "classic-weird/coolio_ganstaparadise.wav.mp3"
    , "classic-weird/denis-brogniart-ah-original.mp3"
    , "classic-weird/didiersuper_gensquibossent.wav.mp3"
    , "classic-weird/digitallove.wav.mp3"
    , "classic-weird/donald-trump-fake-news-sound-effect.mp3"
    , "classic-weird/doors_strange.wav.mp3"
    , "classic-weird/drdre_stilldre.wav.mp3"
    , "classic-weird/drwho.mp3"
    , "classic-weird/eminem_slimshady.wav.mp3"
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
    , "classic-weird/indochine_aventurier.wav.mp3"
    , "classic-weird/its-me-mario.mp3"
    , "classic-weird/jurrasic-theme-2-hq.mp3"
    , "classic-weird/kaamelott-theme.mp3"
    , "classic-weird/kiss_madeforlovingyou.wav.mp3"
    , "classic-weird/knight-rider.mp3"
    , "classic-weird/lemon-grab-unacceptable.mp3"
    , "classic-weird/lmfao_partyrockanthem.wav.mp3"
    , "classic-weird/macron_projet_final.mp3"
    , "classic-weird/matmatah_apologie.wav.mp3"
    , "classic-weird/mc-hammer-u-cant-touch-this.mp3"
    , "classic-weird/mission-impossible.mp3"
    , "classic-weird/mjackson_beatit.wav.mp3"
    , "classic-weird/music-missionimpossibletheme.mp3"
    , "classic-weird/nyan-cat_1.mp3"
    , "classic-weird/o-bom-o-mal-e-o-feio-velho-oeste-desafio-dont-talk-duelo-desafio-armas.mp3"
    , "classic-weird/over9000.swf.mp3"
    , "classic-weird/perlin.mp3"
    , "classic-weird/poudreperlinpinpin_fqw6cN8.mp3"
    , "classic-weird/psy-gangnam-style-1.mp3"
    , "classic-weird/queen_breakfree.wav.mp3"
    , "classic-weird/rickroll.wav.mp3"
    , "classic-weird/robin-hood-1973-whistle-stop.mp3"
    , "classic-weird/smokeonthewater.wav.mp3"
    , "classic-weird/spindoctors_twoprinces.wav.mp3"
    , "classic-weird/star-wars-john-williams-duel-of-the-fates.mp3"
    , "classic-weird/super-mario-bros-ost-8-youre-dead.mp3"
    , "classic-weird/sweethomealabam.wav.mp3"
    , "classic-weird/tetris-theme.mp3"
    , "classic-weird/the-addams-family-intro-theme-song.mp3"
    , "classic-weird/the-benny-hill-show-theme-short-sound-clip-and-quote-hark.mp3"
    , "classic-weird/the-it-crowd-theme.mp3"
    , "classic-weird/the-pink-panther-theme-song-original-version.mp3"
    , "classic-weird/the-simpsons-nelsons-haha.mp3"
    , "classic-weird/the-weather-girls-its-raining-men-1-cut-mp3.mp3"
    , "classic-weird/thislove.wav.mp3"
    , "classic-weird/toto_africa.wav.mp3"
    , "classic-weird/toxic.wav.mp3"
    , "classic-weird/utini.mp3"
    , "classic-weird/we-are-the-champions-copia.mp3"
    , "classic-weird/zelda.mp3"
    ]


officeSafe : List Sound
officeSafe =
    [ "classic-weird/007-james-bond-theme.mp3"
    , "classic-weird/007-sound-final.mp3"
    , "classic-weird/a-ha-take-on-me-cut-mp3.mp3"
    , "classic-weird/anthologie-de-julien-lepers.mp3"
    , "classic-weird/aroundtheworld.wav.mp3"
    , "classic-weird/boneym_rasputin.wav.mp3"
    , "classic-weird/breaking-bad-intro.mp3"
    , "classic-weird/cantina-band.mp3"
    , "classic-weird/carldouglas_kungfufighting.wav.mp3"
    , "classic-weird/chic_freak.wav.mp3"
    , "classic-weird/coolio_ganstaparadise.wav.mp3"
    , "classic-weird/denis-brogniart-ah-original.mp3"
    , "classic-weird/digitallove.wav.mp3"
    , "classic-weird/donald-trump-fake-news-sound-effect.mp3"
    , "classic-weird/doors_strange.wav.mp3"
    , "classic-weird/drdre_stilldre.wav.mp3"
    , "classic-weird/drwho.mp3"
    , "classic-weird/eminem_slimshady.wav.mp3"
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
    , "classic-weird/indochine_aventurier.wav.mp3"
    , "classic-weird/its-me-mario.mp3"
    , "classic-weird/jurrasic-theme-2-hq.mp3"
    , "classic-weird/kaamelott-theme.mp3"
    , "classic-weird/kiss_madeforlovingyou.wav.mp3"
    , "classic-weird/knight-rider.mp3"
    , "classic-weird/lemon-grab-unacceptable.mp3"
    , "classic-weird/lmfao_partyrockanthem.wav.mp3"
    , "classic-weird/matmatah_apologie.wav.mp3"
    , "classic-weird/mc-hammer-u-cant-touch-this.mp3"
    , "classic-weird/mission-impossible.mp3"
    , "classic-weird/mjackson_beatit.wav.mp3"
    , "classic-weird/nyan-cat_1.mp3"
    , "classic-weird/psy-gangnam-style-1.mp3"
    , "classic-weird/queen_breakfree.wav.mp3"
    , "classic-weird/rickroll.wav.mp3"
    , "classic-weird/robin-hood-1973-whistle-stop.mp3"
    , "classic-weird/smokeonthewater.wav.mp3"
    , "classic-weird/spindoctors_twoprinces.wav.mp3"
    , "classic-weird/star-wars-john-williams-duel-of-the-fates.mp3"
    , "classic-weird/super-mario-bros-ost-8-youre-dead.mp3"
    , "classic-weird/sweethomealabam.wav.mp3"
    , "classic-weird/tetris-theme.mp3"
    , "classic-weird/the-addams-family-intro-theme-song.mp3"
    , "classic-weird/the-benny-hill-show-theme-short-sound-clip-and-quote-hark.mp3"
    , "classic-weird/the-it-crowd-theme.mp3"
    , "classic-weird/the-pink-panther-theme-song-original-version.mp3"
    , "classic-weird/the-simpsons-nelsons-haha.mp3"
    , "classic-weird/the-weather-girls-its-raining-men-1-cut-mp3.mp3"
    , "classic-weird/thislove.wav.mp3"
    , "classic-weird/toto_africa.wav.mp3"
    , "classic-weird/toxic.wav.mp3"
    , "classic-weird/we-are-the-champions-copia.mp3"
    , "classic-weird/zelda.mp3"

    -- TODO: what is love
    ]
