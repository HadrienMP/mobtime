module Mob.Clock.Main exposing (..)

import Lib.Duration as Duration exposing (Duration)
import Lib.Ratio as Ratio exposing (Ratio)
import Mob.Clock.Circle
import Mob.Clock.Events exposing (Event(..))
import Mob.Clock.Settings
import Svg exposing (Svg)
import Task
import Time


type Model
    = Off
    | On { timeLeft : Duration, length : Duration, start: Time.Posix }


start : Time.Posix -> Duration -> Model
start now duration =
    On { timeLeft = duration, length = duration, start = now }


timePassed : Time.Posix -> Model -> UpdateResult
timePassed now model =
    case model of
        Off ->
            { model = model
            , command = Cmd.none
            , event = Nothing
            }

        On on ->
            let
                timeLeft =
                    Duration.subtract on.length (Duration.between on.start now)
            in
            if Duration.toSeconds timeLeft <= 0 then
                { model = Off
                , command = Cmd.none
                , event = Just Finished
                }

            else
                { model = On { on | timeLeft = timeLeft }
                , command = Cmd.none
                , event = Nothing
                }



-- UPDATE


type Msg
    = StartRequest
    | StopRequest
    | StartWithTime Time.Posix


type alias UpdateResult =
    { model : Model, command : Cmd Msg, event : Maybe Event }


update : Msg -> Model -> Duration -> UpdateResult
update msg model length =
    case ( msg, model ) of
        ( StartRequest, Off ) ->
            { model = model, command = Task.perform StartWithTime Time.now, event = Nothing }

        ( StopRequest, On _ ) ->
            { model = Off, command = Cmd.none, event = Nothing }

        (StartWithTime now, Off) ->
            { model = start now length, command = Cmd.none, event = Just Started }

        _ ->
            { model = model, command = Cmd.none, event = Nothing }



-- VIEW


view : Mob.Clock.Circle.Circle -> Model -> List (Svg msg)
view mobCircle turn =
    Mob.Clock.Circle.draw mobCircle (ratio turn)


ratio : Model -> Ratio
ratio state =
    case state of
        On on ->
            Duration.div on.timeLeft on.length
                |> (-) 1
                |> Ratio.from

        Off ->
            Ratio.full



-- OTHER


humanReadableTimeLeft : Model -> Mob.Clock.Settings.Model -> List String
humanReadableTimeLeft clock settings =
    case clock of
        On turn ->
            Mob.Clock.Settings.format settings turn.timeLeft

        Off ->
            []
