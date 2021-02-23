module Mob.Pomodoro exposing (..)

import Lib.Duration exposing (Duration)
import Mob.Clock.Circle exposing (Circle)
import Mob.Clock.Events
import Mob.Clock.Main as Clock
import Mob.Clock.Settings as ClockSettings
import Svg exposing (Svg)


type Model
    = Working Clock.Model
    | OnABreak
    | Ready


init : Model
init =
    Working <| Clock.Off


type Msg
    = Start
    | Stop
    | BreakTaken


timePassed : Model -> ClockSettings.Model -> Model
timePassed model settings =
    case model of
        Working clockModel ->
            let
                result =
                    Clock.timePassed clockModel settings
            in
            case result.event of
                Just Mob.Clock.Events.Finished ->
                    OnABreak

                _ ->
                    Working result.model

        _ ->
            model


update : Msg -> Model -> Duration -> ( Model, Cmd Msg )
update msg model duration =
    case ( msg, model ) of
        ( Start, Ready ) ->
            ( Working <| Clock.start duration, Cmd.none )

        ( Stop, Working _ ) ->
            ( OnABreak, Cmd.none )

        ( BreakTaken, OnABreak ) ->
            ( Ready, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Circle -> Model -> List (Svg Msg)
view circle model =
    case model of
        Working working ->
            Clock.view circle working

        _ ->
            Clock.view circle Clock.Off
