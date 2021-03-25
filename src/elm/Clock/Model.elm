module Clock.Model exposing (..)

import Js.Commands
import Lib.Duration as Duration exposing (Duration)
import Lib.Ratio
import Time


type alias OnModel =
    { end : Time.Posix, length : Duration, ended : Bool }


type ClockState
    = Off
    | On { end : Time.Posix, length : Duration, ended : Bool }


timePassed : Time.Posix -> ClockState -> ( ClockState, Cmd msg )
timePassed now clockState =
    case clockState of
        On on ->
            if ended on now then
                ( On { on | ended = True }
                , Js.Commands.send Js.Commands.SoundAlarm
                )

            else
                ( clockState, Cmd.none )

        Off ->
            ( clockState, Cmd.none )


ended : OnModel -> Time.Posix -> Bool
ended on now =
    not on.ended && Duration.secondsBetween now on.end == 0


clockEnded : ClockState -> Bool
clockEnded clockState =
    case clockState of
        On on ->
            on.ended

        Off ->
            False


clockRatio : Time.Posix -> ClockState -> Lib.Ratio.Ratio
clockRatio now model =
    case model of
        Off ->
            Lib.Ratio.full

        On on ->
            Duration.div (Duration.minus (Duration.between now on.end) (Duration.ofSeconds 1)) on.length
                |> (-) 1
                |> Lib.Ratio.from
