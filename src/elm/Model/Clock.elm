module Model.Clock exposing (ClockState(..), Event(..), OnModel, isOn, ratio, timePassed)

import Lib.Duration as Duration exposing (Duration)
import Lib.Ratio
import Time


type alias OnModel =
    { end : Time.Posix, length : Duration, ended : Bool }


type ClockState
    = Off
    | On OnModel


type Event
    = Ended
    | Continued


isOn : ClockState -> Bool
isOn clockState =
    clockState /= Off


timePassed : Time.Posix -> ClockState -> ( ClockState, Event )
timePassed now clockState =
    case clockState of
        On on ->
            if ended on now then
                ( On { on | ended = True }
                , Ended
                )

            else
                ( clockState, Continued )

        Off ->
            ( clockState, Continued )


ended : OnModel -> Time.Posix -> Bool
ended on now =
    not on.ended && Duration.secondsBetween now on.end == 0


ratio : Time.Posix -> ClockState -> Lib.Ratio.Ratio
ratio now model =
    case model of
        Off ->
            Lib.Ratio.full

        On on ->
            Duration.ratio (Duration.minus (Duration.between now on.end) (Duration.ofSeconds 1)) on.length
                |> (-) 1
                |> Lib.Ratio.from
