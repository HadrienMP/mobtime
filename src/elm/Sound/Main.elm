module Mob.Sound.Main exposing (..)

import Html exposing (Html)
import Out.Commands
import Out.Events
import Out.EventsMapping as EventsMapping exposing (EventsMapping)
import Random
import Sound.Library as SoundLibrary



-- MODEL


type SoundStatus
    = Playing
    | NotPlaying


type alias Model =
    { state : SoundStatus
    , sound : SoundLibrary.Sound
    }


init : Int -> Model
init _ =
    { state = NotPlaying
    , sound = SoundLibrary.default
    }



-- UPDATE


type Msg
    = Ended
    | Stop


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        Ended ->
            ( { model | state = NotPlaying }, Cmd.none )

        Stop ->
            ( { model | state = NotPlaying }, stop )



-- EVENTS SUBSCRIPTIONS


eventsMapping : EventsMapping Msg
eventsMapping =
    [ Out.Events.EventMessage "SoundEnded" (\_ -> Ended) ]
        |> EventsMapping.create



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
    Out.Commands.send Out.Commands.SoundAlarm


stop : Cmd msg
stop =
    Out.Commands.send Out.Commands.SoundStop
