module Mob.Clock.Main exposing (..)

import Mob.Clock.Circle
import Mob.Clock.Events exposing (Event(..))
import Mob.Clock.Settings
import Mob.Lib.Duration as Duration exposing (Duration)
import Mob.Lib.Ratio as Ratio exposing (Ratio)
import Mob.Tabs.Dev
import Svg exposing (Svg)


type Model
    = Off
    | On { timeLeft : Duration, length : Duration }


start : Duration -> Model
start duration =
    On { timeLeft = duration, length = duration }


timePassed : Model -> Mob.Tabs.Dev.Model -> UpdateResult
timePassed model devSettings =
    case model of
        Off ->
            { model = model
            , command = Cmd.none
            , event = Nothing
            }

        On on ->
            let
                timeLeft =
                    Duration.subtract on.timeLeft (Mob.Tabs.Dev.seconds devSettings)
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


update : Mob.Clock.Settings.Model -> Msg -> UpdateResult
update settings msg =
    case msg of
        StartRequest ->
            { model = start settings.turnLength, command = Cmd.none, event = Just Started }

        StopRequest ->
            { model = Off, command = Cmd.none, event = Nothing }



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