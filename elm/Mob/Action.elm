module Mob.Action exposing (..)

import Mob.Clock.Main
import Mob.Clock.Settings
import Html exposing (Html, button, i, span, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Mob.Sound.Main


type Action
    = Start
    | Stop
    | StopSound


type alias Model =
    { clock : Mob.Clock.Main.Model
    , sound : Mob.Sound.Main.Model
    , clockSettings : Mob.Clock.Settings.Model
    }


type alias Messages msg =
    { clock : Mob.Clock.Main.Msg -> msg
    , sound : Mob.Sound.Main.Msg -> msg
    }


actionView : Model -> Messages msg -> Html msg
actionView model messages =
    button
        [ onClick <| actionMessage messages <| actionOf model
        , class <| turnToString model
        ]
        [ span [ id "time-left" ] (Mob.Clock.Main.humanReadableTimeLeft model.clock model.clockSettings |> List.map (\it -> span [] [ text it ]))
        , actionIcon <| actionOf model
        ]


actionMessage : Messages msg -> Action -> msg
actionMessage messages action =
    case action of
        Start ->
            Mob.Clock.Main.StartRequest |> messages.clock

        Stop ->
            Mob.Clock.Main.StopRequest |> messages.clock

        StopSound ->
            Mob.Sound.Main.Stop |> messages.sound


turnToString : Model -> String
turnToString model =
    case model.clock of
        Mob.Clock.Main.On _ ->
            "on"

        Mob.Clock.Main.Off ->
            "off"


actionOf : Model -> Action
actionOf model =
    case ( model.clock, model.sound.state ) of
        ( Mob.Clock.Main.On _, Mob.Sound.Main.NotPlaying ) ->
            Stop

        ( Mob.Clock.Main.On _, Mob.Sound.Main.Playing ) ->
            StopSound

        ( Mob.Clock.Main.Off, Mob.Sound.Main.Playing ) ->
            StopSound

        ( Mob.Clock.Main.Off, Mob.Sound.Main.NotPlaying ) ->
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
