port module Sound.Main exposing (..)

import Sound.Library as SoundLibrary
import Json.Encode
import Random


port soundEnded : (String -> msg) -> Sub msg


port soundCommands2 : Json.Encode.Value -> Cmd msg



--
-- MODEL
--


type SoundStatus
    = Playing
    | NotPlaying



-- todo ranger tout ce qui concerne le son dans un même dossier ?


type alias Model =
    { state : SoundStatus
    , sound : SoundLibrary.Sound
    }


init : Model
init =
    { state = NotPlaying
    , sound = SoundLibrary.default
    }



--
-- UPDATE
--


type Msg
    = Picked SoundLibrary.Sound
    | Ended String
    | Stop


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        Picked sound ->
            ( { model | sound = sound }, Cmd.none )

        Ended _ ->
            ( { model | state = NotPlaying }, Cmd.none )

        Stop ->
            ( { model | state = NotPlaying }, stop )



--
-- SUBSCRIPTIONS
--


subscriptions : Sub Msg
subscriptions = soundEnded Ended



--
-- Other stuff
--


pick : SoundLibrary.Profile -> Cmd Msg
pick soundProfile =
    -- todo il faudrait que ce module porte ses settings
    Random.generate Picked <| SoundLibrary.pick soundProfile


turnEnded : Model -> ( Model, Cmd msg )
turnEnded model =
    ( { model | state = Playing }, play )


play : Cmd msg
play =
    soundCommands2 <|
        Json.Encode.object
            [ ( "name", Json.Encode.string "play" )
            , ( "data", Json.Encode.object [] )
            ]


stop : Cmd msg
stop =
    soundCommands2 <|
        Json.Encode.object
            [ ( "name", Json.Encode.string "stop" )
            , ( "data", Json.Encode.object [] )
            ]
