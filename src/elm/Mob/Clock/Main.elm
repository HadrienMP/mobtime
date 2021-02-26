module Mob.Clock.Main exposing (..)

import Lib.Duration as Duration exposing (Duration)
import Lib.Ratio as Ratio exposing (Ratio)
import Mob.Clock.Circle
import Mob.Clock.Events exposing (Event(..))
import Mob.Clock.Settings
import Svg exposing (Svg)


type Model
    = Off
    | On { timeLeft : Duration, length : Duration }


start : Duration -> Model
start duration =
    On { timeLeft = duration, length = duration }


timePassed : Model -> Mob.Clock.Settings.Model -> UpdateResult
timePassed model settings =
    case model of
        Off ->
            { model = model
            , command = Cmd.none
            , event = Nothing
            }

        On on ->
            let
                timeLeft =
                    Duration.subtract on.timeLeft (Mob.Clock.Settings.seconds settings)
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


type alias UpdateResult =
    { model : Model, command : Cmd Msg, event : Maybe Event }


update : Msg -> Model -> Duration -> UpdateResult
update msg model length =
    case ( msg, model ) of
        ( StartRequest, Off ) ->
            { model = start length, command = Cmd.none, event = Just Started }

        ( StopRequest, On _ ) ->
            { model = Off, command = Cmd.none, event = Nothing }

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
