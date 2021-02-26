module Mob.Pomodoro exposing (..)

import Lib.Duration exposing (Duration)
import Lib.Toast
import Mob.Clock.Circle exposing (Circle)
import Mob.Clock.Events
import Mob.Clock.Main as Clock
import Mob.Clock.Settings as ClockSettings
import Svg exposing (Svg)
import Task
import Time


type Model
    = Working Clock.Model
    | OnABreak
    | Ready


init : Model
init =
    Working <| Clock.Off


type Msg
    = Start
    | StartWithTime Time.Posix
    | Stop
    | BreakTaken


type alias TimePassedResult =
    { model: Model
    , toasts: Lib.Toast.Toasts
    }

timePassed : Time.Posix -> Model -> TimePassedResult
timePassed now model =
    case model of
        Working clockModel ->
            let
                result =
                    Clock.timePassed now clockModel
            in
            case result.event of
                Just Mob.Clock.Events.Finished ->
                    TimePassedResult OnABreak [Lib.Toast.Toast Lib.Toast.Info "Take a break !"]

                _ ->
                    TimePassedResult (Working result.model) []

        _ ->
            TimePassedResult model []


update : Msg -> Model -> Duration -> ( Model, Cmd Msg )
update msg model duration =
    case ( msg, model ) of
        ( Start, Ready ) ->
            ( model, Task.perform StartWithTime Time.now )

        ( StartWithTime now, Ready ) ->
            ( Working <| Clock.start now duration, Cmd.none )

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
