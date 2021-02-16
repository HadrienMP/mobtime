port module Sound.Main exposing (..)

import Clock.Events
import Html exposing (Html, audio)
import Html.Attributes exposing (src)
import Json.Encode
import Random
import Sound.Library as SoundLibrary
import Sound.Settings


port soundEnded : (String -> msg) -> Sub msg


port soundCommands : Json.Encode.Value -> Cmd msg



-- MODEL


type SoundStatus
    = Playing
    | NotPlaying


type alias Model =
    { state : SoundStatus
    , sound : SoundLibrary.Sound
    , settings : Sound.Settings.Model
    }


-- TODO ports should maybe be more general (like a port type)
init : Sound.Settings.StorePort -> Int -> Model
init storePort volume =
    { state = NotPlaying
    , sound = SoundLibrary.default
    , settings = Sound.Settings.init soundCommands storePort volume
    }



-- UPDATE


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
            Sound.Settings.update soundMsg model.settings
                |> Tuple.mapBoth
                    (\it -> { model | settings = it })
                    (Cmd.map SettingsMsg)



-- SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    soundEnded Ended



-- VIEW


view : Model -> Html Msg
view model =
    audio [ src <| "/sound/" ++ model.sound ] []



-- SETTINGS VIEW


settingsView : Model -> Html Msg
settingsView model =
    Sound.Settings.view model.settings
        |> Html.map SettingsMsg



-- Other stuff


type alias EventHandlingResult =
    { model : Model
    , command : Cmd Msg
    }


handleClockEvents : Model -> Maybe Clock.Events.Event -> EventHandlingResult
handleClockEvents model maybeEvent =
    case maybeEvent of
        Just event ->
            case event of
                Clock.Events.Finished ->
                    { model = { model | state = Playing }, command = play }

                Clock.Events.Started ->
                    { model = { model | state = NotPlaying }, command = pick model }

        Nothing ->
            { model = model, command = Cmd.none }


pick : Model -> Cmd Msg
pick model =
    Random.generate Picked <| SoundLibrary.pick model.settings.profile


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
