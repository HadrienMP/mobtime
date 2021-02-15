module Clock.Main exposing (..)

import Clock.Circle
import Clock.Settings
import Lib.Duration as Duration exposing (Duration)
import Lib.Ratio as Ratio exposing (Ratio)
import Settings.Dev
import Svg exposing (Svg)
import Time


type Event
    = Finished


type State
    = Off
    | On { timeLeft : Duration, length : Duration }


start : Duration -> State
start duration =
    On { timeLeft = duration, length = duration }


timePassed : State -> Duration -> ( State, List Event )
timePassed state duration =
    case state of
        Off ->
            ( state, [] )

        On on ->
            let
                timeLeft =
                    Duration.subtract on.timeLeft duration
            in
            if Duration.toSeconds timeLeft <= 0 then
                ( Off, [Finished] )

            else
                ( On { on | timeLeft = timeLeft }, [] )



-- UPDATE


type Msg
    = TimePassed Time.Posix
    | StartRequest
    | StopRequest


type alias UpdateResult =
    { model : State, command : Cmd Msg, events : List Event }


update : State -> Settings.Dev.Model -> Clock.Settings.Model -> Msg -> UpdateResult
update state dev settings msg =
    case msg of
        TimePassed _ ->
            let
                ( clock, events ) =
                    timePassed state <| Settings.Dev.seconds dev
            in
            {model = clock, command = Cmd.none, events = events}

        StartRequest ->
            { model = start settings.turnLength, command = Cmd.none, events = [] }

        StopRequest ->
            { model = Off, command = Cmd.none, events = [] }



-- VIEW


view : Clock.Circle.Circle -> State -> List (Svg msg)
view mobCircle turn =
    Clock.Circle.draw mobCircle (ratio turn)


ratio : State -> Ratio
ratio state =
    case state of
        On on ->
            Duration.div on.timeLeft on.length
                |> (-) 1
                |> Ratio.from

        Off ->
            Ratio.full
