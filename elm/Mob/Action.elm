module Mob.Action exposing (..)

import Html exposing (Html, button, i, span, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Mob.Clock.Main as Clock
import Mob.Clock.Settings
import Mob.Pomodoro as Pomodoro
import Mob.Sound.Main as Sound


type Action
    = Start
    | Stop
    | StopSound
    | StopBreak


type alias Model =
    { clock : Clock.Model
    , sound : Sound.Model
    , pomodoro : Pomodoro.Model
    , clockSettings : Mob.Clock.Settings.Model
    }


type alias Messages msg =
    { clock : Clock.Msg -> msg
    , sound : Sound.Msg -> msg
    , pomodoro : Pomodoro.Msg -> msg
    , batch : List msg -> msg
    }


actionView : Model -> Messages msg -> Html msg
actionView model messages =
    button
        [ onClick <| actionMessage messages <| actionOf model
        , class <| turnToString model
        , id "action"
        ]
        [ span [ id "time-left" ]
            (Clock.humanReadableTimeLeft model.clock model.clockSettings
                |> List.map (\it -> span [] [ text it ])
            )
        , actionIcon <| actionOf model
        ]


actionMessage : Messages msg -> Action -> msg
actionMessage messages action =
    case action of
        Start ->
            messages.batch <|
                [ Clock.StartRequest |> messages.clock
                , Pomodoro.Start |> messages.pomodoro
                ]

        Stop ->
            Clock.StopRequest |> messages.clock

        StopSound ->
            Sound.Stop |> messages.sound

        StopBreak ->
            Pomodoro.BreakTaken |> messages.pomodoro


turnToString : Model -> String
turnToString model =
    case model.clock of
        Clock.On _ ->
            "on"

        Clock.Off ->
            "off"



-- TODO HadrienMP il faudrait un workflow commun, sinon il y a trop de risques d'erreur


actionOf : Model -> Action
actionOf model =
    case ( model.clock, model.pomodoro, model.sound.state ) of
        ( Clock.On _, _, Sound.NotPlaying ) ->
            Stop

        ( Clock.On _, _, Sound.Playing ) ->
            StopSound

        ( Clock.Off, _, Sound.Playing ) ->
            StopSound

        ( Clock.Off, Pomodoro.OnABreak, Sound.NotPlaying ) ->
            StopBreak

        ( Clock.Off, _, Sound.NotPlaying ) ->
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

        StopBreak ->
            i [ class "fas fa-coffee" ] []
