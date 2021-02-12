port module Sound.Main exposing (..)

import Html exposing (Html)
import Sound.Library as SoundLibrary
import Json.Encode
import Random
import Sound.Settings


port soundEnded : (String -> msg) -> Sub msg


port soundCommands : Json.Encode.Value -> Cmd msg



--
-- MODEL
--


type SoundStatus
    = Playing
    | NotPlaying


type alias Model =
    { state : SoundStatus
    , sound : SoundLibrary.Sound
    , settings : Sound.Settings.Model
    }


init : Model
init =
    { state = NotPlaying
    , sound = SoundLibrary.default
    , settings = Sound.Settings.init
    }



--
-- UPDATE
--


type Msg
    = Picked SoundLibrary.Sound
    | Ended String
    | Stop
    | SettingsMsg Sound.Settings.Msg


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        Picked sound ->
            ( { model | sound = sound }, Cmd.none )

        Ended _ ->
            ( { model | state = NotPlaying }, Cmd.none )

        Stop ->
            ( { model | state = NotPlaying }, stop )

        SettingsMsg soundMsg ->
            Sound.Settings.update soundMsg model.settings soundCommands
                |> Tuple.mapBoth
                    (\it -> { model | settings = it })
                    (Cmd.map SettingsMsg)



--
-- SUBSCRIPTIONS
--


subscriptions : Sub Msg
subscriptions = soundEnded Ended


--
-- SETTINGS VIEW
--
settingsView : Model -> Html Msg
settingsView model=
    Sound.Settings.view model.settings
        |> Html.map SettingsMsg


--
-- Other stuff
--


pick : Model -> Cmd Msg
pick model =
    Random.generate Picked <| SoundLibrary.pick model.settings.profile


turnEnded : Model -> ( Model, Cmd msg )
turnEnded model =
    ( { model | state = Playing }, play )


play : Cmd msg
play =
    soundCommands <|
        Json.Encode.object
            [ ( "name", Json.Encode.string "play" )
            , ( "data", Json.Encode.object [] )
            ]


stop : Cmd msg
stop =
    soundCommands <|
        Json.Encode.object
            [ ( "name", Json.Encode.string "stop" )
            , ( "data", Json.Encode.object [] )
            ]
