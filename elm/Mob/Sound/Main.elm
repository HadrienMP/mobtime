module Mob.Sound.Main exposing (..)

import Interface.Commands
import Interface.Events
import Json.Decode
import Mob.Clock.Events
import Html exposing (Html, audio)
import Html.Attributes exposing (src)
import Random
import Mob.Sound.Library as SoundLibrary
import Mob.Sound.Settings



-- MODEL


type SoundStatus
    = Playing
    | NotPlaying


type alias Model =
    { state : SoundStatus
    , sound : SoundLibrary.Sound
    , settings : Mob.Sound.Settings.Model
    }


init : Int -> Model
init volume =
    { state = NotPlaying
    , sound = SoundLibrary.default
    , settings = Mob.Sound.Settings.init volume
    }



-- UPDATE


type Msg
    = Picked SoundLibrary.Sound
    | Ended Interface.Events.Event
    | Stop
    | SettingsMsg Mob.Sound.Settings.Msg


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
            Mob.Sound.Settings.update soundMsg model.settings
                |> Tuple.mapBoth
                    (\it -> { model | settings = it })
                    (Cmd.map SettingsMsg)



-- SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    Interface.Events.events Ended



-- VIEW


view : Model -> Html Msg
view model =
    audio [ src <| "/sound/" ++ model.sound ] []



-- SETTINGS VIEW


settingsView : Model -> Html Msg
settingsView model =
    Mob.Sound.Settings.view model.settings
        |> Html.map SettingsMsg



-- Other stuff


type alias EventHandlingResult =
    { model : Model
    , command : Cmd Msg
    }


handleClockEvents : Model -> Maybe Mob.Clock.Events.Event -> EventHandlingResult
handleClockEvents model maybeEvent =
    case maybeEvent of
        Just event ->
            case event of
                Mob.Clock.Events.Finished ->
                    { model = { model | state = Playing }, command = play }

                Mob.Clock.Events.Started ->
                    { model = { model | state = NotPlaying }, command = pick model }

        Nothing ->
            { model = model, command = Cmd.none }


pick : Model -> Cmd Msg
pick model =
    Random.generate Picked <| SoundLibrary.pick model.settings.profile


play : Cmd msg
play =
    Interface.Commands.send Interface.Commands.SoundPlay


stop : Cmd msg
stop =
    Interface.Commands.send Interface.Commands.SoundStop
