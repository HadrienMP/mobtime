module Action exposing (..)

import Clock.Main
import Clock.Settings
import Html exposing (Html, button, i, span, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Sound.Main


type Action
    = Start
    | Stop
    | StopSound


type alias Model =
    { clock : Clock.Main.Model
    , sound : Sound.Main.Model
    , clockSettings : Clock.Settings.Model
    }


type alias Messages msg =
    { clock : Clock.Main.Msg -> msg
    , sound : Sound.Main.Msg -> msg
    }


actionView : Model -> Messages msg -> Html msg
actionView model messages =
    button
        [ onClick <| actionMessage messages <| actionOf model
        , class <| turnToString model
        ]
        [ span [ id "time-left" ] (Clock.Main.humanReadableTimeLeft model.clock model.clockSettings |> List.map (\it -> span [] [ text it ]))
        , actionIcon <| actionOf model
        ]


actionMessage : Messages msg -> Action -> msg
actionMessage messages action =
    case action of
        Start ->
            Clock.Main.StartRequest |> messages.clock

        Stop ->
            Clock.Main.StopRequest |> messages.clock

        StopSound ->
            Sound.Main.Stop |> messages.sound


turnToString : Model -> String
turnToString model =
    case model.clock of
        Clock.Main.On _ ->
            "on"

        Clock.Main.Off ->
            "off"


actionOf : Model -> Action
actionOf model =
    case ( model.clock, model.sound.state ) of
        ( Clock.Main.On _, Sound.Main.NotPlaying ) ->
            Stop

        ( Clock.Main.On _, Sound.Main.Playing ) ->
            StopSound

        ( Clock.Main.Off, Sound.Main.Playing ) ->
            StopSound

        ( Clock.Main.Off, Sound.Main.NotPlaying ) ->
            Start


actionIcon : Action -> Html msg
actionIcon action =
    case action of
        Start ->
            i [ class "fas fa-play" ] []

        Stop ->
            i [ class "fas fa-square" ] []

        StopSound ->
            i [ class "fas fa-volume-mute" ] []
